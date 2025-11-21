import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/language_model.dart';
import '../network/dio_client.dart';
import '../network/dto/api_response.dart';

/// Service for language-related API operations
class LanguageService {
  final DioClient _dioClient;
  static const String _baseEndpoint = '/api/languages';
  static const String _profileEndpoint = '/api/profile';

  LanguageService(this._dioClient);

  /// Get all active languages
  Future<List<LanguageModel>> getActiveLanguages() async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      '$_baseEndpoint/active',
    );

    final apiResponse = ApiResponse<List<dynamic>>.fromJson(
      response.data!,
      (json) => json as List<dynamic>,
    );

    if (apiResponse.success && apiResponse.data != null) {
      return apiResponse.data!
          .map((json) => LanguageModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    throw Exception(apiResponse.message);
  }

  /// Get language by code
  Future<LanguageModel> getLanguageByCode(String code) async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      '$_baseEndpoint/$code',
    );

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data!,
      (json) => json as Map<String, dynamic>,
    );

    if (apiResponse.success && apiResponse.data != null) {
      return LanguageModel.fromJson(apiResponse.data!);
    }

    throw Exception(apiResponse.message);
  }

  /// Update user's preferred language in profile
  Future<void> updateProfileLanguage(String languageCode) async {
    final response = await _dioClient.put<Map<String, dynamic>>(
      _profileEndpoint,
      data: {
        'preferredLanguage': languageCode,
      },
    );

    final apiResponse = ApiResponse<dynamic>.fromJson(
      response.data!,
      (json) => json,
    );

    if (!apiResponse.success) {
      throw Exception(apiResponse.message);
    }
  }
}

/// Provider for LanguageService
final languageServiceProvider = Provider<LanguageService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return LanguageService(dioClient);
});
