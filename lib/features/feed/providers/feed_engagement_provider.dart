import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks optimistic local engagement state for feed items.
/// Overlaid on top of server data so UI updates instantly on user actions.
class FeedEngagementOverlay {
  final bool? isLiked;
  final bool? isBookmarked;
  final bool? isFollowed;
  final int likeCountDelta;
  final int bookmarkCountDelta;

  const FeedEngagementOverlay({
    this.isLiked,
    this.isBookmarked,
    this.isFollowed,
    this.likeCountDelta = 0,
    this.bookmarkCountDelta = 0,
  });

  FeedEngagementOverlay copyWith({
    bool? isLiked,
    bool? isBookmarked,
    bool? isFollowed,
    int? likeCountDelta,
    int? bookmarkCountDelta,
  }) {
    return FeedEngagementOverlay(
      isLiked: isLiked ?? this.isLiked,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isFollowed: isFollowed ?? this.isFollowed,
      likeCountDelta: likeCountDelta ?? this.likeCountDelta,
      bookmarkCountDelta: bookmarkCountDelta ?? this.bookmarkCountDelta,
    );
  }
}

/// Keyed by "TYPE:publicId" (same as event itemKey).
/// Cards read from this overlay first, fall back to server contentData values.
final feedEngagementProvider =
    StateProvider<Map<String, FeedEngagementOverlay>>((ref) => {});
