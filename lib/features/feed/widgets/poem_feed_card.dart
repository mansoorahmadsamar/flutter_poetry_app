import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/design_system/app_typography.dart';
import 'package:flutter_poetry_app/core/providers/language_provider.dart';
import 'package:flutter_poetry_app/features/engagement/providers/bookmark_providers.dart';
import 'package:flutter_poetry_app/features/engagement/providers/reaction_providers.dart';
import '../models/feed_content_data.dart';
import '../models/feed_item.dart';
import '../providers/feed_engagement_provider.dart';
import '../providers/feed_provider.dart';
import 'feed_engagement_row.dart';
import 'social_proof_badge.dart';

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
      color: _cardColor(isDark),
      child: InkWell(
        onTap: () => _onTap(context, ref),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Optional thumbnail
            if (data.thumbnailUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.radiusMd),
                ),
                child: CachedNetworkImage(
                  imageUrl: data.thumbnailUrl!,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  memCacheWidth: 600,
                  placeholder: (_, __) => Container(
                    height: 180,
                    color:
                        isDark ? AppColors.borderDark : AppColors.shimmerBase,
                  ),
                  errorWidget: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),

            Padding(
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

                  // Social proof
                  SocialProofBadge(socialContext: item.socialContext),

                  // Title
                  if (data.title != null)
                    Text(
                      data.title!,
                      style: isUrdu
                          ? AppTypography.urduPoetNameStyle.copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            )
                          : Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
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

                  // Couplets in a tinted container
                  if (data.excerpt != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    _buildCoupletsBlock(context, data.excerpt!, isDark, isUrdu),
                  ],

                  // "Read more" CTA
                  const SizedBox(height: AppSpacing.md),
                  Align(
                    alignment: Alignment.center,
                    child: GestureDetector(
                      onTap: () => _onTap(context, ref),
                      child: Text(
                        isAppUrdu
                            ? 'مزید پڑھیے  ←'
                            : data.poetryType?.toUpperCase() == 'GHAZAL'
                                ? 'Read full ghazal →'
                                : 'Read full poem →',
                        style: isAppUrdu
                            ? TextStyle(
                                fontFamily: AppTypography.urduFontFamily,
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.primaryLight : AppColors.primary,
                                height: 1.6,
                              )
                            : GoogleFonts.roboto(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.primaryLight : AppColors.primary,
                              ),
                        textDirection:
                            isAppUrdu ? TextDirection.rtl : TextDirection.ltr,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.feedSectionGap),
                  Divider(
                    color: isDark
                        ? AppColors.dividerDark
                        : AppColors.dividerLight,
                    height: 1,
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  FeedEngagementRow(
                    likeCount:
                        data.likeCount + (overlay?.reactionCountDelta ?? overlay?.likeCountDelta ?? 0),
                    shareCount: 0,
                    isLiked: overlay?.userReaction != null || overlay?.isLiked == true,
                    isBookmarked: overlay?.isBookmarked ?? false,
                    onBookmark: () => _onBookmark(ref, itemKey, overlay),
                    onShare: () => _onShare(context, ref),
                    totalReactions: item.socialContext?.totalReactions,
                    userReaction: overlay?.userReaction,
                    reactionsByType: _parseReactionsByType(data.reactions),
                    reactionTypes: ref.watch(reactionTypesProvider).valueOrNull ?? [],
                    onReact: (reactionType) => _onReact(ref, itemKey, overlay, reactionType),
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
    bool isAppUrdu,
  ) {
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
                // Social reason — below poet info
                // Use Nastaleeq when content or app is Urdu
                if (item.reason == 'FOLLOWING')
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      (isUrdu || isAppUrdu) ? 'آپ کے پسندیدہ شاعر کی طرف سے' : 'From a poet you follow',
                      style: (isUrdu || isAppUrdu)
                          ? TextStyle(
                              fontFamily: AppTypography.urduFontFamily,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isDark ? AppColors.primaryLight : AppColors.primary,
                              height: 1.5,
                            )
                          : GoogleFonts.roboto(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isDark ? AppColors.primaryLight : AppColors.primary,
                            ),
                      textDirection: (isUrdu || isAppUrdu) ? TextDirection.rtl : TextDirection.ltr,
                    ),
                  ),
                if (item.reason == 'TIME_CAPSULE')
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bookmark, size: 12,
                            color: isDark ? AppColors.secondaryLight : AppColors.secondary),
                        const SizedBox(width: 3),
                        Text(
                          (isUrdu || isAppUrdu) ? 'آپ نے پہلے محفوظ کیا تھا' : 'You saved this before',
                          style: (isUrdu || isAppUrdu)
                              ? TextStyle(
                                  fontFamily: AppTypography.urduFontFamily,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? AppColors.secondaryLight : AppColors.secondary,
                                  height: 1.5,
                                )
                              : GoogleFonts.roboto(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? AppColors.secondaryLight : AppColors.secondary,
                                ),
                          textDirection: (isUrdu || isAppUrdu) ? TextDirection.rtl : TextDirection.ltr,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Poetry type badge — Urdu Nastaliq, poetic green
        if (data.poetryType != null)
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
              _poetryTypeLabel(data.poetryType!),
              style: TextStyle(
                fontFamily: AppTypography.urduFontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.primaryLight : AppColors.primary,
                height: 1.6,
              ),
              textDirection: TextDirection.rtl,
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
    context.push('/main/poems/${item.publicId}');
  }

  void _onReact(WidgetRef ref, String itemKey, FeedEngagementOverlay? overlay, String reactionType) {
    final currentReaction = overlay?.userReaction;
    final bool isRemoving = currentReaction == reactionType;
    final bool isAdding = currentReaction == null;

    final newOverlay = (overlay ?? const FeedEngagementOverlay()).copyWith(
      userReaction: () => isRemoving ? null : reactionType,
      isLiked: !isRemoving,
      reactionCountDelta: (overlay?.reactionCountDelta ?? 0) +
          (isRemoving ? -1 : (isAdding ? 1 : 0)),
      likeCountDelta: (overlay?.likeCountDelta ?? 0) +
          (isRemoving ? -1 : (isAdding ? 1 : 0)),
    );
    ref.read(feedEngagementProvider.notifier).state = {
      ...ref.read(feedEngagementProvider),
      itemKey: newOverlay,
    };
    ref.read(feedProvider.notifier).trackAction(item, 'react');
    _fireReact(ref, item.publicId, reactionType, itemKey, overlay);
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

  Future<void> _fireReact(
    WidgetRef ref,
    String publicId,
    String reactionType,
    String itemKey,
    FeedEngagementOverlay? previousOverlay,
  ) async {
    try {
      await ref.read(reactionActionProvider.notifier).react(
            targetType: 'poems',
            publicId: publicId,
            reactionType: reactionType,
          );
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

  void _onShare(BuildContext context, WidgetRef ref) {
    final parts = <String>[];
    if (data.title != null) parts.add(data.title!);
    if (data.excerpt != null) parts.add(data.excerpt!);
    if (parts.isEmpty) return;
    final poet = data.poetName ?? '';
    final text = poet.isNotEmpty
        ? '${parts.join('\n')}\n\n— $poet'
        : parts.join('\n');
    Share.shareWithResult(text).then((result) {
      if (result.status == ShareResultStatus.success) {
        ref.read(feedProvider.notifier).trackAction(item, 'share');
      }
    });
  }

  String? _formatEra(int? birthYear, int? deathYear) {
    if (birthYear == null || birthYear == 0) return null;
    if (deathYear == null || deathYear == 0) return '$birthYear';
    return '$birthYear \u2013 $deathYear';
  }

  Color _cardColor(bool isDark) {
    return isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
  }

  /// Splits the excerpt into lines, groups them as couplets (2 lines each),
  /// and renders at least 2 couplets inside a tinted container.
  /// Each verse auto-scales to fit on a single line — larger font for short
  /// verses, smaller for long ones.
  Widget _buildCoupletsBlock(
    BuildContext context,
    String excerpt,
    bool isDark,
    bool isUrdu,
  ) {
    // Split into non-empty lines
    final lines = excerpt
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    if (lines.isEmpty) return const SizedBox.shrink();

    // Show at least 2 couplets (4 lines) when available
    final maxLines = (lines.length >= 4) ? 4 : lines.length;
    final visibleLines = lines.sublist(0, maxLines);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 4,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : AppColors.primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        children: [
          for (int i = 0; i < visibleLines.length; i++) ...[
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                visibleLines[i],
                style: isUrdu
                    ? AppTypography.urduVerseStyle.copyWith(
                        fontSize: 21,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                        height: 1.8,
                      )
                    : Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 17,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                          fontStyle: FontStyle.italic,
                          height: 1.6,
                        ),
                textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
            ),
            // Small gap within couplet, larger between couplets
            if (i < visibleLines.length - 1)
              SizedBox(height: (i % 2 == 1) ? 10 : 2),
          ],
        ],
      ),
    );
  }

  Map<String, int>? _parseReactionsByType(Map<String, dynamic>? reactions) {
    if (reactions == null) return null;
    final byType = reactions['byType'];
    if (byType == null) return null;
    return Map<String, int>.from(byType as Map);
  }

  String _poetryTypeLabel(String type) {
    return switch (type.toUpperCase()) {
      'GHAZAL' => 'غزل',
      'NAZM' || 'NAZAM' => 'نظم',
      'RUBAI' => 'رباعی',
      'QITA' => 'قطعہ',
      'MARSIYA' => 'مرثیہ',
      'MASNAVI' => 'مثنوی',
      'HAMD' => 'حمد',
      'NAAT' => 'نعت',
      'QASIDA' => 'قصیدہ',
      'FREE_VERSE' => 'آزاد نظم',
      _ => type,
    };
  }
}
