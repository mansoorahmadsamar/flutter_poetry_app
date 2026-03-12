import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/widgets/localized_text.dart';
import 'package:flutter_poetry_app/features/engagement/providers/couplet_providers.dart';
import 'package:flutter_poetry_app/features/hashtags/widgets/hashtag_pill.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/models/couplet_model.dart';

class BookmarkedCoupletsScreen extends ConsumerStatefulWidget {
  const BookmarkedCoupletsScreen({super.key});

  @override
  ConsumerState<BookmarkedCoupletsScreen> createState() =>
      _BookmarkedCoupletsScreenState();
}

class _BookmarkedCoupletsScreenState
    extends ConsumerState<BookmarkedCoupletsScreen> {
  final ScrollController _scrollController = ScrollController();
  String? _selectedPoetryType;
  String _sortBy = 'createdAt';
  int _currentPage = 0;
  bool _isLoadingMore = false;
  bool _hasMorePages = true;
  List<BookmarkedCoupletResponse> _allCouplets = [];

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

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      _loadMoreCouplets();
    }
  }

  Future<void> _loadMoreCouplets() async {
    if (_isLoadingMore || !_hasMorePages) return;

    setState(() => _isLoadingMore = true);

    final nextPage = _currentPage + 1;
    final params = BookmarkedCoupletsParams(
      page: nextPage,
      poetryType: _selectedPoetryType,
      sortBy: _sortBy,
    );

    try {
      final result = await ref.read(bookmarkedCoupletsProvider(params).future);

      if (mounted) {
        setState(() {
          _currentPage = nextPage;
          _allCouplets.addAll(result.content);
          _hasMorePages = nextPage < result.totalPages - 1;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _currentPage = 0;
      _allCouplets.clear();
      _hasMorePages = true;
    });

    ref.invalidate(bookmarkedCoupletsProvider);

    final params = BookmarkedCoupletsParams(
      page: 0,
      poetryType: _selectedPoetryType,
      sortBy: _sortBy,
    );

    try {
      await ref.read(bookmarkedCoupletsProvider(params).future);
    } catch (e) {
      // Error handled by UI
    }
  }

  void _resetPagination() {
    setState(() {
      _currentPage = 0;
      _allCouplets.clear();
      _hasMorePages = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final params = BookmarkedCoupletsParams(
      page: 0,
      poetryType: _selectedPoetryType,
      sortBy: _sortBy,
    );

    final coupletsAsync = ref.watch(bookmarkedCoupletsProvider(params));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarked Couplets'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: coupletsAsync.when(
          data: (paginatedResponse) {
            // Update cached couplets with first page
            if (_currentPage == 0 && _allCouplets.isEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _allCouplets = List.from(paginatedResponse.content);
                    _hasMorePages = paginatedResponse.totalPages > 1;
                  });
                }
              });
            }

            final allCouplets = _currentPage == 0
                ? paginatedResponse.content
                : _allCouplets;

            if (allCouplets.isEmpty) {
              return _buildEmptyState(context);
            }

            return ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(AppSpacing.md),
              itemCount: allCouplets.length + (_hasMorePages || _isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == allCouplets.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                return _buildBookmarkedCoupletCard(allCouplets[index]);
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildErrorState(context, error),
        ),
      ),
    );
  }

  Widget _buildBookmarkedCoupletCard(BookmarkedCoupletResponse couplet) {
    return Card(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: () {
          // Navigate to poem detail
          context.push('/main/poems/${couplet.poemPublicId}');
        },
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Couplet type badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (couplet.coupletTypeName != null)
                    Chip(
                      label: Text(
                        couplet.coupletTypeName!,
                        style: const TextStyle(fontSize: 11),
                      ),
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    ),
                  Icon(Icons.bookmark, color: AppColors.primary, size: 20),
                ],
              ),

              SizedBox(height: AppSpacing.sm),

              // Verses
              ...couplet.verses.map((verse) => Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
                    child: LocalizedText(
                      verse.text,
                      style: const TextStyle(
                        fontSize: 18,
                        height: 1.8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )),

              // Hashtag pills
              if (couplet.tagSlugs.isNotEmpty) ...[
                SizedBox(height: AppSpacing.sm),
                HashtagSlugRow(slugs: couplet.tagSlugs),
              ],

              SizedBox(height: AppSpacing.md),
              Divider(color: Colors.grey[300]),
              SizedBox(height: AppSpacing.sm),

              // Poem and poet info
              Row(
                children: [
                  if (couplet.poetProfileImageUrl != null)
                    CircleAvatar(
                      radius: 16,
                      backgroundImage:
                          NetworkImage(couplet.poetProfileImageUrl!),
                    ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          couplet.poetName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        if (couplet.poemTitle != null)
                          LocalizedText(
                            couplet.poemTitle!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
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
              'No Bookmarked Couplets',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tap on a couplet and bookmark it to see it here',
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
              'Failed to Load Couplets',
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
              onPressed: _handleRefresh,
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
                        selected: _sortBy == 'createdAt',
                        onSelected: (selected) {
                          setModalState(() {
                            _sortBy = 'createdAt';
                          });
                        },
                      ),
                      ChoiceChip(
                        label: const Text('Most Liked'),
                        selected: _sortBy == 'likeCount',
                        onSelected: (selected) {
                          setModalState(() {
                            _sortBy = 'likeCount';
                          });
                        },
                      ),
                      ChoiceChip(
                        label: const Text('Most Viewed'),
                        selected: _sortBy == 'viewCount',
                        onSelected: (selected) {
                          setModalState(() {
                            _sortBy = 'viewCount';
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
                          _resetPagination();
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
}
