import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:flutter_poetry_app/core/network/dio_client.dart';
import 'package:flutter_poetry_app/core/network/dto/api_response.dart';
import 'package:flutter_poetry_app/core/providers/language_provider.dart';
import '../models/app_content_model.dart';

final Logger _logger = Logger();

/// Fetch all active app content pages for the current language.
/// Used on the profile/settings screen to build the "About" section.
final appContentListProvider =
    FutureProvider.autoDispose<List<AppContentModel>>((ref) async {
  final dioClient = ref.watch(dioClientProvider);
  final lang = ref.watch(selectedLanguageProvider);

  try {
    final response = await dioClient.get<Map<String, dynamic>>(
      '/api/app-content',
      queryParameters: {'lang': lang},
    );

    if (response.statusCode == 200 && response.data != null) {
      final apiResponse = ApiResponse<dynamic>.fromJson(
        response.data!,
        (json) => json,
      );

      if (apiResponse.success && apiResponse.data != null) {
        final List<dynamic> data = apiResponse.data as List<dynamic>;
        _logger.i('✅ App content loaded: ${data.length} items');
        return data
            .map((item) =>
                AppContentModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    }

    return [];
  } catch (e) {
    _logger.e('❌ Error loading app content: $e');
    return [];
  }
});

/// Fetch a single app content page by its contentKey.
/// Used on the detail screen when user taps an item.
final appContentDetailProvider = FutureProvider.autoDispose
    .family<AppContentModel, String>((ref, contentKey) async {
  final dioClient = ref.watch(dioClientProvider);
  final lang = ref.watch(selectedLanguageProvider);

  try {
    final response = await dioClient.get<Map<String, dynamic>>(
      '/api/app-content/$contentKey',
      queryParameters: {'lang': lang},
    );

    if (response.statusCode == 200 && response.data != null) {
      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data!,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        _logger.i('✅ App content detail loaded: $contentKey');
        return AppContentModel.fromJson(apiResponse.data!);
      }
    }

    throw Exception('Content not found for key: $contentKey');
  } catch (e) {
    _logger.e('❌ Error loading app content detail ($contentKey): $e');
    rethrow;
  }
});
