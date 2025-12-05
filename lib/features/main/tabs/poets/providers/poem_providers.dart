import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:flutter_poetry_app/core/network/dto/api_response.dart';
import '../models/poem_model.dart';
import 'poet_providers.dart';

final Logger _logger = Logger();

// ============= PAGINATION STATE =============

/// Track loaded pages per poetry type for a specific poet
final poemPagesProvider = StateProvider.family<Map<String, int>, String>(
  (ref, poetPublicId) => {},
);

/// Track if more poems available per poetry type
final poemHasMoreProvider = StateProvider.family<Map<String, bool>, String>(
  (ref, poetPublicId) => {},
);

// ============= POEM PROVIDERS =============

/// Get poems by poet with optional poetry type filtering
final poetPoemsProvider = FutureProvider.autoDispose.family<
    PaginatedResponse<PoemModel>,
    ({String poetPublicId, String? poetryType, int page})>(
  (ref, params) async {
    final service = ref.watch(poetServiceProvider);
    final language = ref.watch(selectedLanguageProvider);

    try {
      final result = await service.getPoemsByPoet(
        poetPublicId: params.poetPublicId,
        poetryType: params.poetryType,
        page: params.page,
        size: 20,
        lang: language,
      );
      _logger.i('✅ Poems loaded - Page: ${params.page}, Type: ${params.poetryType}, Lang: $language');
      return result;
    } catch (e) {
      _logger.e('❌ Error loading poems: $e');
      rethrow;
    }
  },
);

/// Get single poem detail
final poemDetailProvider = FutureProvider.autoDispose.family<
    PoemModel,
    String>(
  (ref, publicId) async {
    final service = ref.watch(poetServiceProvider);
    final language = ref.watch(selectedLanguageProvider);

    try {
      final result = await service.getPoemById(publicId, lang: language);
      _logger.i('✅ Poem detail loaded: $publicId, Lang: $language');
      return result;
    } catch (e) {
      _logger.e('❌ Error loading poem detail: $e');
      rethrow;
    }
  },
);
