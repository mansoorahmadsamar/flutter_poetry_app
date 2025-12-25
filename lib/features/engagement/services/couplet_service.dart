import 'package:dio/dio.dart';
import 'package:flutter_poetry_app/core/network/dto/api_response.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/models/couplet_model.dart';

class CoupletService {
  final Dio _dio;

  CoupletService(this._dio);

  /// Get all couplets for a poem
  Future<List<CoupletModel>> getCoupletsByPoem(
    String poemPublicId, {
    String? lang,
  }) async {
    final queryParams = <String, dynamic>{};
    if (lang != null && lang.isNotEmpty) {
      queryParams['lang'] = lang;
    }

    final response = await _dio.get(
      '/api/poems/$poemPublicId/couplets',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    final apiResponse = ApiResponse<List<dynamic>>.fromJson(
      response.data,
      (json) => json as List<dynamic>,
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.message ?? 'Failed to load couplets');
    }

    return apiResponse.data!
        .map((json) => CoupletModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get single couplet detail
  Future<CoupletDetailResponse> getCouplet(String coupletPublicId) async {
    final response = await _dio.get('/api/couplets/$coupletPublicId');

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>,
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.message ?? 'Failed to load couplet');
    }

    return CoupletDetailResponse.fromJson(apiResponse.data!);
  }

  /// Toggle like on couplet
  Future<CoupletDetailResponse> toggleLike(String coupletPublicId) async {
    final response = await _dio.post('/api/couplets/$coupletPublicId/like');

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>,
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.message ?? 'Failed to toggle like');
    }

    return CoupletDetailResponse.fromJson(apiResponse.data!);
  }

  /// Toggle bookmark on couplet
  Future<CoupletDetailResponse> toggleBookmark(String coupletPublicId) async {
    final response = await _dio.post('/api/couplets/$coupletPublicId/bookmark');

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>,
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.message ?? 'Failed to toggle bookmark');
    }

    return CoupletDetailResponse.fromJson(apiResponse.data!);
  }

  /// Get user's bookmarked couplets with pagination
  Future<PaginatedResponse<BookmarkedCoupletResponse>> getMyBookmarkedCouplets({
    int page = 0,
    int size = 20,
    String? search,
    String? poetryType,
    String sortBy = 'createdAt',
    String sortDir = 'desc',
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'size': size,
      'sortBy': sortBy,
      'sortDir': sortDir,
    };

    // Use search endpoint if query exists
    String endpoint = '/api/users/me/couplets/bookmarked';
    if (search != null && search.isNotEmpty && search.length >= 3) {
      endpoint = '/api/users/me/couplets/bookmarked/search';
      queryParams['query'] = search;
    }

    if (poetryType != null && poetryType.isNotEmpty) {
      queryParams['poetryType'] = poetryType;
    }

    final response = await _dio.get(endpoint, queryParameters: queryParams);

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>,
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(
          apiResponse.message ?? 'Failed to load bookmarked couplets');
    }

    return PaginatedResponse<BookmarkedCoupletResponse>.fromJson(
      apiResponse.data!,
      (json) =>
          BookmarkedCoupletResponse.fromJson(json as Map<String, dynamic>),
    );
  }
}
