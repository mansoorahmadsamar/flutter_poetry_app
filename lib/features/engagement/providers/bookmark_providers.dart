import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:flutter_poetry_app/core/network/dio_client.dart';
import 'package:flutter_poetry_app/core/network/dto/api_response.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/models/poem_model.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/providers/poem_providers.dart';
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

/// Convert UI sort option to backend field name and direction
String _mapSortByToField(String sortBy) {
  switch (sortBy) {
    case 'NEWEST':
      return 'createdAt';
    case 'OLDEST':
      return 'createdAt';
    default:
      return 'createdAt';
  }
}

String _mapSortByToDirection(String sortBy) {
  switch (sortBy) {
    case 'NEWEST':
      return 'desc';
    case 'OLDEST':
      return 'asc';
    default:
      return 'desc';
  }
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
        sortBy: _mapSortByToField(params.sortBy),
        sortDir: _mapSortByToDirection(params.sortBy),
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
  /// Returns the enriched poem model with updated engagement data
  /// [lang] - Language code when bookmarking (ur, en, hi, etc.) to preserve language context
  Future<PoemModel> toggleBookmark(String poemPublicId, {String lang = 'ur'}) async {
    state = const AsyncValue.loading();

    try {
      final service = ref.read(bookmarkServiceProvider);
      final enrichedPoem = await service.toggleBookmark(poemPublicId, lang: lang);

      state = const AsyncValue.data(null);
      _logger.i('✅ Bookmark toggled: $poemPublicId - lang: $lang - isBookmarked: ${enrichedPoem.isBookmarkedByCurrentUser}');

      // Invalidate bookmarks list to refresh
      ref.invalidate(bookmarksProvider);

      // Invalidate poem detail provider to refresh with server data
      ref.invalidate(poemDetailProvider(poemPublicId));

      return enrichedPoem;
    } catch (e, stack) {
      _logger.e('❌ Error toggling bookmark: $e');
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}
