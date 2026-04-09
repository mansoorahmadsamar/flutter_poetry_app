import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks optimistic local engagement state for feed items.
/// Overlaid on top of server data so UI updates instantly on user actions.
class FeedEngagementOverlay {
  final bool? isLiked;
  final bool? isBookmarked;
  final bool? isFollowed;
  final int likeCountDelta;
  final int bookmarkCountDelta;

  /// The user's current reaction key (e.g. "WAH_WAH", "LOVE").
  /// null = no reaction. When non-null, isLiked is derived as true.
  final String? userReaction;

  /// Optimistic delta for total reaction count (+1 / -1 / 0).
  final int reactionCountDelta;

  /// Optimistic reaction breakdown by type, updated after user reacts.
  /// null = no optimistic override, use server data.
  final Map<String, int>? reactionsByType;

  const FeedEngagementOverlay({
    this.isLiked,
    this.isBookmarked,
    this.isFollowed,
    this.likeCountDelta = 0,
    this.bookmarkCountDelta = 0,
    this.userReaction,
    this.reactionCountDelta = 0,
    this.reactionsByType,
  });

  FeedEngagementOverlay copyWith({
    bool? isLiked,
    bool? isBookmarked,
    bool? isFollowed,
    int? likeCountDelta,
    int? bookmarkCountDelta,
    String? Function()? userReaction,
    int? reactionCountDelta,
    Map<String, int>? Function()? reactionsByType,
  }) {
    return FeedEngagementOverlay(
      isLiked: isLiked ?? this.isLiked,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isFollowed: isFollowed ?? this.isFollowed,
      likeCountDelta: likeCountDelta ?? this.likeCountDelta,
      bookmarkCountDelta: bookmarkCountDelta ?? this.bookmarkCountDelta,
      userReaction: userReaction != null ? userReaction() : this.userReaction,
      reactionCountDelta: reactionCountDelta ?? this.reactionCountDelta,
      reactionsByType: reactionsByType != null ? reactionsByType() : this.reactionsByType,
    );
  }
}

/// Keyed by "TYPE:publicId" (same as event itemKey).
/// Cards read from this overlay first, fall back to server contentData values.
final feedEngagementProvider =
    StateProvider<Map<String, FeedEngagementOverlay>>((ref) => {});
