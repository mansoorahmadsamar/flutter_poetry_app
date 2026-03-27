import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/network/dto/api_response.dart';
import '../../main/tabs/poets/models/couplet_model.dart';
import '../../main/tabs/poets/models/poet_model.dart';
import '../../main/tabs/poets/models/poem_model.dart';
import '../models/hashtag_model.dart';

final hashtagServiceProvider = Provider<HashtagService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return HashtagService(dioClient.dio);
});

class HashtagService {
  final Dio _dio;

  HashtagService(this._dio);

  /// Get trending hashtags
  Future<List<HashtagDto>> getTrending({int limit = 20}) async {
    final response = await _dio.get(
      '/api/hashtags/trending',
      queryParameters: {'limit': limit},
    );

    final apiResponse = ApiResponse<List<dynamic>>.fromJson(
      response.data,
      (json) => json as List<dynamic>,
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.message);
    }

    return apiResponse.data!
        .map((json) => HashtagDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get metadata for a single hashtag
  Future<HashtagDto> getHashtagMeta(String slug) async {
    final response = await _dio.get('/api/hashtags/$slug');

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>,
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.message);
    }

    return HashtagDto.fromJson(apiResponse.data!);
  }

  /// Get poems by hashtag (paginated)
  Future<PaginatedResponse<PoemModel>> getPoemsByHashtag(
    String slug, {
    String lang = 'ur',
    int page = 0,
    int size = 10,
  }) async {
    final response = await _dio.get(
      '/api/hashtags/$slug/poems',
      queryParameters: {'lang': lang, 'page': page, 'size': size},
    );

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>,
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.message);
    }

    return PaginatedResponse<PoemModel>.fromJson(
      apiResponse.data!,
      (json) => PoemModel.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Get couplets by hashtag (paginated)
  Future<PaginatedResponse<CoupletDetailResponse>> getCoupletsByHashtag(
    String slug, {
    String lang = 'ur',
    int page = 0,
    int size = 10,
  }) async {
    final response = await _dio.get(
      '/api/hashtags/$slug/couplets',
      queryParameters: {'lang': lang, 'page': page, 'size': size},
    );

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>,
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.message);
    }

    return PaginatedResponse<CoupletDetailResponse>.fromJson(
      apiResponse.data!,
      (json) => CoupletDetailResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Get images by hashtag (paginated)
  Future<PaginatedResponse<Map<String, dynamic>>> getImagesByHashtag(
    String slug, {
    int page = 0,
    int size = 20,
  }) async {
    final response = await _dio.get(
      '/api/hashtags/$slug/images',
      queryParameters: {'page': page, 'size': size},
    );

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>,
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.message);
    }

    return PaginatedResponse<Map<String, dynamic>>.fromJson(
      apiResponse.data!,
      (json) => json as Map<String, dynamic>,
    );
  }

  /// Get poets by hashtag (paginated)
  Future<PaginatedResponse<PoetModel>> getPoetsByHashtag(
    String slug, {
    String lang = 'ur',
    int page = 0,
    int size = 20,
  }) async {
    final response = await _dio.get(
      '/api/hashtags/$slug/poets',
      queryParameters: {'lang': lang, 'page': page, 'size': size},
    );

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>,
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.message);
    }

    return PaginatedResponse<PoetModel>.fromJson(
      apiResponse.data!,
      (json) => PoetModel.fromJson(json as Map<String, dynamic>),
    );
  }
}
