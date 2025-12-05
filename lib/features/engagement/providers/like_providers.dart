import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:flutter_poetry_app/core/network/dio_client.dart';
import '../services/like_service.dart';

final Logger _logger = Logger();

// ============= SERVICE PROVIDER =============

final likeServiceProvider = Provider<LikeService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return LikeService(dioClient.dio);
});

// ============= LIKE ACTION PROVIDERS =============

/// Provider for like action state
final likeActionProvider =
    StateNotifierProvider<LikeActionNotifier, AsyncValue<void>>(
  (ref) => LikeActionNotifier(ref),
);

class LikeActionNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  LikeActionNotifier(this.ref) : super(const AsyncValue.data(null));

  /// Like a poem
  Future<void> likePoem(String poemPublicId) async {
    state = const AsyncValue.loading();

    try {
      final service = ref.read(likeServiceProvider);
      await service.likePoem(poemPublicId);

      state = const AsyncValue.data(null);
      _logger.i('✅ Poem liked: $poemPublicId');
    } catch (e, stack) {
      _logger.e('❌ Error liking poem: $e');
      state = AsyncValue.error(e, stack);
    }
  }

  /// Unlike a poem
  Future<void> unlikePoem(String poemPublicId) async {
    state = const AsyncValue.loading();

    try {
      final service = ref.read(likeServiceProvider);
      await service.unlikePoem(poemPublicId);

      state = const AsyncValue.data(null);
      _logger.i('✅ Poem unliked: $poemPublicId');
    } catch (e, stack) {
      _logger.e('❌ Error unliking poem: $e');
      state = AsyncValue.error(e, stack);
    }
  }

  /// Toggle like (add if not liked, remove if liked)
  Future<void> toggleLike(String poemPublicId, bool isCurrentlyLiked) async {
    if (isCurrentlyLiked) {
      await unlikePoem(poemPublicId);
    } else {
      await likePoem(poemPublicId);
    }
  }
}
