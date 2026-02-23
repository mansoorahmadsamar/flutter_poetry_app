import 'dart:async';
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
  bool _isLoadingMore = false;

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
    if (isLoadMore && _isLoadingMore) return;
    _isLoadingMore = isLoadMore;

    if (!isLoadMore) {
      state = const AsyncValue.loading();
    }

    try {
      UnifiedBookmarksResponse bookmarksResponse;

      _logger.d('Fetching bookmarks with filters: type=${_currentFilters.type}, '
          'lang=${_currentFilters.language}, page=${_currentFilters.page}, '
          'search=${_currentFilters.searchQuery}');

      // Determine which service method to use based on filters
      if (_currentFilters.searchQuery != null &&
          _currentFilters.searchQuery!.isNotEmpty) {
        bookmarksResponse = await _service.searchBookmarks(
          query: _currentFilters.searchQuery!,
          page: _currentFilters.page,
          size: _currentFilters.size,
          type: _currentFilters.type != 'ALL' ? _currentFilters.type : null,
          lang: _currentFilters.language != 'ALL'
              ? _currentFilters.language
              : null,
        );
      } else {
        switch (_currentFilters.type) {
          case 'POEM':
            bookmarksResponse = await _service.getPoemBookmarks(
              page: _currentFilters.page,
              size: _currentFilters.size,
              lang: _currentFilters.language != 'ALL'
                  ? _currentFilters.language
                  : null,
              sortBy: _currentFilters.sortBy,
              sortDir: _currentFilters.sortDir,
            );
            break;
          case 'COUPLET':
            bookmarksResponse = await _service.getCoupletBookmarks(
              page: _currentFilters.page,
              size: _currentFilters.size,
              lang: _currentFilters.language != 'ALL'
                  ? _currentFilters.language
                  : null,
              sortBy: _currentFilters.sortBy,
              sortDir: _currentFilters.sortDir,
            );
            break;
          case 'IMAGE':
            bookmarksResponse = await _service.getImageBookmarks(
              page: _currentFilters.page,
              size: _currentFilters.size,
              lang: _currentFilters.language != 'ALL'
                  ? _currentFilters.language
                  : null,
              sortBy: _currentFilters.sortBy,
              sortDir: _currentFilters.sortDir,
            );
            break;
          case 'ALL':
          default:
            bookmarksResponse = await _service.getRecentBookmarks(
              page: _currentFilters.page,
              size: _currentFilters.size,
              lang: _currentFilters.language != 'ALL'
                  ? _currentFilters.language
                  : null,
            );
        }
      }

      _logger.d('Got ${bookmarksResponse.content.length} bookmarks '
          '(total: ${bookmarksResponse.totalElements}, last: ${bookmarksResponse.last})');

      if (isLoadMore && state.hasValue) {
        final currentData = state.value!;
        final updatedContent = [
          ...currentData.content,
          ...bookmarksResponse.content,
        ];
        state = AsyncValue.data(
          bookmarksResponse.copyWith(content: updatedContent),
        );
      } else {
        state = AsyncValue.data(bookmarksResponse);
      }
    } catch (e, stackTrace) {
      if (!isLoadMore) {
        state = AsyncValue.error(e, stackTrace);
      }
      _logger.e('Error fetching bookmarks', error: e);
    } finally {
      _isLoadingMore = false;
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
    _currentFilters = newFilters.copyWith(page: 0);
    await fetchBookmarks();
  }

  /// Refresh bookmarks
  Future<void> refresh() async {
    _currentFilters = _currentFilters.copyWith(page: 0);
    await fetchBookmarks();
  }

  /// Remove a bookmark locally (optimistic update)
  void removeBookmarkLocally(String bookmarkId) {
    if (state.hasValue) {
      final currentData = state.value!;
      final updatedContent = currentData.content
          .where((b) => b.bookmarkId != bookmarkId)
          .toList();
      state = AsyncValue.data(
        currentData.copyWith(
          content: updatedContent,
          totalElements: currentData.totalElements - 1,
        ),
      );
    }
  }

  /// Re-add a bookmark locally (undo delete)
  void addBookmarkLocally(UnifiedBookmark bookmark, int index) {
    if (state.hasValue) {
      final currentData = state.value!;
      final updatedContent = List<UnifiedBookmark>.from(currentData.content);
      if (index <= updatedContent.length) {
        updatedContent.insert(index, bookmark);
      } else {
        updatedContent.add(bookmark);
      }
      state = AsyncValue.data(
        currentData.copyWith(
          content: updatedContent,
          totalElements: currentData.totalElements + 1,
        ),
      );
    }
  }

  /// Update notes on a bookmark locally
  void updateNotesLocally(String bookmarkId, String? notes) {
    if (state.hasValue) {
      final currentData = state.value!;
      final updatedContent = currentData.content.map((b) {
        if (b.bookmarkId == bookmarkId) {
          return UnifiedBookmark(
            bookmarkId: b.bookmarkId,
            type: b.type,
            contentId: b.contentId,
            languageCode: b.languageCode,
            bookmarkedAt: b.bookmarkedAt,
            notes: notes,
            poetName: b.poetName,
            poetId: b.poetId,
            poetProfileImageUrl: b.poetProfileImageUrl,
            contentSubType: b.contentSubType,
            contentSubTypeUrdu: b.contentSubTypeUrdu,
            poemTitle: b.poemTitle,
            coupletVerse1: b.coupletVerse1,
            coupletVerse2: b.coupletVerse2,
            coupletPoemTitle: b.coupletPoemTitle,
            coupletPoemPublicId: b.coupletPoemPublicId,
            imageUrl: b.imageUrl,
            thumbnailUrl: b.thumbnailUrl,
            templateName: b.templateName,
            likeCount: b.likeCount,
            bookmarkCount: b.bookmarkCount,
            shareCount: b.shareCount,
          );
        }
        return b;
      }).toList();
      state = AsyncValue.data(
        currentData.copyWith(content: updatedContent),
      );
    }
  }

  BookmarkFilters get currentFilters => _currentFilters;
}

// ============= BOOKMARK STATISTICS PROVIDER =============

final bookmarkStatsProvider =
    FutureProvider.autoDispose<BookmarkStats>((ref) async {
  final service = ref.watch(unifiedBookmarkServiceProvider);
  return await service.getBookmarkStats();
});

// ============= BOOKMARK ACTION PROVIDERS =============

/// Provider for removing a bookmark
final removeBookmarkProvider = Provider.autoDispose((ref) {
  final service = ref.watch(unifiedBookmarkServiceProvider);

  return ({
    required String bookmarkId,
    required String type,
  }) async {
    await service.removeBookmark(
      bookmarkId: bookmarkId,
      type: type,
    );
    ref.invalidate(unifiedBookmarksProvider);
    ref.invalidate(bookmarkStatsProvider);
  };
});

/// Provider for updating bookmark notes
final updateBookmarkNotesProvider = Provider.autoDispose((ref) {
  final service = ref.watch(unifiedBookmarkServiceProvider);

  return ({
    required String typePath,
    required String bookmarkId,
    required String? notes,
  }) async {
    await service.updateBookmarkNotes(
      typePath: typePath,
      bookmarkId: bookmarkId,
      notes: notes,
    );
  };
});
