import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_poetry_app/core/network/dio_client.dart';
import 'package:flutter_poetry_app/features/image_poetry/models/generated_image_model.dart';
import 'package:flutter_poetry_app/features/image_poetry/services/image_generation_service.dart';

// Service provider
final imageGenerationServiceProvider = Provider<ImageGenerationService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ImageGenerationService(dioClient.dio);
});

// Couplet images provider
final coupletImagesProvider =
    FutureProvider.family<List<GeneratedImageModel>, String>(
  (ref, coupletId) async {
    final service = ref.watch(imageGenerationServiceProvider);
    return service.getCoupletImages(coupletId);
  },
);

// StateNotifier for generation actions
final imageGenerationActionProvider = StateNotifierProvider<
    ImageGenerationNotifier, AsyncValue<GeneratedImageModel?>>(
  (ref) => ImageGenerationNotifier(ref),
);

class ImageGenerationNotifier
    extends StateNotifier<AsyncValue<GeneratedImageModel?>> {
  final Ref ref;

  ImageGenerationNotifier(this.ref) : super(const AsyncValue.data(null));

  /// Generate image with system template
  Future<GeneratedImageModel> generateWithTemplate({
    required String coupletId,
    required String templateId,
    String languageCode = 'ur',
    bool includePoetImage = true,
    bool includeWatermark = true,
  }) async {
    state = const AsyncValue.loading();

    try {
      final service = ref.read(imageGenerationServiceProvider);
      final request = GenerateImageRequest(
        generationType: 'SYSTEM',
        templateId: templateId,
        languageCode: languageCode,
        includePoetImage: includePoetImage,
        includeWatermark: includeWatermark,
      );

      final generatedImage = await service.generateImage(coupletId, request);
      state = AsyncValue.data(generatedImage);

      // Invalidate to refresh couplet images
      ref.invalidate(coupletImagesProvider(coupletId));

      return generatedImage;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Generate image with custom background
  Future<GeneratedImageModel> generateWithCustomBackground({
    required String coupletId,
    required String customBackgroundUrl,
    String languageCode = 'ur',
    bool includePoetImage = true,
    bool includeWatermark = true,
    String? customTextColor,
  }) async {
    state = const AsyncValue.loading();

    try {
      final service = ref.read(imageGenerationServiceProvider);
      final request = GenerateImageRequest(
        generationType: 'CUSTOM',
        customBackgroundUrl: customBackgroundUrl,
        languageCode: languageCode,
        includePoetImage: includePoetImage,
        includeWatermark: includeWatermark,
        customTextColor: customTextColor,
      );

      final generatedImage = await service.generateImage(coupletId, request);
      state = AsyncValue.data(generatedImage);

      ref.invalidate(coupletImagesProvider(coupletId));

      return generatedImage;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Upload custom background
  Future<String> uploadBackground(String filePath) async {
    final service = ref.read(imageGenerationServiceProvider);
    return service.uploadCustomBackground(filePath);
  }

  /// Reset state
  void reset() {
    state = const AsyncValue.data(null);
  }
}
