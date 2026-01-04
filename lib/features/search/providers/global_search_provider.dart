import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_poetry_app/core/network/dio_client.dart';
import 'package:flutter_poetry_app/core/network/dto/api_response.dart';
import 'package:flutter_poetry_app/core/providers/language_provider.dart';
import 'package:flutter_poetry_app/features/search/models/global_search_state.dart';
import 'package:flutter_poetry_app/features/search/models/search_models.dart';
import 'package:flutter_poetry_app/features/search/services/search_service.dart';
import 'package:flutter_poetry_app/features/search/services/search_history_service.dart';

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
/// - Load discovery data (trending, recommendations)
/// - Handle sort/filter changes
class GlobalSearchNotifier extends StateNotifier<GlobalSearchState> {
  final SearchService _searchService;
  final SearchHistoryService _historyService;
  final String _languageCode;

  Timer? _debounceTimer;

  GlobalSearchNotifier(
    this._searchService,
    this._historyService,
    this._languageCode,
  ) : super(const GlobalSearchState()) {
    _loadInitialData();
  }

  // ==========================================================================
  // INITIALIZATION
  // ==========================================================================

  /// Load initial discovery data on startup
  ///
  /// Loads in parallel:
  /// - Recent search history (from SharedPreferences)
  /// - Trending searches (from API)
  /// - Hybrid recommendations (from API)
  Future<void> _loadInitialData() async {
    try {
      // Load all in parallel for better performance
      final results = await Future.wait([
        _historyService.getHistory(),
        _searchService.getTrendingSearches(timeframe: 'week', limit: 10),
        _searchService.getRecommendations(type: 'hybrid', limit: 10),
      ]);

      state = state.copyWith(
        recentSearches: results[0] as List<String>,
        trendingSearches: results[1] as TrendingSearchesResponse,
        recommendations: results[2] as RecommendationResponse,
      );
    } catch (e) {
      // Graceful degradation - continue with empty discovery data
      // User can still search
      state = state.copyWith(
        errorMessage: 'Failed to load discovery data',
      );
    }
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

    // Cancel previous debounce timer
    _debounceTimer?.cancel();

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

    state = state.copyWith(
      isLoadingAutocomplete: true,
      mode: SearchMode.autocompleting,
    );

    try {
      final results = await _searchService.getAutocomplete(
        query: query,
        lang: _languageCode,
      );

      // Only update if query hasn't changed
      if (state.currentQuery == query) {
        state = state.copyWith(
          autocompleteResults: results,
          isLoadingAutocomplete: false,
        );
      }
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
      // Fetch search results and related searches in parallel
      final results = await Future.wait([
        _searchService.searchCouplets(
          query: searchQuery,
          sortBy: state.sortBy,
          lang: _languageCode,
          page: 0,
          size: 20,
        ),
        _searchService.getRelatedSearches(
          query: searchQuery,
          limit: 5,
        ),
      ]);

      // Update state with results
      state = state.copyWith(
        mode: SearchMode.results,
        isLoadingResults: false,
        coupletResults: results[0] as PaginatedResponse<CoupletSearchResult>,
        relatedSearches: results[1] as RelatedSearchesResponse,
      );

      // Reload recent searches to show latest
      final history = await _historyService.getHistory();
      state = state.copyWith(recentSearches: history);
    } catch (e) {
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

  /// Refresh discovery data (trending, recommendations)
  Future<void> refreshDiscovery() async {
    try {
      final results = await Future.wait([
        _searchService.getTrendingSearches(timeframe: 'week', limit: 10),
        _searchService.getRecommendations(type: 'hybrid', limit: 10),
      ]);

      state = state.copyWith(
        trendingSearches: results[0] as TrendingSearchesResponse,
        recommendations: results[1] as RecommendationResponse,
      );
    } catch (e) {
      // Silent fail - keep existing data
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
  final languageCode = ref.watch(selectedLanguageProvider);

  return GlobalSearchNotifier(
    searchService,
    historyService,
    languageCode,
  );
});
