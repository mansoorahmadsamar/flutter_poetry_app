import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/providers/language_provider.dart';
import 'package:flutter_poetry_app/features/search/models/search_models.dart';
import 'package:flutter_poetry_app/features/search/providers/global_search_provider.dart';
import 'package:flutter_poetry_app/features/search/widgets/top_match_card.dart';

/// Autocomplete suggestions overlay widget
///
/// Features:
/// - Top match card (first poet or poem result)
/// - Grouped suggestions (Poets max 3, Poems max 5, Tags max 3, Categories max 3)
/// - Bilingual section headers
/// - Poet avatars with CircleAvatar
/// - Tap actions: Navigate to detail OR execute search
/// - Floating card with shadow and border
/// - Language-aware text display
class AutocompleteSuggestions extends ConsumerWidget {
  final AutocompleteResponse suggestions;

  const AutocompleteSuggestions({
    super.key,
    required this.suggestions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final languageCode = ref.watch(selectedLanguageProvider);

    if (suggestions.totalCount == 0) {
      return const SizedBox.shrink();
    }

    // Get top match (first poet or first poem)
    final hasTopMatch = suggestions.poets.isNotEmpty || suggestions.poems.isNotEmpty;

    return Column(
      children: [
        // Top Match Card
        if (hasTopMatch) _buildTopMatch(context, suggestions),

        // Grouped Suggestions
        Container(
          margin: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.06),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.5)
                    : Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            children: [
              // Poets Section (skip first if shown as top match)
              if (suggestions.poets.isNotEmpty) ...[
                _buildSectionHeader(
                  context,
                  _getLabel('Poets', languageCode),
                  Icons.person_outline,
                  isDark,
                ),
                ...suggestions.poets.skip(1).map((poet) => _buildPoetItem(
                      context,
                      ref,
                      poet,
                      isDark,
                    )),
                if (_hasMoreSections(suggestions)) _buildDivider(isDark),
              ],

          // Poems Section
          if (suggestions.poems.isNotEmpty) ...[
            _buildSectionHeader(
              context,
              _getLabel('Poems', languageCode),
              Icons.auto_stories_outlined,
              isDark,
            ),
            ...suggestions.poems.map((poem) => _buildPoemItem(
                  context,
                  ref,
                  poem,
                  isDark,
                )),
            if (suggestions.tags.isNotEmpty || suggestions.categories.isNotEmpty)
              _buildDivider(isDark),
          ],

          // Tags Section
          if (suggestions.tags.isNotEmpty) ...[
            _buildSectionHeader(
              context,
              _getLabel('Tags', languageCode),
              Icons.label_outline,
              isDark,
            ),
            ...suggestions.tags.map((tag) => _buildTagItem(
                  context,
                  ref,
                  tag,
                  isDark,
                )),
            if (suggestions.categories.isNotEmpty) _buildDivider(isDark),
          ],

          // Categories Section
          if (suggestions.categories.isNotEmpty) ...[
            _buildSectionHeader(
              context,
              _getLabel('Categories', languageCode),
              Icons.category_outlined,
              isDark,
            ),
            ...suggestions.categories.map((category) => _buildCategoryItem(
                  context,
                  ref,
                  category,
                  isDark,
                )),
          ],
        ],
      ),
        ),
      ],
    );
  }

  /// Build top match card
  Widget _buildTopMatch(BuildContext context, AutocompleteResponse suggestions) {
    // Prioritize poet, fallback to poem
    if (suggestions.poets.isNotEmpty) {
      final poet = suggestions.poets.first;
      return TopMatchCard(
        title: poet.name,
        type: 'poet',
        subtitle: poet.era,
        imageUrl: null, // Could add poet image URL if available
        onTap: () {
          context.pushNamed(
            'poet-detail',
            pathParameters: {'publicId': poet.publicId},
          );
        },
      );
    } else if (suggestions.poems.isNotEmpty) {
      final poem = suggestions.poems.first;
      return TopMatchCard(
        title: poem.title,
        type: 'poem',
        subtitle: poem.poetName,
        imageUrl: null,
        onTap: () {
          context.pushNamed(
            'poem-detail',
            pathParameters: {'publicId': poem.publicId},
          );
        },
      );
    }
    return const SizedBox.shrink();
  }

  /// Build section header with icon
  Widget _buildSectionHeader(
    BuildContext context,
    String label,
    IconData icon,
    bool isDark,
  ) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: AppColors.primary.withValues(alpha: 0.7),
        ),
      ),
    );
  }

  /// Build poet suggestion item
  Widget _buildPoetItem(
    BuildContext context,
    WidgetRef ref,
    AutocompletePoet poet,
    bool isDark,
  ) {
    final isUrdu = _isUrduText(poet.name);

    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: AppColors.primary.withValues(alpha: 0.15),
        child: Text(
          poet.name.isNotEmpty ? poet.name[0] : 'P',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            fontFamily: isUrdu ? 'Jameel Noori Nastaleeq' : null,
            color: AppColors.primary,
          ),
        ),
      ),
      title: Text(
        poet.name,
        textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
        style: TextStyle(
          fontSize: isUrdu ? 17 : 15,
          fontFamily: isUrdu ? 'Jameel Noori Nastaleeq' : null,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : Colors.black87,
          height: isUrdu ? 1.8 : 1.3,
        ),
      ),
      subtitle: poet.era != null
          ? Text(
              poet.era!,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.4)
                    : Colors.black.withValues(alpha: 0.4),
              ),
            )
          : null,
      onTap: () {
        context.pushNamed(
          'poet-detail',
          pathParameters: {'publicId': poet.publicId},
        );
      },
    );
  }

  /// Build poem suggestion item
  Widget _buildPoemItem(
    BuildContext context,
    WidgetRef ref,
    AutocompletePoem poem,
    bool isDark,
  ) {
    final isUrdu = _isUrduText(poem.title);

    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      title: Text(
        poem.title,
        textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
        style: TextStyle(
          fontSize: isUrdu ? 17 : 15,
          fontFamily: isUrdu ? 'Jameel Noori Nastaleeq' : null,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : Colors.black87,
          height: isUrdu ? 1.8 : 1.3,
        ),
      ),
      subtitle: Text(
        poem.poetName,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.secondary,
          letterSpacing: 0.2,
        ),
      ),
      onTap: () {
        context.pushNamed(
          'poem-detail',
          pathParameters: {'publicId': poem.publicId},
        );
      },
    );
  }

  /// Build tag suggestion item
  Widget _buildTagItem(
    BuildContext context,
    WidgetRef ref,
    AutocompleteTag tag,
    bool isDark,
  ) {
    final isUrdu = _isUrduText(tag.name);

    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 6,
      ),
      title: Text(
        tag.name,
        textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
        style: TextStyle(
          fontSize: isUrdu ? 16 : 14,
          fontFamily: isUrdu ? 'Jameel Noori Nastaleeq' : null,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : Colors.black87,
          height: isUrdu ? 1.8 : 1.3,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 12,
        color: isDark
            ? Colors.white.withValues(alpha: 0.3)
            : Colors.black.withValues(alpha: 0.3),
      ),
      onTap: () {
        ref.read(globalSearchProvider.notifier).executeSearch(query: tag.name);
      },
    );
  }

  /// Build category suggestion item
  Widget _buildCategoryItem(
    BuildContext context,
    WidgetRef ref,
    AutocompleteCategory category,
    bool isDark,
  ) {
    final isUrdu = _isUrduText(category.name);

    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 6,
      ),
      title: Text(
        category.name,
        textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
        style: TextStyle(
          fontSize: isUrdu ? 16 : 14,
          fontFamily: isUrdu ? 'Jameel Noori Nastaleeq' : null,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : Colors.black87,
          height: isUrdu ? 1.8 : 1.3,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (category.poemCount > 0)
            Text(
              '${category.poemCount}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.4)
                    : Colors.black.withValues(alpha: 0.4),
              ),
            ),
          SizedBox(width: AppSpacing.xs),
          Icon(
            Icons.arrow_forward_ios,
            size: 12,
            color: isDark
                ? Colors.white.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.3),
          ),
        ],
      ),
      onTap: () {
        ref.read(globalSearchProvider.notifier).executeSearch(query: category.name);
      },
    );
  }

  /// Build divider between sections
  Widget _buildDivider(bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Divider(
        height: 1,
        thickness: 1,
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.04),
      ),
    );
  }

  /// Check if there are more sections after poets
  bool _hasMoreSections(AutocompleteResponse suggestions) {
    return suggestions.poems.isNotEmpty ||
        suggestions.tags.isNotEmpty ||
        suggestions.categories.isNotEmpty;
  }

  /// Get localized label
  String _getLabel(String key, String languageCode) {
    final labels = {
      'ur': {
        'Poets': 'شاعر',
        'Poems': 'نظمیں / غزلیں',
        'Tags': 'ٹیگز',
        'Categories': 'زمرے',
      },
      'hi': {
        'Poets': 'कवि',
        'Poems': 'कविताएं',
        'Tags': 'टैग',
        'Categories': 'श्रेणियाँ',
      },
      'en': {
        'Poets': 'Poets',
        'Poems': 'Poems',
        'Tags': 'Tags',
        'Categories': 'Categories',
      },
    };

    return labels[languageCode]?[key] ?? labels['en']![key]!;
  }

  /// Detect if text is primarily Urdu
  bool _isUrduText(String text) {
    final urduPattern = RegExp(r'[\u0600-\u06FF]');
    final urduMatches = urduPattern.allMatches(text).length;
    return urduMatches > text.length / 3;
  }
}
