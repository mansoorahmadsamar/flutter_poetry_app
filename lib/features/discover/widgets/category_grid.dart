import 'package:flutter/material.dart';

import '../../../core/design_system/app_colors.dart';
import '../models/discover_bundle_model.dart';
import 'section_header.dart';

/// Category grid with watermark icons, accent colors, RTL/LTR text detection,
/// and an "All Categories" tile when totalCount > items.length.
class CategoryGrid extends StatelessWidget {
  final List<ContentCard> categories;
  final int totalCount;
  final bool isRtl;
  final Function(ContentCard) onCategoryTap;
  final VoidCallback? onSeeMore;

  const CategoryGrid({
    super.key,
    required this.categories,
    this.totalCount = 0,
    required this.isRtl,
    required this.onCategoryTap,
    this.onSeeMore,
  });

  static const _categoryConfig = <String, _CategoryStyle>{
    'Classical Poetry':
        _CategoryStyle(Icons.auto_stories_rounded, Color(0xFF1B4D3E)),
    'Modern Poetry':
        _CategoryStyle(Icons.edit_note_rounded, Color(0xFF4A7C8E)),
    'Thematic Poetry':
        _CategoryStyle(Icons.palette_rounded, Color(0xFFC5A059)),
    'Poetry Forms':
        _CategoryStyle(Icons.format_quote_rounded, Color(0xFF2D7A5A)),
    'Occasional Poetry':
        _CategoryStyle(Icons.celebration_rounded, Color(0xFFD4A259)),
    'Ghazal':
        _CategoryStyle(Icons.music_note_rounded, Color(0xFFC84B31)),
    'Qasida':
        _CategoryStyle(Icons.history_edu_rounded, Color(0xFF1B4D3E)),
    'Rubai': _CategoryStyle(Icons.grid_4x4_rounded, Color(0xFF4A7C8E)),
  };

  static bool _isLatinText(String text) {
    return RegExp(r'^[a-zA-Z\s\-&]+$').hasMatch(text.trim());
  }

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    final showAllTile = totalCount > categories.length && onSeeMore != null;
    final itemCount = categories.length + (showAllTile ? 1 : 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: isRtl ? 'زمرے' : 'Categories',
          icon: Icons.category_rounded,
          iconColor: AppColors.info,
          isRtl: isRtl,
          itemCount: categories.length,
          totalCount: totalCount,
          onSeeMore: onSeeMore,
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount =
                  constraints.maxWidth > 600 ? 4 : 2;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 2.2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: itemCount,
                itemBuilder: (context, index) {
                  if (showAllTile && index == categories.length) {
                    return _AllCategoriesTile(
                      totalCount: totalCount,
                      isRtl: isRtl,
                      onTap: onSeeMore!,
                    );
                  }

                  final cat = categories[index];
                  final config =
                      _categoryConfig[cat.primaryText] ??
                      _CategoryStyle(
                          Icons.folder_rounded, AppColors.info);
                  return _CategoryTile(
                    category: cat,
                    icon: config.icon,
                    accentColor: config.color,
                    isRtl: isRtl,
                    onTap: () => onCategoryTap(cat),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CategoryStyle {
  final IconData icon;
  final Color color;
  const _CategoryStyle(this.icon, this.color);
}

class _CategoryTile extends StatelessWidget {
  final ContentCard category;
  final IconData icon;
  final Color accentColor;
  final bool isRtl;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.category,
    required this.icon,
    required this.accentColor,
    required this.isRtl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLatin = CategoryGrid._isLatinText(category.primaryText);
    final textDir = isLatin ? TextDirection.ltr : TextDirection.rtl;
    final useNastaleeq = !isLatin;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.surfaceDark
                : accentColor.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: accentColor
                  .withValues(alpha: isDark ? 0.2 : 0.12),
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.1)
                    : accentColor.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Watermark icon in the background corner
              Positioned(
                right: isLatin ? 0 : null,
                left: isLatin ? null : 0,
                bottom: -2,
                child: Icon(
                  icon,
                  size: 32,
                  color: accentColor.withValues(alpha: isDark ? 0.06 : 0.05),
                ),
              ),
              // Content
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: accentColor
                          .withValues(alpha: isDark ? 0.2 : 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 16, color: accentColor),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      category.primaryText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textDirection: textDir,
                      style: TextStyle(
                        fontFamily:
                            useNastaleeq ? 'Jameel Noori Nastaleeq' : null,
                        fontSize: useNastaleeq ? 13 : 12,
                        fontWeight: FontWeight.w600,
                        height: useNastaleeq ? 1.5 : 1.3,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
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

/// "All Categories (N)" tile
class _AllCategoriesTile extends StatelessWidget {
  final int totalCount;
  final bool isRtl;
  final VoidCallback onTap;

  const _AllCategoriesTile({
    required this.totalCount,
    required this.isRtl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.primaryDark.withValues(alpha: 0.3)
                : AppColors.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.primary
                  .withValues(alpha: isDark ? 0.3 : 0.15),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary
                      .withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.grid_view_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isRtl
                      ? 'تمام زمرے ($totalCount)'
                      : 'All ($totalCount)',
                  style: TextStyle(
                    fontFamily:
                        isRtl ? 'Jameel Noori Nastaleeq' : null,
                    fontSize: isRtl ? 13 : 12,
                    fontWeight: FontWeight.w600,
                    height: isRtl ? 1.5 : 1.3,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Icon(
                isRtl
                    ? Icons.arrow_back_ios_rounded
                    : Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
