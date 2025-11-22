import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/poets_pagination_provider.dart';
import '../widgets/poet_card.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';

class PoetsListScreen extends ConsumerStatefulWidget {
  const PoetsListScreen({super.key});

  @override
  ConsumerState<PoetsListScreen> createState() => _PoetsListScreenState();
}

class _PoetsListScreenState extends ConsumerState<PoetsListScreen> {
  final ScrollController _scrollController = ScrollController();
  PoetsFilterType _selectedFilter = PoetsFilterType.all;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Load more when 200px from bottom
      ref.read(poetsPaginationProvider.notifier).loadMore();
    }
  }

  Future<void> _onRefresh() async {
    await ref.read(poetsPaginationProvider.notifier).refresh();
  }

  void _onFilterChanged(PoetsFilterType filter) {
    if (_selectedFilter == filter) {
      // Deselect if same filter tapped
      setState(() => _selectedFilter = PoetsFilterType.all);
      ref.read(poetsPaginationProvider.notifier).setFilter(PoetsFilterType.all);
    } else {
      setState(() => _selectedFilter = filter);
      ref.read(poetsPaginationProvider.notifier).setFilter(filter);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final paginationState = ref.watch(poetsPaginationProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // App Bar
            SliverAppBar(
              floating: true,
              snap: true,
              elevation: 0,
              backgroundColor:
                  isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              title: Text(
                'Poets',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    context.push('/main/poets-search');
                  },
                  tooltip: 'Search poets',
                ),
                const SizedBox(width: AppSpacing.xs),
              ],
            ),
            // Discovery Tags
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
              sliver: SliverToBoxAdapter(
                child: _buildDiscoveryTags(context),
              ),
            ),
            // Poets List
            SliverPadding(
              padding: EdgeInsets.only(top: AppSpacing.md),
              sliver: _buildPoetsList(context, isDark, paginationState),
            ),
            // Loading More Indicator
            if (paginationState.isLoadingMore)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
            // End of List Message
            if (!paginationState.hasMore &&
                paginationState.poets.isNotEmpty &&
                !paginationState.isLoading)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: Center(
                    child: Text(
                      'No more poets to load',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscoveryTags(BuildContext context) {
    final tags = [
      ('Trending', PoetsFilterType.trending),
      ('Top Poets', PoetsFilterType.topByViews),
      ('Featured', PoetsFilterType.featured),
      ('Classical', PoetsFilterType.classical),
      ('Modern', PoetsFilterType.modern),
      ('Women Poets', PoetsFilterType.women),
    ];

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tags.length,
        itemBuilder: (context, index) {
          final (label, filter) = tags[index];
          final isSelected = _selectedFilter == filter;

          return Padding(
            padding: EdgeInsets.only(right: AppSpacing.sm),
            child: FilterChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (_) => _onFilterChanged(filter),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPoetsList(
    BuildContext context,
    bool isDark,
    PoetsPaginationState paginationState,
  ) {
    // Initial loading state
    if (paginationState.isLoading && paginationState.poets.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    // Error state
    if (paginationState.error != null && paginationState.poets.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red),
                SizedBox(height: AppSpacing.md),
                Text('Error loading poets'),
                SizedBox(height: AppSpacing.md),
                ElevatedButton(
                  onPressed: () =>
                      ref.read(poetsPaginationProvider.notifier).loadInitial(),
                  child: Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Empty state
    if (paginationState.poets.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Center(child: Text('No poets available')),
        ),
      );
    }

    // Poets grid
    return SliverPadding(
      padding: EdgeInsets.all(AppSpacing.md),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final poet = paginationState.poets[index];
            return PoetCard(
              poet: poet,
              onTap: () => context.push('/main/poets/${poet.publicId}'),
            );
          },
          childCount: paginationState.poets.length,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
        ),
      ),
    );
  }
}
