import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/models/poet_model.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/services/poet_service.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/providers/poet_providers.dart';
import 'package:flutter_poetry_app/core/network/dto/api_response.dart';
import 'package:flutter_poetry_app/features/search/models/search_state.dart';
import 'package:flutter_poetry_app/features/search/providers/search_providers.dart';

final _logger = Logger();

/// Search pagination provider
final searchPaginationProvider =
    StateNotifierProvider<SearchPaginationNotifier, SearchPaginationState>(
  (ref) => SearchPaginationNotifier(ref),
);

/// Search pagination notifier
class SearchPaginationNotifier extends StateNotifier<SearchPaginationState> {
  final Ref _ref;
  static const int _pageSize = 20;

  SearchPaginationNotifier(this._ref) : super(const SearchPaginationState());

  PoetService get _service => _ref.read(poetServiceProvider);
  String get _lang => _ref.watch(selectedLanguageProvider);
  SearchFilters get _filters => _ref.read(searchFiltersProvider);

  /// Search poets with a query
  Future<void> search(String query) async {
    if (query.trim().isEmpty || query.length < 2) {
      _logger.w('⚠️ Search query too short: "$query"');
      return;
    }

    _logger.i('🔍 Starting search for: "$query"');

    // Reset state for new search
    state = SearchPaginationState(
      isLoading: true,
      currentQuery: query,
    );

    try {
      final result = await _fetchPoets(query, 0);

      state = state.copyWith(
        results: result.content,
        currentPage: 0,
        totalElements: result.totalElements,
        hasMore: result.content.length >= _pageSize && !result.last,
        isLoading: false,
        error: null,
      );

      _logger.i('✅ Search completed: ${result.content.length} results found');

      // Add to search history
      _ref.read(searchHistoryProvider.notifier).addSearch(query);
    } catch (e) {
      _logger.e('❌ Search failed: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Load more results
  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) {
      return;
    }

    // If no query, it means we're browsing by filters
    final isBrowsing = state.currentQuery == '';
    final hasQuery = state.currentQuery != null && state.currentQuery!.isNotEmpty;

    if (!isBrowsing && !hasQuery) {
      return; // No query and not browsing, nothing to load
    }

    _logger.i('📄 Loading more results - Page: ${state.currentPage + 1}');

    state = state.copyWith(isLoadingMore: true);

    try {
      final nextPage = state.currentPage + 1;
      final result = isBrowsing
          ? await _fetchPoetsByFiltersOnly(nextPage)
          : await _fetchPoets(state.currentQuery!, nextPage);

      final updatedResults = [...state.results, ...result.content];

      state = state.copyWith(
        results: updatedResults,
        currentPage: nextPage,
        totalElements: result.totalElements,
        hasMore: result.content.length >= _pageSize && !result.last,
        isLoadingMore: false,
        error: null,
      );

      _logger.i('✅ Loaded ${result.content.length} more results');
    } catch (e) {
      _logger.e('❌ Load more failed: $e');
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  /// Refresh search results
  Future<void> refresh() async {
    if (state.currentQuery == null) return;
    _logger.i('🔄 Refreshing search results');
    await search(state.currentQuery!);
  }

  /// Reset search state
  void reset() {
    _logger.i('🧹 Reset search state');
    state = const SearchPaginationState();
  }

  /// Browse poets by filters only (without search query)
  Future<void> browseByFilters() async {
    final filters = _filters;

    if (!filters.hasActiveFilters) {
      _logger.w('⚠️ No active filters to browse');
      return;
    }

    _logger.i('🔍 Browsing poets by filters');

    // Reset state for new browse
    state = SearchPaginationState(
      isLoading: true,
      currentQuery: '', // Empty query for filter-only browsing
    );

    try {
      final result = await _fetchPoetsByFiltersOnly(0);

      state = state.copyWith(
        results: result.content,
        currentPage: 0,
        totalElements: result.totalElements,
        hasMore: result.content.length >= _pageSize && !result.last,
        isLoading: false,
        error: null,
      );

      _logger.i('✅ Browse completed: ${result.content.length} results found');
    } catch (e) {
      _logger.e('❌ Browse failed: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Fetch poets by filters only (no query)
  Future<PaginatedResponse<PoetModel>> _fetchPoetsByFiltersOnly(int page) async {
    final filters = _filters;

    // Priority: Era > Gender > Featured > Trending
    if (filters.selectedEras.isNotEmpty) {
      final era = filters.selectedEras.first;
      _logger.i('🔍 Browsing poets in era: $era');
      return await _service.getPoetsByEra(
        era: era,
        page: page,
        size: _pageSize,
        lang: _lang,
      );
    }

    if (filters.selectedGenders.isNotEmpty) {
      final gender = filters.selectedGenders.first;
      _logger.i('🔍 Browsing poets of gender: $gender');
      return await _service.getPoetsByGender(
        gender: gender,
        page: page,
        size: _pageSize,
        lang: _lang,
      );
    }

    if (filters.onlyFeatured) {
      _logger.i('🔍 Browsing featured poets');
      return await _service.getFeaturedPoets(
        page: page,
        size: _pageSize,
        lang: _lang,
      );
    }

    if (filters.onlyTrending) {
      _logger.i('🔍 Browsing trending poets');
      return await _service.getTrendingPoets(
        page: page,
        size: _pageSize,
        lang: _lang,
      );
    }

    // Should not reach here if hasActiveFilters is true
    throw Exception('No active filters');
  }

  /// Fetch poets based on filters
  Future<PaginatedResponse<PoetModel>> _fetchPoets(
    String query,
    int page,
  ) async {
    final filters = _filters;

    // If specific filters are active, use filtered endpoints
    if (filters.selectedEras.isNotEmpty) {
      // Use era filter endpoint - take first era for now
      // In future, could make multiple calls and merge results
      final era = filters.selectedEras.first;
      _logger.i('🔍 Searching poets in era: $era with query: $query');
      final result = await _service.getPoetsByEra(
        era: era,
        page: page,
        size: _pageSize,
        lang: _lang,
      );
      // Filter results by query text
      final filteredContent = result.content
          .where((poet) =>
              poet.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
      return PaginatedResponse(
        content: filteredContent,
        pageable: result.pageable,
        totalElements: filteredContent.length,
        totalPages: result.totalPages,
        last: result.last,
        first: result.first,
        numberOfElements: filteredContent.length,
        size: result.size,
        number: result.number,
        empty: filteredContent.isEmpty,
      );
    }

    if (filters.selectedGenders.isNotEmpty) {
      final gender = filters.selectedGenders.first;
      _logger.i('🔍 Searching poets of gender: $gender with query: $query');
      final result = await _service.getPoetsByGender(
        gender: gender,
        page: page,
        size: _pageSize,
        lang: _lang,
      );
      final filteredContent = result.content
          .where((poet) =>
              poet.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
      return PaginatedResponse(
        content: filteredContent,
        pageable: result.pageable,
        totalElements: filteredContent.length,
        totalPages: result.totalPages,
        last: result.last,
        first: result.first,
        numberOfElements: filteredContent.length,
        size: result.size,
        number: result.number,
        empty: filteredContent.isEmpty,
      );
    }

    if (filters.onlyFeatured) {
      _logger.i('🔍 Searching featured poets with query: $query');
      final result = await _service.getFeaturedPoets(
        page: page,
        size: _pageSize,
        lang: _lang,
      );
      final filteredContent = result.content
          .where((poet) =>
              poet.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
      return PaginatedResponse(
        content: filteredContent,
        pageable: result.pageable,
        totalElements: filteredContent.length,
        totalPages: result.totalPages,
        last: result.last,
        first: result.first,
        numberOfElements: filteredContent.length,
        size: result.size,
        number: result.number,
        empty: filteredContent.isEmpty,
      );
    }

    if (filters.onlyTrending) {
      _logger.i('🔍 Searching trending poets with query: $query');
      final result = await _service.getTrendingPoets(
        page: page,
        size: _pageSize,
        lang: _lang,
      );
      final filteredContent = result.content
          .where((poet) =>
              poet.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
      return PaginatedResponse(
        content: filteredContent,
        pageable: result.pageable,
        totalElements: filteredContent.length,
        totalPages: result.totalPages,
        last: result.last,
        first: result.first,
        numberOfElements: filteredContent.length,
        size: result.size,
        number: result.number,
        empty: filteredContent.isEmpty,
      );
    }

    // Default: use search endpoint
    _logger.i('🔍 Searching poets with query: $query');
    return await _service.searchPoets(
      query: query,
      lang: _lang,
      page: page,
      size: _pageSize,
    );
  }
}
