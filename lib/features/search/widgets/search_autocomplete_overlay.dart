import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/providers/language_provider.dart';
import 'package:flutter_poetry_app/features/search/models/search_models.dart';

/// Autocomplete suggestions overlay
///
/// Features:
/// - Grouped suggestions (Poets, Poems, Tags, Categories)
/// - Proper RTL support for Urdu text
/// - Brand colors and polished design
/// - Smooth animations
class SearchAutocompleteOverlay extends ConsumerWidget {
  final AutocompleteResponse results;
  final ValueChanged<String> onSelect;

  const SearchAutocompleteOverlay({
    super.key,
    required this.results,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageCode = ref.watch(selectedLanguageProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final hasResults = results.poets.isNotEmpty ||
        results.poems.isNotEmpty ||
        results.tags.isNotEmpty ||
        results.categories.isNotEmpty;

    if (!hasResults) return const SizedBox.shrink();

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Poets
                  if (results.poets.isNotEmpty)
                    _SuggestionSection(
                      title: _getPoetsTitle(languageCode),
                      icon: Icons.person_rounded,
                      isDark: isDark,
                      languageCode: languageCode,
                      children: results.poets.map((poet) {
                        return _PoetSuggestionItem(
                          poet: poet,
                          isDark: isDark,
                          languageCode: languageCode,
                          onTap: () => onSelect(poet.name),
                        );
                      }).toList(),
                    ),

                  // Poems
                  if (results.poems.isNotEmpty)
                    _SuggestionSection(
                      title: _getPoemsTitle(languageCode),
                      icon: Icons.auto_stories_rounded,
                      isDark: isDark,
                      languageCode: languageCode,
                      children: results.poems.map((poem) {
                        return _TextSuggestionItem(
                          text: poem.title,
                          subtitle: poem.poetName,
                          isDark: isDark,
                          languageCode: languageCode,
                          onTap: () => onSelect(poem.title),
                        );
                      }).toList(),
                    ),

                  // Tags
                  if (results.tags.isNotEmpty)
                    _SuggestionSection(
                      title: _getTagsTitle(languageCode),
                      icon: Icons.tag_rounded,
                      isDark: isDark,
                      languageCode: languageCode,
                      children: results.tags.map((tag) {
                        return _TextSuggestionItem(
                          text: tag.name,
                          isDark: isDark,
                          languageCode: languageCode,
                          onTap: () => onSelect(tag.name),
                        );
                      }).toList(),
                    ),

                  // Categories
                  if (results.categories.isNotEmpty)
                    _SuggestionSection(
                      title: _getCategoriesTitle(languageCode),
                      icon: Icons.category_rounded,
                      isDark: isDark,
                      languageCode: languageCode,
                      children: results.categories.map((category) {
                        return _TextSuggestionItem(
                          text: category.name,
                          isDark: isDark,
                          languageCode: languageCode,
                          onTap: () => onSelect(category.name),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getPoetsTitle(String languageCode) {
    switch (languageCode) {
      case 'ur':
        return 'شعراء';
      case 'hi':
        return 'कवि';
      default:
        return 'Poets';
    }
  }

  String _getPoemsTitle(String languageCode) {
    switch (languageCode) {
      case 'ur':
        return 'کلام';
      case 'hi':
        return 'कविताएँ';
      default:
        return 'Poems';
    }
  }

  String _getTagsTitle(String languageCode) {
    switch (languageCode) {
      case 'ur':
        return 'ٹیگز';
      case 'hi':
        return 'टैग';
      default:
        return 'Tags';
    }
  }

  String _getCategoriesTitle(String languageCode) {
    switch (languageCode) {
      case 'ur':
        return 'زمرے';
      case 'hi':
        return 'श्रेणियाँ';
      default:
        return 'Categories';
    }
  }
}

/// Section header for suggestion groups
class _SuggestionSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isDark;
  final String languageCode;
  final List<Widget> children;

  const _SuggestionSection({
    required this.title,
    required this.icon,
    required this.isDark,
    required this.languageCode,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final isUrdu = languageCode == 'ur';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.xs,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: AppColors.secondary,
              ),
              SizedBox(width: AppSpacing.xs),
              Text(
                title,
                style: TextStyle(
                  fontFamily: isUrdu ? 'Jameel Noori Nastaleeq' : null,
                  fontSize: isUrdu ? 14 : 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondary,
                  height: isUrdu ? 1.8 : 1.4,
                ),
              ),
            ],
          ),
        ),

        // Items
        ...children,

        // Divider
        Divider(
          height: 1,
          color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
        ),
      ],
    );
  }
}

/// Poet suggestion item with image
class _PoetSuggestionItem extends StatelessWidget {
  final AutocompletePoet poet;
  final bool isDark;
  final String languageCode;
  final VoidCallback onTap;

  const _PoetSuggestionItem({
    required this.poet,
    required this.isDark,
    required this.languageCode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUrdu = _isUrduText(poet.name);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            // Avatar
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: poet.profileImageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: poet.profileImageUrl!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => _buildPlaceholder(),
                      errorWidget: (_, __, ___) => _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),
            ),

            SizedBox(width: AppSpacing.md),

            // Name
            Expanded(
              child: Text(
                poet.name,
                textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
                style: TextStyle(
                  fontFamily: isUrdu ? 'Jameel Noori Nastaleeq' : null,
                  fontSize: isUrdu ? 16 : 14,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                  height: isUrdu ? 1.8 : 1.4,
                ),
              ),
            ),

            // Arrow
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: isDark
                  ? AppColors.textDisabledDark
                  : AppColors.textDisabledLight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person_rounded,
        size: 20,
        color: AppColors.primary.withValues(alpha: 0.5),
      ),
    );
  }

  bool _isUrduText(String text) {
    final urduPattern = RegExp(r'[\u0600-\u06FF]');
    return urduPattern.hasMatch(text);
  }
}

/// Text-only suggestion item
class _TextSuggestionItem extends StatelessWidget {
  final String text;
  final String? subtitle;
  final bool isDark;
  final String languageCode;
  final VoidCallback onTap;

  const _TextSuggestionItem({
    required this.text,
    this.subtitle,
    required this.isDark,
    required this.languageCode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUrdu = _isUrduText(text);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
                    style: TextStyle(
                      fontFamily: isUrdu ? 'Jameel Noori Nastaleeq' : null,
                      fontSize: isUrdu ? 16 : 14,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                      height: isUrdu ? 1.8 : 1.4,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 2),
                    Text(
                      subtitle!,
                      textDirection: _isUrduText(subtitle!)
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      style: TextStyle(
                        fontFamily: _isUrduText(subtitle!)
                            ? 'Jameel Noori Nastaleeq'
                            : null,
                        fontSize: _isUrduText(subtitle!) ? 13 : 12,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                        height: _isUrduText(subtitle!) ? 1.6 : 1.3,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: isDark
                  ? AppColors.textDisabledDark
                  : AppColors.textDisabledLight,
            ),
          ],
        ),
      ),
    );
  }

  bool _isUrduText(String text) {
    final urduPattern = RegExp(r'[\u0600-\u06FF]');
    return urduPattern.hasMatch(text);
  }
}
