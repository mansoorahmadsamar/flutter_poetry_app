import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';

/// Horizontal scrollable row of poetry style/category icons.
///
/// Each category maps to a tag slug used by the `/api/poets/tags/{tagSlug}` endpoint.
/// Tapping a category triggers the [onCategoryTap] callback with the tag slug.
class PoetryCategoryIcons extends StatelessWidget {
  final String? selectedCategory;
  final ValueChanged<String> onCategoryTap;

  const PoetryCategoryIcons({
    super.key,
    this.selectedCategory,
    required this.onCategoryTap,
  });

  static const _categories = [
    _Category('Ghazal', 'ghazal', Icons.auto_stories),
    _Category('Nazam', 'nazam', Icons.article_outlined),
    _Category('Hamd', 'hamd', Icons.mosque_outlined),
    _Category('Naat', 'naat', Icons.star_outline),
    _Category('Marsiya', 'marsiya', Icons.water_drop_outlined),
    _Category('Qawwali', 'qawwali', Icons.music_note_outlined),
    _Category('Rubai', 'rubai', Icons.format_quote),
    _Category('Masnavi', 'masnavi', Icons.menu_book_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 88,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = selectedCategory == cat.slug;

          return Padding(
            padding: EdgeInsets.only(
              right: index < _categories.length - 1 ? 12 : 0,
            ),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onCategoryTap(cat.slug);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 68,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon circle
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? AppColors.primary
                            : (isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : AppColors.primary.withValues(alpha: 0.08)),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : (isDark
                                  ? Colors.white.withValues(alpha: 0.12)
                                  : AppColors.primary.withValues(alpha: 0.15)),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        cat.icon,
                        size: 22,
                        color: isSelected
                            ? Colors.white
                            : (isDark
                                ? Colors.white.withValues(alpha: 0.6)
                                : AppColors.primary.withValues(alpha: 0.7)),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Label
                    Text(
                      cat.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.roboto(
                        fontSize: 11,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected
                            ? AppColors.primary
                            : (isDark
                                ? Colors.white.withValues(alpha: 0.5)
                                : AppColors.textSecondaryLight),
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Category {
  final String label;
  final String slug;
  final IconData icon;

  const _Category(this.label, this.slug, this.icon);
}
