import 'package:dio/dio.dart';
import 'package:flutter_poetry_app/core/network/dto/api_response.dart';
import 'package:flutter_poetry_app/features/image_poetry/models/generated_image_model.dart';

class ImageGenerationService {
  final Dio _dio;

  ImageGenerationService(this._dio);

  /// Generate an image for a couplet
  Future<GeneratedImageModel> generateImage(
    String coupletId,
    GenerateImageRequest request,
  ) async {
    final response = await _dio.post(
      '/api/couplets/$coupletId/generate-image',
      data: request.toJson(),
      options: Options(
        receiveTimeout: const Duration(minutes: 2), // 120 seconds for image generation
      ),
    );

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>,
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.message ?? 'Failed to generate image');
    }

    return GeneratedImageModel.fromJson(apiResponse.data!);
  }

  /// Get all generated images for a couplet
  Future<List<GeneratedImageModel>> getCoupletImages(String coupletId) async {
    final response = await _dio.get('/api/couplets/$coupletId/images');

    final apiResponse = ApiResponse<List<dynamic>>.fromJson(
      response.data,
      (json) => json as List<dynamic>,
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.message ?? 'Failed to load images');
    }

    return apiResponse.data!
        .map((json) => GeneratedImageModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Upload custom background image
  Future<String> uploadCustomBackground(String filePath) async {
    final fileName = filePath.split('/').last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        filePath,
        filename: fileName,
      ),
    });

    final response = await _dio.post(
      '/api/users/me/upload-background',
      data: formData,
      options: Options(
        receiveTimeout: const Duration(minutes: 2), // 120 seconds for file upload
      ),
    );

    final apiResponse = ApiResponse<String>.fromJson(
      response.data,
      (json) => json as String,
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.message ?? 'Failed to upload background');
    }

    return apiResponse.data!; // Returns S3 URL
  }
}
