import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:flutter_poetry_app/core/network/dio_client.dart';
import 'package:flutter_poetry_app/core/network/dto/api_response.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/models/poem_model.dart';
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
    .family<PaginatedResponse<PoemModel>, BookmarksParams>(
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

  /// Toggle bookmark (add if not bookmarked, remove if bookmarked)
  /// Returns true if bookmarked, false if removed
  Future<bool> toggleBookmark(String poemPublicId) async {
    state = const AsyncValue.loading();

    try {
      final service = ref.read(bookmarkServiceProvider);
      final isBookmarked = await service.toggleBookmark(poemPublicId);

      state = const AsyncValue.data(null);
      _logger.i('✅ Bookmark toggled: $poemPublicId - isBookmarked: $isBookmarked');

      // Invalidate bookmarks list to refresh
      ref.invalidate(bookmarksProvider);

      return isBookmarked;
    } catch (e, stack) {
      _logger.e('❌ Error toggling bookmark: $e');
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}
