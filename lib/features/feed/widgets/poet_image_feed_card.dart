import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
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
    final isUrdu = item.lang == 'ur';
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
        onTap: () => _onTap(context, ref),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: poet avatar + name + era + Gallery badge
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.feedCardPadding,
                AppSpacing.feedCardPaddingVertical,
                AppSpacing.feedCardPadding,
                AppSpacing.sm,
              ),
              child: _buildHeader(context, isDark, isUrdu),
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
                  color:
                      isDark ? AppColors.borderDark : AppColors.shimmerBase,
                ),
                errorWidget: (_, __, ___) => Container(
                  height: 280,
                  color:
                      isDark ? AppColors.borderDark : AppColors.shimmerBase,
                  child: Icon(
                    Icons.broken_image_outlined,
                    size: AppSpacing.iconXl,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ),

            // Engagement
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.feedCardPadding,
                AppSpacing.sm,
                AppSpacing.feedCardPadding,
                AppSpacing.feedCardPadding,
              ),
              child: Column(
                children: [
                  Divider(
                    color: isDark
                        ? AppColors.dividerDark
                        : AppColors.dividerLight,
                    height: 1,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  FeedEngagementRow(
                    likeCount:
                        data.likeCount + (overlay?.likeCountDelta ?? 0),
                    bookmarkCount:
                        data.bookmarkCount +
                        (overlay?.bookmarkCountDelta ?? 0),
                    shareCount: data.shareCount,
                    isLiked: overlay?.isLiked ?? false,
                    isBookmarked: overlay?.isBookmarked ?? false,
                    onLike: () => _onLike(ref, itemKey, overlay),
                    onBookmark: () => _onBookmark(ref, itemKey, overlay),
                    onShare: () => _onShare(ref),
                    extraActions:
                        data.contentText != null &&
                                data.contentText!.isNotEmpty
                            ? [
                                _CopyButton(
                                  onTap: () => _onCopy(context),
                                  isDark: isDark,
                                ),
                              ]
                            : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, bool isUrdu) {
    return Row(
      children: [
        // Poet avatar
        GestureDetector(
          onTap: () {
            if (data.poetPublicId != null) {
              context.push('/main/poets/${data.poetPublicId}');
            }
          },
          child: ClipOval(
            child: data.poetProfileImageUrl != null
                ? CachedNetworkImage(
                    imageUrl: data.poetProfileImageUrl!,
                    width: AppSpacing.feedAvatarSize,
                    height: AppSpacing.feedAvatarSize,
                    fit: BoxFit.cover,
                    memCacheWidth: 88,
                    placeholder: (_, __) => _avatarPlaceholder(isDark),
                    errorWidget: (_, __, ___) => _avatarPlaceholder(isDark),
                  )
                : _avatarPlaceholder(isDark),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),

        // Poet name + era
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (data.poetPublicId != null) {
                context.push('/main/poets/${data.poetPublicId}');
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (data.poetName != null)
                  Text(
                    data.poetName!,
                    style: isUrdu
                        ? TextStyle(
                            fontFamily: 'Jameel Noori Nastaleeq',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                            height: 1.8,
                          )
                        : GoogleFonts.roboto(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ),
                    textDirection:
                        isUrdu ? TextDirection.rtl : TextDirection.ltr,
                    textAlign: TextAlign.start,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (_formatEra(data.poetBirthYear, data.poetDeathYear) !=
                    null)
                  Text(
                    _formatEra(data.poetBirthYear, data.poetDeathYear)!,
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Gallery badge
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.photo_library_outlined,
                size: 14,
                color: isDark ? AppColors.primaryLight : AppColors.primary,
              ),
              const SizedBox(width: 4),
              Text(
                'Gallery',
                style: GoogleFonts.roboto(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color:
                      isDark ? AppColors.primaryLight : AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _avatarPlaceholder(bool isDark) {
    return Container(
      width: AppSpacing.feedAvatarSize,
      height: AppSpacing.feedAvatarSize,
      decoration: BoxDecoration(
        color: isDark ? AppColors.borderDark : AppColors.shimmerBase,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person_outline,
        size: AppSpacing.iconSm,
        color: isDark
            ? AppColors.textSecondaryDark
            : AppColors.textSecondaryLight,
      ),
    );
  }

  void _onTap(BuildContext context, WidgetRef ref) {
    ref.read(feedProvider.notifier).trackAction(item, 'open_item');
    if (data.poetPublicId != null) {
      context.push('/main/poets/${data.poetPublicId}');
    }
  }

  void _onCopy(BuildContext context) {
    if (data.contentText == null || data.contentText!.isEmpty) return;
    Clipboard.setData(ClipboardData(text: data.contentText!));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Text copied'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _onLike(
      WidgetRef ref, String itemKey, FeedEngagementOverlay? overlay) {
    final wasLiked = overlay?.isLiked ?? false;
    final newOverlay = (overlay ?? const FeedEngagementOverlay()).copyWith(
      isLiked: !wasLiked,
      likeCountDelta:
          (overlay?.likeCountDelta ?? 0) + (wasLiked ? -1 : 1),
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
      await ref
          .read(imageBookmarkActionProvider.notifier)
          .toggleLike(publicId);
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
      await ref
          .read(imageBookmarkActionProvider.notifier)
          .toggleBookmark(publicId);
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

  String? _formatEra(int? birthYear, int? deathYear) {
    if (birthYear == null || birthYear == 0) return null;
    if (deathYear == null || deathYear == 0) return '$birthYear';
    return '$birthYear \u2013 $deathYear';
  }
}

/// Copy button widget for use as an extra action in the engagement row.
class _CopyButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isDark;

  const _CopyButton({required this.onTap, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 8,
        ),
        child: Icon(
          Icons.copy_outlined,
          size: AppSpacing.feedEngagementIconSize,
          color: isDark
              ? AppColors.engagementIconDark
              : AppColors.engagementIcon,
        ),
      ),
    );
  }
}
