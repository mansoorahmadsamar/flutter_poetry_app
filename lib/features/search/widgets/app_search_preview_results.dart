import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/providers/language_provider.dart';
import 'package:flutter_poetry_app/features/search/models/global_search_state.dart';
import 'package:flutter_poetry_app/features/search/models/search_models.dart';
import 'package:flutter_poetry_app/features/search/providers/global_search_provider.dart';
import 'package:flutter_poetry_app/features/search/widgets/app_search_couplet_card.dart';
import 'package:flutter_poetry_app/features/search/widgets/app_search_poet_card.dart';
import 'package:flutter_poetry_app/features/search/widgets/app_search_poem_card.dart';

/// Smart grouped overview (the "سب" tab experience).
///
/// Uses CustomScrollView + Slivers for virtualized rendering.
/// Shows all non-empty content types grouped with counts + "سب دیکھیں".
///
/// Only watches `unifiedResults` and `relatedSearches` via `.select()`.
class AppSearchPreviewResults extends ConsumerWidget {
  final ValueChanged<String> onRelatedSearchTap;

  const AppSearchPreviewResults({
    super.key,
    required this.onRelatedSearchTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unified = ref.watch(
      globalSearchProvider.select((s) => s.unifiedResults),
    );
    final related = ref.watch(
      globalSearchProvider.select((s) => s.relatedSearches),
    );
    final query = ref.watch(
      globalSearchProvider.select((s) => s.currentQuery),
    );
    final isLoading = ref.watch(
      globalSearchProvider.select((s) => s.isLoadingResults),
    );
    final languageCode = ref.watch(selectedLanguageProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUrdu = languageCode == 'ur';

    // Loading state — show skeletons
    if (isLoading && unified == null) {
      return _buildLoadingState(isDark);
    }

    // Empty state
    if (unified == null || unified.totalResults == 0) {
      return _buildEmptyState(isDark, isUrdu, languageCode);
    }

    return CustomScrollView(
      slivers: [
        // Result count
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Text(
              _resultsText(query, unified.totalResults, languageCode),
              textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
              style: TextStyle(
                fontFamily: isUrdu ? 'Jameel Noori Nastaleeq' : null,
                fontSize: isUrdu ? 14 : 13,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                height: isUrdu ? 1.8 : 1.4,
              ),
            ),
          ),
        ),

        // Poets section (horizontal)
        if (unified.poets.isNotEmpty)
          SliverToBoxAdapter(
            child: _SectionWithHeader(
              title: _poetsTitle(languageCode),
              count: unified.poetCount,
              icon: Icons.person_rounded,
              isDark: isDark,
              isUrdu: isUrdu,
              languageCode: languageCode,
              onSeeAll: unified.poetCount > 5
                  ? () => ref
                      .read(globalSearchProvider.notifier)
                      .setActiveSegment(DiscoverSegment.poets)
                  : null,
              child: SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding:
                      EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  itemCount: unified.poets.take(5).length,
                  separatorBuilder: (_, __) =>
                      SizedBox(width: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final poet = unified.poets[index];
                    return _MiniPoetCard(
                      name: poet.name,
                      imageUrl: poet.profileImageUrl,
                      isDark: isDark,
                      onTap: () =>
                          context.push('/main/poets/${poet.publicId}'),
                    );
                  },
                ),
              ),
            ),
          ),

        // Couplets section (max 3)
        if (unified.couplets.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: _SectionHeader(
              title: _versesTitle(languageCode),
              count: unified.coupletCount,
              icon: Icons.format_quote_rounded,
              isDark: isDark,
              isUrdu: isUrdu,
              languageCode: languageCode,
              onSeeAll: unified.coupletCount > 3
                  ? () => ref
                      .read(globalSearchProvider.notifier)
                      .setActiveSegment(DiscoverSegment.verses)
                  : null,
            ),
          ),
          SliverList.builder(
            itemCount: unified.couplets.take(3).length,
            itemBuilder: (context, index) {
              return RepaintBoundary(
                child: AppSearchCoupletCard(
                  couplet: unified.couplets[index],
                  searchQuery: query,
                ),
              );
            },
          ),
          SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
        ],

        // Poems section (max 3)
        if (unified.poems.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: _SectionHeader(
              title: _poemsTitle(languageCode),
              count: unified.poemCount,
              icon: Icons.auto_stories_rounded,
              isDark: isDark,
              isUrdu: isUrdu,
              languageCode: languageCode,
              onSeeAll: unified.poemCount > 3
                  ? () => ref
                      .read(globalSearchProvider.notifier)
                      .setActiveSegment(DiscoverSegment.poems)
                  : null,
            ),
          ),
          SliverList.builder(
            itemCount: unified.poems.take(3).length,
            itemBuilder: (context, index) {
              return RepaintBoundary(
                child: AppSearchPoemCard(
                  poem: unified.poems[index],
                  searchQuery: query,
                ),
              );
            },
          ),
          SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
        ],

        // Categories section (wrapped chips, max 6)
        if (unified.categories.isNotEmpty)
          SliverToBoxAdapter(
            child: _CategoriesChips(
              title: _categoriesTitle(languageCode),
              categories: unified.categories.take(6).toList(),
              isDark: isDark,
              isUrdu: isUrdu,
              languageCode: languageCode,
            ),
          ),

        // Tags section (wrapped chips, max 5)
        if (unified.tags.isNotEmpty)
          SliverToBoxAdapter(
            child: _TagsChips(
              tags: unified.tags.take(5).toList(),
              isDark: isDark,
              isUrdu: isUrdu,
              languageCode: languageCode,
            ),
          ),

        // Related Searches
        if (related != null && related.relatedSearches.isNotEmpty)
          SliverToBoxAdapter(
            child: _RelatedSearches(
              searches: related.relatedSearches,
              isDark: isDark,
              isUrdu: isUrdu,
              languageCode: languageCode,
              onTap: onRelatedSearchTap,
            ),
          ),

        // Bottom padding
        SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
      ],
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return ListView(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
      children: [
        for (int i = 0; i < 2; i++) const AppSearchPoetSkeleton(),
        for (int i = 0; i < 3; i++) const AppSearchCoupletSkeleton(),
      ],
    );
  }

  Widget _buildEmptyState(bool isDark, bool isUrdu, String languageCode) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: isDark
                  ? AppColors.textDisabledDark
                  : AppColors.textDisabledLight,
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              languageCode == 'ur'
                  ? 'کوئی نتیجہ نہیں ملا'
                  : 'No Results Found',
              style: TextStyle(
                fontFamily: isUrdu ? 'Jameel Noori Nastaleeq' : null,
                fontSize: isUrdu ? 20 : 18,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
                height: isUrdu ? 1.8 : 1.4,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              languageCode == 'ur'
                  ? 'مختلف الفاظ استعمال کریں'
                  : 'Try different keywords',
              style: TextStyle(
                fontFamily: isUrdu ? 'Jameel Noori Nastaleeq' : null,
                fontSize: isUrdu ? 16 : 14,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                height: isUrdu ? 1.8 : 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Localized strings
  String _resultsText(String query, int count, String lang) {
    switch (lang) {
      case 'ur':
        return '"$query" کے لیے $count نتائج';
      case 'hi':
        return '"$query" के लिए $count परिणाम';
      default:
        return '$count results for "$query"';
    }
  }

  String _poetsTitle(String l) =>
      l == 'ur' ? 'شعراء' : (l == 'hi' ? 'कवि' : 'Poets');
  String _versesTitle(String l) =>
      l == 'ur' ? 'اشعار' : (l == 'hi' ? 'शेर' : 'Verses');
  String _poemsTitle(String l) =>
      l == 'ur' ? 'غزلیں / نظمیں' : (l == 'hi' ? 'ग़ज़लें' : 'Poems');
  String _categoriesTitle(String l) =>
      l == 'ur' ? 'زمرے' : (l == 'hi' ? 'श्रेणियाँ' : 'Categories');
}

// ---------------------------------------------------------------------------
// Section header (standalone, for use above SliverList)
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final bool isDark;
  final bool isUrdu;
  final String languageCode;
  final VoidCallback? onSeeAll;

  const _SectionHeader({
    required this.title,
    required this.count,
    required this.icon,
    required this.isDark,
    required this.isUrdu,
    required this.languageCode,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          SizedBox(width: AppSpacing.sm),
          Text(
            title,
            style: TextStyle(
              fontFamily: isUrdu ? 'Jameel Noori Nastaleeq' : null,
              fontSize: isUrdu ? 18 : 16,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
              height: isUrdu ? 1.8 : 1.4,
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          _CountBadge(count: count),
          const Spacer(),
          if (onSeeAll != null) _SeeAllButton(languageCode: languageCode, onTap: onSeeAll!),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section with header + child (for horizontal sections)
// ---------------------------------------------------------------------------

class _SectionWithHeader extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final bool isDark;
  final bool isUrdu;
  final String languageCode;
  final VoidCallback? onSeeAll;
  final Widget child;

  const _SectionWithHeader({
    required this.title,
    required this.count,
    required this.icon,
    required this.isDark,
    required this.isUrdu,
    required this.languageCode,
    this.onSeeAll,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: title,
            count: count,
            icon: icon,
            isDark: isDark,
            isUrdu: isUrdu,
            languageCode: languageCode,
            onSeeAll: onSeeAll,
          ),
          SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Count badge
// ---------------------------------------------------------------------------

class _CountBadge extends StatelessWidget {
  final int count;

  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        count.toString(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// "See All" button
// ---------------------------------------------------------------------------

class _SeeAllButton extends StatelessWidget {
  final String languageCode;
  final VoidCallback onTap;

  const _SeeAllButton({required this.languageCode, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isUrdu = languageCode == 'ur';
    final text = isUrdu ? 'سب دیکھیں' : (languageCode == 'hi' ? 'सभी देखें' : 'See All');

    return TextButton(
      onPressed: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
              fontFamily: isUrdu ? 'Jameel Noori Nastaleeq' : null,
              fontSize: isUrdu ? 14 : 13,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
              height: isUrdu ? 1.8 : 1.4,
            ),
          ),
          SizedBox(width: 4),
          Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.primary),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Mini poet card for horizontal scroll in preview
// ---------------------------------------------------------------------------

class _MiniPoetCard extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final bool isDark;
  final VoidCallback onTap;

  const _MiniPoetCard({
    required this.name,
    this.imageUrl,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUrdu = _isUrduText(name);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 90,
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: imageUrl!,
                      width: 90,
                      height: 70,
                      fit: BoxFit.cover,
                      memCacheWidth: 180,
                      placeholder: (_, __) => _placeholder(),
                      errorWidget: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),
            Padding(
              padding: EdgeInsets.all(AppSpacing.xs),
              child: Text(
                name,
                textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: isUrdu ? 'Jameel Noori Nastaleeq' : null,
                  fontSize: isUrdu ? 12 : 11,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                  height: isUrdu ? 1.5 : 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 90,
      height: 70,
      color: AppColors.primary.withValues(alpha: 0.1),
      child: Icon(Icons.person_rounded, size: 28, color: AppColors.primary.withValues(alpha: 0.5)),
    );
  }
}

// ---------------------------------------------------------------------------
// Categories chips
// ---------------------------------------------------------------------------

class _CategoriesChips extends StatelessWidget {
  final String title;
  final List<AutocompleteCategory> categories;
  final bool isDark;
  final bool isUrdu;
  final String languageCode;

  const _CategoriesChips({
    required this.title,
    required this.categories,
    required this.isDark,
    required this.isUrdu,
    required this.languageCode,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                Icon(Icons.category_rounded, size: 20, color: AppColors.primary),
                SizedBox(width: AppSpacing.sm),
                Text(title, style: _headerStyle(isUrdu, isDark)),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: categories.map((cat) {
                final isTextUrdu = _isUrduText(cat.name);
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    cat.name,
                    textDirection: isTextUrdu ? TextDirection.rtl : TextDirection.ltr,
                    style: TextStyle(
                      fontFamily: isTextUrdu ? 'Jameel Noori Nastaleeq' : null,
                      fontSize: isTextUrdu ? 14 : 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                      height: isTextUrdu ? 1.8 : 1.4,
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
}

// ---------------------------------------------------------------------------
// Tags chips
// ---------------------------------------------------------------------------

class _TagsChips extends StatelessWidget {
  final List<AutocompleteTag> tags;
  final bool isDark;
  final bool isUrdu;
  final String languageCode;

  const _TagsChips({
    required this.tags,
    required this.isDark,
    required this.isUrdu,
    required this.languageCode,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                Icon(Icons.tag_rounded, size: 20, color: AppColors.secondary),
                SizedBox(width: AppSpacing.sm),
                Text(
                  isUrdu ? 'ٹیگز' : 'Tags',
                  style: _headerStyle(isUrdu, isDark),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: tags.map((tag) {
                final isTextUrdu = _isUrduText(tag.name);
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.verseBackground,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                  child: Text(
                    tag.name,
                    textDirection: isTextUrdu ? TextDirection.rtl : TextDirection.ltr,
                    style: TextStyle(
                      fontFamily: isTextUrdu ? 'Jameel Noori Nastaleeq' : null,
                      fontSize: isTextUrdu ? 14 : 13,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      height: isTextUrdu ? 1.8 : 1.4,
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
}

// ---------------------------------------------------------------------------
// Related searches
// ---------------------------------------------------------------------------

class _RelatedSearches extends StatelessWidget {
  final List<TrendingSearch> searches;
  final bool isDark;
  final bool isUrdu;
  final String languageCode;
  final ValueChanged<String> onTap;

  const _RelatedSearches({
    required this.searches,
    required this.isDark,
    required this.isUrdu,
    required this.languageCode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.manage_search_rounded, size: 20, color: AppColors.secondary),
              SizedBox(width: AppSpacing.sm),
              Text(
                isUrdu ? 'متعلقہ تلاش' : 'Related Searches',
                style: _headerStyle(isUrdu, isDark),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: searches.map((search) {
              final isTextUrdu = _isUrduText(search.query);
              return GestureDetector(
                onTap: () => onTap(search.query),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.verseBackground,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                  child: Text(
                    search.query,
                    textDirection: isTextUrdu ? TextDirection.rtl : TextDirection.ltr,
                    style: TextStyle(
                      fontFamily: isTextUrdu ? 'Jameel Noori Nastaleeq' : null,
                      fontSize: isTextUrdu ? 14 : 13,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      height: isTextUrdu ? 1.8 : 1.4,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
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
