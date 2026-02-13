import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/language_provider.dart';
import '../../../core/design_system/app_colors.dart';
import '../providers/discover_provider.dart';
import '../widgets/discover_search_button.dart';
import '../widgets/featured_poets_section.dart';
import '../widgets/recent_searches_section.dart';
import '../widgets/recommendation_section.dart';
import '../widgets/trending_section.dart';

/// Main discover screen - shown as default tab
/// No back button (it's a main tab)
/// Tapping search bar navigates to full SearchScreen
class DiscoverScreen extends ConsumerWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageCode = ref.watch(selectedLanguageProvider);
    final discoverState = ref.watch(discoverProvider);
    final isRtl = languageCode == 'ur';

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () => ref.read(discoverProvider.notifier).refresh(),
            child: CustomScrollView(
              slivers: [
                // Sticky search button at top
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 8),
                    child: DiscoverSearchButton(
                      onTap: () => context.push('/search'),
                      isRtl: isRtl,
                    ),
                  ),
                ),

                // Content based on state
                if (discoverState.status == DiscoverStatus.loading)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (discoverState.status == DiscoverStatus.error)
                  SliverFillRemaining(
                    child: _buildErrorState(context, ref, discoverState),
                  )
                else ...[
                  // Recent Searches Section
                  if (discoverState.recentSearches.isNotEmpty)
                    SliverToBoxAdapter(
                      child: RecentSearchesSection(
                        searches: discoverState.recentSearches,
                        isRtl: isRtl,
                        onSearchTap: (query) => context.push('/search?q=$query'),
                        onClearAll: () => ref
                            .read(discoverProvider.notifier)
                            .clearRecentSearches(),
                        onRemove: (query) => ref
                            .read(discoverProvider.notifier)
                            .removeRecentSearch(query),
                      ),
                    ),

                  // Trending Searches Section
                  if (discoverState.bundle?.trendingSearches != null)
                    SliverToBoxAdapter(
                      child: TrendingSection(
                        trending: discoverState.bundle!.trendingSearches,
                        isRtl: isRtl,
                        onQueryTap: (query) => context.push('/search?q=$query'),
                      ),
                    ),

                  // Editor's Picks Section
                  if (discoverState.bundle?.editorsPicks.items.isNotEmpty ==
                      true)
                    SliverToBoxAdapter(
                      child: RecommendationSection(
                        title: isRtl ? 'ایڈیٹر کی پسند' : "Editor's Picks",
                        items: discoverState.bundle!.editorsPicks.items,
                        isRtl: isRtl,
                        onItemTap: _navigateToContent,
                        onSeeAll: () => context.push('/discover/editors-picks'),
                      ),
                    ),

                  // Recommended For You Section
                  if (discoverState.bundle?.recommended.items.isNotEmpty == true)
                    SliverToBoxAdapter(
                      child: RecommendationSection(
                        title: isRtl ? 'آپ کے لیے' : 'Recommended For You',
                        items: discoverState.bundle!.recommended.items,
                        isRtl: isRtl,
                        onItemTap: _navigateToContent,
                        onSeeAll: () => context.push('/discover/recommended'),
                      ),
                    ),

                  // Featured Poets Section
                  if (discoverState.bundle?.featuredPoets.items.isNotEmpty ==
                      true)
                    SliverToBoxAdapter(
                      child: FeaturedPoetsSection(
                        poets: discoverState.bundle!.featuredPoets.items,
                        isRtl: isRtl,
                        onPoetTap: (poet) =>
                            context.push('/poets/${poet.publicId}'),
                        onSeeAll: () => context.push('/discover/featured-poets'),
                      ),
                    ),

                  // Bottom padding
                  const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    WidgetRef ref,
    DiscoverState state,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.textSecondaryLight,
            ),
            const SizedBox(height: 16),
            Text(
              state.errorMessage ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.read(discoverProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToContent(BuildContext context, dynamic item) {
    final type = item.type as String;
    final publicId = item.publicId as String;

    switch (type) {
      case 'POET':
        context.push('/poets/$publicId');
        break;
      case 'POEM':
        context.push('/poems/$publicId');
        break;
      case 'VERSE':
      case 'COUPLET':
        context.push('/couplets/$publicId');
        break;
      case 'CATEGORY':
        context.push('/categories/$publicId');
        break;
      case 'TAG':
        context.push('/tags/$publicId');
        break;
    }
  }
}
