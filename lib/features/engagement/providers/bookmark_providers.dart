import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:flutter_poetry_app/core/network/dio_client.dart';
import 'package:flutter_poetry_app/core/network/dto/api_response.dart';
import '../models/bookmark_model.dart';
import '../services/bookmark_service.dart';

final Logger _logger = Logger();

// ============= SERVICE PROVIDER =============

final bookmarkServiceProvider = Provider<BookmarkService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return BookmarkService(dioClient.dio);
});

// ============= BOOKMARKS LIST PROVIDER =============

/// Parameters for fetching bookmarks
class BookmarksParams {
  final int page;
  final String? search;
  final String? poetryType;
  final String sortBy;

  BookmarksParams({
    this.page = 0,
    this.search,
    this.poetryType,
    this.sortBy = 'NEWEST',
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookmarksParams &&
          runtimeType == other.runtimeType &&
          page == other.page &&
          search == other.search &&
          poetryType == other.poetryType &&
          sortBy == other.sortBy;

  @override
  int get hashCode =>
      page.hashCode ^ search.hashCode ^ poetryType.hashCode ^ sortBy.hashCode;
}

/// Get user's bookmarks with pagination and filters
final bookmarksProvider = FutureProvider.autoDispose
    .family<PaginatedResponse<BookmarkModel>, BookmarksParams>(
  (ref, params) async {
    final service = ref.watch(bookmarkServiceProvider);

    try {
      final result = await service.getMyBookmarks(
        page: params.page,
        size: 20,
        search: params.search,
        poetryType: params.poetryType,
        sortBy: params.sortBy,
      );
      _logger.i('✅ Bookmarks loaded - Page: ${params.page}');
      return result;
    } catch (e) {
      _logger.e('❌ Error loading bookmarks: $e');
      rethrow;
    }
  },
);

// ============= BOOKMARK ACTION PROVIDERS =============

/// Provider for bookmark action state
final bookmarkActionProvider =
    StateNotifierProvider<BookmarkActionNotifier, AsyncValue<void>>(
  (ref) => BookmarkActionNotifier(ref),
);

class BookmarkActionNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  BookmarkActionNotifier(this.ref) : super(const AsyncValue.data(null));

  /// Add a bookmark for a poem
  Future<void> bookmarkPoem(String poemPublicId) async {
    state = const AsyncValue.loading();

    try {
      final service = ref.read(bookmarkServiceProvider);
      await service.bookmarkPoem(poemPublicId);

      state = const AsyncValue.data(null);
      _logger.i('✅ Poem bookmarked: $poemPublicId');

      // Invalidate bookmarks list to refresh
      ref.invalidate(bookmarksProvider);
    } catch (e, stack) {
      _logger.e('❌ Error bookmarking poem: $e');
      state = AsyncValue.error(e, stack);
    }
  }

  /// Remove a bookmark
  Future<void> removeBookmark(String poemPublicId) async {
    state = const AsyncValue.loading();

    try {
      final service = ref.read(bookmarkServiceProvider);
      await service.removeBookmark(poemPublicId);

      state = const AsyncValue.data(null);
      _logger.i('✅ Bookmark removed: $poemPublicId');

      // Invalidate bookmarks list to refresh
      ref.invalidate(bookmarksProvider);
    } catch (e, stack) {
      _logger.e('❌ Error removing bookmark: $e');
      state = AsyncValue.error(e, stack);
    }
  }

  /// Toggle bookmark (add if not bookmarked, remove if bookmarked)
  Future<void> toggleBookmark(String poemPublicId, bool isCurrentlyBookmarked) async {
    if (isCurrentlyBookmarked) {
      await removeBookmark(poemPublicId);
    } else {
      await bookmarkPoem(poemPublicId);
    }
  }
}
