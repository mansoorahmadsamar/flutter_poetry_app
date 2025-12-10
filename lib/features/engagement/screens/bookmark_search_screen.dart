import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/models/poem_model.dart';
import 'package:flutter_poetry_app/features/engagement/providers/bookmark_search_provider.dart';
import 'package:flutter_poetry_app/features/engagement/widgets/bookmark_recent_searches.dart';
import 'package:flutter_poetry_app/features/engagement/widgets/bookmark_search_suggestions.dart';
import 'package:flutter_poetry_app/features/engagement/widgets/bookmark_search_filter_sheet.dart';

class BookmarkSearchScreen extends ConsumerStatefulWidget {
  const BookmarkSearchScreen({super.key});

  @override
  ConsumerState<BookmarkSearchScreen> createState() =>
      _BookmarkSearchScreenState();
}

class _BookmarkSearchScreenState extends ConsumerState<BookmarkSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounceTimer;
  bool _isSearching = false;
  String? _selectedPoetryType;
  String _sortBy = 'createdAt';

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus(); // Auto-focus search field
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // Load more at 80% scroll
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      ref.read(bookmarkSearchProvider.notifier).loadMore();
    }
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();

    setState(() {
      _isSearching = value.trim().isNotEmpty;
    });

    if (value.trim().isEmpty) {
      ref.read(bookmarkSearchProvider.notifier).reset();
      return;
    }

    // Debounce: 500ms
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (value.trim().length >= 3) {
        ref.read(bookmarkSearchProvider.notifier).search(
              value.trim(),
              poetryType: _selectedPoetryType,
              sortBy: _sortBy,
            );
      }
      setState(() {
        _isSearching = false;
      });
    });
  }

  void _onSearchSubmitted(String value) {
    _debounceTimer?.cancel();

    if (value.trim().length >= 3) {
      ref.read(bookmarkSearchProvider.notifier).search(
            value.trim(),
            poetryType: _selectedPoetryType,
            sortBy: _sortBy,
          );
      setState(() {
        _isSearching = false;
      });
    }
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(bookmarkSearchProvider.notifier).reset();
    setState(() {
      _isSearching = false;
    });
  }

  void _onRecentSearchTapped(String query) {
    _searchController.text = query;
    _onSearchSubmitted(query);
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
      ),
      builder: (context) => BookmarkSearchFilterSheet(
        selectedPoetryType: _selectedPoetryType,
        selectedSortBy: _sortBy,
        onApply: (poetryType, sortBy) {
          setState(() {
            _selectedPoetryType = poetryType;
            _sortBy = sortBy;
          });

          if (_searchController.text.trim().length >= 3) {
            ref.read(bookmarkSearchProvider.notifier).search(
                  _searchController.text.trim(),
                  poetryType: poetryType,
                  sortBy: sortBy,
                );
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(bookmarkSearchProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final query = _searchController.text.trim();

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildSearchAppBar(context, isDark),

          if (_selectedPoetryType != null) _buildActiveFilters(),

          if (searchState.hasResults)
            _buildResultsGrid(searchState)
          else if (searchState.isLoading && searchState.results.isEmpty)
            _buildLoadingState()
          else if (searchState.error != null)
            _buildErrorState(searchState.error!)
          else if (!searchState.isLoading &&
              searchState.isEmpty &&
              searchState.currentQuery != null)
            _buildNoResultsState()
          else if (query.isEmpty)
            ..._buildEmptyState()
          else if (query.length < 3)
            _buildMinimumCharsHint(),

          if (searchState.isLoadingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),

          if (!searchState.hasMore && searchState.results.isNotEmpty)
            _buildEndOfResults(),
        ],
      ),
    );
  }

  Widget _buildSearchAppBar(BuildContext context, bool isDark) {
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
          hintText: 'Search your bookmarks...',
          hintStyle: TextStyle(color: Colors.grey[500]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            borderSide: BorderSide.none,
          ),
          prefixIcon: _isSearching
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clearSearch,
                )
              : null,
          filled: true,
          fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
          contentPadding:
              const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        ),
        textInputAction: TextInputAction.search,
        onChanged: _onSearchChanged,
        onSubmitted: _onSearchSubmitted,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list),
          tooltip: 'Filter & Sort',
          onPressed: () => _showFilterBottomSheet(context),
        ),
      ],
    );
  }

  Widget _buildActiveFilters() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Wrap(
          spacing: AppSpacing.sm,
          children: [
            if (_selectedPoetryType != null)
              Chip(
                label: Text(_selectedPoetryType!),
                onDeleted: () {
                  setState(() {
                    _selectedPoetryType = null;
                  });
                  if (_searchController.text.trim().length >= 3) {
                    ref.read(bookmarkSearchProvider.notifier).search(
                          _searchController.text.trim(),
                          sortBy: _sortBy,
                        );
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsGrid(searchState) {
    return SliverPadding(
      padding: const EdgeInsets.all(AppSpacing.md),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final poem = searchState.results[index];
            return _buildBookmarkCard(poem);
          },
          childCount: searchState.results.length,
        ),
      ),
    );
  }

  Widget _buildBookmarkCard(PoemModel poem) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.push('/main/poems/${poem.publicId}');
        },
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bookmark icon
              Align(
                alignment: Alignment.topRight,
                child: Icon(
                  Icons.bookmark,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),

              // Title
              Text(
                poem.getDisplayTitle('ur'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.sm),

              // Excerpt
              Expanded(
                child: Text(
                  poem.getDisplayText('ur'),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Poet and type
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    poem.poetName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    poem.poetryTypeName ?? poem.poetryType,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildEmptyState() {
    return [
      const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
      BookmarkRecentSearches(onSearchTap: _onRecentSearchTapped),
      const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
      const BookmarkSearchSuggestions(),
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
                'Type at least 3 characters to search',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Search by poem title, content, or poet name',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
    return SliverFillRemaining(
      hasScrollBody: false,
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
                'No bookmarks found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Try different keywords or filters',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: AppSpacing.md),
            Text('Searching bookmarks...'),
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
              const Text(
                'Something went wrong',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                error,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton.icon(
                onPressed: () {
                  if (_searchController.text.trim().length >= 3) {
                    ref.read(bookmarkSearchProvider.notifier).search(
                          _searchController.text.trim(),
                          poetryType: _selectedPoetryType,
                          sortBy: _sortBy,
                        );
                  }
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEndOfResults() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Center(
          child: Text(
            "That's all your bookmarks",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }
}
