import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/features/search/models/search_models.dart';
import 'package:flutter_poetry_app/features/search/utils/highlighted_text.dart';
import 'package:shimmer/shimmer.dart';

/// Compact couplet card optimized for search results.
///
/// Displays:
/// - Verse text (Nastaliq, 20px, centered)
/// - Thin separator between verses
/// - Poet attribution row with avatar, name, poem title, and engagement metrics
///
/// Design: marginH:16, marginV:4, padding:16, borderRadius:12
class AppSearchCoupletCard extends StatelessWidget {
  final CoupletSearchResult couplet;
  final VoidCallback? onTap;
  final String searchQuery;

  const AppSearchCoupletCard({
    super.key,
    required this.couplet,
    this.onTap,
    this.searchQuery = '',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: AppColors.primary.withValues(alpha: 0.1),
        highlightColor: AppColors.primary.withValues(alpha: 0.05),
        child: Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.dividerLight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Type badge (optional)
              if (couplet.coupletTypeName != null) ...[
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      couplet.coupletTypeName!,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
              ],

              // Verse lines
              ...List.generate(couplet.verses.length, (index) {
                final verse = couplet.verses[index];
                final isLast = index == couplet.verses.length - 1;

                return Column(
                  children: [
                    HighlightedText(
                      text: verse.text,
                      query: searchQuery,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Jameel Noori Nastaleeq',
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        height: 2.2,
                        letterSpacing: 0.5,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    if (!isLast) ...[
                      SizedBox(height: AppSpacing.xs),
                      Center(
                        child: Container(
                          width: 60,
                          height: 1,
                          color: isDark
                              ? AppColors.dividerDark
                              : AppColors.dividerLight,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs),
                    ],
                  ],
                );
              }),

              SizedBox(height: AppSpacing.md),

              // Poet attribution row
              Row(
                children: [
                  // Poet avatar
                  _buildAvatar(isDark),
                  SizedBox(width: AppSpacing.sm),

                  // Poet name + poem title
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (couplet.poet != null)
                          HighlightedText(
                            text: couplet.poet!.name,
                            query: searchQuery,
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontFamily: 'Jameel Noori Nastaleeq',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              height: 1.8,
                              color: AppColors.secondary,
                            ),
                          ),
                        if (couplet.poem != null)
                          HighlightedText(
                            text: couplet.poem!.title,
                            query: searchQuery,
                            textDirection: TextDirection.rtl,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Jameel Noori Nastaleeq',
                              fontSize: 12,
                              height: 1.6,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Engagement metrics
                  _buildMetrics(isDark),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(bool isDark) {
    final imageUrl = couplet.poet?.profileImageUrl;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: imageUrl != null
          ? CachedNetworkImage(
              imageUrl: imageUrl,
              width: 32,
              height: 32,
              fit: BoxFit.cover,
              memCacheWidth: 64,
              placeholder: (_, __) => _avatarPlaceholder(),
              errorWidget: (_, __, ___) => _avatarPlaceholder(),
            )
          : _avatarPlaceholder(),
    );
  }

  Widget _avatarPlaceholder() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person_rounded,
        size: 16,
        color: AppColors.primary.withValues(alpha: 0.5),
      ),
    );
  }

  Widget _buildMetrics(bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (couplet.likeCount > 0) ...[
          Icon(
            Icons.favorite_rounded,
            size: 14,
            color: isDark
                ? AppColors.textDisabledDark
                : AppColors.textDisabledLight,
          ),
          SizedBox(width: 3),
          Text(
            _formatCount(couplet.likeCount),
            style: TextStyle(
              fontSize: 11,
              color: isDark
                  ? AppColors.textDisabledDark
                  : AppColors.textDisabledLight,
            ),
          ),
          SizedBox(width: AppSpacing.md),
        ],
        if (couplet.bookmarkCount > 0) ...[
          Icon(
            Icons.bookmark_rounded,
            size: 14,
            color: isDark
                ? AppColors.textDisabledDark
                : AppColors.textDisabledLight,
          ),
          SizedBox(width: 3),
          Text(
            _formatCount(couplet.bookmarkCount),
            style: TextStyle(
              fontSize: 11,
              color: isDark
                  ? AppColors.textDisabledDark
                  : AppColors.textDisabledLight,
            ),
          ),
        ],
      ],
    );
  }

  String _formatCount(int count) {
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}k';
    return count.toString();
  }
}

/// Shimmer skeleton matching AppSearchCoupletCard dimensions.
class AppSearchCoupletSkeleton extends StatelessWidget {
  const AppSearchCoupletSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Shimmer.fromColors(
        baseColor: isDark ? AppColors.surfaceDark : AppColors.shimmerBase,
        highlightColor:
            isDark ? AppColors.borderDark : AppColors.shimmerHighlight,
        child: Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Verse line 1
              Center(
                child: Container(
                  height: 24,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.xs),
              // Verse line 2
              Center(
                child: Container(
                  height: 24,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.md),
              // Poet row
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      SizedBox(height: 4),
                      Container(
                        width: 80,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
