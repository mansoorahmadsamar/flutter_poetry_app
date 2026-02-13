import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/providers/language_provider.dart';
import 'package:flutter_poetry_app/features/search/providers/global_search_provider.dart';
import 'package:flutter_poetry_app/features/search/providers/search_providers.dart';

/// Discovery content shown before user starts typing
///
/// Sections:
/// - Recent Searches (chips)
/// - Trending Searches (chips with fire icon)
/// - Top Poets (horizontal scroll cards)
/// - Popular Tags (chips)
class SearchDiscoveryContent extends ConsumerWidget {
  const SearchDiscoveryContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageCode = ref.watch(selectedLanguageProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final searchState = ref.watch(globalSearchProvider);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent Searches
          if (searchState.recentSearches.isNotEmpty)
            _RecentSearchesSection(
              searches: searchState.recentSearches,
              languageCode: languageCode,
              isDark: isDark,
              onTap: (query) {
                ref.read(globalSearchProvider.notifier).executeSearch(query: query);
              },
              onClear: () async {
                // Clear via the search history provider
                await ref.read(searchHistoryProvider.notifier).clearAll();
                // Reload the search state
                ref.invalidate(globalSearchProvider);
              },
            ),

          // Trending Searches
          if (searchState.trendingSearches != null &&
              searchState.trendingSearches!.searches.isNotEmpty)
            _TrendingSearchesSection(
              searches: searchState.trendingSearches!.searches,
              languageCode: languageCode,
              isDark: isDark,
              onTap: (query) {
                ref.read(globalSearchProvider.notifier).executeSearch(query: query);
              },
            ),

          // Top Poets
          _TopPoetsSection(
            languageCode: languageCode,
            isDark: isDark,
          ),

          // Popular Categories
          _PopularCategoriesSection(
            languageCode: languageCode,
            isDark: isDark,
          ),

          SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

/// Recent Searches Section
class _RecentSearchesSection extends StatelessWidget {
  final List<String> searches;
  final String languageCode;
  final bool isDark;
  final ValueChanged<String> onTap;
  final VoidCallback onClear;

  const _RecentSearchesSection({
    required this.searches,
    required this.languageCode,
    required this.isDark,
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.history_rounded,
                      size: 20,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      _getTitle(),
                      style: TextStyle(
                        fontFamily: languageCode == 'ur'
                            ? 'Jameel Noori Nastaleeq'
                            : null,
                        fontSize: languageCode == 'ur' ? 18 : 16,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                        height: languageCode == 'ur' ? 1.8 : 1.4,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: onClear,
                  child: Text(
                    languageCode == 'ur' ? 'صاف کریں' : 'Clear',
                    style: TextStyle(
                      fontFamily: languageCode == 'ur'
                          ? 'Jameel Noori Nastaleeq'
                          : null,
                      fontSize: languageCode == 'ur' ? 14 : 12,
                      color: AppColors.primary,
                      height: languageCode == 'ur' ? 1.8 : 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: AppSpacing.sm),

          // Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: searches.map((search) {
                final isUrdu = _isUrduText(search);
                return Padding(
                  padding: EdgeInsetsDirectional.only(end: AppSpacing.sm),
                  child: _SearchChip(
                    label: search,
                    isUrdu: isUrdu,
                    isDark: isDark,
                    onTap: () => onTap(search),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _getTitle() {
    switch (languageCode) {
      case 'ur':
        return 'حالیہ تلاش';
      case 'hi':
        return 'हाल की खोज';
      default:
        return 'Recent Searches';
    }
  }

  bool _isUrduText(String text) {
    final urduPattern = RegExp(r'[\u0600-\u06FF]');
    return urduPattern.hasMatch(text);
  }
}

/// Trending Searches Section
class _TrendingSearchesSection extends StatelessWidget {
  final List<dynamic> searches;
  final String languageCode;
  final bool isDark;
  final ValueChanged<String> onTap;

  const _TrendingSearchesSection({
    required this.searches,
    required this.languageCode,
    required this.isDark,
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
                Icon(
                  Icons.local_fire_department_rounded,
                  size: 20,
                  color: AppColors.secondary,
                ),
                SizedBox(width: AppSpacing.sm),
                Text(
                  _getTitle(),
                  style: TextStyle(
                    fontFamily: languageCode == 'ur'
                        ? 'Jameel Noori Nastaleeq'
                        : null,
                    fontSize: languageCode == 'ur' ? 18 : 16,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                    height: languageCode == 'ur' ? 1.8 : 1.4,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: AppSpacing.sm),

          // Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: searches.take(10).map((search) {
                final query = search.query ?? search.toString();
                final isUrdu = _isUrduText(query);
                return Padding(
                  padding: EdgeInsetsDirectional.only(end: AppSpacing.sm),
                  child: _TrendingChip(
                    label: query,
                    isUrdu: isUrdu,
                    isDark: isDark,
                    onTap: () => onTap(query),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _getTitle() {
    switch (languageCode) {
      case 'ur':
        return 'مقبول تلاش';
      case 'hi':
        return 'ट्रेंडिंग';
      default:
        return 'Trending';
    }
  }

  bool _isUrduText(String text) {
    final urduPattern = RegExp(r'[\u0600-\u06FF]');
    return urduPattern.hasMatch(text);
  }
}

/// Top Poets Section
class _TopPoetsSection extends ConsumerWidget {
  final String languageCode;
  final bool isDark;

  const _TopPoetsSection({
    required this.languageCode,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestedPoets = ref.watch(suggestedPoetsProvider);

    return suggestedPoets.when(
      data: (response) {
        if (response.content.isEmpty) return const SizedBox.shrink();

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
                    Icon(
                      Icons.star_rounded,
                      size: 20,
                      color: AppColors.secondary,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      _getTitle(),
                      style: TextStyle(
                        fontFamily: languageCode == 'ur'
                            ? 'Jameel Noori Nastaleeq'
                            : null,
                        fontSize: languageCode == 'ur' ? 18 : 16,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                        height: languageCode == 'ur' ? 1.8 : 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppSpacing.md),

              // Horizontal Scroll
              SizedBox(
                height: 140,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  itemCount: response.content.length,
                  itemBuilder: (context, index) {
                    final poet = response.content[index];
                    return Padding(
                      padding: EdgeInsetsDirectional.only(end: AppSpacing.md),
                      child: _PoetCard(
                        name: poet.name,
                        imageUrl: poet.profileImageUrl,
                        isDark: isDark,
                        languageCode: languageCode,
                        onTap: () {
                          context.push('/main/poets/${poet.publicId}');
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  String _getTitle() {
    switch (languageCode) {
      case 'ur':
        return 'مشہور شعراء';
      case 'hi':
        return 'प्रसिद्ध कवि';
      default:
        return 'Popular Poets';
    }
  }
}

/// Popular Categories Section
class _PopularCategoriesSection extends StatelessWidget {
  final String languageCode;
  final bool isDark;

  const _PopularCategoriesSection({
    required this.languageCode,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final categories = _getCategories();

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
                Icon(
                  Icons.category_rounded,
                  size: 20,
                  color: AppColors.primary,
                ),
                SizedBox(width: AppSpacing.sm),
                Text(
                  _getTitle(),
                  style: TextStyle(
                    fontFamily: languageCode == 'ur'
                        ? 'Jameel Noori Nastaleeq'
                        : null,
                    fontSize: languageCode == 'ur' ? 18 : 16,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                    height: languageCode == 'ur' ? 1.8 : 1.4,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: AppSpacing.md),

          // Grid of Categories
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: categories.map((category) {
                return _CategoryChip(
                  label: category.label,
                  icon: category.icon,
                  isDark: isDark,
                  languageCode: languageCode,
                  onTap: () {
                    // TODO: Navigate to category
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _getTitle() {
    switch (languageCode) {
      case 'ur':
        return 'مقبول زمرے';
      case 'hi':
        return 'लोकप्रिय श्रेणियाँ';
      default:
        return 'Popular Categories';
    }
  }

  List<_CategoryItem> _getCategories() {
    return [
      _CategoryItem(
        label: languageCode == 'ur' ? 'غزل' : 'Ghazal',
        icon: Icons.auto_stories_rounded,
      ),
      _CategoryItem(
        label: languageCode == 'ur' ? 'نظم' : 'Nazm',
        icon: Icons.article_rounded,
      ),
      _CategoryItem(
        label: languageCode == 'ur' ? 'رباعی' : 'Rubaai',
        icon: Icons.format_quote_rounded,
      ),
      _CategoryItem(
        label: languageCode == 'ur' ? 'مرثیہ' : 'Marsiya',
        icon: Icons.menu_book_rounded,
      ),
      _CategoryItem(
        label: languageCode == 'ur' ? 'قصیدہ' : 'Qasida',
        icon: Icons.library_books_rounded,
      ),
      _CategoryItem(
        label: languageCode == 'ur' ? 'حمد' : 'Hamd',
        icon: Icons.brightness_7_rounded,
      ),
      _CategoryItem(
        label: languageCode == 'ur' ? 'نعت' : 'Naat',
        icon: Icons.favorite_rounded,
      ),
      _CategoryItem(
        label: languageCode == 'ur' ? 'سلام' : 'Salam',
        icon: Icons.waving_hand_rounded,
      ),
    ];
  }
}

class _CategoryItem {
  final String label;
  final IconData icon;

  const _CategoryItem({
    required this.label,
    required this.icon,
  });
}

/// Search Chip Widget
class _SearchChip extends StatelessWidget {
  final String label;
  final bool isUrdu;
  final bool isDark;
  final VoidCallback onTap;

  const _SearchChip({
    required this.label,
    required this.isUrdu,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.backgroundDark
              : AppColors.verseBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: Text(
          label,
          textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
          style: TextStyle(
            fontFamily: isUrdu ? 'Jameel Noori Nastaleeq' : null,
            fontSize: isUrdu ? 15 : 13,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
            height: isUrdu ? 1.8 : 1.4,
          ),
        ),
      ),
    );
  }
}

/// Trending Chip Widget (with fire accent)
class _TrendingChip extends StatelessWidget {
  final String label;
  final bool isUrdu;
  final bool isDark;
  final VoidCallback onTap;

  const _TrendingChip({
    required this.label,
    required this.isUrdu,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.secondary.withValues(alpha: 0.15),
              AppColors.secondary.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.secondary.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
          style: TextStyle(
            fontFamily: isUrdu ? 'Jameel Noori Nastaleeq' : null,
            fontSize: isUrdu ? 15 : 13,
            fontWeight: FontWeight.w500,
            color: isDark
                ? AppColors.secondary
                : AppColors.secondaryDark,
            height: isUrdu ? 1.8 : 1.4,
          ),
        ),
      ),
    );
  }
}

/// Category Chip Widget
class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isDark;
  final String languageCode;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.isDark,
    required this.languageCode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUrdu = languageCode == 'ur';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.primary.withValues(alpha: 0.15)
              : AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: AppColors.primary,
            ),
            SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: TextStyle(
                fontFamily: isUrdu ? 'Jameel Noori Nastaleeq' : null,
                fontSize: isUrdu ? 14 : 12,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
                height: isUrdu ? 1.8 : 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Poet Card Widget
class _PoetCard extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final bool isDark;
  final String languageCode;
  final VoidCallback onTap;

  const _PoetCard({
    required this.name,
    this.imageUrl,
    required this.isDark,
    required this.languageCode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUrdu = _isUrduText(name);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: imageUrl != null && imageUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl!,
                      width: 100,
                      height: 80,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        width: 100,
                        height: 80,
                        color: AppColors.primary.withValues(alpha: 0.1),
                        child: Icon(
                          Icons.person_rounded,
                          size: 32,
                          color: AppColors.primary.withValues(alpha: 0.5),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        width: 100,
                        height: 80,
                        color: AppColors.primary.withValues(alpha: 0.1),
                        child: Icon(
                          Icons.person_rounded,
                          size: 32,
                          color: AppColors.primary.withValues(alpha: 0.5),
                        ),
                      ),
                    )
                  : Container(
                      width: 100,
                      height: 80,
                      color: AppColors.primary.withValues(alpha: 0.1),
                      child: Icon(
                        Icons.person_rounded,
                        size: 32,
                        color: AppColors.primary.withValues(alpha: 0.5),
                      ),
                    ),
            ),

            // Name
            Padding(
              padding: EdgeInsets.all(AppSpacing.sm),
              child: Text(
                name,
                textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: isUrdu ? 'Jameel Noori Nastaleeq' : null,
                  fontSize: isUrdu ? 14 : 12,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                  height: isUrdu ? 1.6 : 1.3,
                ),
              ),
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
