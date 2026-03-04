import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/design_system/app_typography.dart';
import 'package:flutter_poetry_app/core/providers/language_provider.dart';
import '../models/feed_content_data.dart';
import '../models/feed_item.dart';
import '../providers/feed_engagement_provider.dart';
import '../providers/feed_provider.dart';
import 'feed_engagement_row.dart';

class CoupletFeedCard extends ConsumerWidget {
  final FeedItem item;
  final CoupletContentData data;

  const CoupletFeedCard({
    super.key,
    required this.item,
    required this.data,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = ref.watch(selectedLanguageProvider);
    final isUrdu = lang == 'ur';
    final itemKey = '${item.type}:${item.publicId}';
    final overlay = ref.watch(feedEngagementProvider)[itemKey];

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      elevation: AppSpacing.elevationSm,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      child: InkWell(
        onTap: () => _onTap(context, ref),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: poet avatar + name + reason badge
              _buildHeader(context, isDark),
              const SizedBox(height: AppSpacing.md),

              // Body: verses
              if (data.versesTextArabic != null)
                Center(
                  child: Text(
                    data.versesTextArabic!,
                    style: AppTypography.urduVerseStyle.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                  ),
                ),

              if (data.versesTextRoman != null && !isUrdu) ...[
                const SizedBox(height: AppSpacing.sm),
                Center(
                  child: Text(
                    data.versesTextRoman!,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.md),
              Divider(
                color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
                height: 1,
              ),
              const SizedBox(height: AppSpacing.sm),

              // Footer: engagement row
              FeedEngagementRow(
                likeCount:
                    data.likeCount + (overlay?.likeCountDelta ?? 0),
                bookmarkCount:
                    data.bookmarkCount + (overlay?.bookmarkCountDelta ?? 0),
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
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Row(
      children: [
        // Poet avatar
        ClipOval(
          child: data.poetProfileImageUrl != null
              ? CachedNetworkImage(
                  imageUrl: data.poetProfileImageUrl!,
                  width: 36,
                  height: 36,
                  fit: BoxFit.cover,
                  memCacheWidth: 72,
                  placeholder: (_, __) => _avatarPlaceholder(isDark),
                  errorWidget: (_, __, ___) => _avatarPlaceholder(isDark),
                )
              : _avatarPlaceholder(isDark),
        ),
        const SizedBox(width: AppSpacing.sm),

        // Poet name
        Expanded(
          child: Text(
            data.poetName ?? '',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // Reason badge
        if (item.reason.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _reasonColor(item.reason).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
            ),
            child: Text(
              _reasonLabel(item.reason),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: _reasonColor(item.reason),
              ),
            ),
          ),
      ],
    );
  }

  Widget _avatarPlaceholder(bool isDark) {
    return Container(
      width: 36,
      height: 36,
      color: isDark ? AppColors.borderDark : AppColors.borderLight,
      child: Icon(
        Icons.person_outline,
        size: 20,
        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
      ),
    );
  }

  void _onTap(BuildContext context, WidgetRef ref) {
    ref.read(feedProvider.notifier).trackAction(item, 'open_item');
    if (data.poemPublicId != null) {
      context.push('/main/poems/${data.poemPublicId}');
    }
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
    ref.read(feedProvider.notifier).trackAction(item, 'bookmark');
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
  }

  void _onShare(WidgetRef ref) {
    ref.read(feedProvider.notifier).trackAction(item, 'share');
  }

  Color _reasonColor(String reason) {
    return switch (reason) {
      'TRENDING' => Colors.orange,
      'PERSONALIZED' => AppColors.primary,
      'DISCOVERY' => AppColors.info,
      'CURATED' => AppColors.secondary,
      _ => AppColors.textSecondaryLight,
    };
  }

  String _reasonLabel(String reason) {
    return switch (reason) {
      'TRENDING' => 'Trending',
      'PERSONALIZED' => 'For You',
      'DISCOVERY' => 'Discover',
      'CURATED' => 'Curated',
      _ => reason,
    };
  }
}
