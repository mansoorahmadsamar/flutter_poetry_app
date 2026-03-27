import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
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

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dismissible(
      key: Key('dismiss_${item.type}:${item.publicId}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        color: isDark ? const Color(0xFF2C1B1B) : const Color(0xFFFBE9E7),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.block,
              color: isDark ? Colors.red.shade300 : Colors.red.shade700,
            ),
            const SizedBox(height: 4),
            Text(
              'Not interested',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.red.shade300 : Colors.red.shade700,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (_) async {
        ref.read(feedProvider.notifier).hideItem(item);
        return false; // We handle removal via state — don't let Dismissible remove the widget
      },
      child: VisibilityDetector(
        key: Key('feed_${item.type}:${item.publicId}'),
        onVisibilityChanged: (info) {
          if (info.visibleFraction > 0.5) {
            ref.read(feedProvider.notifier).onItemVisible(item);
          } else if (info.visibleFraction == 0) {
            ref.read(feedProvider.notifier).onItemHidden(item);
          }
        },
        child: Stack(
          children: [
            card,
            // 3-dot overflow menu
            Positioned(
              top: AppSpacing.feedCardVerticalMargin + 8,
              right: AppSpacing.md + 4,
              child: _OverflowMenu(
                onHide: () =>
                    ref.read(feedProvider.notifier).hideItem(item),
                isDark: isDark,
              ),
            ),
          ],
        ),
      ),
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

class _OverflowMenu extends StatelessWidget {
  final VoidCallback onHide;
  final bool isDark;

  const _OverflowMenu({required this.onHide, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 28,
      child: PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'hide') onHide();
        },
        padding: EdgeInsets.zero,
        iconSize: 18,
        icon: Icon(
          Icons.more_vert,
          size: 18,
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
        itemBuilder: (_) => const [
          PopupMenuItem(
            value: 'hide',
            child: Row(
              children: [
                Icon(Icons.block, size: 18),
                SizedBox(width: 8),
                Text('Not interested'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
