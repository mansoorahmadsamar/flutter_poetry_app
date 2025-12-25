import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_poetry_app/core/network/dio_client.dart';
import 'package:flutter_poetry_app/core/network/dto/api_response.dart';
import 'package:flutter_poetry_app/features/image_poetry/models/generated_image_model.dart';
import 'package:flutter_poetry_app/features/image_poetry/models/image_collection_model.dart';
import 'package:flutter_poetry_app/features/image_poetry/services/image_collection_service.dart';

/// Service provider
final imageCollectionServiceProvider = Provider<ImageCollectionService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ImageCollectionService(dioClient.dio);
});

/// Parameters for saved images query
class SavedImagesParams {
  final String? collectionName;
  final bool? favoritesOnly;
  final int page;
  final int size;

  const SavedImagesParams({
    this.collectionName,
    this.favoritesOnly,
    this.page = 1,
    this.size = 20,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedImagesParams &&
          runtimeType == other.runtimeType &&
          collectionName == other.collectionName &&
          favoritesOnly == other.favoritesOnly &&
          page == other.page &&
          size == other.size;

  @override
  int get hashCode =>
      collectionName.hashCode ^
      favoritesOnly.hashCode ^
      page.hashCode ^
      size.hashCode;
}

/// Saved images provider with pagination
final savedImagesProvider = FutureProvider.family<
    PaginatedResponse<GeneratedImageModel>, SavedImagesParams>((ref, params) async {
  final service = ref.watch(imageCollectionServiceProvider);
  return service.getSavedImages(
    collectionName: params.collectionName,
    favoritesOnly: params.favoritesOnly,
    page: params.page,
    size: params.size,
  );
});

/// Collection names provider
final collectionNamesProvider = FutureProvider<List<String>>((ref) async {
  final service = ref.watch(imageCollectionServiceProvider);
  return service.getCollectionNames();
});

/// Collection stats provider
final collectionStatsProvider = FutureProvider<CollectionStatsModel>((ref) async {
  final service = ref.watch(imageCollectionServiceProvider);
  return service.getCollectionStats();
});

/// Collection action provider (for mutations)
final collectionActionProvider =
    StateNotifierProvider<CollectionActionNotifier, AsyncValue<void>>(
  (ref) => CollectionActionNotifier(ref),
);

class CollectionActionNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  CollectionActionNotifier(this.ref) : super(const AsyncValue.data(null));

  /// Save an image to a collection
  Future<GeneratedImageModel> saveImage({
    required String imageId,
    String collectionName = 'My Images',
    bool isFavorite = false,
  }) async {
    state = const AsyncValue.loading();

    try {
      final service = ref.read(imageCollectionServiceProvider);
      final request = SaveImageRequest(
        collectionName: collectionName,
        isFavorite: isFavorite,
      );

      final savedImage = await service.saveImage(imageId, request);

      // Invalidate saved images and stats to refresh
      ref.invalidate(collectionStatsProvider);
      ref.invalidate(collectionNamesProvider);

      state = const AsyncValue.data(null);
      return savedImage;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Toggle favorite status
  Future<bool> toggleFavorite(String imageId) async {
    try {
      final service = ref.read(imageCollectionServiceProvider);
      final isFavorite = await service.toggleFavorite(imageId);

      // Invalidate to refresh
      ref.invalidate(collectionStatsProvider);

      return isFavorite;
    } catch (e) {
      rethrow;
    }
  }

  /// Remove image from collection
  Future<void> removeImage(String imageId) async {
    state = const AsyncValue.loading();

    try {
      final service = ref.read(imageCollectionServiceProvider);
      await service.removeImage(imageId);

      // Invalidate to refresh
      ref.invalidate(collectionStatsProvider);
      ref.invalidate(collectionNamesProvider);

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}
