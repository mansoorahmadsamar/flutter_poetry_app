import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/design_system/app_typography.dart';
import 'package:flutter_poetry_app/core/providers/language_provider.dart';
import 'package:flutter_poetry_app/core/widgets/localized_text.dart';
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
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      child: InkWell(
        onTap: () => _onTap(context, ref),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, isDark),
              const SizedBox(height: AppSpacing.md),

              // Urdu verses
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

              // Roman transliteration (non-Urdu mode only)
              if (data.versesTextRoman != null && !isUrdu) ...[
                const SizedBox(height: AppSpacing.sm),
                Center(
                  child: Text(
                    data.versesTextRoman!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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

        // Poet name + era
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              LocalizedText(
                data.poetName ?? '',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.start,
              ),
              if (_formatEra(data.poetBirthYear, data.poetDeathYear) != null)
                Text(
                  _formatEra(data.poetBirthYear, data.poetDeathYear)!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
            ],
          ),
        ),

        // Reason badge
        if (item.reason.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: _reasonColor(item.reason, isDark).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
            ),
            child: Text(
              _reasonLabel(item.reason),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: _reasonColor(item.reason, isDark),
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
      decoration: BoxDecoration(
        color: isDark ? AppColors.borderDark : AppColors.shimmerBase,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person_outline,
        size: AppSpacing.iconSm,
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
    ref.read(feedProvider.notifier).trackAction(item, 'like');
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

  String? _formatEra(int? birthYear, int? deathYear) {
    if (birthYear == null || birthYear == 0) return null;
    if (deathYear == null || deathYear == 0) return '$birthYear';
    return '$birthYear \u2013 $deathYear';
  }

  Color _reasonColor(String reason, bool isDark) {
    return switch (reason) {
      'TRENDING' => AppColors.secondary,
      'PERSONALIZED' => AppColors.primary,
      'DISCOVERY' => AppColors.info,
      'CURATED' => AppColors.secondaryDark,
      _ => isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
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
