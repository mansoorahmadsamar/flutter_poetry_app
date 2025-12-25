import 'package:dio/dio.dart';
import 'package:flutter_poetry_app/core/network/dto/api_response.dart';
import 'package:flutter_poetry_app/features/image_poetry/models/image_template_model.dart';

class ImageTemplateService {
  final Dio _dio;

  ImageTemplateService(this._dio);

  /// Get all templates with pagination and optional filters
  Future<PaginatedResponse<ImageTemplateModel>> getTemplates({
    String? category,
    bool? isPremium,
    int page = 0,
    int size = 20,
  }) async {
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

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>,
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.message ?? 'Failed to load templates');
    }

    return PaginatedResponse<ImageTemplateModel>.fromJson(
      apiResponse.data!,
      (json) => ImageTemplateModel.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Get a single template by ID
  Future<ImageTemplateModel> getTemplate(String publicId) async {
    final response = await _dio.get('/api/image-templates/$publicId');

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>,
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
      (json) => json as List<dynamic>,
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.message ?? 'Failed to load popular templates');
    }

    return apiResponse.data!
        .map((json) => ImageTemplateModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
