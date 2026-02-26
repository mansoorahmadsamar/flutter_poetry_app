import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/utils/language_typography.dart';
import 'package:flutter_poetry_app/features/main/tabs/bookmarks/models/unified_bookmark_model.dart';
import 'package:flutter_poetry_app/features/main/tabs/bookmarks/widgets/unified_bookmark_card.dart';
import 'package:flutter_poetry_app/features/engagement/providers/unified_bookmark_provider.dart';

/// Unified Bookmarks Screen - All content types in one feed
class UnifiedBookmarksScreen extends ConsumerStatefulWidget {
  const UnifiedBookmarksScreen({super.key});

  @override
  ConsumerState<UnifiedBookmarksScreen> createState() =>
      _UnifiedBookmarksScreenState();
}

class _UnifiedBookmarksScreenState
    extends ConsumerState<UnifiedBookmarksScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  // Filter state
  String _selectedType = 'ALL';
  String _selectedLanguage = 'ALL';
  String? _searchQuery;

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

  BookmarkFilters _buildFilters() {
    return BookmarkFilters(
      type: _selectedType,
      language: _selectedLanguage,
      searchQuery: _searchQuery,
    );
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final filters = _buildFilters();
      final notifier = ref.read(unifiedBookmarksProvider(filters).notifier);
      final state = ref.read(unifiedBookmarksProvider(filters));

      // Load more if not already loading and has more data
      if (state.hasValue && !state.value!.last) {
        notifier.loadMore();
      }
    }
  }

  Future<void> _onRefresh() async {
    final filters = _buildFilters();
    await ref.read(unifiedBookmarksProvider(filters).notifier).refresh();
  }

  void _onSearchChanged(String query) {
    if (query.length >= 3 || query.isEmpty) {
      setState(() {
        _searchQuery = query.isEmpty ? null : query;
      });
    }
  }

  void _onTypeFilterChanged(String type) {
    setState(() {
      _selectedType = type;
    });
  }

  void _onLanguageFilterChanged(String language) {
    setState(() {
      _selectedLanguage = language;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filters = _buildFilters();
    final bookmarksAsync = ref.watch(unifiedBookmarksProvider(filters));

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : AppColors.backgroundLight,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppColors.secondary,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // App Bar
            SliverAppBar(
              floating: true,
              pinned: true,
              backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
              elevation: 0,
              title: Text(
                'All Bookmarks',
                style: GoogleFonts.roboto(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppColors.primary,
                ),
              ),
            ),

            // Sticky Search Bar
            SliverPersistentHeader(
              pinned: true,
              delegate: _SearchBarDelegate(
                isDark: isDark,
                searchController: _searchController,
                onSearchChanged: _onSearchChanged,
              ),
            ),

            // Type Filter (Segmented)
            SliverPersistentHeader(
              pinned: true,
              delegate: _TypeFilterDelegate(
                isDark: isDark,
                selectedType: _selectedType,
                onTypeChanged: _onTypeFilterChanged,
              ),
            ),

            // Language Filter (Chips)
            SliverPersistentHeader(
              pinned: true,
              delegate: _LanguageFilterDelegate(
                isDark: isDark,
                selectedLanguage: _selectedLanguage,
                onLanguageChanged: _onLanguageFilterChanged,
              ),
            ),

            // Bookmarks List
            _buildBookmarksList(isDark, bookmarksAsync),

            // Bottom Padding
            SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.xl),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookmarksList(
    bool isDark,
    AsyncValue<UnifiedBookmarksResponse> bookmarksAsync,
  ) {
    return bookmarksAsync.when(
      data: (response) {
        if (response.content.isEmpty) {
          return SliverFillRemaining(
            child: _EmptyState(
              isDark: isDark,
              selectedType: _selectedType,
              selectedLanguage: _selectedLanguage,
            ),
          );
        }

        return SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                // Show loading indicator at the end if not last page
                if (index == response.content.length) {
                  return Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.secondary,
                      ),
                    ),
                  );
                }

                final bookmark = response.content[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.sm),
                  child: UnifiedBookmarkCard(
                    bookmark: bookmark,
                    onTap: () => _navigateToContent(bookmark),
                    isDark: isDark,
                  ),
                );
              },
              childCount: response.content.length + (response.last ? 0 : 1),
            ),
          ),
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
              SizedBox(height: AppSpacing.md),
              Text(
                'Failed to load bookmarks',
                style: GoogleFonts.roboto(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.6)
                      : Colors.black.withValues(alpha: 0.5),
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.4)
                      : Colors.black.withValues(alpha: 0.4),
                ),
              ),
              SizedBox(height: AppSpacing.md),
              ElevatedButton.icon(
                onPressed: _onRefresh,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToContent(UnifiedBookmark bookmark) {
    switch (bookmark.type) {
      case 'POEM':
        context.push('/main/poems/${bookmark.contentId}');
        break;
      case 'COUPLET':
        // Navigate to poem detail with couplet focus
        if (bookmark.coupletPoemPublicId != null) {
          context.push('/main/poems/${bookmark.coupletPoemPublicId}');
        }
        break;
      case 'IMAGE':
        context.push(
          '/image-poetry/${bookmark.contentId}',
          extra: {'imageUrl': bookmark.imageUrl ?? bookmark.thumbnailUrl},
        );
        break;
    }
  }
}

/// Search bar persistent header delegate
class _SearchBarDelegate extends SliverPersistentHeaderDelegate {
  final bool isDark;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;

  _SearchBarDelegate({
    required this.isDark,
    required this.searchController,
    required this.onSearchChanged,
  });

  @override
  double get minExtent => 80;

  @override
  double get maxExtent => 80;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: isDark ? const Color(0xFF121212) : AppColors.backgroundLight,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: TextField(
        controller: searchController,
        onChanged: onSearchChanged,
        style: LanguageTypography.labelStyle(isDark: isDark),
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
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    onSearchChanged('');
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
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_SearchBarDelegate oldDelegate) => false;
}

/// Type filter persistent header delegate
class _TypeFilterDelegate extends SliverPersistentHeaderDelegate {
  final bool isDark;
  final String selectedType;
  final ValueChanged<String> onTypeChanged;

  _TypeFilterDelegate({
    required this.isDark,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  double get minExtent => 60;

  @override
  double get maxExtent => 60;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: isDark ? const Color(0xFF121212) : AppColors.backgroundLight,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          _SegmentedButton(
            label: 'All',
            value: 'ALL',
            selectedValue: selectedType,
            onTap: () => onTypeChanged('ALL'),
            isDark: isDark,
          ),
          SizedBox(width: AppSpacing.xs),
          _SegmentedButton(
            label: 'Poems',
            value: 'POEM',
            selectedValue: selectedType,
            onTap: () => onTypeChanged('POEM'),
            isDark: isDark,
          ),
          SizedBox(width: AppSpacing.xs),
          _SegmentedButton(
            label: 'Couplets',
            value: 'COUPLET',
            selectedValue: selectedType,
            onTap: () => onTypeChanged('COUPLET'),
            isDark: isDark,
          ),
          SizedBox(width: AppSpacing.xs),
          _SegmentedButton(
            label: 'Images',
            value: 'IMAGE',
            selectedValue: selectedType,
            onTap: () => onTypeChanged('IMAGE'),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_TypeFilterDelegate oldDelegate) =>
      selectedType != oldDelegate.selectedType;
}

/// Language filter persistent header delegate
class _LanguageFilterDelegate extends SliverPersistentHeaderDelegate {
  final bool isDark;
  final String selectedLanguage;
  final ValueChanged<String> onLanguageChanged;

  _LanguageFilterDelegate({
    required this.isDark,
    required this.selectedLanguage,
    required this.onLanguageChanged,
  });

  @override
  double get minExtent => 50;

  @override
  double get maxExtent => 50;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: isDark ? const Color(0xFF121212) : AppColors.backgroundLight,
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        bottom: AppSpacing.xs,
      ),
      child: Row(
        children: [
          _LanguageChip(
            label: 'All',
            value: 'ALL',
            selectedValue: selectedLanguage,
            onTap: () => onLanguageChanged('ALL'),
            isDark: isDark,
          ),
          SizedBox(width: AppSpacing.xs),
          _LanguageChip(
            label: 'اردو',
            value: 'ur',
            selectedValue: selectedLanguage,
            onTap: () => onLanguageChanged('ur'),
            isDark: isDark,
          ),
          SizedBox(width: AppSpacing.xs),
          _LanguageChip(
            label: 'English',
            value: 'en',
            selectedValue: selectedLanguage,
            onTap: () => onLanguageChanged('en'),
            isDark: isDark,
          ),
          SizedBox(width: AppSpacing.xs),
          _LanguageChip(
            label: 'हिंदी',
            value: 'hi',
            selectedValue: selectedLanguage,
            onTap: () => onLanguageChanged('hi'),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_LanguageFilterDelegate oldDelegate) =>
      selectedLanguage != oldDelegate.selectedLanguage;
}

/// Segmented button widget for type filter
class _SegmentedButton extends StatelessWidget {
  final String label;
  final String value;
  final String selectedValue;
  final VoidCallback onTap;
  final bool isDark;

  const _SegmentedButton({
    required this.label,
    required this.value,
    required this.selectedValue,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selectedValue;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary
                : isDark
                    ? const Color(0xFF1E1E1E)
                    : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : AppColors.borderLight,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: LanguageTypography.labelStyle(
              isDark: isDark,
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ).copyWith(
              color: isSelected
                  ? Colors.white
                  : isDark
                      ? Colors.white.withValues(alpha: 0.8)
                      : AppColors.textPrimaryLight,
            ),
          ),
        ),
      ),
    );
  }
}

/// Language chip widget
class _LanguageChip extends StatelessWidget {
  final String label;
  final String value;
  final String selectedValue;
  final VoidCallback onTap;
  final bool isDark;

  const _LanguageChip({
    required this.label,
    required this.value,
    required this.selectedValue,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selectedValue;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.secondary
              : isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.secondary
                : Colors.transparent,
            width: isSelected ? 1.5 : 0,
          ),
        ),
        child: Text(
          label,
          style: LanguageTypography.labelStyle(
            isDark: isDark,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ).copyWith(
            color: isSelected
                ? Colors.white
                : isDark
                    ? Colors.white.withValues(alpha: 0.7)
                    : Colors.black.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}

/// Empty state widget
class _EmptyState extends StatelessWidget {
  final bool isDark;
  final String selectedType;
  final String selectedLanguage;

  const _EmptyState({
    required this.isDark,
    required this.selectedType,
    required this.selectedLanguage,
  });

  @override
  Widget build(BuildContext context) {
    String message = 'No bookmarks yet';
    String subtitle = 'Start saving poems, couplets, and images you love';

    if (selectedType != 'ALL') {
      message = 'No ${selectedType.toLowerCase()} bookmarks';
      subtitle = 'Save some ${selectedType.toLowerCase()}s to see them here';
    }

    if (selectedLanguage != 'ALL') {
      message = 'No ${selectedLanguage.toUpperCase()} bookmarks';
      subtitle = 'Save content in this language to see it here';
    }

    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
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
              message,
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
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                fontSize: 14,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.4)
                    : Colors.black.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
