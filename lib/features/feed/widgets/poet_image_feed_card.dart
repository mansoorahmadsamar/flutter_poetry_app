import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/providers/language_provider.dart';
import 'package:flutter_poetry_app/features/image_poetry/providers/image_bookmark_providers.dart';
import 'package:flutter_poetry_app/features/engagement/providers/reaction_providers.dart';
import '../models/feed_content_data.dart';
import '../models/feed_item.dart';
import '../providers/feed_engagement_provider.dart';
import '../providers/feed_provider.dart';
import 'feed_engagement_row.dart';
import 'social_proof_badge.dart';

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
      color: _cardColor(isDark),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, isDark, isUrdu),
                  // "From a poet you follow" / "You saved this before"
                  if (item.reason == 'FOLLOWING') ...[
                    const SizedBox(height: 4),
                    Text(
                      'From a poet you follow',
                      style: GoogleFonts.roboto(
                        fontSize: 11,
                        color: isDark ? const Color(0xFF64B5F6) : const Color(0xFF1565C0),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  if (item.reason == 'TIME_CAPSULE') ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bookmark, size: 13,
                            color: isDark ? const Color(0xFFFFB74D) : const Color(0xFFE65100)),
                        const SizedBox(width: 4),
                        Text(
                          'You saved this before',
                          style: GoogleFonts.roboto(
                            fontSize: 11,
                            color: isDark ? const Color(0xFFFFB74D) : const Color(0xFFE65100),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Social proof
            if (item.socialContext != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.feedCardPadding,
                ),
                child: SocialProofBadge(socialContext: item.socialContext),
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
                        data.likeCount + (overlay?.reactionCountDelta ?? overlay?.likeCountDelta ?? 0),
                    bookmarkCount:
                        data.bookmarkCount +
                        (overlay?.bookmarkCountDelta ?? 0),
                    shareCount: data.shareCount,
                    isLiked: overlay?.userReaction != null || overlay?.isLiked == true,
                    isBookmarked: overlay?.isBookmarked ?? false,
                    onBookmark: () => _onBookmark(ref, itemKey, overlay),
                    onShare: () => _onShare(context, ref),
                    totalReactions: item.socialContext?.totalReactions,
                    userReaction: overlay?.userReaction,
                    reactionsByType: _parseReactionsByType(data.reactions),
                    reactionTypes: ref.watch(reactionTypesProvider).valueOrNull ?? [],
                    onReact: (reactionType) => _onReact(ref, itemKey, overlay, reactionType),
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
    _fireToggleBookmark(ref, item.publicId, itemKey, overlay);
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
            targetType: 'poetry-images',
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

  void _onShare(BuildContext context, WidgetRef ref) {
    _shareAsync(context, ref);
  }

  Future<void> _shareAsync(BuildContext context, WidgetRef ref) async {
    final lang = ref.read(selectedLanguageProvider);
    try {
      // Call backend to get formatted share text + image URL
      final service = ref.read(imageCollectionServiceProvider);
      final shareInfo = await service.recordShare(item.publicId, lang: lang);
      final shareText = shareInfo['shareText'] as String?;
      final shareImageUrl = shareInfo['shareImageUrl'] as String?;

      ShareResult result;

      if (shareImageUrl != null && shareImageUrl.isNotEmpty) {
        // Download image to temp file
        final tmpDir = await getTemporaryDirectory();
        final ext = shareImageUrl.contains('.png') ? 'png' : 'jpg';
        final tmpPath = '${tmpDir.path}/share_${item.publicId}.$ext';
        await Dio().download(shareImageUrl, tmpPath);

        result = await Share.shareXFiles(
          [XFile(tmpPath)],
          text: shareText ?? '',
        );
      } else {
        // Text-only fallback
        result = await Share.shareWithResult(shareText ?? '');
      }

      if (result.status == ShareResultStatus.success) {
        ref.read(feedProvider.notifier).trackAction(item, 'share');
      }
    } catch (_) {
      // Fallback: share contentText locally if API fails
      final fallbackText = data.contentText;
      if (fallbackText != null && fallbackText.isNotEmpty) {
        final poet = data.poetName ?? '';
        final text = poet.isNotEmpty ? '$fallbackText\n\n— $poet' : fallbackText;
        final result = await Share.shareWithResult(text);
        if (result.status == ShareResultStatus.success) {
          ref.read(feedProvider.notifier).trackAction(item, 'share');
        }
      }
    }
  }

  Map<String, int>? _parseReactionsByType(Map<String, dynamic>? reactions) {
    if (reactions == null) return null;
    final byType = reactions['byType'];
    if (byType == null) return null;
    return Map<String, int>.from(byType as Map);
  }

  String? _formatEra(int? birthYear, int? deathYear) {
    if (birthYear == null || birthYear == 0) return null;
    if (deathYear == null || deathYear == 0) return '$birthYear';
    return '$birthYear \u2013 $deathYear';
  }

  Color _cardColor(bool isDark) {
    return isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
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
