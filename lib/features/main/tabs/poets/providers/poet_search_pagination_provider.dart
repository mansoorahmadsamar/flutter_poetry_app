import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../services/poet_service.dart';
import 'poet_providers.dart';
import 'package:flutter_poetry_app/features/search/models/search_state.dart';
import 'package:flutter_poetry_app/features/search/providers/search_providers.dart';

final Logger _logger = Logger();

/// Proper poet search pagination notifier.
/// Replaces the deprecated stub `OldSearchPaginationNotifier`.
class PoetSearchPaginationNotifier extends StateNotifier<SearchPaginationState> {
  final PoetService _poetService;
  final String _language;
  final Ref _ref;

  PoetSearchPaginationNotifier(this._poetService, this._language, this._ref)
      : super(const SearchPaginationState());

  /// Search poets by query using /api/poets/search
  Future<void> search(String query) async {
    if (query.trim().length < 2) return;
    if (state.isLoading) return;

    state = state.copyWith(
      isLoading: true,
      error: null,
      results: [],
      currentPage: 0,
      hasMore: true,
      currentQuery: query,
      totalElements: 0,
    );

    try {
      final result = await _poetService.searchPoets(
        query: query,
        lang: _language,
        page: 0,
        size: 10,
      );

      state = state.copyWith(
        isLoading: false,
        results: result.content,
        currentPage: 0,
        hasMore: !result.last,
        totalElements: result.totalElements,
      );

      // Save to search history
      _ref.read(searchHistoryProvider.notifier).addSearch(query);

      _logger.i('✅ Poet search: "$query" → ${result.totalElements} results');
    } catch (e) {
      _logger.e('❌ Poet search error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Browse poets by filters (no query, filter-based browsing)
  Future<void> browseByFilters() async {
    if (state.isLoading) return;

    final filters = _ref.read(searchFiltersProvider);

    state = state.copyWith(
      isLoading: true,
      error: null,
      results: [],
      currentPage: 0,
      hasMore: true,
      currentQuery: null,
      totalElements: 0,
    );

    try {
      final result = await _fetchByFilters(filters, 0);

      state = state.copyWith(
        isLoading: false,
        results: result.content,
        currentPage: 0,
        hasMore: !result.last,
        totalElements: result.totalElements,
      );

      _logger.i('✅ Filter browse → ${result.totalElements} results');
    } catch (e) {
      _logger.e('❌ Filter browse error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Load next page of results
  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.isLoading) return;

    state = state.copyWith(isLoadingMore: true, error: null);

    try {
      final nextPage = state.currentPage + 1;
      final filters = _ref.read(searchFiltersProvider);

      final result = state.currentQuery != null
          ? await _poetService.searchPoets(
              query: state.currentQuery!,
              lang: _language,
              page: nextPage,
              size: 10,
            )
          : await _fetchByFilters(filters, nextPage);

      state = state.copyWith(
        isLoadingMore: false,
        results: [...state.results, ...result.content],
        currentPage: nextPage,
        hasMore: !result.last,
      );
    } catch (e) {
      _logger.e('❌ Load more error: $e');
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  /// Reset to initial empty state
  void reset() {
    state = const SearchPaginationState();
  }

  /// Fetch poets based on active filters
  Future<dynamic> _fetchByFilters(SearchFilters filters, int page) async {
    // Priority: gender → era → featured → trending → all
    if (filters.selectedGenders.isNotEmpty) {
      return _poetService.getPoetsByGender(
        gender: filters.selectedGenders.first,
        page: page,
        size: 10,
        lang: _language,
      );
    }

    if (filters.selectedEras.isNotEmpty) {
      return _poetService.getPoetsByEra(
        era: filters.selectedEras.first,
        page: page,
        size: 10,
        lang: _language,
      );
    }

    if (filters.onlyFeatured) {
      return _poetService.getFeaturedPoets(
        page: page,
        size: 10,
        lang: _language,
      );
    }

    if (filters.onlyTrending) {
      return _poetService.getTrendingPoets(
        page: page,
        size: 10,
        lang: _language,
      );
    }

    return _poetService.getAllPoets(
      page: page,
      size: 10,
      lang: _language,
    );
  }
}

/// Provider for poet search pagination.
/// Drop-in replacement for the deprecated `searchPaginationProvider`.
final poetSearchPaginationProvider = StateNotifierProvider<
    PoetSearchPaginationNotifier, SearchPaginationState>((ref) {
  final poetService = ref.watch(poetServiceProvider);
  final language = ref.watch(selectedLanguageProvider);
  return PoetSearchPaginationNotifier(poetService, language, ref);
});
