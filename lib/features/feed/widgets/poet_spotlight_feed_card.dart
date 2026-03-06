import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/design_system/app_typography.dart';
import 'package:flutter_poetry_app/core/providers/language_provider.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/widgets/follow_button.dart';
import '../models/feed_content_data.dart';
import '../models/feed_item.dart';
import '../providers/feed_provider.dart';

class PoetSpotlightFeedCard extends ConsumerWidget {
  final FeedItem item;
  final PoetSpotlightContentData data;

  const PoetSpotlightFeedCard({
    super.key,
    required this.item,
    required this.data,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    final isUrdu = item.lang == 'ur';
    final isAppUrdu = ref.watch(selectedLanguageProvider) == 'ur';
    final couplet = data.featuredCouplet;
    final hasVerse = couplet != null && couplet.verses.isNotEmpty;

    return GestureDetector(
      onTap: () => _onTap(context, ref),
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.feedCardVerticalMargin,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF0F2D24),
                    const Color(0xFF122E23),
                  ]
                : [
                    AppColors.primary,
                    const Color(0xFF163D31),
                  ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.feedCardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Discover badge
              _buildBadge(textTheme, isAppUrdu),
              const SizedBox(height: AppSpacing.feedSectionGap),

              // Header: Avatar + Name/years + Follow
              _buildHeader(context, textTheme, isDark, isUrdu),

              // Featured couplet block
              if (hasVerse) ...[
                const SizedBox(height: AppSpacing.feedSectionGap),
                _buildCoupletBlock(couplet, isDark, isUrdu),
              ],

              const SizedBox(height: AppSpacing.feedSectionGap),

              // Stats row or fallback text
              _buildStatsRow(),

              // "View Profile" CTA
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: () => _onTap(context, ref),
                  child: Text(
                    isAppUrdu ? 'پروفائل دیکھیے' : 'View Profile →',
                    style: isAppUrdu
                        ? TextStyle(
                            fontFamily: AppTypography.urduFontFamily,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.85),
                            height: 1.6,
                          )
                        : GoogleFonts.roboto(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                    textDirection:
                        isAppUrdu ? TextDirection.rtl : TextDirection.ltr,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(TextTheme textTheme, bool isAppUrdu) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_awesome,
            size: 12,
            color: AppColors.secondary,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            _reasonLabel(item.reason, isAppUrdu),
            style: textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    TextTheme textTheme,
    bool isDark,
    bool isUrdu,
  ) {
    return Row(
      children: [
        // Avatar
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: data.profileImageUrl != null
              ? CachedNetworkImage(
                  imageUrl: data.profileImageUrl!,
                  width: AppSpacing.feedSpotlightAvatarSize,
                  height: AppSpacing.feedSpotlightAvatarSize,
                  fit: BoxFit.cover,
                  memCacheWidth: 128,
                  placeholder: (_, __) => _imagePlaceholder(isDark),
                  errorWidget: (_, __, ___) => _imagePlaceholder(isDark),
                )
              : _imagePlaceholder(isDark),
        ),
        const SizedBox(width: AppSpacing.sm + 4),

        // Name + era
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.poetName ?? '',
                style: isUrdu
                    ? AppTypography.urduPoetNameStyle.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      )
                    : GoogleFonts.roboto(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondary,
                        letterSpacing: 0.2,
                      ),
                textDirection:
                    isUrdu ? TextDirection.rtl : TextDirection.ltr,
                textAlign: TextAlign.start,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (_formatEra(data.birthYear, data.deathYear) != null)
                Text(
                  _formatEra(data.birthYear, data.deathYear)!,
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),

        // Follow button
        FollowButton(
          publicId: data.poetPublicId,
          compact: true,
        ),
      ],
    );
  }

  Widget _buildCoupletBlock(
    FeaturedCouplet couplet,
    bool isDark,
    bool isUrdu,
  ) {
    final isArabicScript = couplet.script == 'ARABIC' || isUrdu;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 4,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Stack(
        children: [
          // Subtle quote watermark
          Positioned(
            top: -4,
            left: isArabicScript ? null : 0,
            right: isArabicScript ? 0 : null,
            child: Icon(
              Icons.format_quote_rounded,
              size: 32,
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),

          // Verses + like count
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Verses
              for (final verse in couplet.verses)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    verse,
                    style: isArabicScript
                        ? AppTypography.urduVerseStyle.copyWith(
                            fontSize: 17,
                            color: Colors.white.withValues(alpha: 0.95),
                            height: 2.0,
                          )
                        : GoogleFonts.roboto(
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
                            color: Colors.white.withValues(alpha: 0.9),
                            height: 1.6,
                          ),
                    textDirection: isArabicScript
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

              // Like count
              if (couplet.likeCount > 0) ...[
                const SizedBox(height: AppSpacing.xs),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.favorite_rounded,
                      size: 12,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      _formatCount(couplet.likeCount),
                      style: GoogleFonts.roboto(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final allZero =
        data.poemCount == 0 && data.followerCount == 0 && data.viewCount == 0;

    if (allZero) {
      final fallback = switch (item.reason) {
        'DISCOVERY' => 'Discover this poet',
        'TRENDING' => 'Trending poet',
        'PERSONALIZED' => 'Recommended for you',
        'CURATED' => 'Editor\'s pick',
        _ => 'Discover this poet',
      };
      return Text(
        fallback,
        style: GoogleFonts.roboto(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.italic,
          color: Colors.white.withValues(alpha: 0.6),
        ),
      );
    }

    final parts = <String>[];
    if (data.poemCount > 0) parts.add('${_formatCount(data.poemCount)} Poems');
    if (data.followerCount > 0) {
      parts.add('${_formatCount(data.followerCount)} Followers');
    }
    if (data.viewCount > 0) parts.add('${_formatCount(data.viewCount)} Reads');

    return Text(
      parts.join(' \u2022 '),
      style: GoogleFonts.roboto(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: Colors.white.withValues(alpha: 0.6),
      ),
    );
  }

  String? _formatEra(int? birthYear, int? deathYear) {
    if (birthYear == null || birthYear == 0) return null;
    if (deathYear == null || deathYear == 0) return 'b. $birthYear';
    return '$birthYear \u2013 $deathYear';
  }

  Widget _imagePlaceholder(bool isDark) {
    return Container(
      width: AppSpacing.feedSpotlightAvatarSize,
      height: AppSpacing.feedSpotlightAvatarSize,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Icon(
        Icons.person_outline,
        size: AppSpacing.iconMd,
        color: Colors.white.withValues(alpha: 0.3),
      ),
    );
  }

  void _onTap(BuildContext context, WidgetRef ref) {
    ref.read(feedProvider.notifier).trackAction(item, 'open_item');
    context.push('/main/poets/${data.poetPublicId}');
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }

  String _reasonLabel(String reason, bool isAppUrdu) {
    if (isAppUrdu) {
      return switch (reason) {
        'DISCOVERY' => 'تجویز کردہ شاعر',
        'TRENDING' => 'مقبول شاعر',
        'PERSONALIZED' => 'آپ کے لیے',
        'CURATED' => 'ایڈیٹر کی پسند',
        _ => 'دریافت',
      };
    }
    return switch (reason) {
      'DISCOVERY' => 'Suggested Poet',
      'TRENDING' => 'Trending Poet',
      'PERSONALIZED' => 'For You',
      'CURATED' => 'Editor\'s Pick',
      _ => 'Discover',
    };
  }
}
