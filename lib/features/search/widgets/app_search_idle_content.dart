import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/providers/language_provider.dart';
import 'package:flutter_poetry_app/features/search/providers/global_search_provider.dart';
import 'package:flutter_poetry_app/features/discover/models/discover_bundle_model.dart';

/// Idle state content — shown when search input is empty.
///
/// Sections:
/// - حالیہ تلاش (Recent Searches) — horizontal chips from SharedPreferences
/// - مقبول تلاش (Trending) — gold-tinted chips from discover bundle
/// - مشہور شعراء (Popular Poets) — horizontal scroll cards
/// - مقبول زمرے (Categories) — wrapped chips
///
/// Zero-state: local data loads instantly, discover bundle from cache.
class AppSearchIdleContent extends ConsumerWidget {
  final ValueChanged<String> onRecentTap;
  final ValueChanged<String> onTrendingTap;
  final ValueChanged<ContentCard> onPoetTap;
  final ValueChanged<ContentCard> onCategoryTap;

  const AppSearchIdleContent({
    super.key,
    required this.onRecentTap,
    required this.onTrendingTap,
    required this.onPoetTap,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentSearches = ref.watch(
      globalSearchProvider.select((s) => s.recentSearches),
    );
    final trendingSearches = ref.watch(
      globalSearchProvider.select((s) => s.trendingSearches),
    );
    final discoverBundle = ref.watch(
      globalSearchProvider.select((s) => s.discoverBundle),
    );
    final languageCode = ref.watch(selectedLanguageProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUrdu = languageCode == 'ur';

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent Searches
          if (recentSearches.isNotEmpty)
            _RecentSearchesSection(
              searches: recentSearches,
              isDark: isDark,
              isUrdu: isUrdu,
              languageCode: languageCode,
              onTap: onRecentTap,
              onClear: () {
                // Clear handled by provider
              },
            ),

          // Trending Searches
          if (trendingSearches != null &&
              trendingSearches.searches.isNotEmpty)
            _TrendingSearchesSection(
              searches: trendingSearches.searches
                  .take(10)
                  .map((s) => s.query)
                  .toList(),
              isDark: isDark,
              isUrdu: isUrdu,
              languageCode: languageCode,
              onTap: onTrendingTap,
            ),

          // Popular Poets
          if (discoverBundle != null &&
              discoverBundle.featuredPoets.items.isNotEmpty)
            _PopularPoetsSection(
              poets: discoverBundle.featuredPoets.items,
              isDark: isDark,
              isUrdu: isUrdu,
              languageCode: languageCode,
              onTap: onPoetTap,
            ),

          // Popular Categories
          if (discoverBundle != null &&
              discoverBundle.categories.items.isNotEmpty)
            _CategoriesSection(
              categories: discoverBundle.categories.items,
              isDark: isDark,
              isUrdu: isUrdu,
              languageCode: languageCode,
              onTap: onCategoryTap,
            ),

          SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section: Recent Searches
// ---------------------------------------------------------------------------

class _RecentSearchesSection extends StatelessWidget {
  final List<String> searches;
  final bool isDark;
  final bool isUrdu;
  final String languageCode;
  final ValueChanged<String> onTap;
  final VoidCallback onClear;

  const _RecentSearchesSection({
    required this.searches,
    required this.isDark,
    required this.isUrdu,
    required this.languageCode,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                Icon(Icons.history_rounded, size: 20, color: AppColors.primary),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    _title(languageCode),
                    style: _headerStyle(isUrdu, isDark),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.sm),

          // Horizontal chips
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
              itemCount: searches.length,
              separatorBuilder: (_, __) => SizedBox(width: AppSpacing.sm),
              itemBuilder: (_, index) {
                final query = searches[index];
                final isQueryUrdu = _isUrduText(query);
                return GestureDetector(
                  onTap: () => onTap(query),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.surfaceDark
                          : AppColors.verseBackground,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                      ),
                    ),
                    child: Text(
                      query,
                      textDirection:
                          isQueryUrdu ? TextDirection.rtl : TextDirection.ltr,
                      style: TextStyle(
                        fontFamily:
                            isQueryUrdu ? 'Jameel Noori Nastaleeq' : null,
                        fontSize: isQueryUrdu ? 14 : 13,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                        height: isQueryUrdu ? 1.8 : 1.4,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _title(String lang) {
    switch (lang) {
      case 'ur':
        return 'حالیہ تلاش';
      case 'hi':
        return 'हालिया खोज';
      default:
        return 'Recent Searches';
    }
  }
}

// ---------------------------------------------------------------------------
// Section: Trending Searches
// ---------------------------------------------------------------------------

class _TrendingSearchesSection extends StatelessWidget {
  final List<String> searches;
  final bool isDark;
  final bool isUrdu;
  final String languageCode;
  final ValueChanged<String> onTap;

  const _TrendingSearchesSection({
    required this.searches,
    required this.isDark,
    required this.isUrdu,
    required this.languageCode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                Icon(Icons.local_fire_department_rounded,
                    size: 20, color: AppColors.secondary),
                SizedBox(width: AppSpacing.sm),
                Text(
                  _title(languageCode),
                  style: _headerStyle(isUrdu, isDark),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.sm),

          // Horizontal chips with gold tint
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
              itemCount: searches.length,
              separatorBuilder: (_, __) => SizedBox(width: AppSpacing.sm),
              itemBuilder: (_, index) {
                final query = searches[index];
                final isQueryUrdu = _isUrduText(query);
                return GestureDetector(
                  onTap: () => onTap(query),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.secondary.withValues(alpha: 0.08),
                          AppColors.secondary.withValues(alpha: 0.15),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.secondary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      query,
                      textDirection:
                          isQueryUrdu ? TextDirection.rtl : TextDirection.ltr,
                      style: TextStyle(
                        fontFamily:
                            isQueryUrdu ? 'Jameel Noori Nastaleeq' : null,
                        fontSize: isQueryUrdu ? 14 : 13,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                        height: isQueryUrdu ? 1.8 : 1.4,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _title(String lang) {
    switch (lang) {
      case 'ur':
        return 'مقبول تلاش';
      case 'hi':
        return 'लोकप्रिय खोज';
      default:
        return 'Trending';
    }
  }
}

// ---------------------------------------------------------------------------
// Section: Popular Poets
// ---------------------------------------------------------------------------

class _PopularPoetsSection extends StatelessWidget {
  final List<ContentCard> poets;
  final bool isDark;
  final bool isUrdu;
  final String languageCode;
  final ValueChanged<ContentCard> onTap;

  const _PopularPoetsSection({
    required this.poets,
    required this.isDark,
    required this.isUrdu,
    required this.languageCode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                Icon(Icons.star_rounded, size: 20, color: AppColors.secondary),
                SizedBox(width: AppSpacing.sm),
                Text(
                  _title(languageCode),
                  style: _headerStyle(isUrdu, isDark),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.md),

          // Horizontal scroll
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
              itemCount: poets.length,
              separatorBuilder: (_, __) => SizedBox(width: AppSpacing.md),
              itemBuilder: (_, index) {
                final poet = poets[index];
                return GestureDetector(
                  onTap: () => onTap(poet),
                  child: SizedBox(
                    width: 90,
                    child: Column(
                      children: [
                        // Avatar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(35),
                          child: poet.imageUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: poet.imageUrl!,
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                  memCacheWidth: 140,
                                  placeholder: (_, __) =>
                                      _poetPlaceholder(),
                                  errorWidget: (_, __, ___) =>
                                      _poetPlaceholder(),
                                )
                              : _poetPlaceholder(),
                        ),
                        SizedBox(height: AppSpacing.sm),
                        // Name
                        Text(
                          poet.primaryText,
                          textDirection: _isUrduText(poet.primaryText)
                              ? TextDirection.rtl
                              : TextDirection.ltr,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: _isUrduText(poet.primaryText)
                                ? 'Jameel Noori Nastaleeq'
                                : null,
                            fontSize: _isUrduText(poet.primaryText) ? 12 : 11,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                            height:
                                _isUrduText(poet.primaryText) ? 1.5 : 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _poetPlaceholder() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person_rounded,
        size: 32,
        color: AppColors.primary.withValues(alpha: 0.5),
      ),
    );
  }

  String _title(String lang) {
    switch (lang) {
      case 'ur':
        return 'مشہور شعراء';
      case 'hi':
        return 'प्रसिद्ध कवि';
      default:
        return 'Popular Poets';
    }
  }
}

// ---------------------------------------------------------------------------
// Section: Categories
// ---------------------------------------------------------------------------

class _CategoriesSection extends StatelessWidget {
  final List<ContentCard> categories;
  final bool isDark;
  final bool isUrdu;
  final String languageCode;
  final ValueChanged<ContentCard> onTap;

  const _CategoriesSection({
    required this.categories,
    required this.isDark,
    required this.isUrdu,
    required this.languageCode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                Icon(Icons.category_rounded,
                    size: 20, color: AppColors.primary),
                SizedBox(width: AppSpacing.sm),
                Text(
                  _title(languageCode),
                  style: _headerStyle(isUrdu, isDark),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.md),

          // Wrapped chips
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: categories.map((cat) {
                final isTextUrdu = _isUrduText(cat.primaryText);
                return GestureDetector(
                  onTap: () => onTap(cat),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      cat.primaryText,
                      textDirection:
                          isTextUrdu ? TextDirection.rtl : TextDirection.ltr,
                      style: TextStyle(
                        fontFamily:
                            isTextUrdu ? 'Jameel Noori Nastaleeq' : null,
                        fontSize: isTextUrdu ? 14 : 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                        height: isTextUrdu ? 1.8 : 1.4,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _title(String lang) {
    switch (lang) {
      case 'ur':
        return 'مقبول زمرے';
      case 'hi':
        return 'लोकप्रिय श्रेणियाँ';
      default:
        return 'Categories';
    }
  }
}

// ---------------------------------------------------------------------------
// Shared helpers
// ---------------------------------------------------------------------------

TextStyle _headerStyle(bool isUrdu, bool isDark) {
  return TextStyle(
    fontFamily: isUrdu ? 'Jameel Noori Nastaleeq' : null,
    fontSize: isUrdu ? 18 : 16,
    fontWeight: FontWeight.w600,
    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
    height: isUrdu ? 1.8 : 1.4,
  );
}

bool _isUrduText(String text) {
  return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
}
