import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/design_system/app_typography.dart';
import '../models/feed_content_data.dart';
import '../models/feed_item.dart';
import '../providers/feed_engagement_provider.dart';
import '../providers/feed_provider.dart';
import 'feed_engagement_row.dart';

class PoetImageFeedCard extends ConsumerWidget {
  final FeedItem item;
  final PoetImageContentData data;

  const PoetImageFeedCard({
    super.key,
    required this.item,
    required this.data,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final itemKey = '${item.type}:${item.publicId}';
    final overlay = ref.watch(feedEngagementProvider)[itemKey];
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      elevation: AppSpacing.elevationSm,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _onTap(ref),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Gallery label
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.photo_library_outlined,
                    size: AppSpacing.iconXs,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Gallery',
                    style: textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),

            // Image
            if (data.imageUrl != null)
              CachedNetworkImage(
                imageUrl: data.imageUrl!,
                width: double.infinity,
                fit: BoxFit.cover,
                memCacheWidth: 600,
                placeholder: (_, __) => Container(
                  height: 220,
                  color: isDark ? AppColors.borderDark : AppColors.shimmerBase,
                ),
                errorWidget: (_, __, ___) => Container(
                  height: 220,
                  color: isDark ? AppColors.borderDark : AppColors.shimmerBase,
                  child: Icon(
                    Icons.broken_image_outlined,
                    size: AppSpacing.iconXl,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ),

            // Caption + engagement
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Caption text
                  if (data.contentText != null && data.contentText!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: Text(
                        data.contentText!,
                        style: AppTypography.urduVerseStyle.copyWith(
                          fontSize: 16,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                        textDirection: TextDirection.rtl,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                  Divider(
                    color:
                        isDark ? AppColors.dividerDark : AppColors.dividerLight,
                    height: 1,
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Engagement row
                  FeedEngagementRow(
                    likeCount:
                        data.likeCount + (overlay?.likeCountDelta ?? 0),
                    shareCount: data.shareCount,
                    isLiked: overlay?.isLiked ?? false,
                    onLike: () => _onLike(ref, itemKey, overlay),
                    onShare: () => _onShare(ref),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onTap(WidgetRef ref) {
    ref.read(feedProvider.notifier).trackAction(item, 'open_item');
  }

  void _onLike(WidgetRef ref, String itemKey, FeedEngagementOverlay? overlay) {
    final wasLiked = overlay?.isLiked ?? false;
    final newOverlay = (overlay ?? const FeedEngagementOverlay()).copyWith(
      isLiked: !wasLiked,
      likeCountDelta: (overlay?.likeCountDelta ?? 0) + (wasLiked ? -1 : 1),
    );
    ref.read(feedEngagementProvider.notifier).state = {
      ...ref.read(feedEngagementProvider),
      itemKey: newOverlay,
    };
    ref.read(feedProvider.notifier).trackAction(item, 'like');
  }

  void _onShare(WidgetRef ref) {
    ref.read(feedProvider.notifier).trackAction(item, 'share');
  }
}
