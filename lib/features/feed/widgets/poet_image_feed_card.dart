import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/design_system/app_typography.dart';
import 'package:flutter_poetry_app/features/image_poetry/providers/image_bookmark_providers.dart';
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

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.feedCardVerticalMargin,
      ),
      elevation: AppSpacing.elevationNone,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        side: BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.dividerLight,
          width: 0.5,
        ),
      ),
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _onTap(ref),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Gallery badge
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.feedCardPadding,
                AppSpacing.feedCardPadding,
                AppSpacing.feedCardPadding,
                AppSpacing.sm,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.feedAccentBg,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusRound),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.photo_library_outlined,
                      size: 14,
                      color: AppColors.feedAccent,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Gallery',
                      style: GoogleFonts.roboto(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.feedAccent,
                      ),
                    ),
                  ],
                ),
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
                  height: 280,
                  color: isDark ? AppColors.borderDark : AppColors.shimmerBase,
                ),
                errorWidget: (_, __, ___) => Container(
                  height: 280,
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
              padding: const EdgeInsets.all(AppSpacing.feedCardPadding),
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
                          fontSize: 18,
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
                    isBookmarked: overlay?.isBookmarked ?? false,
                    onLike: () => _onLike(ref, itemKey, overlay),
                    onBookmark: () => _onBookmark(ref, itemKey, overlay),
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
    _fireToggleLike(ref, item.publicId, itemKey, overlay);
  }

  void _onBookmark(
      WidgetRef ref, String itemKey, FeedEngagementOverlay? overlay) {
    final wasBookmarked = overlay?.isBookmarked ?? false;
    final newOverlay = (overlay ?? const FeedEngagementOverlay()).copyWith(
      isBookmarked: !wasBookmarked,
      bookmarkCountDelta:
          (overlay?.bookmarkCountDelta ?? 0) + (wasBookmarked ? -1 : 1),
    );
    ref.read(feedEngagementProvider.notifier).state = {
      ...ref.read(feedEngagementProvider),
      itemKey: newOverlay,
    };
    ref.read(feedProvider.notifier).trackAction(item, 'bookmark');
    _fireToggleBookmark(ref, item.publicId, itemKey, overlay);
  }

  Future<void> _fireToggleLike(
    WidgetRef ref,
    String publicId,
    String itemKey,
    FeedEngagementOverlay? previousOverlay,
  ) async {
    try {
      await ref.read(imageBookmarkActionProvider.notifier).toggleLike(publicId);
    } catch (_) {
      ref.read(feedEngagementProvider.notifier).state = {
        ...ref.read(feedEngagementProvider),
        itemKey: previousOverlay ?? const FeedEngagementOverlay(),
      };
    }
  }

  Future<void> _fireToggleBookmark(
    WidgetRef ref,
    String publicId,
    String itemKey,
    FeedEngagementOverlay? previousOverlay,
  ) async {
    try {
      await ref.read(imageBookmarkActionProvider.notifier).toggleBookmark(publicId);
    } catch (_) {
      ref.read(feedEngagementProvider.notifier).state = {
        ...ref.read(feedEngagementProvider),
        itemKey: previousOverlay ?? const FeedEngagementOverlay(),
      };
    }
  }

  void _onShare(WidgetRef ref) {
    ref.read(feedProvider.notifier).trackAction(item, 'share');
  }
}
