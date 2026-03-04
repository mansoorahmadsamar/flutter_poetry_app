import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/models/poet_model.dart';
import 'package:flutter_poetry_app/features/search/utils/highlighted_text.dart';
import 'package:shimmer/shimmer.dart';

/// Poet result card for search results.
///
/// Full-width card with avatar (56x56), name, era, poem count, and arrow.
/// Design: marginH:16, marginV:4, padding:16, borderRadius:16
class AppSearchPoetCard extends StatelessWidget {
  final PoetModel poet;
  final VoidCallback? onTap;
  final String searchQuery;

  const AppSearchPoetCard({
    super.key,
    required this.poet,
    this.onTap,
    this.searchQuery = '',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUrdu = _isUrduText(poet.name);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: AppColors.primary.withValues(alpha: 0.08),
        child: Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Avatar
              _buildAvatar(isDark),
              SizedBox(width: AppSpacing.md),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HighlightedText(
                      text: poet.name,
                      query: searchQuery,
                      textDirection:
                          isUrdu ? TextDirection.rtl : TextDirection.ltr,
                      style: TextStyle(
                        fontFamily:
                            isUrdu ? 'Jameel Noori Nastaleeq' : null,
                        fontSize: isUrdu ? 18 : 16,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                        height: isUrdu ? 1.8 : 1.4,
                      ),
                    ),
                    if (poet.birthYear > 0) ...[
                      SizedBox(height: 4),
                      Text(
                        _formatEra(poet.birthYear, poet.deathYear),
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                    if (poet.poemCount > 0) ...[
                      SizedBox(height: 4),
                      Text(
                        '${poet.poemCount} غزلیں',
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontFamily: 'Jameel Noori Nastaleeq',
                          fontSize: 12,
                          color: AppColors.secondary,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Arrow
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: isDark
                    ? AppColors.textDisabledDark
                    : AppColors.textDisabledLight,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: poet.profileImageUrl != null
          ? CachedNetworkImage(
              imageUrl: poet.profileImageUrl!,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              memCacheWidth: 112,
              placeholder: (_, __) => _avatarPlaceholder(),
              errorWidget: (_, __, ___) => _avatarPlaceholder(),
            )
          : _avatarPlaceholder(),
    );
  }

  Widget _avatarPlaceholder() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person_rounded,
        size: 28,
        color: AppColors.primary.withValues(alpha: 0.5),
      ),
    );
  }

  String _formatEra(int birthYear, int deathYear) {
    if (deathYear == 0) return '$birthYear - حال';
    return '$birthYear - $deathYear';
  }

  bool _isUrduText(String text) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }
}

/// Shimmer skeleton matching AppSearchPoetCard dimensions.
class AppSearchPoetSkeleton extends StatelessWidget {
  const AppSearchPoetSkeleton({super.key});

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
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 160,
                    height: 18,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(height: 6),
                  Container(
                    width: 100,
                    height: 13,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
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
