import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/widgets/localized_text.dart';
import 'package:flutter_poetry_app/features/search/providers/search_pagination_provider.dart';
import 'package:flutter_poetry_app/features/search/widgets/skeleton_loaders/couplet_skeleton.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/widgets/couplet_card.dart';
import 'package:flutter_poetry_app/features/search/utils/search_adapters.dart';

/// Category results screen with infinite scroll pagination
///
/// Features:
/// - Infinite scroll with 80% threshold
/// - Initial skeleton loaders
/// - Load more indicator at bottom
/// - "No more results" message when exhausted
/// - Reusable for couplets category (poems/poets future)
class CategoryResultsScreen extends ConsumerStatefulWidget {
  final String query;
  final String sortBy;
  final String category;
  final String? poetId;

  const CategoryResultsScreen({
    super.key,
    required this.query,
    required this.sortBy,
    required this.category,
    this.poetId,
  });

  @override
  ConsumerState<CategoryResultsScreen> createState() => _CategoryResultsScreenState();
}

class _CategoryResultsScreenState extends ConsumerState<CategoryResultsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Handle scroll events for infinite scroll
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      // Load more when 80% scrolled
      final paginationParams = SearchPaginationParams(
        query: widget.query,
        sortBy: widget.sortBy,
        poetId: widget.poetId,
      );

      ref.read(searchResultsPaginationProvider(paginationParams).notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final paginationParams = SearchPaginationParams(
      query: widget.query,
      sortBy: widget.sortBy,
      poetId: widget.poetId,
    );

    final paginationState = ref.watch(searchResultsPaginationProvider(paginationParams));

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFFFFBF7),
      appBar: AppBar(
        title: LocalizedText(
          widget.query,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFFFFBF7),
        elevation: 0,
      ),
      body: _buildBody(context, paginationState, isDark),
    );
  }

  /// Build body based on pagination state
  Widget _buildBody(
    BuildContext context,
    SearchPaginationState paginationState,
    bool isDark,
  ) {
    // Initial loading
    if (paginationState.isLoading && paginationState.results.isEmpty) {
      return ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) => const CoupletSkeleton(),
      );
    }

    // Error state
    if (paginationState.error != null && paginationState.results.isEmpty) {
      return _buildErrorState(paginationState.error!, isDark);
    }

    // Empty state
    if (paginationState.isEmpty) {
      return _buildEmptyState(isDark);
    }

    // Results list
    return RefreshIndicator(
      onRefresh: () async {
        final paginationParams = SearchPaginationParams(
          query: widget.query,
          sortBy: widget.sortBy,
          poetId: widget.poetId,
        );
        await ref.read(searchResultsPaginationProvider(paginationParams).notifier).refresh();
      },
      child: ListView.builder(
        controller: _scrollController,
        itemCount: paginationState.results.length + 1, // +1 for load more indicator
        itemBuilder: (context, index) {
          // Load more indicator
          if (index == paginationState.results.length) {
            return _buildLoadMoreIndicator(paginationState, isDark);
          }

          // Result item
          final result = paginationState.results[index];
          return CoupletCard(
            couplet: convertSearchResultToCoupletModel(result),
            // Navigation disabled until poem publicId is available from search API
            onTap: null,
          );
        },
      ),
    );
  }

  /// Build load more indicator
  Widget _buildLoadMoreIndicator(SearchPaginationState state, bool isDark) {
    if (state.isLoadingMore) {
      return Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!state.hasMore) {
      return Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Center(
          child: Text(
            'No more results',
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.6)
                  : Colors.black.withValues(alpha: 0.6),
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  /// Build empty state
  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              'No results found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.9)
                    : Colors.black.withValues(alpha: 0.9),
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              'Try different keywords or filters',
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.7)
                    : Colors.black.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Build error state
  Widget _buildErrorState(String error, bool isDark) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              'Error Loading Results',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.9)
                    : Colors.black.withValues(alpha: 0.9),
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              error,
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.7)
                    : Colors.black.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.md),
            ElevatedButton.icon(
              onPressed: () {
                final paginationParams = SearchPaginationParams(
                  query: widget.query,
                  sortBy: widget.sortBy,
                  poetId: widget.poetId,
                );
                ref.read(searchResultsPaginationProvider(paginationParams).notifier).retry();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
