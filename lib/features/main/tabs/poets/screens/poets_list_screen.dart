import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/poet_providers.dart';
import '../widgets/poet_card.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';

class PoetsListScreen extends ConsumerStatefulWidget {
  const PoetsListScreen({super.key});

  @override
  ConsumerState<PoetsListScreen> createState() => _PoetsListScreenState();
}

class _PoetsListScreenState extends ConsumerState<PoetsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedTag;
  int _currentPage = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            snap: true,
            elevation: 0,
            backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            title: Text(
              'Poets',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          // Search Bar
          SliverPadding(
            padding: EdgeInsets.all(AppSpacing.md),
            sliver: SliverToBoxAdapter(
              child: _buildSearchBar(context, isDark),
            ),
          ),
          // Discovery Tags
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            sliver: SliverToBoxAdapter(
              child: _buildDiscoveryTags(context),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.only(top: AppSpacing.md),
            sliver: _buildPoetsList(context, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, bool isDark) {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search poets by name...',
        prefixIcon: Icon(Icons.search),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  setState(() {});
                },
              )
            : null,
        filled: true,
        fillColor: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
      ),
      onChanged: (value) {
        setState(() {});
        ref.read(poetsSearchQueryProvider.notifier).state = value;
      },
    );
  }

  Widget _buildDiscoveryTags(BuildContext context) {
    final tags = [
      ('Trending', 'trending'),
      ('Top Poets', 'top'),
      ('Featured', 'featured'),
      ('Classical', 'classical'),
      ('Modern', 'modern'),
      ('Women Poets', 'women'),
    ];

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tags.length,
        itemBuilder: (context, index) {
          final (label, value) = tags[index];
          final isSelected = _selectedTag == value;

          return Padding(
            padding: EdgeInsets.only(right: AppSpacing.sm),
            child: FilterChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedTag = selected ? value : null;
                  _currentPage = 0;
                });
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildPoetsList(BuildContext context, bool isDark) {
    // Determine which provider to watch based on selected tag/search
    if (_searchController.text.isNotEmpty) {
      return _buildSearchResults();
    }

    switch (_selectedTag) {
      case 'trending':
        return _buildProviderList(ref.watch(trendingPoetsProvider));
      case 'top':
        return _buildProviderList(ref.watch(topPoetsByViewsProvider));
      case 'featured':
        return _buildProviderList(ref.watch(featuredPoetsProvider));
      case 'classical':
        return _buildProviderList(ref.watch(poetsByEraProvider('CLASSICAL')));
      case 'modern':
        return _buildProviderList(ref.watch(poetsByEraProvider('MODERN')));
      case 'women':
        return _buildProviderList(ref.watch(poetsByGenderProvider('FEMALE')));
      default:
        return _buildProviderList(ref.watch(allPoetsProvider(_currentPage)));
    }
  }

  Widget _buildSearchResults() {
    return SliverToBoxAdapter(
      child: ref.watch(searchPoetsProvider).when(
            data: (result) {
              if (result.content.isEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: Text('No poets found'),
                  ),
                );
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                padding: EdgeInsets.all(AppSpacing.md),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                ),
                itemCount: result.content.length,
                itemBuilder: (context, index) {
                  final poet = result.content[index];
                  return PoetCard(
                    poet: poet,
                    onTap: () => context.push('/main/poets/${poet.publicId}'),
                  );
                },
              );
            },
            loading: () => SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
            error: (error, stack) => SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    children: [
                      Icon(Icons.error_outline, size: 48, color: Colors.red),
                      SizedBox(height: AppSpacing.md),
                      Text('Error loading poets'),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildProviderList(AsyncValue asyncValue) {
    return asyncValue.when(
      data: (result) {
        if (result.content.isEmpty) {
          return SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Text('No poets available'),
              ),
            ),
          );
        }

        return SliverPadding(
          padding: EdgeInsets.all(AppSpacing.md),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final poet = result.content[index];
                return PoetCard(
                  poet: poet,
                  onTap: () => context.push('/main/poets/${poet.publicId}'),
                );
              },
              childCount: result.content.length,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
            ),
          ),
        );
      },
      loading: () => SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      error: (error, stack) => SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red),
                SizedBox(height: AppSpacing.md),
                Text('Error loading poets: $error'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
