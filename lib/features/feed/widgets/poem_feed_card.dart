import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/design_system/app_typography.dart';
import 'package:flutter_poetry_app/features/engagement/providers/like_providers.dart';
import 'package:flutter_poetry_app/features/engagement/providers/bookmark_providers.dart';
import '../models/feed_content_data.dart';
import '../models/feed_item.dart';
import '../providers/feed_engagement_provider.dart';
import '../providers/feed_provider.dart';
import 'feed_engagement_row.dart';

class PoemFeedCard extends ConsumerWidget {
  final FeedItem item;
  final PoemContentData data;

  const PoemFeedCard({
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
      child: InkWell(
        onTap: () => _onTap(context, ref),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Optional thumbnail
            if (data.thumbnailUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.radiusLg),
                ),
                child: CachedNetworkImage(
                  imageUrl: data.thumbnailUrl!,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  memCacheWidth: 600,
                  placeholder: (_, __) => Container(
                    height: 160,
                    color:
                        isDark ? AppColors.borderDark : AppColors.shimmerBase,
                  ),
                  errorWidget: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(context, isDark, isUrdu, textTheme),
                  const SizedBox(height: AppSpacing.md),

                  // Title
                  if (data.title != null)
                    Text(
                      data.title!,
                      style: isUrdu
                          ? AppTypography.urduPoetNameStyle.copyWith(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            )
                          : textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                      textDirection:
                          isUrdu ? TextDirection.rtl : TextDirection.ltr,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                  // Excerpt
                  if (data.excerpt != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      data.excerpt!,
                      style: isUrdu
                          ? AppTypography.urduVerseStyle.copyWith(
                              fontSize: 19,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                              height: 2.0,
                            )
                          : textTheme.bodyMedium?.copyWith(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                      textDirection:
                          isUrdu ? TextDirection.rtl : TextDirection.ltr,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  // "Read full ghazal →" / "Read full poem →" CTA
                  const SizedBox(height: AppSpacing.sm),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => _onTap(context, ref),
                      child: Text(
                        data.poetryType?.toUpperCase() == 'GHAZAL'
                            ? 'Read full ghazal →'
                            : 'Read full poem →',
                        style: GoogleFonts.roboto(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sm),
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
                    shareCount: 0,
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

  Widget _buildHeader(
    BuildContext context,
    bool isDark,
    bool isUrdu,
    TextTheme textTheme,
  ) {
    return Row(
      children: [
        // Poet avatar — taps to poet profile
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
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    memCacheWidth: 80,
                    placeholder: (_, __) => _avatarPlaceholder(isDark),
                    errorWidget: (_, __, ___) => _avatarPlaceholder(isDark),
                  )
                : _avatarPlaceholder(isDark),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),

        // Poet name + era — taps to poet profile
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

        // Poetry type badge
        if (data.poetryType != null)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color:
                  _poetryTypeColor(data.poetryType!).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
            ),
            child: Text(
              data.poetryType!.toUpperCase(),
              style: GoogleFonts.roboto(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: _poetryTypeColor(data.poetryType!),
              ),
            ),
          ),
      ],
    );
  }

  Widget _avatarPlaceholder(bool isDark) {
    return Container(
      width: 40,
      height: 40,
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
    context.push('/main/poems/${item.publicId}');
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

    // Fire real API call — revert overlay on error
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

    // Fire real API call — revert overlay on error
    _fireToggleBookmark(ref, item.publicId, item.lang ?? 'ur', itemKey, overlay);
  }

  Future<void> _fireToggleLike(
    WidgetRef ref,
    String publicId,
    String itemKey,
    FeedEngagementOverlay? previousOverlay,
  ) async {
    try {
      await ref.read(likeActionProvider.notifier).toggleLike(publicId);
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
      await ref.read(bookmarkActionProvider.notifier).toggleBookmark(publicId, lang: lang);
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

  Color _poetryTypeColor(String type) {
    return switch (type.toUpperCase()) {
      'GHAZAL' => AppColors.primary,
      'NAZAM' => AppColors.info,
      'RUBAI' => AppColors.success,
      'QITA' => AppColors.primaryLight,
      'MARSIYA' => AppColors.secondaryDark,
      'MASNAVI' => AppColors.warning,
      'HAMD' => AppColors.success,
      'NAAT' => AppColors.secondary,
      _ => AppColors.primary,
    };
  }
}
