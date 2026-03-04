import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:flutter_poetry_app/core/network/dto/api_response.dart';
import 'package:flutter_poetry_app/features/main/tabs/bookmarks/models/unified_bookmark_model.dart';

final Logger _logger = Logger();

class UnifiedBookmarkService {
  final Dio _dio;

  UnifiedBookmarkService(this._dio);

  /// Get recent bookmarks (mixed feed, all types)
  Future<UnifiedBookmarksResponse> getRecentBookmarks({
    int page = 0,
    int size = 20,
    String? lang,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'size': size,
    };

    if (lang != null && lang != 'ALL') {
      queryParams['lang'] = lang;
    }

    _logger.d('Fetching bookmarks: /api/bookmarks/recent params: $queryParams');

    final response = await _dio.get(
      '/api/bookmarks/recent',
      queryParameters: queryParams,
    );

    return _parseBookmarksResponse(response);
  }

  /// Get poem bookmarks with sortBy support
  Future<UnifiedBookmarksResponse> getPoemBookmarks({
    int page = 0,
    int size = 20,
    String? lang,
    String sortBy = 'bookmarkedAt',
    String sortDir = 'desc',
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'size': size,
      'sortBy': sortBy,
      'sortDir': sortDir,
    };

    if (lang != null && lang != 'ALL') {
      queryParams['lang'] = lang;
    }

    final response = await _dio.get(
      '/api/bookmarks/poems',
      queryParameters: queryParams,
    );

    return _parseBookmarksResponse(response);
  }

  /// Get couplet bookmarks with sortBy support
  Future<UnifiedBookmarksResponse> getCoupletBookmarks({
    int page = 0,
    int size = 20,
    String? lang,
    String sortBy = 'bookmarkedAt',
    String sortDir = 'desc',
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'size': size,
      'sortBy': sortBy,
      'sortDir': sortDir,
    };

    if (lang != null && lang != 'ALL') {
      queryParams['lang'] = lang;
    }

    final response = await _dio.get(
      '/api/bookmarks/couplets',
      queryParameters: queryParams,
    );

    return _parseBookmarksResponse(response);
  }

  /// Get image poetry bookmarks with sortBy support
  Future<UnifiedBookmarksResponse> getImageBookmarks({
    int page = 0,
    int size = 20,
    String? lang,
    String sortBy = 'bookmarkedAt',
    String sortDir = 'desc',
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'size': size,
      'sortBy': sortBy,
      'sortDir': sortDir,
    };

    if (lang != null && lang != 'ALL') {
      queryParams['lang'] = lang;
    }

    final response = await _dio.get(
      '/api/bookmarks/images',
      queryParameters: queryParams,
    );

    return _parseBookmarksResponse(response);
  }

  /// Search bookmarks across all types
  Future<UnifiedBookmarksResponse> searchBookmarks({
    required String query,
    int page = 0,
    int size = 20,
    String? type,
    String? lang,
  }) async {
    final queryParams = <String, dynamic>{
      'query': query,
      'page': page,
      'size': size,
    };

    if (type != null && type != 'ALL') {
      queryParams['type'] = type;
    }

    if (lang != null && lang != 'ALL') {
      queryParams['lang'] = lang;
    }

    final response = await _dio.get(
      '/api/bookmarks/search',
      queryParameters: queryParams,
    );

    return _parseBookmarksResponse(response);
  }

  /// Get bookmark statistics with language breakdown
  Future<BookmarkStats> getBookmarkStats() async {
    final response = await _dio.get('/api/bookmarks/stats');

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>,
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.message);
    }

    return BookmarkStats.fromJson(apiResponse.data!);
  }

  /// Update bookmark notes (add, update, or clear)
  ///
  /// [typePath] must be 'poems', 'couplets', or 'images'
  /// [notes] set to null or empty string to clear
  Future<void> updateBookmarkNotes({
    required String typePath,
    required String bookmarkId,
    required String? notes,
  }) async {
    final response = await _dio.patch(
      '/api/bookmarks/$typePath/$bookmarkId/notes',
      data: {'notes': notes},
    );

    final apiResponse = ApiResponse<Map<String, dynamic>?>.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>?,
    );

    if (!apiResponse.success) {
      throw Exception(apiResponse.message);
    }
  }

  /// Remove a bookmark
  Future<void> removeBookmark({
    required String bookmarkId,
    required String type,
  }) async {
    String endpoint;
    switch (type.toUpperCase()) {
      case 'POEM':
        endpoint = '/api/bookmarks/poems/$bookmarkId';
        break;
      case 'COUPLET':
        endpoint = '/api/bookmarks/couplets/$bookmarkId';
        break;
      case 'IMAGE':
        endpoint = '/api/bookmarks/images/$bookmarkId';
        break;
      default:
        throw Exception('Invalid bookmark type: $type');
    }

    final response = await _dio.delete(endpoint);

    final apiResponse = ApiResponse<Map<String, dynamic>?>.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>?,
    );

    if (!apiResponse.success) {
      throw Exception(apiResponse.message);
    }
  }

  /// Parse bookmarks response
  UnifiedBookmarksResponse _parseBookmarksResponse(Response response) {
    try {
      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.success || apiResponse.data == null) {
        throw Exception(apiResponse.message);
      }

      final bookmarksResponse =
          UnifiedBookmarksResponse.fromJson(apiResponse.data!);
      _logger.d('Parsed ${bookmarksResponse.content.length} bookmarks');

      return bookmarksResponse;
    } catch (e, stackTrace) {
      _logger.e('Error parsing bookmarks response',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
