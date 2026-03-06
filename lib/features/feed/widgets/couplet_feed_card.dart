import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/design_system/app_typography.dart';
import 'package:flutter_poetry_app/core/providers/language_provider.dart';
import 'package:flutter_poetry_app/features/engagement/providers/couplet_providers.dart';
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
    final isUrdu = item.lang == 'ur';
    final isAppUrdu = ref.watch(selectedLanguageProvider) == 'ur';
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
      child: InkWell(
        onTap: () => _onTap(context, ref),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.feedCardPadding,
            AppSpacing.feedCardPaddingVertical,
            AppSpacing.feedCardPadding,
            AppSpacing.feedCardPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context, isDark, isUrdu, isAppUrdu),
              const SizedBox(height: AppSpacing.feedSectionGap),

              // Urdu verses
              if (data.versesTextArabic != null)
                Text(
                  data.versesTextArabic!,
                  style: AppTypography.urduVerseStyle.copyWith(
                    fontSize: 22,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                    height: 2.4,
                  ),
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                ),

              // Roman transliteration (non-Urdu mode only)
              if (data.versesTextRoman != null && !isUrdu) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  data.versesTextRoman!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              // "Open poem →" CTA
              if (data.poemPublicId != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTap: () => _onTap(context, ref),
                    child: Text(
                      isAppUrdu ? 'مزید پڑھیے' : 'Open poem →',
                      style: isAppUrdu
                          ? TextStyle(
                              fontFamily: AppTypography.urduFontFamily,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: AppColors.feedAccent,
                              height: 1.6,
                            )
                          : GoogleFonts.roboto(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.feedAccent,
                            ),
                      textDirection:
                          isAppUrdu ? TextDirection.rtl : TextDirection.ltr,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.feedSectionGap),
              Divider(
                color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
                height: 1,
              ),
              const SizedBox(height: AppSpacing.sm),

              // Engagement row with copy button as extra action
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
                extraActions: data.versesTextArabic != null
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
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, bool isDark, bool isUrdu, bool isAppUrdu) {
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
                Text(
                  data.poetName ?? '',
                  style: isUrdu
                      ? AppTypography.urduPoetNameStyle.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
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

        // Reason badge — poetic green, always English
        if (item.reason.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
            ),
            child: Text(
              _reasonLabel(item.reason),
              style: GoogleFonts.roboto(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: isDark ? AppColors.primaryLight : AppColors.primary,
              ),
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
    if (data.poemPublicId != null) {
      context.push('/main/poems/${data.poemPublicId}');
    }
  }

  void _onCopy(BuildContext context) {
    if (data.versesTextArabic == null) return;
    Clipboard.setData(ClipboardData(text: data.versesTextArabic!));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Couplet copied'),
        duration: Duration(seconds: 2),
      ),
    );
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
    _fireToggleBookmark(ref, item.publicId, item.lang ?? 'ur', itemKey, overlay);
  }

  Future<void> _fireToggleLike(
    WidgetRef ref,
    String publicId,
    String itemKey,
    FeedEngagementOverlay? previousOverlay,
  ) async {
    try {
      await ref.read(coupletActionProvider.notifier).toggleLike(publicId);
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
    String lang,
    String itemKey,
    FeedEngagementOverlay? previousOverlay,
  ) async {
    try {
      await ref.read(coupletActionProvider.notifier).toggleBookmark(publicId, lang: lang);
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
          color: isDark ? AppColors.engagementIconDark : AppColors.engagementIcon,
        ),
      ),
    );
  }
}
