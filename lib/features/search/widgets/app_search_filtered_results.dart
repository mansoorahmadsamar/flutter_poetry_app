import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/providers/language_provider.dart';
import 'package:flutter_poetry_app/features/search/models/global_search_state.dart';
import 'package:flutter_poetry_app/features/search/models/search_models.dart';
import 'package:flutter_poetry_app/features/search/providers/global_search_provider.dart';
import 'package:flutter_poetry_app/features/search/widgets/app_search_couplet_card.dart';
import 'package:flutter_poetry_app/features/search/widgets/app_search_poet_card.dart';
import 'package:flutter_poetry_app/features/search/widgets/app_search_poem_card.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/models/poet_model.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/models/poem_model.dart';

/// Virtualized infinite-scroll list for a single segment.
///
/// Uses `ListView.builder` for true virtualization (NOT Column + .map().toList()).
/// Loads more at 80% scroll threshold. Page size: 20 items.
/// Each card wrapped in RepaintBoundary for scroll performance.
class AppSearchFilteredResults extends ConsumerStatefulWidget {
  final DiscoverSegment segment;
  final ValueChanged<PoetModel>? onPoetTap;
  final ValueChanged<PoemModel>? onPoemTap;
  final ValueChanged<CoupletSearchResult>? onCoupletTap;

  const AppSearchFilteredResults({
    super.key,
    required this.segment,
    this.onPoetTap,
    this.onPoemTap,
    this.onCoupletTap,
  });

  @override
  ConsumerState<AppSearchFilteredResults> createState() =>
      _AppSearchFilteredResultsState();
}

class _AppSearchFilteredResultsState
    extends ConsumerState<AppSearchFilteredResults> {
  @override
  Widget build(BuildContext context) {
    final languageCode = ref.watch(selectedLanguageProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUrdu = languageCode == 'ur';

    final unifiedResults = ref.watch(
      globalSearchProvider.select((s) => s.unifiedResults),
    );
    final isLoading = ref.watch(
      globalSearchProvider.select((s) => s.isLoadingResults),
    );
    final query = ref.watch(
      globalSearchProvider.select((s) => s.currentQuery),
    );

    // If still loading and no results, show skeleton
    if (isLoading && unifiedResults == null) {
      return _buildSkeletonList();
    }

    if (unifiedResults == null) {
      return _buildEmptyState(isDark, isUrdu, query);
    }

    // Get items for the active segment
    final itemCount = _getItemCount(unifiedResults);

    if (itemCount == 0) {
      return _buildEmptyState(isDark, isUrdu, query);
    }

    final isLoadingMore = ref.watch(
      globalSearchProvider.select((s) => s.isLoadingMore),
    );
    final hasMore = _hasMoreForSegment(unifiedResults);

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        // Trigger load more at 80% scroll position
        if (notification is ScrollUpdateNotification) {
          final metrics = notification.metrics;
          if (metrics.maxScrollExtent > 0 &&
              metrics.pixels >= metrics.maxScrollExtent * 0.8) {
            ref.read(globalSearchProvider.notifier).loadMore();
          }
        }
        return false;
      },
      child: ListView.builder(
        key: PageStorageKey('filtered_${widget.segment.name}'),
        cacheExtent: 500.0, // Pre-render ~2-3 cards ahead
        padding: EdgeInsets.only(
          top: AppSpacing.sm,
          bottom: AppSpacing.xl + MediaQuery.of(context).padding.bottom,
        ),
        itemCount: itemCount + 1 + (hasMore || isLoadingMore ? 1 : 0), // +1 header, +1 loader
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildResultCountHeader(
              _getTotalCount(unifiedResults),
              isDark,
              isUrdu,
              query,
            );
          }

          final itemIndex = index - 1;

          // Loading more indicator at the end
          if (itemIndex >= itemCount) {
            return _buildLoadMoreIndicator(isDark);
          }

          return RepaintBoundary(
            child: _buildItem(unifiedResults, itemIndex, isDark, query),
          );
        },
      ),
    );
  }

  bool _hasMoreForSegment(UnifiedSearchResponse results) {
    switch (widget.segment) {
      case DiscoverSegment.poets:
        return results.hasMorePoets;
      case DiscoverSegment.poems:
        return results.hasMorePoems;
      case DiscoverSegment.verses:
        return results.hasMoreCouplets;
      case DiscoverSegment.categories:
        return results.hasMoreCategories;
      default:
        return false;
    }
  }

  /// Total count in DB for this segment (for header label)
  int _getTotalCount(UnifiedSearchResponse results) {
    switch (widget.segment) {
      case DiscoverSegment.poets:
        return results.totalPoets;
      case DiscoverSegment.poems:
        return results.totalPoems;
      case DiscoverSegment.verses:
        return results.totalCouplets;
      case DiscoverSegment.categories:
        return results.totalCategories;
      default:
        return 0;
    }
  }

  int _getItemCount(UnifiedSearchResponse results) {
    switch (widget.segment) {
      case DiscoverSegment.poets:
        return results.poets.length;
      case DiscoverSegment.poems:
        return results.poems.length;
      case DiscoverSegment.verses:
        return results.couplets.length;
      case DiscoverSegment.categories:
        return results.categories.length;
      default:
        return 0;
    }
  }

  Widget _buildItem(
    UnifiedSearchResponse results,
    int index,
    bool isDark,
    String query,
  ) {
    switch (widget.segment) {
      case DiscoverSegment.poets:
        if (index >= results.poets.length) return const SizedBox.shrink();
        final poet = results.poets[index];
        return AppSearchPoetCard(
          poet: poet,
          searchQuery: query,
          onTap: widget.onPoetTap != null ? () => widget.onPoetTap!(poet) : null,
        );

      case DiscoverSegment.poems:
        if (index >= results.poems.length) return const SizedBox.shrink();
        final poem = results.poems[index];
        return AppSearchPoemCard(
          poem: poem,
          searchQuery: query,
          onTap: widget.onPoemTap != null ? () => widget.onPoemTap!(poem) : null,
        );

      case DiscoverSegment.verses:
        if (index >= results.couplets.length) return const SizedBox.shrink();
        final couplet = results.couplets[index];
        return AppSearchCoupletCard(
          couplet: couplet,
          searchQuery: query,
          onTap: widget.onCoupletTap != null
              ? () => widget.onCoupletTap!(couplet)
              : null,
        );

      case DiscoverSegment.categories:
        if (index >= results.categories.length) return const SizedBox.shrink();
        final category = results.categories[index];
        return _CategoryListItem(
          category: category,
          isDark: isDark,
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildResultCountHeader(
    int count,
    bool isDark,
    bool isUrdu,
    String query,
  ) {
    final segmentLabel = _getSegmentLabel(isUrdu);
    final countText = isUrdu
        ? '"$query" کے لیے $count $segmentLabel'
        : '$count $segmentLabel for "$query"';

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: Text(
        countText,
        textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
        style: TextStyle(
          fontFamily: isUrdu ? 'Jameel Noori Nastaleeq' : null,
          fontSize: isUrdu ? 15 : 13,
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          height: isUrdu ? 1.8 : 1.4,
        ),
      ),
    );
  }

  String _getSegmentLabel(bool isUrdu) {
    switch (widget.segment) {
      case DiscoverSegment.poets:
        return isUrdu ? 'شعراء' : 'poets';
      case DiscoverSegment.poems:
        return isUrdu ? 'غزلیں' : 'poems';
      case DiscoverSegment.verses:
        return isUrdu ? 'اشعار' : 'verses';
      case DiscoverSegment.categories:
        return isUrdu ? 'زمرے' : 'categories';
      default:
        return isUrdu ? 'نتائج' : 'results';
    }
  }

  Widget _buildEmptyState(bool isDark, bool isUrdu, String query) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 48,
              color: isDark
                  ? AppColors.textDisabledDark
                  : AppColors.textDisabledLight,
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              isUrdu
                  ? '"$query" کے لیے ${_getSegmentLabel(isUrdu)} نہیں ملے'
                  : 'No ${_getSegmentLabel(isUrdu)} found for "$query"',
              textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: isUrdu ? 'Jameel Noori Nastaleeq' : null,
                fontSize: isUrdu ? 18 : 16,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                height: isUrdu ? 2.0 : 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadMoreIndicator(bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.primary.withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonList() {
    switch (widget.segment) {
      case DiscoverSegment.poets:
        return ListView.builder(
          padding: EdgeInsets.only(top: AppSpacing.md),
          itemCount: 6,
          itemBuilder: (_, __) => const AppSearchPoetSkeleton(),
        );
      case DiscoverSegment.poems:
        return ListView.builder(
          padding: EdgeInsets.only(top: AppSpacing.md),
          itemCount: 6,
          itemBuilder: (_, __) => const AppSearchPoemSkeleton(),
        );
      case DiscoverSegment.verses:
        return ListView.builder(
          padding: EdgeInsets.only(top: AppSpacing.md),
          itemCount: 4,
          itemBuilder: (_, __) => const AppSearchCoupletSkeleton(),
        );
      default:
        return ListView.builder(
          padding: EdgeInsets.only(top: AppSpacing.md),
          itemCount: 6,
          itemBuilder: (_, __) => const AppSearchPoemSkeleton(),
        );
    }
  }
}

// ---------------------------------------------------------------------------
// Category list item (for filtered categories view)
// ---------------------------------------------------------------------------

class _CategoryListItem extends StatelessWidget {
  final AutocompleteCategory category;
  final bool isDark;

  const _CategoryListItem({
    required this.category,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final isUrdu = _isUrduText(category.name);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        splashColor: AppColors.primary.withValues(alpha: 0.08),
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
              // Category icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.category_rounded,
                  size: 22,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: AppSpacing.md),

              // Name + poem count
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      textDirection:
                          isUrdu ? TextDirection.rtl : TextDirection.ltr,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
                    if (category.poemCount > 0) ...[
                      SizedBox(height: 4),
                      Text(
                        '${category.poemCount} غزلیں',
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontFamily: 'Jameel Noori Nastaleeq',
                          fontSize: 12,
                          color: AppColors.secondary,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ],
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
      ),
    );
  }

  bool _isUrduText(String text) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }
}
