import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/providers/language_provider.dart';
import 'package:flutter_poetry_app/core/widgets/localized_text.dart';
import 'package:flutter_poetry_app/features/search/providers/global_search_provider.dart';
import 'package:flutter_poetry_app/features/search/models/search_models.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/widgets/couplet_card.dart';
import 'package:flutter_poetry_app/features/search/utils/search_adapters.dart';

/// Search results section with expandable categories
///
/// Features:
/// - Semantic summary header (language-aware result count)
/// - Sort & filter row
/// - Expandable sections (Couplets top 5, Poems top 3, Poets top 3)
/// - "See All" buttons for each section
/// - Related searches at bottom
class SearchResultsSection extends ConsumerWidget {
  const SearchResultsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(globalSearchProvider);
    final languageCode = ref.watch(selectedLanguageProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (searchState.coupletResults == null) {
      return const SizedBox.shrink();
    }

    final results = searchState.coupletResults!;
    final couplets = results.content;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Semantic summary header
        _buildSummaryHeader(
          context,
          searchState.currentQuery,
          results.totalElements,
          languageCode,
          isDark,
        ),

        SizedBox(height: AppSpacing.md),

        // Sort & Filter row
        _buildSortFilterRow(context, ref, searchState, languageCode, isDark),

        SizedBox(height: AppSpacing.md),

        // Couplets section (expandable, top 5)
        if (couplets.isNotEmpty) ...[
          _buildSectionHeader(
            context,
            _getLabel('Couplets', languageCode),
            couplets.length,
            results.totalElements,
            isDark,
          ),
          SizedBox(height: AppSpacing.sm),
          ...couplets.take(5).map((couplet) => _buildCoupletResultCard(
                context,
                ref,
                couplet,
              )),
          if (results.totalElements > 5)
            _buildSeeAllButton(
              context,
              _getLabel('See All Couplets', languageCode),
              () {
                context.pushNamed(
                  'category-results',
                  pathParameters: {'category': 'couplets'},
                  extra: {
                    'query': searchState.currentQuery,
                    'sortBy': searchState.sortBy,
                  },
                );
              },
              isDark,
            ),
          SizedBox(height: AppSpacing.lg),
        ],

        // Related searches section
        if (searchState.relatedSearches != null &&
            searchState.relatedSearches!.relatedSearches.isNotEmpty) ...[
          _buildRelatedSearches(
            context,
            ref,
            searchState.relatedSearches!.relatedSearches,
            languageCode,
            isDark,
          ),
        ],
      ],
    );
  }

  /// Build semantic summary header
  Widget _buildSummaryHeader(
    BuildContext context,
    String query,
    int totalResults,
    String languageCode,
    bool isDark,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Query title
          LocalizedText(
            query,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: AppSpacing.xs),

          // Results count
          Text(
            _getResultsCountText(totalResults, languageCode),
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.7)
                  : Colors.black.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// Build sort and filter row
  Widget _buildSortFilterRow(
    BuildContext context,
    WidgetRef ref,
    dynamic searchState,
    String languageCode,
    bool isDark,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          // Sort dropdown
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.1),
              ),
            ),
            child: DropdownButton<String>(
              value: searchState.sortBy,
              isDense: true,
              underline: const SizedBox(),
              icon: Icon(
                Icons.arrow_drop_down,
                color: isDark ? Colors.white : Colors.black87,
              ),
              items: [
                'relevance',
                'likes',
                'shares',
                'bookmarks',
                'trending',
              ].map((sort) {
                return DropdownMenuItem(
                  value: sort,
                  child: Text(
                    _getSortLabel(sort, languageCode),
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  ref.read(globalSearchProvider.notifier).setSortBy(value);
                }
              },
            ),
          ),

          SizedBox(width: AppSpacing.sm),

          // Filter button (poet filter - future enhancement)
          OutlinedButton.icon(
            onPressed: () {
              // TODO: Show poet filter bottom sheet
            },
            icon: Icon(
              Icons.filter_list,
              size: 16,
              color: isDark ? Colors.white : Colors.black87,
            ),
            label: Text(
              _getLabel('Filter', languageCode),
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              side: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build section header
  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    int showing,
    int total,
    bool isDark,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          Text(
            '$showing of $total',
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.6)
                  : Colors.black.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  /// Build couplet result card
  Widget _buildCoupletResultCard(
    BuildContext context,
    WidgetRef ref,
    CoupletSearchResult couplet,
  ) {
    return CoupletCard(
      couplet: convertSearchResultToCoupletModel(couplet),
      // TODO: Add navigation when poem publicId is available from search API
      // For now, keep null to disable tap (user can still use like/bookmark/share actions)
      onTap: null,
    );
  }

  /// Build "See All" button
  Widget _buildSeeAllButton(
    BuildContext context,
    String label,
    VoidCallback onTap,
    bool isDark,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Center(
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            side: BorderSide(
              color: AppColors.primary,
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  /// Build related searches section
  Widget _buildRelatedSearches(
    BuildContext context,
    WidgetRef ref,
    List<dynamic> relatedSearches,
    String languageCode,
    bool isDark,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getLabel('Related Searches', languageCode),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.9)
                  : Colors.black.withValues(alpha: 0.9),
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: relatedSearches.map((search) {
              final query = search.query ?? search.toString();
              return ActionChip(
                label: Text(query),
                labelStyle: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                backgroundColor: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.05),
                side: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.1),
                  width: 1,
                ),
                onPressed: () {
                  ref.read(globalSearchProvider.notifier).executeSearch(
                    query: query,
                  );
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Get localized results count text
  String _getResultsCountText(int count, String languageCode) {
    switch (languageCode) {
      case 'ur':
        return '$count اشعار ملے';
      case 'hi':
        return '$count छंद मिले';
      case 'en':
      default:
        return '$count couplets found';
    }
  }

  /// Get localized sort label
  String _getSortLabel(String sort, String languageCode) {
    final labels = {
      'ur': {
        'relevance': 'مطابقت',
        'likes': 'پسندیدگی',
        'shares': 'اشتراک',
        'bookmarks': 'بک مارک',
        'trending': 'مقبول',
      },
      'hi': {
        'relevance': 'प्रासंगिकता',
        'likes': 'पसंद',
        'shares': 'साझा',
        'bookmarks': 'बुकमार्क',
        'trending': 'ट्रेंडिंग',
      },
      'en': {
        'relevance': 'Relevance',
        'likes': 'Likes',
        'shares': 'Shares',
        'bookmarks': 'Bookmarks',
        'trending': 'Trending',
      },
    };

    return labels[languageCode]?[sort] ?? labels['en']![sort]!;
  }

  /// Get localized label
  String _getLabel(String key, String languageCode) {
    final labels = {
      'ur': {
        'Couplets': 'اشعار',
        'See All Couplets': 'تمام اشعار دیکھیں',
        'Filter': 'فلٹر',
        'Related Searches': 'متعلقہ تلاش',
      },
      'hi': {
        'Couplets': 'छंद',
        'See All Couplets': 'सभी छंद देखें',
        'Filter': 'फ़िल्टर',
        'Related Searches': 'संबंधित खोजें',
      },
      'en': {
        'Couplets': 'Couplets',
        'See All Couplets': 'See All Couplets',
        'Filter': 'Filter',
        'Related Searches': 'Related Searches',
      },
    };

    return labels[languageCode]?[key] ?? labels['en']![key]!;
  }
}
