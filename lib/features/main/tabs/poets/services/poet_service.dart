import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:flutter_poetry_app/core/network/dto/api_response.dart';
import '../models/poet_model.dart';
import '../models/poet_profile_model.dart';
import '../models/poet_image_model.dart';
import '../models/poet_book_model.dart';
import '../models/poet_video_model.dart';

class PoetService {
  final Dio _dio;
  final Logger _logger = Logger();

  static const String _baseEndpoint = '/api/poets';

  PoetService(this._dio);

  /// Get all poets with pagination
  /// sortBy options: viewCount, poemCount, followerCount, birthYear, deathYear, createdAt, updatedAt
  /// sortDir options: asc, desc
  Future<PaginatedResponse<PoetModel>> getAllPoets({
    int page = 0,
    int size = 10,
    String lang = 'ur',
    String sortBy = 'viewCount',
    String sortDir = 'desc',
  }) async {
    try {
      final response = await _dio.get(
        _baseEndpoint,
        queryParameters: {
          'page': page,
          'size': size,
          'lang': lang,
          'sortBy': sortBy,
          'sortDir': sortDir,
        },
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        _logger.i('✅ Poets fetched successfully - Page: $page');
        return PaginatedResponse<PoetModel>.fromJson(
          apiResponse.data!,
          (json) => PoetModel.fromJson(json as Map<String, dynamic>? ?? {}),
        );
      } else {
        throw Exception(apiResponse.message);
      }
    } on DioException catch (e) {
      _logger.e('❌ Error fetching poets: ${e.message}');
      rethrow;
    }
  }

  /// Get featured poets
  Future<PaginatedResponse<PoetModel>> getFeaturedPoets({
    int page = 0,
    int size = 10,
    String lang = 'ur',
  }) async {
    try {
      final response = await _dio.get(
        '$_baseEndpoint/featured',
        queryParameters: {
          'page': page,
          'size': size,
          'lang': lang,
        },
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        _logger.i('✅ Featured poets fetched successfully');
        return PaginatedResponse<PoetModel>.fromJson(
          apiResponse.data!,
          (json) => PoetModel.fromJson(json as Map<String, dynamic>? ?? {}),
        );
      } else {
        throw Exception(apiResponse.message ?? 'Failed to fetch featured poets');
      }
    } on DioException catch (e) {
      _logger.e('❌ Error fetching featured poets: ${e.message}');
      rethrow;
    }
  }

  /// Get trending poets
  Future<PaginatedResponse<PoetModel>> getTrendingPoets({
    int page = 0,
    int size = 10,
    String lang = 'ur',
  }) async {
    try {
      final response = await _dio.get(
        '$_baseEndpoint/trending',
        queryParameters: {
          'page': page,
          'size': size,
          'lang': lang,
        },
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        _logger.i('✅ Trending poets fetched successfully');
        return PaginatedResponse<PoetModel>.fromJson(
          apiResponse.data!,
          (json) => PoetModel.fromJson(json as Map<String, dynamic>? ?? {}),
        );
      } else {
        throw Exception(apiResponse.message ?? 'Failed to fetch trending poets');
      }
    } on DioException catch (e) {
      _logger.e('❌ Error fetching trending poets: ${e.message}');
      rethrow;
    }
  }

  /// Get poets by gender
  Future<PaginatedResponse<PoetModel>> getPoetsByGender({
    required String gender,
    int page = 0,
    int size = 10,
    String lang = 'ur',
  }) async {
    try {
      final response = await _dio.get(
        '$_baseEndpoint/gender/$gender',
        queryParameters: {
          'page': page,
          'size': size,
          'lang': lang,
        },
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        _logger.i('✅ Poets by gender fetched successfully - Gender: $gender');
        return PaginatedResponse<PoetModel>.fromJson(
          apiResponse.data!,
          (json) => PoetModel.fromJson(json as Map<String, dynamic>? ?? {}),
        );
      } else {
        throw Exception(apiResponse.message ?? 'Failed to fetch poets by gender');
      }
    } on DioException catch (e) {
      _logger.e('❌ Error fetching poets by gender: ${e.message}');
      rethrow;
    }
  }

  /// Get poets by era
  Future<PaginatedResponse<PoetModel>> getPoetsByEra({
    required String era,
    int page = 0,
    int size = 10,
    String lang = 'ur',
  }) async {
    try {
      final response = await _dio.get(
        '$_baseEndpoint/era/$era',
        queryParameters: {
          'page': page,
          'size': size,
          'lang': lang,
        },
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        _logger.i('✅ Poets by era fetched successfully - Era: $era');
        return PaginatedResponse<PoetModel>.fromJson(
          apiResponse.data!,
          (json) => PoetModel.fromJson(json as Map<String, dynamic>? ?? {}),
        );
      } else {
        throw Exception(apiResponse.message ?? 'Failed to fetch poets by era');
      }
    } on DioException catch (e) {
      _logger.e('❌ Error fetching poets by era: ${e.message}');
      rethrow;
    }
  }

  /// Get poets by tag
  Future<PaginatedResponse<PoetModel>> getPoetsByTag({
    required String tagSlug,
    int page = 0,
    int size = 10,
    String lang = 'ur',
  }) async {
    try {
      final response = await _dio.get(
        '$_baseEndpoint/tags/$tagSlug',
        queryParameters: {
          'page': page,
          'size': size,
          'lang': lang,
        },
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        _logger.i('✅ Poets by tag fetched successfully - Tag: $tagSlug');
        return PaginatedResponse<PoetModel>.fromJson(
          apiResponse.data!,
          (json) => PoetModel.fromJson(json as Map<String, dynamic>? ?? {}),
        );
      } else {
        throw Exception(apiResponse.message ?? 'Failed to fetch poets by tag');
      }
    } on DioException catch (e) {
      _logger.e('❌ Error fetching poets by tag: ${e.message}');
      rethrow;
    }
  }

  /// Search poets
  Future<PaginatedResponse<PoetModel>> searchPoets({
    required String query,
    String lang = 'ur',
    int page = 0,
    int size = 10,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseEndpoint/search',
        queryParameters: {
          'query': query,
          'lang': lang,
          'page': page,
          'size': size,
        },
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        _logger.i('✅ Poet search completed - Query: $query');
        return PaginatedResponse<PoetModel>.fromJson(
          apiResponse.data!,
          (json) => PoetModel.fromJson(json as Map<String, dynamic>? ?? {}),
        );
      } else {
        throw Exception(apiResponse.message ?? 'Failed to search poets');
      }
    } on DioException catch (e) {
      _logger.e('❌ Error searching poets: ${e.message}');
      rethrow;
    }
  }

  /// Get poets by poem count (top poets)
  Future<PaginatedResponse<PoetModel>> getTopPoetsByPoemCount({
    int page = 0,
    int size = 10,
    String lang = 'ur',
  }) async {
    try {
      final response = await _dio.get(
        '$_baseEndpoint/top/by-poems',
        queryParameters: {
          'page': page,
          'size': size,
          'lang': lang,
        },
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        _logger.i('✅ Top poets by poem count fetched successfully');
        return PaginatedResponse<PoetModel>.fromJson(
          apiResponse.data!,
          (json) => PoetModel.fromJson(json as Map<String, dynamic>? ?? {}),
        );
      } else {
        throw Exception(apiResponse.message ?? 'Failed to fetch top poets');
      }
    } on DioException catch (e) {
      _logger.e('❌ Error fetching top poets by poem count: ${e.message}');
      rethrow;
    }
  }

  /// Get poets by views (most popular)
  Future<PaginatedResponse<PoetModel>> getTopPoetsByViews({
    int page = 0,
    int size = 10,
    String lang = 'ur',
  }) async {
    try {
      final response = await _dio.get(
        '$_baseEndpoint/top/by-views',
        queryParameters: {
          'page': page,
          'size': size,
          'lang': lang,
        },
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        _logger.i('✅ Top poets by views fetched successfully');
        return PaginatedResponse<PoetModel>.fromJson(
          apiResponse.data!,
          (json) => PoetModel.fromJson(json as Map<String, dynamic>? ?? {}),
        );
      } else {
        throw Exception(apiResponse.message ?? 'Failed to fetch top poets');
      }
    } on DioException catch (e) {
      _logger.e('❌ Error fetching top poets by views: ${e.message}');
      rethrow;
    }
  }

  /// Get complete poet profile
  Future<PoetProfileModel> getPoetProfile({
    required String publicId,
    String lang = 'ur',
  }) async {
    try {
      final response = await _dio.get(
        '$_baseEndpoint/$publicId/profile',
        queryParameters: {
          'lang': lang,
        },
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        _logger.i('✅ Poet profile fetched successfully - ID: $publicId');
        return PoetProfileModel.fromJson(apiResponse.data!);
      } else {
        throw Exception(apiResponse.message ?? 'Failed to fetch poet profile');
      }
    } on DioException catch (e) {
      _logger.e('❌ Error fetching poet profile: ${e.message}');
      rethrow;
    }
  }

  /// Get poet gallery images
  Future<List<PoetImageModel>> getPoetGallery(String publicId) async {
    try {
      final response = await _dio.get('$_baseEndpoint/$publicId/gallery');

      final apiResponse = ApiResponse<dynamic>.fromJson(
        response.data,
        (json) => json,
      );

      if (apiResponse.success && apiResponse.data != null) {
        final List<dynamic> data = apiResponse.data as List<dynamic>;
        _logger.i('✅ Poet gallery fetched successfully - ID: $publicId');
        return data
            .map((item) => PoetImageModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(apiResponse.message);
      }
    } on DioException catch (e) {
      _logger.e('❌ Error fetching poet gallery: ${e.message}');
      rethrow;
    }
  }

  /// Get poet books
  Future<List<PoetBookModel>> getPoetBooks({
    required String publicId,
    String lang = 'ur',
  }) async {
    try {
      final response = await _dio.get(
        '$_baseEndpoint/$publicId/books',
        queryParameters: {
          'lang': lang,
        },
      );

      final apiResponse = ApiResponse<dynamic>.fromJson(
        response.data,
        (json) => json,
      );

      if (apiResponse.success && apiResponse.data != null) {
        final List<dynamic> data = apiResponse.data as List<dynamic>;
        _logger.i('✅ Poet books fetched successfully - ID: $publicId');
        return data
            .map((item) => PoetBookModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(apiResponse.message);
      }
    } on DioException catch (e) {
      _logger.e('❌ Error fetching poet books: ${e.message}');
      rethrow;
    }
  }

  /// Get poet videos
  Future<List<PoetVideoModel>> getPoetVideos(String publicId) async {
    try {
      final response = await _dio.get('$_baseEndpoint/$publicId/videos');

      final apiResponse = ApiResponse<dynamic>.fromJson(
        response.data,
        (json) => json,
      );

      if (apiResponse.success && apiResponse.data != null) {
        final List<dynamic> data = apiResponse.data as List<dynamic>;
        _logger.i('✅ Poet videos fetched successfully - ID: $publicId');
        return data
            .map((item) => PoetVideoModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(apiResponse.message);
      }
    } on DioException catch (e) {
      _logger.e('❌ Error fetching poet videos: ${e.message}');
      rethrow;
    }
  }
}
