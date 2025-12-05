import 'package:dio/dio.dart';
import 'package:flutter_poetry_app/core/network/dto/api_response.dart';
import 'package:flutter_poetry_app/features/engagement/models/like_model.dart';

class LikeService {
  final Dio _dio;

  LikeService(this._dio);

  /// Like a poem
  Future<LikeModel> likePoem(String poemPublicId) async {
    final response = await _dio.post(
      '/api/likes',
      data: {
        'contentType': 'POEM',
        'contentId': poemPublicId,
      },
    );

    final apiResponse = ApiResponse<LikeModel>.fromJson(
      response.data,
      (json) => LikeModel.fromJson(json as Map<String, dynamic>),
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.message ?? 'Failed to like poem');
    }

    return apiResponse.data!;
  }

  /// Unlike a poem
  Future<void> unlikePoem(String poemPublicId) async {
    await _dio.delete('/api/likes/$poemPublicId');
  }

  /// Check if a poem is liked
  Future<bool> isLiked(String poemPublicId) async {
    final response = await _dio.get('/api/likes/check/$poemPublicId');

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>,
    );

    return apiResponse.data?['isLiked'] ?? false;
  }
}
