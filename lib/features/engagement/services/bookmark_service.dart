import 'package:dio/dio.dart';
import 'package:flutter_poetry_app/core/network/dto/api_response.dart';
import 'package:flutter_poetry_app/features/engagement/models/bookmark_model.dart';

class BookmarkService {
  final Dio _dio;

  BookmarkService(this._dio);

  /// Add a bookmark for a poem
  Future<BookmarkModel> bookmarkPoem(String poemPublicId) async {
    final response = await _dio.post(
      '/api/bookmarks',
      data: {
        'contentType': 'POEM',
        'contentId': poemPublicId,
      },
    );

    final apiResponse = ApiResponse<BookmarkModel>.fromJson(
      response.data,
      (json) => BookmarkModel.fromJson(json as Map<String, dynamic>),
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.message ?? 'Failed to bookmark poem');
    }

    return apiResponse.data!;
  }

  /// Remove a bookmark
  Future<void> removeBookmark(String poemPublicId) async {
    final response = await _dio.delete('/api/bookmarks/$poemPublicId');

    final apiResponse = ApiResponse<void>.fromJson(
      response.data,
      (json) => null,
    );

    if (!apiResponse.success) {
      throw Exception(apiResponse.message ?? 'Failed to remove bookmark');
    }
  }

  /// Get user's bookmarks with pagination and filters
  Future<PaginatedResponse<BookmarkModel>> getMyBookmarks({
    int page = 0,
    int size = 20,
    String? search,
    String? poetryType,
    String sortBy = 'NEWEST',
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'size': size,
      'sortBy': sortBy,
    };

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    if (poetryType != null && poetryType.isNotEmpty) {
      queryParams['poetryType'] = poetryType;
    }

    final response = await _dio.get(
      '/api/bookmarks/my',
      queryParameters: queryParams,
    );

    return PaginatedResponse<BookmarkModel>.fromJson(
      response.data,
      (json) => BookmarkModel.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Check if a poem is bookmarked
  Future<bool> isBookmarked(String poemPublicId) async {
    final response = await _dio.get('/api/bookmarks/check/$poemPublicId');

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>,
    );

    return apiResponse.data?['isBookmarked'] ?? false;
  }
}
