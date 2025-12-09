import 'package:dio/dio.dart';
import 'package:flutter_poetry_app/core/network/dto/api_response.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/models/poem_model.dart';

class BookmarkService {
  final Dio _dio;

  BookmarkService(this._dio);

  /// Toggle bookmark for a poem (add if not bookmarked, remove if bookmarked)
  /// Returns the enriched poem model with updated engagement data
  Future<PoemModel> toggleBookmark(String poemPublicId) async {
    final response = await _dio.post('/api/poems/$poemPublicId/bookmark');

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>,
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.message ?? 'Failed to toggle bookmark');
    }

    return PoemModel.fromJson(apiResponse.data!);
  }

  /// Get user's bookmarks with pagination and filters
  Future<PaginatedResponse<PoemModel>> getMyBookmarks({
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
      '/api/users/me/bookmarks',
      queryParameters: queryParams,
    );

    // The response structure is { success, message, data: { content, totalElements, ... } }
    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>,
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.message ?? 'Failed to load bookmarks');
    }

    // Extract the paginated data from the response
    return PaginatedResponse<PoemModel>.fromJson(
      apiResponse.data!,
      (json) => PoemModel.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Check if a poem is bookmarked
  Future<bool> isBookmarked(String poemPublicId) async {
    final response = await _dio.get('/api/poems/$poemPublicId/status');

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>,
    );

    if (!apiResponse.success || apiResponse.data == null) {
      return false;
    }

    return apiResponse.data!['bookmarked'] as bool? ?? false;
  }
}
