import 'package:dio/dio.dart';
import 'package:flutter_poetry_app/core/network/dto/api_response.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/models/poem_model.dart';

class LikeService {
  final Dio _dio;

  LikeService(this._dio);

  /// Toggle like for a poem (add if not liked, remove if liked)
  /// Returns true if liked, false if removed
  Future<bool> toggleLike(String poemPublicId) async {
    final response = await _dio.post('/api/poems/$poemPublicId/like');

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>,
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.message);
    }

    return apiResponse.data!['liked'] as bool;
  }

  /// Get user's likes with pagination and filters
  Future<PaginatedResponse<PoemModel>> getMyLikes({
    int page = 0,
    int size = 20,
    String? search,
    String? poetryType,
    String? poetId,
    String sortBy = 'createdAt',
    String sortDir = 'desc',
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'size': size,
      'sortBy': sortBy,
      'sortDir': sortDir,
    };

    if (search != null && search.isNotEmpty) {
      queryParams['query'] = search;
    }

    if (poetryType != null && poetryType.isNotEmpty) {
      queryParams['poetryType'] = poetryType;
    }

    if (poetId != null && poetId.isNotEmpty) {
      queryParams['poetId'] = poetId;
    }

    final response = await _dio.get(
      '/api/users/me/likes',
      queryParameters: queryParams,
    );

    // The response structure is { success, message, data: { content, totalElements, ... } }
    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>,
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.message);
    }

    // Extract the paginated data from the response
    return PaginatedResponse<PoemModel>.fromJson(
      apiResponse.data!,
      (json) => PoemModel.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Check if a poem is liked
  Future<bool> isLiked(String poemPublicId) async {
    final response = await _dio.get('/api/poems/$poemPublicId/status');

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>,
    );

    if (!apiResponse.success || apiResponse.data == null) {
      return false;
    }

    return apiResponse.data!['liked'] as bool? ?? false;
  }
}
