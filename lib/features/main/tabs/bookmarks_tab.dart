import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/providers/language_provider.dart';
import 'package:flutter_poetry_app/features/engagement/providers/bookmark_providers.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/models/poem_model.dart';
import 'package:flutter_poetry_app/features/main/tabs/bookmarks/widgets/bookmark_poem_card.dart';

/// Modern unified bookmarks screen - No tabs, mixed horizontal and vertical sections
class BookmarksTab extends ConsumerStatefulWidget {
  const BookmarksTab({super.key});

  @override
  ConsumerState<BookmarksTab> createState() => _BookmarksTabState();
}

class _BookmarksTabState extends ConsumerState<BookmarksTab> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  // State
  int _currentPage = 0;
  List<PoemModel> _allBookmarks = [];
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  String? _searchQuery;
  String? _poetryTypeFilter;
  String _sortBy = 'NEWEST';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _hasMoreData) {
        _loadMore();
      }
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
      _currentPage++;
    });

    final params = BookmarksParams(
      page: _currentPage,
      search: _searchQuery,
      poetryType: _poetryTypeFilter,
      sortBy: _sortBy,
    );

    final asyncValue = await ref.read(bookmarksProvider(params).future);

    setState(() {
      _allBookmarks.addAll(asyncValue.content);
      _hasMoreData = !asyncValue.last;
      _isLoadingMore = false;
    });
  }

  Future<void> _onRefresh() async {
    setState(() {
      _currentPage = 0;
      _allBookmarks.clear();
      _hasMoreData = true;
    });
    ref.invalidate(bookmarksProvider);
  }

  void _onSearch(String query) {
    if (query.length >= 3 || query.isEmpty) {
      setState(() {
        _searchQuery = query.isEmpty ? null : query;
        _currentPage = 0;
        _allBookmarks.clear();
        _hasMoreData = true;
      });
      ref.invalidate(bookmarksProvider);
    }
  }

  void _onFilterChange(String? poetryType) {
    setState(() {
      _poetryTypeFilter = poetryType;
      _currentPage = 0;
      _allBookmarks.clear();
      _hasMoreData = true;
    });
    ref.invalidate(bookmarksProvider);
  }

  void _onSortChange(String sortBy) {
    setState(() {
      _sortBy = sortBy;
      _currentPage = 0;
      _allBookmarks.clear();
      _hasMoreData = true;
    });
    ref.invalidate(bookmarksProvider);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = ref.watch(selectedLanguageProvider);
    final isUrdu = lang == 'ur';

    final params = BookmarksParams(
      page: _currentPage,
      search: _searchQuery,
      poetryType: _poetryTypeFilter,
      sortBy: _sortBy,
    );

    final bookmarksAsync = ref.watch(bookmarksProvider(params));

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : AppColors.backgroundLight,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppColors.secondary,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // App Bar
            SliverAppBar(
              floating: true,
              backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
              elevation: 0,
              title: Text(
                'My Bookmarks',
                style: GoogleFonts.roboto(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppColors.primary,
                ),
              ),
              actions: [
                // Sort Menu
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.sort_rounded,
                    color: isDark ? Colors.white70 : AppColors.primary,
                  ),
                  onSelected: _onSortChange,
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'NEWEST',
                      child: Text('Newest First'),
                    ),
                    const PopupMenuItem(
                      value: 'OLDEST',
                      child: Text('Oldest First'),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
              ],
            ),

            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: [
                    // Search Field
                    TextField(
                      controller: _searchController,
                      onChanged: _onSearch,
                      decoration: InputDecoration(
                        hintText: 'Search bookmarks...',
                        hintStyle: TextStyle(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.4)
                              : Colors.black.withValues(alpha: 0.4),
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  _onSearch('');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : AppColors.borderLight,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : AppColors.borderLight,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.secondary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _FilterChip(
                            label: 'All',
                            isSelected: _poetryTypeFilter == null,
                            onTap: () => _onFilterChange(null),
                            isDark: isDark,
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: 'Ghazal',
                            isSelected: _poetryTypeFilter == 'GHAZAL',
                            onTap: () => _onFilterChange('GHAZAL'),
                            isDark: isDark,
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: 'Nazm',
                            isSelected: _poetryTypeFilter == 'NAZM',
                            onTap: () => _onFilterChange('NAZM'),
                            isDark: isDark,
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: 'Rubaiyat',
                            isSelected: _poetryTypeFilter == 'RUBAIYAT',
                            onTap: () => _onFilterChange('RUBAIYAT'),
                            isDark: isDark,
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: 'Qasida',
                            isSelected: _poetryTypeFilter == 'QASIDA',
                            onTap: () => _onFilterChange('QASIDA'),
                            isDark: isDark,
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: 'Marsiya',
                            isSelected: _poetryTypeFilter == 'MARSIYA',
                            onTap: () => _onFilterChange('MARSIYA'),
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Recent Bookmarks Section (Horizontal)
            bookmarksAsync.when(
              data: (paginatedData) {
                // Combine previously loaded bookmarks with new data
                if (_currentPage == 0) {
                  _allBookmarks = paginatedData.content;
                  _hasMoreData = !paginatedData.last;
                }

                if (_allBookmarks.isEmpty) {
                  return SliverFillRemaining(
                    child: _EmptyState(isDark: isDark, isUrdu: isUrdu),
                  );
                }

                // Show horizontal recent bookmarks only if on first page
                final recentBookmarks = _allBookmarks.take(5).toList();

                return SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Recent Bookmarks Header
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          AppSpacing.md,
                          AppSpacing.lg,
                          AppSpacing.md,
                          AppSpacing.sm,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recent',
                              style: GoogleFonts.roboto(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : AppColors.primary,
                              ),
                            ),
                            if (_allBookmarks.length > 5)
                              TextButton(
                                onPressed: () {
                                  // Scroll to all bookmarks section
                                  _scrollController.animateTo(
                                    500,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOut,
                                  );
                                },
                                child: Text(
                                  'View All',
                                  style: GoogleFonts.roboto(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Horizontal Recent List
                      SizedBox(
                        height: 220,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                          itemCount: recentBookmarks.length,
                          itemBuilder: (context, index) {
                            final poem = recentBookmarks[index];
                            return Padding(
                              padding: EdgeInsets.only(
                                right: index < recentBookmarks.length - 1
                                    ? AppSpacing.md
                                    : 0,
                              ),
                              child: SizedBox(
                                width: 160,
                                child: BookmarkPoemCard(
                                  poem: poem,
                                  onTap: () {
                                    context.push('/main/poems/${poem.publicId}');
                                  },
                                  isHorizontal: true,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
              error: (error, stack) => const SliverToBoxAdapter(
                child: SizedBox.shrink(),
              ),
            ),

            // All Bookmarks Header
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.xl,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: Text(
                  'All Bookmarks',
                  style: GoogleFonts.roboto(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.primary,
                  ),
                ),
              ),
            ),

            // All Bookmarks Grid (Vertical 3-column)
            bookmarksAsync.when(
              data: (paginatedData) {
                if (_allBookmarks.isEmpty) {
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                }

                return SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.52,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final poem = _allBookmarks[index];
                        return BookmarkPoemCard(
                          poem: poem,
                          onTap: () {
                            context.push('/main/poems/${poem.publicId}');
                          },
                          isHorizontal: false,
                        );
                      },
                      childCount: _allBookmarks.length,
                    ),
                  ),
                );
              },
              loading: () => SliverPadding(
                padding: EdgeInsets.all(AppSpacing.md),
                sliver: const SliverToBoxAdapter(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.secondary,
                    ),
                  ),
                ),
              ),
              error: (error, stack) => SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.4)
                            : Colors.black.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load bookmarks',
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.6)
                              : Colors.black.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Loading More Indicator
            if (_isLoadingMore)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.secondary,
                    ),
                  ),
                ),
              ),

            // Bottom Padding
            SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.xl),
            ),
          ],
        ),
      ),
    );
  }
}

// Filter Chip Widget
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.secondary
              : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.secondary
                : (isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : AppColors.borderLight),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.roboto(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white70 : Colors.black87),
          ),
        ),
      ),
    );
  }
}

// Empty State Widget
class _EmptyState extends StatelessWidget {
  final bool isDark;
  final bool isUrdu;

  const _EmptyState({
    required this.isDark,
    required this.isUrdu,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_border_rounded,
            size: 80,
            color: isDark
                ? Colors.white.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'No bookmarks yet',
            style: GoogleFonts.roboto(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.6)
                  : Colors.black.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start saving poems you love',
            style: GoogleFonts.roboto(
              fontSize: 14,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.4)
                  : Colors.black.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}
