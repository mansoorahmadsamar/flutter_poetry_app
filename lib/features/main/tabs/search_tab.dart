import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/features/search/providers/global_search_provider.dart';
import 'package:flutter_poetry_app/features/search/models/global_search_state.dart';
import 'package:flutter_poetry_app/features/search/widgets/search_bar_widget.dart';
import 'package:flutter_poetry_app/features/search/widgets/autocomplete_suggestions.dart';
import 'package:flutter_poetry_app/features/search/widgets/search_results_section.dart';
import 'package:flutter_poetry_app/features/search/widgets/skeleton_loaders/couplet_skeleton.dart';
import 'package:flutter_poetry_app/features/search/widgets/discovery_sections/recent_searches_section.dart';
import 'package:flutter_poetry_app/features/search/widgets/discovery_sections/trending_searches_section.dart';
import 'package:flutter_poetry_app/features/search/widgets/discovery_sections/recommendations_section.dart';

/// Search tab - Global search with discovery content
///
/// Features:
/// - Discovery content visible on load (trending, recommendations, recent)
/// - Search bar always visible at top
/// - No auto-focus - user taps when ready to search
/// - Mode-based content rendering
class SearchTab extends ConsumerWidget {
  const SearchTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(globalSearchProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFFFFBF7),
      body: CustomScrollView(
        slivers: [
          // Sticky search bar
          SliverAppBar(
            pinned: true,
            floating: false,
            backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFFFFBF7),
            elevation: 0,
            toolbarHeight: 80,
            automaticallyImplyLeading: false,
            title: const GlobalSearchBar(autofocus: false), // No auto-focus in tab
          ),

          // Content based on search mode
          SliverToBoxAdapter(
            child: _buildContent(context, ref, searchState, isDark),
          ),
        ],
      ),
    );
  }

  /// Build content based on current search mode
  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    GlobalSearchState searchState,
    bool isDark,
  ) {
    switch (searchState.mode) {
      case SearchMode.idle:
      case SearchMode.typing:
        return _buildDiscoveryContent(searchState);

      case SearchMode.autocompleting:
        return Column(
          children: [
            // Autocomplete suggestions
            if (searchState.autocompleteResults != null)
              Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: AutocompleteSuggestions(
                  suggestions: searchState.autocompleteResults!,
                ),
              ),

            // Discovery content below autocomplete
            _buildDiscoveryContent(searchState),
          ],
        );

      case SearchMode.searching:
        return _buildLoadingState();

      case SearchMode.results:
        return _buildResultsState(searchState);

      case SearchMode.error:
        return _buildErrorState(context, ref, searchState, isDark);
    }
  }

  /// Build discovery content (recent, trending, recommendations)
  Widget _buildDiscoveryContent(GlobalSearchState searchState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: AppSpacing.md),
        const RecentSearchesSection(),
        SizedBox(height: AppSpacing.md),
        const TrendingSearchesSection(),
        SizedBox(height: AppSpacing.md),
        const RecommendationsSection(),
        SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  /// Build loading state with skeleton loaders
  Widget _buildLoadingState() {
    return Column(
      children: [
        SizedBox(height: AppSpacing.md),
        // Show 5 skeleton loaders
        ...List.generate(5, (index) => const CoupletSkeleton()),
        SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  /// Build results state
  Widget _buildResultsState(GlobalSearchState searchState) {
    debugPrint('🔵 SearchTab _buildResultsState called');
    debugPrint('🔵 unifiedResults null? ${searchState.unifiedResults == null}');
    debugPrint('🔵 totalResults: ${searchState.unifiedResults?.totalResults}');

    if (searchState.unifiedResults == null ||
        searchState.unifiedResults!.totalResults == 0) {
      debugPrint('🔵 Showing empty state');
      return _buildEmptyState();
    }

    debugPrint('🔵 Showing SearchResultsSection with ${searchState.unifiedResults!.totalResults} results');
    return Column(
      children: [
        SizedBox(height: AppSpacing.md),
        const SearchResultsSection(),
        SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  /// Build empty state (no results found)
  Widget _buildEmptyState() {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.xl),
      child: Center(
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
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              'Try different keywords or check your spelling',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Build error state with retry button
  Widget _buildErrorState(
    BuildContext context,
    WidgetRef ref,
    GlobalSearchState searchState,
    bool isDark,
  ) {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.xl),
      child: Center(
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
              'Search Error',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              searchState.errorMessage ?? 'Something went wrong',
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
                ref.read(globalSearchProvider.notifier).executeSearch();
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
