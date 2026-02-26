import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'poet_providers.dart';

final Logger _logger = Logger();

/// Check if the current user is following a specific poet.
/// Returns true/false. Family provider keyed by poet publicId.
final isFollowingProvider =
    FutureProvider.autoDispose.family<bool, String>((ref, publicId) async {
  final service = ref.watch(poetServiceProvider);

  try {
    final result = await service.isFollowingPoet(publicId: publicId);
    return result.isFollowing;
  } catch (e) {
    _logger.e('❌ Error checking follow status for $publicId: $e');
    return false;
  }
});

/// Manages follow/unfollow toggle with optimistic updates.
///
/// State: `AsyncValue<bool>` where the bool is `isFollowing`.
/// On tap → immediately flips state, calls API in background, reverts on error.
class FollowToggleNotifier extends StateNotifier<AsyncValue<bool>> {
  final String publicId;
  final Ref ref;

  FollowToggleNotifier({
    required this.publicId,
    required this.ref,
  }) : super(const AsyncValue.loading());

  /// Set the initial follow status (called when isFollowingProvider resolves)
  void setInitial(bool isFollowing) {
    state = AsyncValue.data(isFollowing);
  }

  /// Toggle follow state with optimistic update
  Future<void> toggle() async {
    final currentValue = state.valueOrNull ?? false;
    final newValue = !currentValue;

    // Optimistic update
    state = AsyncValue.data(newValue);

    try {
      final service = ref.read(poetServiceProvider);

      if (newValue) {
        await service.followPoet(publicId: publicId);
        _logger.i('✅ Followed poet: $publicId');
      } else {
        await service.unfollowPoet(publicId: publicId);
        _logger.i('✅ Unfollowed poet: $publicId');
      }

      // Invalidate the follow status cache so next screen visit gets fresh data
      ref.invalidate(isFollowingProvider(publicId));
    } catch (e) {
      // Revert on error
      _logger.e('❌ Follow toggle failed for $publicId: $e');
      state = AsyncValue.data(currentValue);
    }
  }
}

/// Provider for follow toggle. Family by poet publicId.
///
/// Usage:
/// ```dart
/// final toggleNotifier = ref.read(followToggleProvider(publicId).notifier);
/// toggleNotifier.toggle();
/// ```
final followToggleProvider = StateNotifierProvider.autoDispose
    .family<FollowToggleNotifier, AsyncValue<bool>, String>(
  (ref, publicId) {
    final notifier = FollowToggleNotifier(
      publicId: publicId,
      ref: ref,
    );

    // Listen to the isFollowingProvider to set initial value
    ref.listen<AsyncValue<bool>>(
      isFollowingProvider(publicId),
      (prev, next) {
        next.whenData((isFollowing) {
          notifier.setInitial(isFollowing);
        });
      },
      fireImmediately: true,
    );

    return notifier;
  },
);

/// Get list of poets the current user is following (paginated)
final followingPoetsProvider = FutureProvider.autoDispose((ref) async {
  final service = ref.watch(poetServiceProvider);

  try {
    final result = await service.getFollowingPoets();
    _logger.i('✅ Following list loaded: ${result.content.length} poets');
    return result;
  } catch (e) {
    _logger.e('❌ Error loading following list: $e');
    rethrow;
  }
});
