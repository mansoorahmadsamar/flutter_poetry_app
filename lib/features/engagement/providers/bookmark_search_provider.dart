import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:flutter_poetry_app/features/engagement/models/bookmark_search_state.dart';
import 'package:flutter_poetry_app/features/engagement/providers/bookmark_providers.dart';
import 'package:flutter_poetry_app/features/engagement/providers/bookmark_search_history_provider.dart';

final Logger _logger = Logger();

// ============= BOOKMARK SEARCH PROVIDER =============

final bookmarkSearchProvider =
    StateNotifierProvider<BookmarkSearchNotifier, BookmarkSearchState>(
  (ref) => BookmarkSearchNotifier(ref),
);

class BookmarkSearchNotifier extends StateNotifier<BookmarkSearchState> {
  final Ref _ref;
  static const int _pageSize = 20;

  BookmarkSearchNotifier(this._ref) : super(const BookmarkSearchState());

  /// Search bookmarks with minimum 3 characters
  Future<void> search(String query, {String? poetryType, String? sortBy}) async {
    if (query.trim().isEmpty || query.length < 3) {
      _logger.w('⚠️ Search query too short: "$query"');
      return;
    }

    _logger.i('🔍 Searching bookmarks: "$query"');
    state = BookmarkSearchState(
      isLoading: true,
      currentQuery: query,
      poetryTypeFilter: poetryType,
      sortBy: sortBy ?? 'createdAt',
    );

    try {
      final service = _ref.read(bookmarkServiceProvider);
      final result = await service.getMyBookmarks(
        page: 0,
        size: _pageSize,
        search: query,
        poetryType: poetryType,
        sortBy: sortBy ?? 'createdAt',
        sortDir: 'desc',
      );

      state = state.copyWith(
        results: result.content,
        currentPage: 0,
        totalElements: result.totalElements,
        hasMore: result.content.length >= _pageSize && !result.last,
        isLoading: false,
        error: null,
      );

      // Save to search history
      _ref.read(bookmarkSearchHistoryProvider.notifier).addSearch(query);

      _logger.i('✅ Found ${result.totalElements} bookmarks');
    } catch (e) {
      _logger.e('❌ Bookmark search error: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Load more results with pagination
  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.currentQuery == null) {
      return;
    }

    state = state.copyWith(isLoadingMore: true);

    try {
      final nextPage = state.currentPage + 1;
      final service = _ref.read(bookmarkServiceProvider);

      final result = await service.getMyBookmarks(
        page: nextPage,
        size: _pageSize,
        search: state.currentQuery!,
        poetryType: state.poetryTypeFilter,
        sortBy: state.sortBy ?? 'createdAt',
        sortDir: 'desc',
      );

      final updatedResults = [...state.results, ...result.content];

      state = state.copyWith(
        results: updatedResults,
        currentPage: nextPage,
        hasMore: result.content.length >= _pageSize && !result.last,
        isLoadingMore: false,
      );

      _logger.i('✅ Loaded page $nextPage (${result.content.length} items)');
    } catch (e) {
      _logger.e('❌ Load more error: $e');
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }

  /// Set poetry type filter and re-search
  void setPoetryTypeFilter(String? poetryType) {
    if (state.currentQuery != null && state.currentQuery!.length >= 3) {
      search(state.currentQuery!, poetryType: poetryType, sortBy: state.sortBy);
    }
  }

  /// Set sort option and re-search
  void setSortBy(String sortBy) {
    if (state.currentQuery != null && state.currentQuery!.length >= 3) {
      search(state.currentQuery!, poetryType: state.poetryTypeFilter, sortBy: sortBy);
    }
  }

  /// Reset search state
  void reset() {
    state = const BookmarkSearchState();
  }
}
