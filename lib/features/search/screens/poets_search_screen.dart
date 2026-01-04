import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/features/search/providers/search_providers.dart';
import 'package:flutter_poetry_app/features/search/widgets/search_results_grid.dart';
import 'package:flutter_poetry_app/features/search/widgets/recent_searches_list.dart';
import 'package:flutter_poetry_app/features/search/widgets/search_suggestions_section.dart';
import 'package:flutter_poetry_app/features/search/widgets/search_filter_chips.dart';

class PoetsSearchScreen extends ConsumerStatefulWidget {
  const PoetsSearchScreen({super.key});

  @override
  ConsumerState<PoetsSearchScreen> createState() => _PoetsSearchScreenState();
}

class _PoetsSearchScreenState extends ConsumerState<PoetsSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounceTimer;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // Clear any previous search results and reset to empty state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(searchPaginationProvider.notifier).reset();
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    // Cancel previous timer
    _debounceTimer?.cancel();

    // Show searching indicator immediately
    setState(() {
      _isSearching = value.trim().isNotEmpty;
    });

    // If empty, reset search
    if (value.trim().isEmpty) {
      ref.read(searchPaginationProvider.notifier).reset();
      return;
    }

    // Debounce the search
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (value.trim().length >= 2) {
        ref.read(searchPaginationProvider.notifier).search(value.trim());
      }
      setState(() {
        _isSearching = false;
      });
    });
  }

  void _onSearchSubmitted(String value) {
    // Cancel debounce timer
    _debounceTimer?.cancel();

    if (value.trim().length >= 2) {
      ref.read(searchPaginationProvider.notifier).search(value.trim());
      setState(() {
        _isSearching = false;
      });
    }
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(searchPaginationProvider.notifier).reset();
    setState(() {
      _isSearching = false;
    });
    _focusNode.requestFocus();
  }

  void _onRecentSearchTapped(String query) {
    _searchController.text = query;
    ref.read(searchPaginationProvider.notifier).search(query);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final searchState = ref.watch(searchPaginationProvider);
    final query = _searchController.text.trim();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Search App Bar
          _buildSearchAppBar(context, isDark),

          // Filter Chips (always show if active)
          SliverToBoxAdapter(
            child: SearchFilterChips(
              onFiltersChanged: () {
                // Re-search with new filters or browse if no query
                if (query.isNotEmpty && query.length >= 2) {
                  ref.read(searchPaginationProvider.notifier).search(query);
                } else {
                  final filters = ref.read(searchFiltersProvider);
                  if (filters.hasActiveFilters) {
                    ref.read(searchPaginationProvider.notifier).browseByFilters();
                  }
                }
              },
            ),
          ),

          // Content based on search state
          if (searchState.hasResults)
            // Show results (from search or filter browse)
            const SearchResultsGrid()
          else if (searchState.isLoading && searchState.results.isEmpty)
            // Loading state
            _buildLoadingState()
          else if (searchState.error != null)
            // Error state
            _buildErrorState(searchState.error!)
          else if (!searchState.isLoading && searchState.isEmpty && searchState.currentQuery != null)
            // No results found (after search/browse)
            ..._buildNoResultsState()
          else if (query.isEmpty)
            // Empty state (no search, no browse)
            ..._buildEmptyState()
          else if (query.length < 2)
            // Query too short
            _buildMinimumCharsHint(),
        ],
      ),
    );
  }

  Widget _buildSearchAppBar(BuildContext context, bool isDark) {
    final filters = ref.watch(searchFiltersProvider);

    return SliverAppBar(
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: TextField(
        controller: _searchController,
        focusNode: _focusNode,
        decoration: InputDecoration(
          hintText: 'Search poets by name...',
          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            borderSide: BorderSide(
              color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            borderSide: BorderSide(
              color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            borderSide: const BorderSide(
              color: AppColors.secondary,
              width: 2,
            ),
          ),
          prefixIcon: _isSearching
              ? Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDark ? AppColors.secondary : AppColors.primary,
                      ),
                    ),
                  ),
                )
              : const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clearSearch,
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          filled: true,
          fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
        ),
        style: Theme.of(context).textTheme.bodyMedium,
        textInputAction: TextInputAction.search,
        onChanged: _onSearchChanged,
        onSubmitted: _onSearchSubmitted,
      ),
      actions: [
        // Filter button with badge
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () {
                _showFilterBottomSheet(context);
              },
            ),
            if (filters.hasActiveFilters)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    '${filters.activeFilterCount}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: AppSpacing.xs),
      ],
    );
  }

  List<Widget> _buildEmptyState() {
    return [
      const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
      RecentSearchesList(onSearchTap: _onRecentSearchTapped),
      const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
      const SearchSuggestionsSection(),
    ];
  }

  Widget _buildMinimumCharsHint() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Type at least 2 characters to search',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Searching...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[400],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Something went wrong',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                error,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton.icon(
                onPressed: () {
                  final query = _searchController.text.trim();
                  if (query.length >= 2) {
                    ref.read(searchPaginationProvider.notifier).search(query);
                  }
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildNoResultsState() {
    return [
      SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'No poets found',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Try searching with a different name or clear filters',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
      const SearchSuggestionsSection(),
    ];
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      builder: (context) => _buildFilterBottomSheet(),
    );
  }

  Widget _buildFilterBottomSheet() {
    return Consumer(
      builder: (context, ref, child) {
        final filters = ref.watch(searchFiltersProvider);

        return Container(
          padding: EdgeInsets.only(
            top: AppSpacing.lg,
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filters',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Era Filters
              Text(
                'Era',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: ['CLASSICAL', 'MODERN', 'CONTEMPORARY', 'EMERGING']
                    .map((era) => FilterChip(
                          label: Text(era),
                          selected: filters.selectedEras.contains(era),
                          onSelected: (_) {
                            ref
                                .read(searchFiltersProvider.notifier)
                                .toggleEra(era);
                          },
                          selectedColor: AppColors.secondary.withValues(alpha: 0.3),
                          checkmarkColor: AppColors.secondary,
                        ))
                    .toList(),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Gender Filters
              Text(
                'Gender',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: ['MALE', 'FEMALE', 'OTHER']
                    .map((gender) => FilterChip(
                          label: Text(gender),
                          selected: filters.selectedGenders.contains(gender),
                          onSelected: (_) {
                            ref
                                .read(searchFiltersProvider.notifier)
                                .toggleGender(gender);
                          },
                          selectedColor: AppColors.secondary.withValues(alpha: 0.3),
                          checkmarkColor: AppColors.secondary,
                        ))
                    .toList(),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Quick Filters
              CheckboxListTile(
                title: const Text('Featured Only'),
                value: filters.onlyFeatured,
                onChanged: (value) {
                  ref
                      .read(searchFiltersProvider.notifier)
                      .setOnlyFeatured(value ?? false);
                },
                activeColor: AppColors.secondary,
                contentPadding: EdgeInsets.zero,
              ),
              CheckboxListTile(
                title: const Text('Trending Only'),
                value: filters.onlyTrending,
                onChanged: (value) {
                  ref
                      .read(searchFiltersProvider.notifier)
                      .setOnlyTrending(value ?? false);
                },
                activeColor: AppColors.secondary,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        ref.read(searchFiltersProvider.notifier).reset();
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.secondary),
                      ),
                      child: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        final query = _searchController.text.trim();
                        final filters = ref.read(searchFiltersProvider);

                        // If there's a query, search with filters
                        if (query.length >= 2) {
                          ref.read(searchPaginationProvider.notifier).search(query);
                        }
                        // If no query but filters are active, browse by filters
                        else if (filters.hasActiveFilters) {
                          ref.read(searchPaginationProvider.notifier).browseByFilters();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: AppColors.primary,
                      ),
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
