import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:flutter_poetry_app/core/network/dto/api_response.dart';
import '../models/poet_model.dart';
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

  /// Bumped by every new search, browse or reset, so a page that was still
  /// loading for the previous results is discarded instead of appended.
  int _generation = 0;

  /// Search poets by query using /api/poets/search
  Future<void> search(String query) async {
    if (query.trim().length < 2) return;
    if (state.isLoading) return;
    _generation++;

    state = state.copyWith(
      isLoading: true,
      isLoadingMore: false,
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
    _generation++;

    state = state.copyWith(
      isLoading: true,
      isLoadingMore: false,
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
    final query = state.currentQuery;
    final generation = _generation;

    try {
      final nextPage = state.currentPage + 1;
      final filters = _ref.read(searchFiltersProvider);

      final result = query != null
          ? await _poetService.searchPoets(
              query: query,
              lang: _language,
              page: nextPage,
              size: 10,
            )
          : await _fetchByFilters(filters, nextPage);

      // A new search, browse or reset replaced the results meanwhile.
      if (generation != _generation) return;

      // The same poet can appear on two pages (and guest search clamps to
      // page 4, repeating it): show each poet once, and stop paging when a
      // page brings nothing new rather than requesting it forever.
      final seen = {for (final poet in state.results) poet.publicId};
      final fresh = <PoetModel>[
        for (final poet in result.content)
          if (seen.add(poet.publicId)) poet,
      ];

      state = state.copyWith(
        isLoadingMore: false,
        results: [...state.results, ...fresh],
        currentPage: nextPage,
        hasMore: !result.last && fresh.isNotEmpty,
      );
    } catch (e) {
      _logger.e('❌ Load more error: $e');
      if (generation != _generation) return;
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  /// Reset to initial empty state
  void reset() {
    _generation++;
    state = const SearchPaginationState();
  }

  /// Fetch poets based on active filters
  Future<PaginatedResponse<PoetModel>> _fetchByFilters(
      SearchFilters filters, int page) async {
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
