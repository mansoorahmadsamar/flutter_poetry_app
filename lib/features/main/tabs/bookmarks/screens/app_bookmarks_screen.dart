import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart'; // v7 API: Share.share(text)
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/features/engagement/providers/unified_bookmark_provider.dart';
import 'package:flutter_poetry_app/features/main/tabs/bookmarks/models/unified_bookmark_model.dart';
import 'package:flutter_poetry_app/features/main/tabs/bookmarks/widgets/app_bookmark_compact_card.dart';
import 'package:flutter_poetry_app/features/main/tabs/bookmarks/widgets/app_bookmark_filter_chips.dart';
import 'package:flutter_poetry_app/features/main/tabs/bookmarks/widgets/app_bookmark_empty_state.dart';

/// Unified bookmarks screen — English header, segmented control,
/// filter bottom sheet, dense list, swipe actions, multi-select.
class AppBookmarksScreen extends ConsumerStatefulWidget {
  const AppBookmarksScreen({super.key});

  @override
  ConsumerState<AppBookmarksScreen> createState() => _AppBookmarksScreenState();
}

class _AppBookmarksScreenState extends ConsumerState<AppBookmarksScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  // State
  BookmarkFilters _filters = const BookmarkFilters();
  bool _isSearchMode = false;
  bool _isSelectMode = false;
  final Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // ──── Scroll & Pagination ────

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      final notifier = ref.read(unifiedBookmarksProvider(_filters).notifier);
      final asyncValue = ref.read(unifiedBookmarksProvider(_filters));
      if (asyncValue.hasValue && !asyncValue.value!.last) {
        notifier.loadMore();
      }
    }
  }

  Future<void> _onRefresh() async {
    await ref.read(unifiedBookmarksProvider(_filters).notifier).refresh();
    ref.invalidate(bookmarkStatsProvider);
  }

  // ──── Filters ────

  void _onTypeChanged(String type) {
    setState(() {
      _filters = _filters.copyWith(type: type, page: 0);
    });
  }

  void _openFilterSheet(bool isDark) async {
    final stats = ref.read(bookmarkStatsProvider).valueOrNull;
    final result = await AppBookmarkFilterSheet.show(
      context,
      selectedLanguage: _filters.language,
      selectedSortBy: _filters.sortBy,
      selectedSortDir: _filters.sortDir,
      byLanguage: stats?.byLanguage,
      isDark: isDark,
    );

    if (result != null && mounted) {
      setState(() {
        _filters = _filters.copyWith(
          language: result.language,
          sortBy: result.sortBy,
          sortDir: result.sortDir,
          page: 0,
        );
      });
    }
  }

  // ──── Search ────

  void _enterSearchMode() {
    setState(() => _isSearchMode = true);
  }

  void _exitSearchMode() {
    _searchController.clear();
    _debounce?.cancel();
    setState(() {
      _isSearchMode = false;
      _filters = _filters.copyWith(searchQuery: null, page: 0);
    });
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      if (mounted) {
        setState(() {
          _filters = _filters.copyWith(
            searchQuery: query.length >= 2 ? query : null,
            page: 0,
          );
        });
      }
    });
  }

  // ──── Selection ────

  void _enterSelectMode(String bookmarkId) {
    setState(() {
      _isSelectMode = true;
      _selectedIds.add(bookmarkId);
    });
  }

  void _exitSelectMode() {
    setState(() {
      _isSelectMode = false;
      _selectedIds.clear();
    });
  }

  void _toggleSelection(String bookmarkId) {
    setState(() {
      if (_selectedIds.contains(bookmarkId)) {
        _selectedIds.remove(bookmarkId);
        if (_selectedIds.isEmpty) _isSelectMode = false;
      } else {
        _selectedIds.add(bookmarkId);
      }
    });
  }

  // ──── Actions ────

  void _navigateToBookmark(UnifiedBookmark bookmark) {
    switch (bookmark.type.toUpperCase()) {
      case 'POEM':
        if (bookmark.contentId.isNotEmpty) {
          context.push('/main/poems/${bookmark.contentId}');
        }
        break;
      case 'COUPLET':
        if (bookmark.coupletPoemPublicId != null &&
            bookmark.coupletPoemPublicId!.isNotEmpty) {
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

  Future<void> _deleteBookmark(UnifiedBookmark bookmark, int index) async {
    final notifier = ref.read(unifiedBookmarksProvider(_filters).notifier);
    notifier.removeBookmarkLocally(bookmark.bookmarkId);

    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Bookmark removed',
            style: GoogleFonts.roboto(fontSize: 13),
          ),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Undo',
            textColor: AppColors.primary,
            onPressed: () {
              notifier.addBookmarkLocally(bookmark, index);
            },
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }

    try {
      final removeAction = ref.read(removeBookmarkProvider);
      await removeAction(
        bookmarkId: bookmark.bookmarkId,
        type: bookmark.type,
      );
    } catch (_) {
      notifier.addBookmarkLocally(bookmark, index);
    }
  }

  void _shareBookmark(UnifiedBookmark bookmark) {
    String text;
    switch (bookmark.type.toUpperCase()) {
      case 'POEM':
        text = bookmark.poemTitle ?? '';
        if (bookmark.poetName != null) text += '\n— ${bookmark.poetName}';
        break;
      case 'COUPLET':
        text = bookmark.coupletVerse1 ?? '';
        if (bookmark.coupletVerse2 != null) {
          text += '\n${bookmark.coupletVerse2}';
        }
        if (bookmark.poetName != null) text += '\n— ${bookmark.poetName}';
        break;
      case 'IMAGE':
        text = bookmark.templateName ?? 'Image Poetry';
        break;
      default:
        text = '';
    }
    if (text.isNotEmpty) {
      Share.share(text);
    }
  }

  Future<void> _deleteSelected() async {
    final bookmarksAsync = ref.read(unifiedBookmarksProvider(_filters));
    if (!bookmarksAsync.hasValue) return;

    final selected = bookmarksAsync.value!.content
        .where((b) => _selectedIds.contains(b.bookmarkId))
        .toList();
    final count = selected.length;

    _exitSelectMode();

    for (final bookmark in selected) {
      try {
        final removeAction = ref.read(removeBookmarkProvider);
        await removeAction(
          bookmarkId: bookmark.bookmarkId,
          type: bookmark.type,
        );
      } catch (_) {}
    }

    await _onRefresh();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$count bookmark${count > 1 ? 's' : ''} removed',
            style: GoogleFonts.roboto(fontSize: 13),
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> _shareSelected() async {
    final bookmarksAsync = ref.read(unifiedBookmarksProvider(_filters));
    if (!bookmarksAsync.hasValue) return;

    final selected = bookmarksAsync.value!.content
        .where((b) => _selectedIds.contains(b.bookmarkId))
        .toList();

    final texts = <String>[];
    for (final b in selected) {
      switch (b.type.toUpperCase()) {
        case 'POEM':
          if (b.poemTitle != null) texts.add(b.poemTitle!);
          break;
        case 'COUPLET':
          final v1 = b.coupletVerse1 ?? '';
          final v2 = b.coupletVerse2 ?? '';
          texts.add(v2.isNotEmpty ? '$v1\n$v2' : v1);
          break;
        case 'IMAGE':
          if (b.templateName != null) texts.add(b.templateName!);
          break;
      }
    }

    if (texts.isNotEmpty) {
      Share.share(texts.join('\n\n'));
    }
    _exitSelectMode();
  }

  // ──── Active filter label ────

  bool get _hasActiveFilters =>
      _filters.language != 'ALL' ||
      _filters.sortBy != 'bookmarkedAt' ||
      _filters.sortDir != 'desc';

  String get _activeFilterLabel {
    final parts = <String>[];
    if (_filters.language != 'ALL') {
      switch (_filters.language) {
        case 'ur':
          parts.add('Urdu');
          break;
        case 'en':
          parts.add('English');
          break;
        case 'hi':
          parts.add('Hindi');
          break;
        default:
          parts.add(_filters.language);
      }
    }
    if (_filters.sortBy == 'bookmarkedAt' && _filters.sortDir == 'asc') {
      parts.add('Oldest first');
    } else if (_filters.sortBy == 'likeCount') {
      parts.add('Most popular');
    }
    return parts.join(' · ');
  }

  void _clearFilters() {
    setState(() {
      _filters = _filters.copyWith(
        language: 'ALL',
        sortBy: 'bookmarkedAt',
        sortDir: 'desc',
        page: 0,
      );
    });
  }

  // ──── Build ────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bookmarksAsync = ref.watch(unifiedBookmarksProvider(_filters));
    final statsAsync = ref.watch(bookmarkStatsProvider);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: Column(
        children: [
          // AppBar
          _buildAppBar(isDark),

          // Segmented control
          if (!_isSelectMode)
            AppBookmarkSegmentedControl(
              selectedType: _filters.type,
              onTypeChanged: _onTypeChanged,
              stats: statsAsync.valueOrNull,
              isDark: isDark,
            ),

          // Active filter indicator
          if (_hasActiveFilters && !_isSelectMode)
            _buildActiveFilterIndicator(isDark),

          // Content
          Expanded(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              color: AppColors.primary,
              child: bookmarksAsync.when(
                data: (response) => _buildContent(response, isDark),
                loading: () => _buildLoadingState(isDark),
                error: (_, __) => AppBookmarkErrorState(
                  isDark: isDark,
                  onRetry: _onRefresh,
                ),
              ),
            ),
          ),

          // Multi-select bottom bar
          if (_isSelectMode) _buildSelectBar(isDark),
        ],
      ),
    );
  }

  Widget _buildAppBar(bool isDark) {
    return SafeArea(
      bottom: false,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: child,
        ),
        child: _isSelectMode
            ? _buildSelectAppBar(isDark)
            : _isSearchMode
                ? _buildSearchBar(isDark)
                : _buildNormalAppBar(isDark),
      ),
    );
  }

  Widget _buildNormalAppBar(bool isDark) {
    return Container(
      key: const ValueKey('normal-appbar'),
      padding: const EdgeInsets.fromLTRB(20, 8, 8, 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bookmarks',
                  style: GoogleFonts.roboto(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.primary,
                  ),
                ),
                Text(
                  'Saved for later',
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.search,
              color: isDark ? Colors.white70 : AppColors.primary,
            ),
            onPressed: _enterSearchMode,
            tooltip: 'Search',
          ),
          IconButton(
            icon: Icon(
              _hasActiveFilters
                  ? Icons.filter_alt
                  : Icons.filter_alt_outlined,
              color: _hasActiveFilters
                  ? AppColors.primary
                  : (isDark ? Colors.white70 : AppColors.primary),
            ),
            onPressed: () => _openFilterSheet(isDark),
            tooltip: 'Filters',
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      key: const ValueKey('search-appbar'),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: isDark ? Colors.white70 : AppColors.primary,
            ),
            onPressed: _exitSearchMode,
          ),
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: _onSearchChanged,
                style: GoogleFonts.roboto(
                  fontSize: 15,
                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                ),
                decoration: InputDecoration(
                  hintText: 'Search bookmarks...',
                  hintStyle: GoogleFonts.roboto(
                    fontSize: 15,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.3),
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? AnimatedScale(
                          scale: 1.0,
                          duration: const Duration(milliseconds: 150),
                          curve: Curves.easeOut,
                          child: IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                          ),
                        )
                      : null,
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildSelectAppBar(bool isDark) {
    return Container(
      key: const ValueKey('select-appbar'),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            color: isDark ? Colors.white70 : AppColors.textPrimaryLight,
            onPressed: _exitSelectMode,
          ),
          const SizedBox(width: 8),
          Text(
            '${_selectedIds.length} selected',
            style: GoogleFonts.roboto(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.textPrimaryLight,
            ),
          ),
          const Spacer(),
          if (_selectedIds.isNotEmpty) ...[
            IconButton(
              icon: const Icon(Icons.share_outlined),
              color: AppColors.primary,
              onPressed: _shareSelected,
              tooltip: 'Share',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: AppColors.error,
              onPressed: _deleteSelected,
              tooltip: 'Remove',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActiveFilterIndicator(bool isDark) {
    return AnimatedOpacity(
      opacity: _hasActiveFilters ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.filter_alt,
              size: 14,
              color: AppColors.primary.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                _activeFilterLabel,
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ),
            GestureDetector(
              onTap: _clearFilters,
              child: Icon(
                Icons.close,
                size: 16,
                color: isDark
                    ? AppColors.textDisabledDark
                    : AppColors.textDisabledLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(UnifiedBookmarksResponse response, bool isDark) {
    if (response.content.isEmpty) {
      if (_isSearchMode &&
          _filters.searchQuery != null &&
          _filters.searchQuery!.isNotEmpty) {
        return AppBookmarkSearchEmpty(
          query: _filters.searchQuery!,
          isDark: isDark,
        );
      }
      return AppBookmarkEmptyState(
        isDark: isDark,
        activeFilter: _filters.type,
        onDiscoverTap: () => context.go('/main'),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      switchInCurve: Curves.easeOut,
      child: ListView.builder(
        key: ValueKey('list_${_filters.type}_${_filters.language}_${_filters.sortBy}'),
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        cacheExtent: 500.0,
        padding: EdgeInsets.only(
          top: _isSearchMode &&
                  _filters.searchQuery != null &&
                  _filters.searchQuery!.isNotEmpty
              ? 0
              : 8,
          bottom: AppSpacing.xl + 16,
        ),
        itemCount: response.content.length +
            (_isSearchMode &&
                    _filters.searchQuery != null &&
                    _filters.searchQuery!.isNotEmpty
                ? 1
                : 0) +
            (response.last ? 0 : 1),
        itemBuilder: (context, index) {
          // Search result count header
          if (_isSearchMode &&
              _filters.searchQuery != null &&
              _filters.searchQuery!.isNotEmpty &&
              index == 0) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Text(
                '${response.totalElements} result${response.totalElements != 1 ? 's' : ''} for "${_filters.searchQuery}"',
                style: GoogleFonts.roboto(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            );
          }

          // Adjust index for search header offset
          final contentIndex = _isSearchMode &&
                  _filters.searchQuery != null &&
                  _filters.searchQuery!.isNotEmpty
              ? index - 1
              : index;

          // Loading more indicator
          if (contentIndex == response.content.length) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              ),
            );
          }

          final bookmark = response.content[contentIndex];

          // Select mode — no swipe
          if (_isSelectMode) {
            return RepaintBoundary(
              child: AppBookmarkCompactCard(
                bookmark: bookmark,
                onTap: () => _toggleSelection(bookmark.bookmarkId),
                isDark: isDark,
                isSelecting: true,
                isSelected: _selectedIds.contains(bookmark.bookmarkId),
              ),
            );
          }

          // Normal mode — bidirectional swipe
          return RepaintBoundary(
            child: Dismissible(
              key: ValueKey(bookmark.bookmarkId),
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.endToStart) {
                  // Swipe left → delete
                  return true;
                } else {
                  // Swipe right → share (don't dismiss)
                  _shareBookmark(bookmark);
                  return false;
                }
              },
              onDismissed: (_) => _deleteBookmark(bookmark, contentIndex),
              // Swipe left background (delete)
              background: Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 24),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F6F5E),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.share_outlined, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Share',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              // Swipe right background (share)
              secondaryBackground: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 24),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFC75B5B),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Remove',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.delete_outline, color: Colors.white, size: 20),
                  ],
                ),
              ),
              child: AppBookmarkCompactCard(
                bookmark: bookmark,
                onTap: () => _navigateToBookmark(bookmark),
                onLongPress: () => _enterSelectMode(bookmark.bookmarkId),
                isDark: isDark,
                searchQuery: _filters.searchQuery,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 8,
      itemBuilder: (_, index) => _SkeletonCard(isDark: isDark),
    );
  }

  Widget _buildSelectBar(bool isDark) {
    return AnimatedSlide(
      offset: _isSelectMode ? Offset.zero : const Offset(0, 1),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          12 + MediaQuery.of(context).padding.bottom,
        ),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _selectedIds.isNotEmpty ? _deleteSelected : null,
                icon: const Icon(Icons.delete_outline, size: 18),
                label: Text(
                  'Remove (${_selectedIds.length})',
                  style: GoogleFonts.roboto(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: BorderSide(
                    color: AppColors.error.withValues(alpha: 0.5),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _selectedIds.isNotEmpty ? _shareSelected : null,
                icon: const Icon(Icons.share_outlined, size: 18),
                label: Text(
                  'Share (${_selectedIds.length})',
                  style: GoogleFonts.roboto(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.5),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton loading card
class _SkeletonCard extends StatelessWidget {
  final bool isDark;
  const _SkeletonCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final baseColor = isDark ? const Color(0xFF2C2C2C) : AppColors.shimmerBase;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFBF7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 14,
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 140,
                  height: 14,
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 100,
                  height: 10,
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            children: [
              Container(
                width: 24,
                height: 12,
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
