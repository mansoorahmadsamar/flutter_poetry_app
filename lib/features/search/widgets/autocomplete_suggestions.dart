import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/widgets/localized_text.dart';
import 'package:flutter_poetry_app/core/providers/language_provider.dart';
import 'package:flutter_poetry_app/features/search/models/search_models.dart';
import 'package:flutter_poetry_app/features/search/providers/global_search_provider.dart';

/// Autocomplete suggestions overlay widget
///
/// Features:
/// - Grouped suggestions (Poets max 3, Poems max 5, Tags max 3, Categories max 3)
/// - Section headers with icons
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

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.12),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.4)
                : Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
        children: [
          // Poets Section
          if (suggestions.poets.isNotEmpty) ...[
            _buildSectionHeader(
              context,
              _getLabel('Poets', languageCode),
              Icons.person_outline,
              isDark,
            ),
            ...suggestions.poets.map((poet) => _buildPoetItem(
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
    );
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
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: isDark
                ? Colors.white.withValues(alpha: 0.6)
                : Colors.black.withValues(alpha: 0.6),
          ),
          SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.7)
                  : Colors.black.withValues(alpha: 0.7),
            ),
          ),
        ],
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
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 2,
      ),
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: AppColors.primary.withValues(alpha: 0.2),
        child: Text(
          poet.name.isNotEmpty ? poet.name[0] : 'P',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ),
      title: LocalizedText(
        poet.name,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      subtitle: poet.era != null
          ? Text(
              poet.era!,
              style: TextStyle(
                fontSize: 11,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.5)
                    : Colors.black.withValues(alpha: 0.5),
              ),
            )
          : null,
      onTap: () {
        // Navigate to poet detail screen
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
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 2,
      ),
      title: LocalizedText(
        poem.title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      subtitle: Text(
        poem.poetName,
        style: TextStyle(
          fontSize: 11,
          color: isDark
              ? Colors.white.withValues(alpha: 0.5)
              : Colors.black.withValues(alpha: 0.5),
        ),
      ),
      onTap: () {
        // Navigate to poem detail screen
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
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 2,
      ),
      leading: Icon(
        Icons.tag,
        size: 18,
        color: isDark
            ? Colors.white.withValues(alpha: 0.5)
            : Colors.black.withValues(alpha: 0.5),
      ),
      title: LocalizedText(
        tag.name,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      trailing: Text(
        tag.tagType,
        style: TextStyle(
          fontSize: 11,
          color: isDark
              ? Colors.white.withValues(alpha: 0.5)
              : Colors.black.withValues(alpha: 0.5),
        ),
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
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 2,
      ),
      leading: Icon(
        Icons.folder_outlined,
        size: 18,
        color: isDark
            ? Colors.white.withValues(alpha: 0.5)
            : Colors.black.withValues(alpha: 0.5),
      ),
      title: LocalizedText(
        category.name,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      trailing: category.poemCount > 0
          ? Text(
              '${category.poemCount}',
              style: TextStyle(
                fontSize: 11,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.5)
                    : Colors.black.withValues(alpha: 0.5),
              ),
            )
          : null,
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
        vertical: AppSpacing.xs,
      ),
      child: Divider(
        height: 1,
        color: isDark
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.black.withValues(alpha: 0.1),
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
}
