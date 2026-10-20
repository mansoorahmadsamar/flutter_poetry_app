import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/widgets/poet_card.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/providers/poet_search_pagination_provider.dart';

class SearchResultsGrid extends ConsumerStatefulWidget {
  const SearchResultsGrid({super.key});

  @override
  ConsumerState<SearchResultsGrid> createState() => _SearchResultsGridState();
}

class _SearchResultsGridState extends ConsumerState<SearchResultsGrid> {
  /// Start loading the next page when this close to the end of the list.
  static const double _loadMoreThresholdPx = 600;

  /// The grid is a sliver, so it scrolls with the enclosing
  /// [CustomScrollView]; listen to that scrollable's position. (A private
  /// ScrollController here was never attached, so page 2 never loaded.)
  ScrollPosition? _position;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final position = Scrollable.maybeOf(context)?.position;
    if (position != _position) {
      _position?.removeListener(_onScroll);
      _position = position?..addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    _position?.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    final position = _position;
    if (position == null || !position.hasContentDimensions) return;
    if (position.extentAfter < _loadMoreThresholdPx) {
      // The notifier ignores calls while a page is loading or after the last.
      ref.read(poetSearchPaginationProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(poetSearchPaginationProvider);

    return SliverPadding(
      padding: const EdgeInsets.all(AppSpacing.md),
      sliver: SliverMainAxisGroup(
        slivers: [
          // Result count header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Text(
                'Found ${searchState.totalElements} ${searchState.totalElements == 1 ? 'poet' : 'poets'}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.secondary,
                    ),
              ),
            ),
          ),

          // Results grid
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.52,
              crossAxisSpacing: AppSpacing.sm,
              mainAxisSpacing: AppSpacing.sm,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final poet = searchState.results[index];
                return PoetCard(
                  poet: poet,
                  onTap: () {
                    context.push('/main/poets/${poet.publicId}');
                  },
                );
              },
              childCount: searchState.results.length,
            ),
          ),

          // Loading more indicator
          if (searchState.isLoadingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.secondary),
                  ),
                ),
              ),
            ),

          // End of results message
          if (!searchState.hasMore && searchState.results.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Center(
                  child: Text(
                    'No more results',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
