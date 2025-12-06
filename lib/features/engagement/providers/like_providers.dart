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

  /// Toggle like (add if not liked, remove if liked)
  /// Returns true if liked, false if removed
  Future<bool> toggleLike(String poemPublicId) async {
    state = const AsyncValue.loading();

    try {
      final service = ref.read(likeServiceProvider);
      final isLiked = await service.toggleLike(poemPublicId);

      state = const AsyncValue.data(null);
      _logger.i('✅ Like toggled: $poemPublicId - isLiked: $isLiked');

      return isLiked;
    } catch (e, stack) {
      _logger.e('❌ Error toggling like: $e');
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}
