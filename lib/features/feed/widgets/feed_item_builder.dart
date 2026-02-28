import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/feed_content_data.dart';
import '../models/feed_item.dart';
import '../providers/feed_provider.dart';
import 'couplet_feed_card.dart';
import 'poem_feed_card.dart';
import 'poet_spotlight_feed_card.dart';
import 'poet_image_feed_card.dart';

class FeedItemBuilder extends ConsumerWidget {
  final FeedItem item;

  const FeedItemBuilder({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final card = _buildCard();
    if (card == null) return const SizedBox.shrink();

    return VisibilityDetector(
      key: Key('feed_${item.type}:${item.publicId}'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.5) {
          ref.read(feedProvider.notifier).onItemVisible(item);
        } else if (info.visibleFraction == 0) {
          ref.read(feedProvider.notifier).onItemHidden(item);
        }
      },
      child: card,
    );
  }

  Widget? _buildCard() {
    final data = item.contentData;
    return switch (data) {
      CoupletContentData() => CoupletFeedCard(item: item, data: data),
      PoemContentData() => PoemFeedCard(item: item, data: data),
      PoetSpotlightContentData() =>
        PoetSpotlightFeedCard(item: item, data: data),
      PoetImageContentData() => PoetImageFeedCard(item: item, data: data),
      UnknownContentData() => null,
    };
  }
}
