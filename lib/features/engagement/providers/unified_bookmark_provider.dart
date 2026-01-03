import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:flutter_poetry_app/core/network/dio_client.dart';
import 'package:flutter_poetry_app/features/main/tabs/bookmarks/models/unified_bookmark_model.dart';
import 'package:flutter_poetry_app/features/engagement/services/unified_bookmark_service.dart';

final Logger _logger = Logger();

// ============= SERVICE PROVIDER =============

final unifiedBookmarkServiceProvider = Provider<UnifiedBookmarkService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return UnifiedBookmarkService(dioClient.dio);
});

// ============= UNIFIED BOOKMARKS PROVIDER =============

/// Provider for unified bookmarks
final unifiedBookmarksProvider = StateNotifierProvider.family<
    UnifiedBookmarksNotifier,
    AsyncValue<UnifiedBookmarksResponse>,
    BookmarkFilters>(
  (ref, filters) => UnifiedBookmarksNotifier(
    service: ref.watch(unifiedBookmarkServiceProvider),
    filters: filters,
  ),
);

/// State notifier for unified bookmarks
class UnifiedBookmarksNotifier
    extends StateNotifier<AsyncValue<UnifiedBookmarksResponse>> {
  final UnifiedBookmarkService _service;
  BookmarkFilters _currentFilters;

  UnifiedBookmarksNotifier({
    required UnifiedBookmarkService service,
    required BookmarkFilters filters,
  })  : _service = service,
        _currentFilters = filters,
        super(const AsyncValue.loading()) {
    fetchBookmarks();
  }

  /// Fetch bookmarks from API
  Future<void> fetchBookmarks({bool isLoadMore = false}) async {
    if (!isLoadMore) {
      state = const AsyncValue.loading();
    }

    _logger.d('🚀 Starting fetchBookmarks - isLoadMore: $isLoadMore, filters: $_currentFilters');

    try {
      UnifiedBookmarksResponse bookmarksResponse;

      // Determine which service method to use based on filters
      if (_currentFilters.searchQuery != null &&
          _currentFilters.searchQuery!.isNotEmpty) {
        // Use search endpoint
        bookmarksResponse = await _service.searchBookmarks(
          query: _currentFilters.searchQuery!,
          page: _currentFilters.page,
          size: _currentFilters.size,
          type: _currentFilters.type != 'ALL' ? _currentFilters.type : null,
          lang: _currentFilters.language != 'ALL' ? _currentFilters.language : null,
        );
      } else {
        // Use type-specific endpoints
        switch (_currentFilters.type) {
          case 'POEM':
            bookmarksResponse = await _service.getPoemBookmarks(
              page: _currentFilters.page,
              size: _currentFilters.size,
              lang: _currentFilters.language != 'ALL' ? _currentFilters.language : null,
              sortBy: _currentFilters.sortBy,
              sortDir: _currentFilters.sortDir,
            );
            break;
          case 'COUPLET':
            bookmarksResponse = await _service.getCoupletBookmarks(
              page: _currentFilters.page,
              size: _currentFilters.size,
              lang: _currentFilters.language != 'ALL' ? _currentFilters.language : null,
              sortBy: _currentFilters.sortBy,
              sortDir: _currentFilters.sortDir,
            );
            break;
          case 'IMAGE':
            bookmarksResponse = await _service.getImageBookmarks(
              page: _currentFilters.page,
              size: _currentFilters.size,
              lang: _currentFilters.language != 'ALL' ? _currentFilters.language : null,
              sortBy: _currentFilters.sortBy,
              sortDir: _currentFilters.sortDir,
            );
            break;
          case 'ALL':
          default:
            bookmarksResponse = await _service.getRecentBookmarks(
              page: _currentFilters.page,
              size: _currentFilters.size,
              lang: _currentFilters.language != 'ALL' ? _currentFilters.language : null,
            );
        }
      }

      _logger.i('✅ Unified bookmarks loaded - Type: ${_currentFilters.type}, Lang: ${_currentFilters.language}, Page: ${_currentFilters.page}');

      // If loading more, append to existing data
      if (isLoadMore && state.hasValue) {
        final currentData = state.value!;
        final updatedContent = [
          ...currentData.content,
          ...bookmarksResponse.content,
        ];

        final updatedResponse = bookmarksResponse.copyWith(
          content: updatedContent,
        );

        state = AsyncValue.data(updatedResponse);
      } else {
        state = AsyncValue.data(bookmarksResponse);
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Load more bookmarks (pagination)
  Future<void> loadMore() async {
    if (state.hasValue) {
      final currentData = state.value!;
      if (!currentData.last) {
        _currentFilters = _currentFilters.copyWith(
          page: _currentFilters.page + 1,
        );
        await fetchBookmarks(isLoadMore: true);
      }
    }
  }

  /// Update filters and refresh
  Future<void> updateFilters(BookmarkFilters newFilters) async {
    _currentFilters = newFilters.copyWith(page: 0); // Reset to first page
    await fetchBookmarks();
  }

  /// Refresh bookmarks
  Future<void> refresh() async {
    _currentFilters = _currentFilters.copyWith(page: 0);
    await fetchBookmarks();
  }

  /// Get current filters
  BookmarkFilters get currentFilters => _currentFilters;
}

// ============= BOOKMARK STATISTICS PROVIDER =============

/// Provider for bookmark statistics
final bookmarkStatsProvider = FutureProvider.autoDispose<BookmarkStats>((ref) async {
  final service = ref.watch(unifiedBookmarkServiceProvider);

  try {
    final stats = await service.getBookmarkStats();
    _logger.i('✅ Bookmark stats loaded - Total: ${stats.totalBookmarks}');
    return stats;
  } catch (e) {
    _logger.e('❌ Error loading bookmark stats: $e');
    rethrow;
  }
});

// ============= BOOKMARK ACTION PROVIDERS =============

/// Provider for removing a bookmark
final removeBookmarkProvider = Provider.autoDispose((ref) {
  final service = ref.watch(unifiedBookmarkServiceProvider);

  return ({
    required String bookmarkId,
    required String type,
  }) async {
    try {
      await service.removeBookmark(
        bookmarkId: bookmarkId,
        type: type,
      );

      _logger.i('✅ Bookmark removed - Type: $type, ID: $bookmarkId');

      // Invalidate all bookmark providers to refresh
      ref.invalidate(unifiedBookmarksProvider);
      ref.invalidate(bookmarkStatsProvider);
    } catch (e) {
      _logger.e('❌ Error removing bookmark: $e');
      rethrow;
    }
  };
});
