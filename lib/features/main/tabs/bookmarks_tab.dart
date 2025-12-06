import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/design_system/app_colors.dart';
import '../../../core/design_system/app_spacing.dart';
import '../../../core/widgets/localized_text.dart';
import '../../engagement/providers/bookmark_providers.dart';

/// Bookmarks tab - Shows saved/bookmarked poems
class BookmarksTab extends ConsumerStatefulWidget {
  const BookmarksTab({super.key});

  @override
  ConsumerState<BookmarksTab> createState() => _BookmarksTabState();
}

class _BookmarksTabState extends ConsumerState<BookmarksTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedPoetryType;
  String _sortBy = 'NEWEST';
  int _currentPage = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final params = BookmarksParams(
      page: _currentPage,
      search: _searchQuery.isEmpty ? null : _searchQuery,
      poetryType: _selectedPoetryType,
      sortBy: _sortBy,
    );

    final bookmarksAsync = ref.watch(bookmarksProvider(params));

    return CustomScrollView(
      slivers: [
        // App bar
        SliverAppBar(
          floating: true,
          snap: true,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          title: const Text(
            'Bookmarks',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () => _showFilterDialog(context),
            ),
          ],
        ),

        // Search bar
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search bookmarks...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                            _currentPage = 0;
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
              onSubmitted: (value) {
                setState(() {
                  _searchQuery = value.trim();
                  _currentPage = 0;
                });
              },
            ),
          ),
        ),

        // Filter chips
        if (_selectedPoetryType != null || _sortBy != 'NEWEST')
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Wrap(
                spacing: AppSpacing.sm,
                children: [
                  if (_selectedPoetryType != null)
                    Chip(
                      label: Text(_selectedPoetryType!),
                      onDeleted: () {
                        setState(() {
                          _selectedPoetryType = null;
                          _currentPage = 0;
                        });
                      },
                    ),
                  if (_sortBy != 'NEWEST')
                    Chip(
                      label: Text(_getSortLabel(_sortBy)),
                      onDeleted: () {
                        setState(() {
                          _sortBy = 'NEWEST';
                          _currentPage = 0;
                        });
                      },
                    ),
                ],
              ),
            ),
          ),

        // Bookmarks list or empty state
        bookmarksAsync.when(
          data: (paginatedResponse) {
            final bookmarks = paginatedResponse.content;

            if (bookmarks.isEmpty) {
              return SliverFillRemaining(
                child: _buildEmptyState(context),
              );
            }

            return SliverPadding(
              padding: EdgeInsets.all(AppSpacing.md),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final poem = bookmarks[index];
                    return Card(
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () {
                          context.push('/main/poems/${poem.publicId}');
                        },
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Bookmark icon
                              const Align(
                                alignment: Alignment.topRight,
                                child: Icon(
                                  Icons.bookmark,
                                  color: AppColors.primary,
                                ),
                              ),
                              SizedBox(height: AppSpacing.sm),
                              // Title
                              if (poem.title != null)
                                LocalizedText(
                                  poem.title!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              SizedBox(height: AppSpacing.sm),
                              // Excerpt
                              if (poem.excerpt != null)
                                Expanded(
                                  child: LocalizedText(
                                    poem.excerpt!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              SizedBox(height: AppSpacing.sm),
                              // Poet name and poetry type
                              Text(
                                poem.poetName,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: AppSpacing.xs),
                              Text(
                                poem.poetryType,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: bookmarks.length,
                ),
              ),
            );
          },
          loading: () => const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => SliverFillRemaining(
            child: _buildErrorState(context, error),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_border,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 24),
            Text(
              _searchQuery.isNotEmpty || _selectedPoetryType != null
                  ? 'No Bookmarks Found'
                  : 'No Bookmarks Yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              _searchQuery.isNotEmpty || _selectedPoetryType != null
                  ? 'Try adjusting your search or filters'
                  : 'Start bookmarking your favorite poems to see them here',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red[300],
            ),
            const SizedBox(height: 24),
            Text(
              'Failed to Load Bookmarks',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _currentPage = 0;
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filter & Sort',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: AppSpacing.lg),
                  // Sort by
                  Text(
                    'Sort By',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    children: [
                      ChoiceChip(
                        label: const Text('Newest'),
                        selected: _sortBy == 'NEWEST',
                        onSelected: (selected) {
                          setModalState(() {
                            _sortBy = 'NEWEST';
                          });
                        },
                      ),
                      ChoiceChip(
                        label: const Text('Oldest'),
                        selected: _sortBy == 'OLDEST',
                        onSelected: (selected) {
                          setModalState(() {
                            _sortBy = 'OLDEST';
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.lg),
                  // Apply button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _currentPage = 0;
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('Apply Filters'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _getSortLabel(String sortBy) {
    switch (sortBy) {
      case 'NEWEST':
        return 'Newest First';
      case 'OLDEST':
        return 'Oldest First';
      default:
        return sortBy;
    }
  }
}
