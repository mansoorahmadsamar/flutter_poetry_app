import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/models/poem_model.dart';
import 'package:flutter_poetry_app/features/search/utils/highlighted_text.dart';
import 'package:shimmer/shimmer.dart';

/// Poem result card for search results.
///
/// Displays poem title, poetry type badge, poet name with avatar,
/// and optional excerpt. Compact design for search context.
class AppSearchPoemCard extends StatelessWidget {
  final PoemModel poem;
  final VoidCallback? onTap;
  final String searchQuery;

  const AppSearchPoemCard({
    super.key,
    required this.poem,
    this.onTap,
    this.searchQuery = '',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayTitle = poem.title ?? poem.poetryTypeName ?? poem.poetryType;
    final isUrdu = _isUrduText(displayTitle);

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
          child: Row(
            children: [
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Poetry type badge
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        poem.poetryTypeUrduName ??
                            poem.poetryTypeName ??
                            poem.poetryType,
                        style: TextStyle(
                          fontFamily: _isUrduText(
                                  poem.poetryTypeUrduName ?? '')
                              ? 'Jameel Noori Nastaleeq'
                              : null,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    SizedBox(height: AppSpacing.sm),

                    // Poem title
                    HighlightedText(
                      text: displayTitle,
                      query: searchQuery,
                      textDirection:
                          isUrdu ? TextDirection.rtl : TextDirection.ltr,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
                    SizedBox(height: AppSpacing.xs),

                    // Poet name with avatar
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: poem.poetProfileImageUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: poem.poetProfileImageUrl!,
                                  width: 24,
                                  height: 24,
                                  fit: BoxFit.cover,
                                  memCacheWidth: 48,
                                  placeholder: (_, __) =>
                                      _miniAvatarPlaceholder(),
                                  errorWidget: (_, __, ___) =>
                                      _miniAvatarPlaceholder(),
                                )
                              : _miniAvatarPlaceholder(),
                        ),
                        SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: HighlightedText(
                            text: poem.poetName,
                            query: searchQuery,
                            textDirection: _isUrduText(poem.poetName)
                                ? TextDirection.rtl
                                : TextDirection.ltr,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: _isUrduText(poem.poetName)
                                  ? 'Jameel Noori Nastaleeq'
                                  : null,
                              fontSize: _isUrduText(poem.poetName) ? 13 : 12,
                              color: AppColors.secondary,
                              height: _isUrduText(poem.poetName) ? 1.6 : 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow
              Padding(
                padding: EdgeInsetsDirectional.only(start: AppSpacing.sm),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: isDark
                      ? AppColors.textDisabledDark
                      : AppColors.textDisabledLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniAvatarPlaceholder() {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person_rounded,
        size: 14,
        color: AppColors.primary.withValues(alpha: 0.5),
      ),
    );
  }

  bool _isUrduText(String text) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }
}

/// Shimmer skeleton matching AppSearchPoemCard dimensions.
class AppSearchPoemSkeleton extends StatelessWidget {
  const AppSearchPoemSkeleton({super.key});

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type badge
              Container(
                width: 60,
                height: 18,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              // Title
              Container(
                width: double.infinity,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              // Poet row
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: AppSpacing.xs),
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
