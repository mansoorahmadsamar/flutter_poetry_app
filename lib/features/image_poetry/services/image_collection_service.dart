import 'package:dio/dio.dart';
import 'package:flutter_poetry_app/core/network/dto/api_response.dart';
import 'package:flutter_poetry_app/features/image_poetry/models/generated_image_model.dart';
import 'package:flutter_poetry_app/features/image_poetry/models/image_collection_model.dart';

class ImageCollectionService {
  final Dio _dio;

  ImageCollectionService(this._dio);

  /// Save a generated image to a collection
  Future<GeneratedImageModel> saveImage(
    String imageId,
    SaveImageRequest request,
  ) async {
    final response = await _dio.post(
      '/api/poetry-images/$imageId/save',
      data: request.toJson(),
    );

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>,
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.message ?? 'Failed to save image');
    }

    return GeneratedImageModel.fromJson(apiResponse.data!);
  }

  /// Get saved images with pagination and filters
  Future<PaginatedResponse<GeneratedImageModel>> getSavedImages({
    String? collectionName,
    bool? favoritesOnly,
    int page = 0,
    int size = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'size': size,
    };

    if (collectionName != null) {
      queryParams['collectionName'] = collectionName;
    }

    if (favoritesOnly != null) {
      queryParams['favoritesOnly'] = favoritesOnly;
    }

    final response = await _dio.get(
      '/api/users/me/saved-images',
      queryParameters: queryParams,
    );

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>,
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.message ?? 'Failed to load saved images');
    }

    return PaginatedResponse.fromJson(
      apiResponse.data!,
      (json) => GeneratedImageModel.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Get list of collection names
  Future<List<String>> getCollectionNames() async {
    final response = await _dio.get('/api/users/me/collection-names');

    final apiResponse = ApiResponse<List<dynamic>>.fromJson(
      response.data,
      (json) => json as List<dynamic>,
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.message ?? 'Failed to load collection names');
    }

    return apiResponse.data!.cast<String>();
  }

  /// Toggle favorite status of an image
  Future<bool> toggleFavorite(String imageId) async {
    final response = await _dio.post(
      '/api/poetry-images/$imageId/toggle-favorite',
    );

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>,
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.message ?? 'Failed to toggle favorite');
    }

    return apiResponse.data!['isFavorite'] as bool? ?? false;
  }

  /// Remove image from saved collection
  Future<void> removeImage(String imageId) async {
    final response = await _dio.delete(
      '/api/users/me/saved-images/$imageId',
    );

    final apiResponse = ApiResponse<void>.fromJson(
      response.data,
      (json) => null,
    );

    if (!apiResponse.success) {
      throw Exception(apiResponse.message ?? 'Failed to remove image');
    }
  }

  /// Get collection statistics
  Future<CollectionStatsModel> getCollectionStats() async {
    final response = await _dio.get('/api/users/me/collection-stats');

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>,
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.message ?? 'Failed to load collection stats');
    }

    return CollectionStatsModel.fromJson(apiResponse.data!);
  }

  /// Toggle bookmark for an image (NEW - Phase 1 & 2 bookmark system)
  /// [lang] - Language code when bookmarking (ur, en, hi, etc.) to preserve language context
  /// Returns true if bookmarked, false if unbookmarked
  Future<bool> toggleBookmark(String imageId, {String lang = 'ur'}) async {
    final response = await _dio.post(
      '/api/poetry-images/$imageId/bookmark',
      queryParameters: {'lang': lang},
    );

    final apiResponse = ApiResponse<bool>.fromJson(
      response.data,
      (json) => json as bool,
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.message ?? 'Failed to toggle bookmark');
    }

    return apiResponse.data!;
  }

  /// Get bookmarked images with pagination and language filtering (NEW - Phase 1 & 2)
  Future<PaginatedResponse<GeneratedImageModel>> getBookmarkedImages({
    String? lang,
    int page = 0,
    int size = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'size': size,
    };

    if (lang != null) {
      queryParams['lang'] = lang;
    }

    final response = await _dio.get(
      '/api/users/me/image-bookmarks',
      queryParameters: queryParams,
    );

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>,
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.message ?? 'Failed to load bookmarked images');
    }

    return PaginatedResponse.fromJson(
      apiResponse.data!,
      (json) => GeneratedImageModel.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Check if an image is bookmarked (NEW - Phase 1 & 2)
  Future<bool> isImageBookmarked(String imageId) async {
    final response = await _dio.get('/api/poetry-images/$imageId/is-bookmarked');

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>,
    );

    if (!apiResponse.success || apiResponse.data == null) {
      return false;
    }

    return apiResponse.data!['isBookmarked'] as bool? ?? false;
  }
}
