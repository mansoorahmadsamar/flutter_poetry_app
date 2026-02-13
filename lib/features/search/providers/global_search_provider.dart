import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:flutter_poetry_app/core/network/dio_client.dart';
import 'package:flutter_poetry_app/core/providers/language_provider.dart';
import 'package:flutter_poetry_app/features/search/models/global_search_state.dart';
import 'package:flutter_poetry_app/features/search/models/search_models.dart';
import 'package:flutter_poetry_app/features/search/services/search_service.dart';
import 'package:flutter_poetry_app/features/search/services/search_history_service.dart';
import 'package:flutter_poetry_app/features/discover/services/discover_service.dart';
import 'package:flutter_poetry_app/features/discover/models/discover_bundle_model.dart';

// ============================================================================
// SERVICE PROVIDERS
// ============================================================================

/// Provider for SearchService (API layer)
final searchServiceProvider = Provider<SearchService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return SearchService(dioClient.dio);
});

/// Provider for SearchHistoryService (local storage)
final searchHistoryServiceProvider = Provider<SearchHistoryService>((ref) {
  return SearchHistoryService();
});

// ============================================================================
// STATE NOTIFIER
// ============================================================================

/// Main state notifier for global search functionality
///
/// Responsibilities:
/// - Manage search state (idle, typing, searching, results, error)
/// - Debounced autocomplete (400ms delay)
/// - Execute searches and save to history
/// - Load discovery data via Discover Bundle API (single call)
/// - Handle sort/filter changes
class GlobalSearchNotifier extends StateNotifier<GlobalSearchState> {
  final SearchService _searchService;
  final SearchHistoryService _historyService;
  final DiscoverService _discoverService;
  final String _languageCode;
  final Logger _logger = Logger();

  Timer? _debounceTimer;
  CancelToken? _autocompleteCancelToken;

  GlobalSearchNotifier(
    this._searchService,
    this._historyService,
    this._discoverService,
    this._languageCode,
  ) : super(const GlobalSearchState()) {
    _loadInitialData();
  }

  // ==========================================================================
  // INITIALIZATION
  // ==========================================================================

  /// Load initial discovery data on startup
  ///
  /// Uses the unified Discover Bundle API (single call) instead of multiple calls
  /// Loads in parallel with local history:
  /// - Recent search history (from SharedPreferences)
  /// - Discover bundle (trending, recommendations, featured poets, categories)
  Future<void> _loadInitialData() async {
    try {
      // Load history and discover bundle in parallel
      final results = await Future.wait([
        _historyService.getHistory(),
        _discoverService.getDiscoverBundle(lang: _languageCode),
      ]);

      final recentSearches = results[0] as List<String>;
      final bundle = results[1] as DiscoverBundle;

      // Convert discover bundle data to legacy format for compatibility
      final trendingSearches = _convertTrendingSearches(bundle.trendingSearches);
      final recommendations = _convertRecommendations(bundle);

      state = state.copyWith(
        recentSearches: recentSearches,
        trendingSearches: trendingSearches,
        recommendations: recommendations,
        discoverBundle: bundle,
      );

      _logger.i('✅ Loaded discover bundle via single API call');
    } catch (e) {
      _logger.e('❌ Failed to load discovery data: $e');
      // Graceful degradation - continue with empty discovery data
      // User can still search
      state = state.copyWith(
        errorMessage: 'Failed to load discovery data',
      );
    }
  }

  /// Convert TrendingSearches from bundle to legacy TrendingSearchesResponse
  TrendingSearchesResponse _convertTrendingSearches(TrendingSearches trending) {
    final searches = trending.daily.map((item) => TrendingSearch(
      query: item.query,
      normalizedQuery: item.query.toLowerCase(),
      count: item.searchCount,
      score: item.rank.toDouble(),
    )).toList();

    return TrendingSearchesResponse(
      searches: searches,
      totalCount: searches.length,
      timeframe: 'daily',
      period: 'daily',
    );
  }

  /// Convert bundle recommendations to legacy RecommendationResponse
  RecommendationResponse _convertRecommendations(DiscoverBundle bundle) {
    // Combine editorsPicks and recommended into items
    final items = <RecommendationItem>[];

    for (final card in bundle.editorsPicks.items) {
      items.add(RecommendationItem(
        contentType: card.type,
        publicId: card.publicId,
        title: card.primaryText,
        poetName: card.secondaryText,
        likeCount: card.metrics?.likeCount ?? 0,
        shareCount: card.metrics?.shareCount ?? 0,
        bookmarkCount: card.metrics?.bookmarkCount ?? 0,
        viewCount: card.metrics?.viewCount ?? 0,
        score: card.score ?? 0.0,
      ));
    }

    for (final card in bundle.recommended.items) {
      items.add(RecommendationItem(
        contentType: card.type,
        publicId: card.publicId,
        title: card.primaryText,
        poetName: card.secondaryText,
        likeCount: card.metrics?.likeCount ?? 0,
        shareCount: card.metrics?.shareCount ?? 0,
        bookmarkCount: card.metrics?.bookmarkCount ?? 0,
        viewCount: card.metrics?.viewCount ?? 0,
        score: card.score ?? 0.0,
      ));
    }

    return RecommendationResponse(
      type: 'HYBRID',
      items: items,
      totalCount: items.length,
      isPersonalized: bundle.personalized,
    );
  }

  // ==========================================================================
  // SEARCH QUERY HANDLING
  // ==========================================================================

  /// Called on every keystroke in search bar
  ///
  /// Features:
  /// - Debounces autocomplete calls (400ms)
  /// - Transitions to idle mode if query is empty
  /// - Cancels pending autocomplete on new input
  ///
  /// Parameters:
  /// - [query]: Current search query
  void onQueryChanged(String query) {
    final trimmedQuery = query.trim();

    // Update current query
    state = state.copyWith(
      currentQuery: trimmedQuery,
      mode: trimmedQuery.isEmpty ? SearchMode.idle : SearchMode.typing,
    );

    // Cancel previous debounce timer and pending request
    _debounceTimer?.cancel();
    _autocompleteCancelToken?.cancel();

    // Clear autocomplete if query is empty
    if (trimmedQuery.isEmpty) {
      state = state.copyWith(
        autocompleteResults: null,
        isLoadingAutocomplete: false,
      );
      return;
    }

    // Debounce autocomplete (400ms sweet spot)
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _fetchAutocomplete(trimmedQuery);
    });
  }

  /// Fetch autocomplete suggestions (debounced)
  ///
  /// Target latency: <200ms
  /// Minimum query length: 2 characters
  ///
  /// Parameters:
  /// - [query]: Search query (already trimmed)
  Future<void> _fetchAutocomplete(String query) async {
    if (query.length < 2) return;

    // Cancel any previous autocomplete request
    _autocompleteCancelToken?.cancel();
    _autocompleteCancelToken = CancelToken();

    state = state.copyWith(
      isLoadingAutocomplete: true,
      mode: SearchMode.autocompleting,
    );

    try {
      final results = await _searchService.getAutocomplete(
        query: query,
        lang: _languageCode,
        cancelToken: _autocompleteCancelToken,
      );

      // Only update if query hasn't changed
      if (state.currentQuery == query) {
        state = state.copyWith(
          autocompleteResults: results,
          isLoadingAutocomplete: false,
        );
      }
    } on DioException catch (e) {
      // Ignore cancelled requests
      if (e.type == DioExceptionType.cancel) return;

      // Graceful degradation - clear autocomplete on error
      state = state.copyWith(
        autocompleteResults: null,
        isLoadingAutocomplete: false,
      );
    } catch (e) {
      // Graceful degradation - clear autocomplete on error
      state = state.copyWith(
        autocompleteResults: null,
        isLoadingAutocomplete: false,
      );
    }
  }

  // ==========================================================================
  // SEARCH EXECUTION
  // ==========================================================================

  /// Execute search and display results
  ///
  /// Workflow:
  /// 1. Save query to search history
  /// 2. Fetch couplet results
  /// 3. Fetch related searches
  /// 4. Transition to results mode
  ///
  /// Parameters:
  /// - [query]: Optional query (uses currentQuery if null)
  Future<void> executeSearch({String? query}) async {
    final searchQuery = query?.trim() ?? state.currentQuery;

    if (searchQuery.isEmpty) return;

    // Save to history
    await _historyService.addSearch(searchQuery);

    // Update state to searching mode
    state = state.copyWith(
      currentQuery: searchQuery,
      mode: SearchMode.searching,
      isLoadingResults: true,
      autocompleteResults: null, // Hide autocomplete
    );

    try {
      // Fetch unified search results and related searches in parallel
      final results = await Future.wait([
        _searchService.searchUnified(
          query: searchQuery,
          type: 'all',  // Search all content types
          lang: _languageCode,
        ),
        _searchService.getRelatedSearches(
          query: searchQuery,
          limit: 5,
        ),
      ]);

      final unifiedResults = results[0] as UnifiedSearchResponse;
      final relatedSearches = results[1] as RelatedSearchesResponse;

      _logger.i('🔍 Setting state with unified results: totalResults=${unifiedResults.totalResults}');
      _logger.i('   Poets: ${unifiedResults.poets.length}, Poems: ${unifiedResults.poems.length}, Couplets: ${unifiedResults.couplets.length}');

      // Update state with results
      state = state.copyWith(
        mode: SearchMode.results,
        isLoadingResults: false,
        unifiedResults: unifiedResults,
        relatedSearches: relatedSearches,
      );

      _logger.i('✅ State updated - mode: ${state.mode}, unifiedResults.totalResults: ${state.unifiedResults?.totalResults}');

      // Reload recent searches to show latest
      final history = await _historyService.getHistory();
      state = state.copyWith(recentSearches: history);
    } catch (e, stackTrace) {
      _logger.e('❌ ERROR in executeSearch: $e');
      _logger.e('❌ Stack trace: $stackTrace');
      state = state.copyWith(
        mode: SearchMode.error,
        isLoadingResults: false,
        errorMessage: 'Search failed: ${e.toString()}',
      );
    }
  }

  // ==========================================================================
  // FILTERS & SORTING
  // ==========================================================================

  /// Change sort option and re-execute search
  ///
  /// Sort options:
  /// - relevance (BM25 scoring)
  /// - likes (most liked)
  /// - shares (most shared)
  /// - bookmarks (most bookmarked)
  /// - trending (engagement score)
  ///
  /// Parameters:
  /// - [sortBy]: New sort option
  void setSortBy(String sortBy) {
    if (state.sortBy == sortBy) return;

    state = state.copyWith(sortBy: sortBy);

    // Re-execute search if in results mode
    if (state.mode == SearchMode.results) {
      executeSearch();
    }
  }

  /// Set poet filter and re-execute search
  ///
  /// Parameters:
  /// - [poetId]: Poet publicId (null to clear filter)
  void setPoetFilter(String? poetId) {
    state = state.copyWith(selectedFilter: poetId);

    // Re-execute search if in results mode
    if (state.mode == SearchMode.results) {
      executeSearch();
    }
  }

  /// Set active segment and re-execute search if needed
  ///
  /// Parameters:
  /// - [segment]: New active segment
  void setActiveSegment(DiscoverSegment segment) {
    state = state.copyWith(activeSegment: segment);

    // If placeholder segment, don't execute search
    if (segment == DiscoverSegment.dictionary ||
        segment == DiscoverSegment.watch) {
      return;
    }

    // Re-execute search with segment filter if in results mode
    if (state.mode == SearchMode.results) {
      executeSearch();
    }
  }

  /// Set couplet sort option and re-execute search
  ///
  /// Parameters:
  /// - [sortOption]: New couplet sort option
  void setCoupletSort(CoupletSortOption sortOption) {
    state = state.copyWith(coupletSort: sortOption);

    // Re-execute search if in verses segment
    if (state.activeSegment == DiscoverSegment.verses &&
        state.mode == SearchMode.results) {
      executeSearch();
    }
  }

  // ==========================================================================
  // STATE MANAGEMENT
  // ==========================================================================

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Reset search to idle state
  ///
  /// Preserves:
  /// - Recent searches
  /// - Trending searches
  /// - Recommendations
  ///
  /// Clears:
  /// - Current query
  /// - Search results
  /// - Autocomplete
  /// - Filters
  void reset() {
    state = state.copyWith(
      mode: SearchMode.idle,
      currentQuery: '',
      sortBy: 'relevance',
      selectedFilter: null,
      autocompleteResults: null,
      isLoadingAutocomplete: false,
      coupletResults: null,
      isLoadingResults: false,
      relatedSearches: null,
      errorMessage: null,
      // Keep discovery data
      // recentSearches: retained
      // trendingSearches: retained
      // recommendations: retained
    );
  }

  /// Refresh discovery data using Discover Bundle API
  Future<void> refreshDiscovery() async {
    try {
      final bundle = await _discoverService.getDiscoverBundle(
        lang: _languageCode,
        forceRefresh: true,
      );

      final trendingSearches = _convertTrendingSearches(bundle.trendingSearches);
      final recommendations = _convertRecommendations(bundle);

      state = state.copyWith(
        trendingSearches: trendingSearches,
        recommendations: recommendations,
        discoverBundle: bundle,
      );
    } catch (e) {
      // Silent fail - keep existing data
      _logger.e('Failed to refresh discovery: $e');
    }
  }

  /// Refresh recent searches from local storage
  Future<void> refreshRecentSearches() async {
    try {
      final history = await _historyService.getHistory();
      state = state.copyWith(recentSearches: history);
    } catch (e) {
      // Silent fail - keep existing data
    }
  }

  // ==========================================================================
  // CLEANUP
  // ==========================================================================

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _autocompleteCancelToken?.cancel();
    super.dispose();
  }
}

// ============================================================================
// MAIN PROVIDER
// ============================================================================

/// Global search provider (main entry point)
///
/// Automatically watches language changes and recreates notifier
final globalSearchProvider =
    StateNotifierProvider<GlobalSearchNotifier, GlobalSearchState>((ref) {
  final searchService = ref.watch(searchServiceProvider);
  final historyService = ref.watch(searchHistoryServiceProvider);
  final discoverService = ref.watch(discoverServiceProvider);
  final languageCode = ref.watch(selectedLanguageProvider);

  return GlobalSearchNotifier(
    searchService,
    historyService,
    discoverService,
    languageCode,
  );
});
