import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:flutter_poetry_app/core/network/dio_client.dart';
import 'package:flutter_poetry_app/core/network/dto/api_response.dart';
import 'package:flutter_poetry_app/features/image_poetry/models/generated_image_model.dart';
import 'package:flutter_poetry_app/features/image_poetry/services/image_collection_service.dart';

final Logger _logger = Logger();

// ============= SERVICE PROVIDER =============

final imageCollectionServiceProvider = Provider<ImageCollectionService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ImageCollectionService(dioClient.dio);
});

// ============= IMAGE BOOKMARKS LIST PROVIDER =============

/// Parameters for fetching image bookmarks
class ImageBookmarksParams {
  final int page;
  final String? lang;

  ImageBookmarksParams({
    this.page = 0,
    this.lang,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageBookmarksParams &&
          runtimeType == other.runtimeType &&
          page == other.page &&
          lang == other.lang;

  @override
  int get hashCode => page.hashCode ^ lang.hashCode;
}

/// Get user's bookmarked images with pagination and language filtering
final imageBookmarksProvider = FutureProvider.autoDispose
    .family<PaginatedResponse<GeneratedImageModel>, ImageBookmarksParams>(
  (ref, params) async {
    final service = ref.watch(imageCollectionServiceProvider);

    try {
      final result = await service.getBookmarkedImages(
        lang: params.lang,
        page: params.page,
        size: 20,
      );
      _logger.i('✅ Image bookmarks loaded - Page: ${params.page}, Lang: ${params.lang}');
      return result;
    } catch (e) {
      _logger.e('❌ Error loading image bookmarks: $e');
      rethrow;
    }
  },
);

// ============= IMAGE BOOKMARK ACTION PROVIDERS =============

/// Provider for image bookmark action state
final imageBookmarkActionProvider =
    StateNotifierProvider<ImageBookmarkActionNotifier, AsyncValue<void>>(
  (ref) => ImageBookmarkActionNotifier(ref),
);

class ImageBookmarkActionNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  ImageBookmarkActionNotifier(this.ref) : super(const AsyncValue.data(null));

  /// Toggle bookmark for an image
  /// Returns true if bookmarked, false if unbookmarked
  /// [lang] - Language code when bookmarking (ur, en, hi, etc.) to preserve language context
  Future<bool> toggleBookmark(String imageId, {String lang = 'ur'}) async {
    state = const AsyncValue.loading();

    try {
      final service = ref.read(imageCollectionServiceProvider);
      final isBookmarked = await service.toggleBookmark(imageId, lang: lang);

      state = const AsyncValue.data(null);
      _logger.i('✅ Image bookmark toggled: $imageId - lang: $lang - isBookmarked: $isBookmarked');

      // Invalidate bookmarks list to refresh
      ref.invalidate(imageBookmarksProvider);

      return isBookmarked;
    } catch (e, stack) {
      _logger.e('❌ Error toggling image bookmark: $e');
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Check if an image is bookmarked
  Future<bool> isBookmarked(String imageId) async {
    try {
      final service = ref.read(imageCollectionServiceProvider);
      return await service.isImageBookmarked(imageId);
    } catch (e) {
      _logger.e('❌ Error checking image bookmark status: $e');
      return false;
    }
  }

  /// Toggle like for an image
  /// Returns true if liked, false if unliked
  Future<bool> toggleLike(String imageId) async {
    try {
      final service = ref.read(imageCollectionServiceProvider);
      final isLiked = await service.toggleLike(imageId);
      _logger.i('✅ Image like toggled: $imageId - isLiked: $isLiked');
      return isLiked;
    } catch (e) {
      _logger.e('❌ Error toggling image like: $e');
      rethrow;
    }
  }

  /// Record a share event for an image
  Future<void> recordShare(String imageId) async {
    try {
      final service = ref.read(imageCollectionServiceProvider);
      await service.recordShare(imageId);
      _logger.i('✅ Image share recorded: $imageId');
    } catch (e) {
      _logger.e('❌ Error recording image share: $e');
      // Don't rethrow — share tracking failure shouldn't block the user
    }
  }

  /// Get full engagement status for an image in one call
  Future<Map<String, dynamic>> getImageStatus(String imageId) async {
    try {
      final service = ref.read(imageCollectionServiceProvider);
      return await service.getImageStatus(imageId);
    } catch (e) {
      _logger.e('❌ Error getting image status: $e');
      return {
        'isLiked': false,
        'isBookmarked': false,
        'likeCount': 0,
        'bookmarkCount': 0,
        'shareCount': 0,
      };
    }
  }
}
