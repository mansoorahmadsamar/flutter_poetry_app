import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:flutter_poetry_app/core/network/dto/api_response.dart';
import 'package:flutter_poetry_app/features/image_poetry/models/image_template_model.dart';

class ImageTemplateService {
  final Dio _dio;
  final Logger _logger = Logger();

  ImageTemplateService(this._dio);

  /// Get all templates with pagination and optional filters
  Future<PaginatedResponse<ImageTemplateModel>> getTemplates({
    String? category,
    bool? isPremium,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'size': size,
      };

      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }
      if (isPremium != null) {
        queryParams['isPremium'] = isPremium;
      }

      final response = await _dio.get(
        '/api/image-templates',
        queryParameters: queryParams,
      );

      _logger.d('Templates response received: ${response.statusCode}');

      // Handle null or non-map response data
      if (response.data == null) {
        _logger.e('No data received from templates API');
        throw Exception('No data received from server');
      }

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json != null ? json as Map<String, dynamic> : <String, dynamic>{},
      );

      if (!apiResponse.success || apiResponse.data == null) {
        _logger.e('Templates API returned error: ${apiResponse.message}');
        throw Exception(apiResponse.message ?? 'Failed to load templates');
      }

      final result = PaginatedResponse<ImageTemplateModel>.fromJson(
        apiResponse.data!,
        (json) => ImageTemplateModel.fromJson(json as Map<String, dynamic>? ?? {}),
      );

      _logger.i('✅ Templates loaded successfully: ${result.content.length} items');
      return result;
    } on DioException catch (e) {
      _logger.e('❌ Dio error loading templates: ${e.message}');
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication required. Please login again.');
      }
      throw Exception(e.response?.data['message'] ?? e.message ?? 'Failed to load templates');
    } catch (e) {
      _logger.e('❌ Error loading templates: $e');
      throw Exception('Failed to load templates: ${e.toString()}');
    }
  }

  /// Get a single template by ID
  Future<ImageTemplateModel> getTemplate(String publicId) async {
    final response = await _dio.get('/api/image-templates/$publicId');

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (json) => json != null ? json as Map<String, dynamic> : <String, dynamic>{},
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.message ?? 'Failed to load template');
    }

    return ImageTemplateModel.fromJson(apiResponse.data!);
  }

  /// Get popular templates
  Future<List<ImageTemplateModel>> getPopularTemplates({int limit = 10}) async {
    final response = await _dio.get(
      '/api/image-templates/popular',
      queryParameters: {'limit': limit},
    );

    final apiResponse = ApiResponse<List<dynamic>>.fromJson(
      response.data,
      (json) => json != null ? json as List<dynamic> : <dynamic>[],
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.message ?? 'Failed to load popular templates');
    }

    return apiResponse.data!
        .map((json) => ImageTemplateModel.fromJson(json as Map<String, dynamic>? ?? {}))
        .toList();
  }
}
