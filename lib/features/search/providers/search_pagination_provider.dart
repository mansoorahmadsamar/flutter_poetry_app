import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_poetry_app/core/providers/language_provider.dart';
import 'package:flutter_poetry_app/features/search/models/search_models.dart';
import 'package:flutter_poetry_app/features/search/services/search_service.dart';
import 'package:flutter_poetry_app/features/search/providers/global_search_provider.dart';

part 'search_pagination_provider.freezed.dart';

// ============================================================================
// PAGINATION STATE
// ============================================================================

/// Pagination state for search results
@freezed
class SearchPaginationState with _$SearchPaginationState {
  const factory SearchPaginationState({
    @Default([]) List<CoupletSearchResult> results,
    @Default(0) int currentPage,
    @Default(true) bool hasMore,
    @Default(false) bool isLoading,
    @Default(false) bool isLoadingMore,
    @Default(false) bool isRefreshing,
    String? error,
    @Default(20) int pageSize,
    @Default(0) int totalElements,
  }) = _SearchPaginationState;

  const SearchPaginationState._();

  bool get isEmpty => results.isEmpty && !isLoading;
  bool get hasResults => results.isNotEmpty;
}

// ============================================================================
// PAGINATION PARAMETERS
// ============================================================================

/// Parameters for search pagination (used as family parameter)
@freezed
class SearchPaginationParams with _$SearchPaginationParams {
  const factory SearchPaginationParams({
    required String query,
    @Default('relevance') String sortBy,
    String? poetId, // Filter by poet
  }) = _SearchPaginationParams;
}

// ============================================================================
// STATE NOTIFIER
// ============================================================================

/// Notifier for managing paginated search results (for "See All" screens)
///
/// Features:
/// - Infinite scroll with 80% threshold
/// - Initial skeleton loaders
/// - Load more indicator
/// - Pull-to-refresh support
/// - Maintains search context (query, sort, filter)
class SearchResultsPaginationNotifier extends StateNotifier<SearchPaginationState> {
  final SearchService _searchService;
  final String _languageCode;
  final SearchPaginationParams _params;

  SearchResultsPaginationNotifier(
    this._searchService,
    this._languageCode,
    this._params,
  ) : super(const SearchPaginationState()) {
    loadInitial();
  }

  // ==========================================================================
  // INITIALIZATION
  // ==========================================================================

  /// Load initial page of search results
  Future<void> loadInitial() async {
    if (state.isLoading) return;

    state = state.copyWith(
      isLoading: true,
      error: null,
      results: [],
      currentPage: 0,
      hasMore: true,
    );

    try {
      final result = await _searchService.searchCouplets(
        query: _params.query,
        poetId: _params.poetId,
        sortBy: _params.sortBy,
        lang: _languageCode,
        page: 0,
        size: state.pageSize,
      );

      state = state.copyWith(
        isLoading: false,
        results: result.content,
        currentPage: 0,
        hasMore: !result.last,
        totalElements: result.totalElements,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // ==========================================================================
  // PAGINATION
  // ==========================================================================

  /// Load more results (next page)
  ///
  /// Called when user scrolls to 80% of list
  Future<void> loadMore() async {
    // Guard conditions
    if (state.isLoadingMore || !state.hasMore || state.isLoading) return;

    state = state.copyWith(isLoadingMore: true, error: null);

    try {
      final nextPage = state.currentPage + 1;

      final result = await _searchService.searchCouplets(
        query: _params.query,
        poetId: _params.poetId,
        sortBy: _params.sortBy,
        lang: _languageCode,
        page: nextPage,
        size: state.pageSize,
      );

      state = state.copyWith(
        isLoadingMore: false,
        results: [...state.results, ...result.content],
        currentPage: nextPage,
        hasMore: !result.last,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  // ==========================================================================
  // REFRESH
  // ==========================================================================

  /// Refresh the list (pull-to-refresh)
  Future<void> refresh() async {
    if (state.isRefreshing) return;

    state = state.copyWith(isRefreshing: true, error: null);

    try {
      final result = await _searchService.searchCouplets(
        query: _params.query,
        poetId: _params.poetId,
        sortBy: _params.sortBy,
        lang: _languageCode,
        page: 0,
        size: state.pageSize,
      );

      state = state.copyWith(
        isRefreshing: false,
        results: result.content,
        currentPage: 0,
        hasMore: !result.last,
        totalElements: result.totalElements,
      );
    } catch (e) {
      state = state.copyWith(
        isRefreshing: false,
        error: e.toString(),
      );
    }
  }

  // ==========================================================================
  // RETRY
  // ==========================================================================

  /// Retry after error
  Future<void> retry() async {
    if (state.results.isEmpty) {
      await loadInitial();
    } else {
      await loadMore();
    }
  }
}

// ============================================================================
// PROVIDER
// ============================================================================

/// Provider for paginated search results (auto-dispose family)
///
/// Usage:
/// ```dart
/// final paginationProvider = ref.watch(
///   searchResultsPaginationProvider(
///     SearchPaginationParams(
///       query: 'محبت',
///       sortBy: 'relevance',
///       poetId: null,
///     ),
///   ),
/// );
/// ```
final searchResultsPaginationProvider = StateNotifierProvider.autoDispose
    .family<SearchResultsPaginationNotifier, SearchPaginationState,
        SearchPaginationParams>((ref, params) {
  final searchService = ref.watch(searchServiceProvider);
  final languageCode = ref.watch(selectedLanguageProvider);

  return SearchResultsPaginationNotifier(
    searchService,
    languageCode,
    params,
  );
});
