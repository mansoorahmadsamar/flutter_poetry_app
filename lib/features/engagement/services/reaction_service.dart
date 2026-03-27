import 'package:dio/dio.dart';
import 'package:flutter_poetry_app/core/network/dto/api_response.dart';
import 'package:flutter_poetry_app/features/engagement/models/reaction_models.dart';

class ReactionService {
  final Dio _dio;

  ReactionService(this._dio);

  /// Fetch available reaction types (cache this — rarely changes).
  Future<List<ReactionType>> getReactionTypes() async {
    final response = await _dio.get('/api/reactions/types');

    final apiResponse = ApiResponse<List<dynamic>>.fromJson(
      response.data,
      (json) => json as List<dynamic>,
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.message);
    }

    return apiResponse.data!
        .map((e) => ReactionType.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// React to content. Toggle behavior:
  /// - No reaction → adds reaction
  /// - Same reaction → removes reaction
  /// - Different reaction → changes reaction
  ///
  /// [targetType]: "poems", "couplets", "poetry-images", "generated-images"
  Future<ReactionResponse> react({
    required String targetType,
    required String publicId,
    required String reactionType,
  }) async {
    final response = await _dio.post(
      '/api/$targetType/$publicId/react',
      data: {'reactionType': reactionType},
    );

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>,
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.message);
    }

    return ReactionResponse.fromJson(apiResponse.data!);
  }

  /// Explicitly remove the user's reaction from content.
  Future<ReactionResponse> removeReaction({
    required String targetType,
    required String publicId,
  }) async {
    final response = await _dio.delete(
      '/api/$targetType/$publicId/react',
    );

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>,
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.message);
    }

    return ReactionResponse.fromJson(apiResponse.data!);
  }
}
