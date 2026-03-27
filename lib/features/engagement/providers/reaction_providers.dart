import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:flutter_poetry_app/core/network/dio_client.dart';
import 'package:flutter_poetry_app/features/engagement/models/reaction_models.dart';
import 'package:flutter_poetry_app/features/engagement/services/reaction_service.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/providers/poem_providers.dart';
import 'package:flutter_poetry_app/features/engagement/providers/couplet_providers.dart';

final Logger _logger = Logger();

// ============= SERVICE PROVIDER =============

final reactionServiceProvider = Provider<ReactionService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ReactionService(dioClient.dio);
});

// ============= REACTION TYPES (CACHED) =============

/// Fetches reaction types once and caches for the session.
/// Not autoDispose — lives for the app lifetime.
final reactionTypesProvider = FutureProvider<List<ReactionType>>((ref) async {
  final service = ref.watch(reactionServiceProvider);
  return service.getReactionTypes();
});

// ============= REACTION ACTION PROVIDER =============

final reactionActionProvider =
    StateNotifierProvider<ReactionActionNotifier, AsyncValue<void>>(
  (ref) => ReactionActionNotifier(ref),
);

class ReactionActionNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  ReactionActionNotifier(this.ref) : super(const AsyncValue.data(null));

  /// React to content. Returns updated reaction state.
  /// [targetType]: "poems", "couplets", "poetry-images", "generated-images"
  Future<ReactionResponse> react({
    required String targetType,
    required String publicId,
    required String reactionType,
  }) async {
    state = const AsyncValue.loading();

    try {
      final service = ref.read(reactionServiceProvider);
      final response = await service.react(
        targetType: targetType,
        publicId: publicId,
        reactionType: reactionType,
      );

      state = const AsyncValue.data(null);
      _logger.i(
        '✅ Reaction: $reactionType on $targetType/$publicId → ${response.message}',
      );

      _invalidateRelatedProviders(targetType, publicId);
      return response;
    } catch (e, stack) {
      _logger.e('❌ Error reacting to $targetType/$publicId: $e');
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Explicitly remove the user's reaction.
  Future<ReactionResponse> removeReaction({
    required String targetType,
    required String publicId,
  }) async {
    state = const AsyncValue.loading();

    try {
      final service = ref.read(reactionServiceProvider);
      final response = await service.removeReaction(
        targetType: targetType,
        publicId: publicId,
      );

      state = const AsyncValue.data(null);
      _logger.i('✅ Reaction removed from $targetType/$publicId');

      _invalidateRelatedProviders(targetType, publicId);
      return response;
    } catch (e, stack) {
      _logger.e('❌ Error removing reaction from $targetType/$publicId: $e');
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  void _invalidateRelatedProviders(String targetType, String publicId) {
    switch (targetType) {
      case 'poems':
        ref.invalidate(poemDetailProvider(publicId));
      case 'couplets':
        ref.invalidate(coupletsProvider);
        ref.invalidate(coupletProvider(publicId));
      // poetry-images and generated-images don't have detail providers yet
    }
  }
}
