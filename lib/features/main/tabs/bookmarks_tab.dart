import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/providers/language_provider.dart';
import 'package:flutter_poetry_app/core/widgets/standard_app_bar.dart';
import 'package:flutter_poetry_app/features/engagement/providers/unified_bookmark_provider.dart';
import 'package:flutter_poetry_app/features/main/tabs/bookmarks/models/unified_bookmark_model.dart';
import 'package:flutter_poetry_app/features/main/tabs/bookmarks/widgets/unified_bookmark_card.dart';

/// Modern unified bookmarks screen - No tabs, mixed horizontal and vertical sections
class BookmarksTab extends ConsumerStatefulWidget {
  const BookmarksTab({super.key});

  @override
  ConsumerState<BookmarksTab> createState() => _BookmarksTabState();
}

class _BookmarksTabState extends ConsumerState<BookmarksTab> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  // Filters
  BookmarkFilters _filters = const BookmarkFilters();

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
    final notifier = ref.read(unifiedBookmarksProvider(_filters).notifier);
    final asyncValue = ref.read(unifiedBookmarksProvider(_filters));

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (asyncValue.hasValue && !asyncValue.value!.last) {
        notifier.loadMore();
      }
    }
  }

  Future<void> _onRefresh() async {
    final notifier = ref.read(unifiedBookmarksProvider(_filters).notifier);
    await notifier.refresh();
  }

  void _onSearch(String query) {
    if (query.length >= 3 || query.isEmpty) {
      setState(() {
        _filters = _filters.copyWith(
          searchQuery: query.isEmpty ? null : query,
          page: 0,
        );
      });
    }
  }

  void _onSortChange(String sortBy) {
    setState(() {
      _filters = _filters.copyWith(
        sortBy: sortBy == 'NEWEST' ? 'bookmarkedAt' : 'bookmarkedAt',
        sortDir: sortBy == 'NEWEST' ? 'desc' : 'asc',
        page: 0,
      );
    });
  }

  void _navigateToBookmark(BuildContext context, UnifiedBookmark bookmark) {
    switch (bookmark.type.toUpperCase()) {
      case 'POEM':
        if (bookmark.contentId.isNotEmpty) {
          context.push('/main/poems/${bookmark.contentId}');
        }
        break;
      case 'COUPLET':
        // Navigate to the parent poem if we have it
        if (bookmark.coupletPoemPublicId != null && bookmark.coupletPoemPublicId!.isNotEmpty) {
          context.push('/main/poems/${bookmark.coupletPoemPublicId}');
        }
        break;
      case 'IMAGE':
        if (bookmark.contentId.isNotEmpty) {
          context.push('/image-poetry/${bookmark.contentId}');
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = ref.watch(selectedLanguageProvider);
    final isUrdu = lang == 'ur';

    final bookmarksAsync = ref.watch(unifiedBookmarksProvider(_filters));

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : AppColors.backgroundLight,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppColors.secondary,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // App Bar
            StandardSliverAppBar(
              title: 'My Bookmarks',
              actions: [
                // Sort Menu
                PopupMenuButton<String>(
                  icon: const Icon(Icons.sort_rounded),
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
                  ],
                ),
              ),
            ),

            // Bookmarks Content
            bookmarksAsync.when(
              data: (response) {
                if (response.content.isEmpty) {
                  return SliverFillRemaining(
                    child: _EmptyState(isDark: isDark, isUrdu: isUrdu),
                  );
                }

                // Build all content in a single SliverList
                return SliverList(
                  delegate: SliverChildListDelegate([
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
                          if (response.content.length > 5)
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
                      height: 280,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                        itemCount: response.content.take(5).length,
                        itemBuilder: (context, index) {
                          final bookmark = response.content[index];
                          return Padding(
                            padding: EdgeInsets.only(
                              right: index < response.content.take(5).length - 1
                                  ? AppSpacing.md
                                  : 0,
                            ),
                            child: SizedBox(
                              width: 200,
                              child: UnifiedBookmarkCard(
                                bookmark: bookmark,
                                onTap: () => _navigateToBookmark(context, bookmark),
                                isDark: isDark,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // All Bookmarks Header
                    Padding(
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

                    // All Bookmarks (Vertical)
                    ...response.content.map((bookmark) {
                      return UnifiedBookmarkCard(
                        bookmark: bookmark,
                        onTap: () => _navigateToBookmark(context, bookmark),
                        isDark: isDark,
                      );
                    }),
                  ]),
                );
              },
              loading: () => SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.secondary,
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
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        style: GoogleFonts.roboto(
                          fontSize: 12,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.4)
                              : Colors.black.withValues(alpha: 0.3),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
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
