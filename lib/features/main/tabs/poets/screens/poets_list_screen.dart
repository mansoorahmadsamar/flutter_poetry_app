import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/poets_pagination_provider.dart';
import '../widgets/poet_card.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';

/// Premium poets listing screen — editorial, calm, literary aesthetic.
///
/// Layout:
///   [1] Deep muted app bar (#12372A) — refined, shorter
///   [2] Elegant underline-style filter tabs
///   [3] 3-column grid of elevated poet cards
///   [4] Infinite scroll with skeleton loading
///
/// Background: warm beige (#F5F1E8 light / #1A1A1A dark)
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
        _scrollController.position.maxScrollExtent * 0.8) {
      ref.read(poetsPaginationProvider.notifier).loadMore();
    }
  }

  Future<void> _onRefresh() async {
    await ref.read(poetsPaginationProvider.notifier).refresh();
  }

  void _onFilterChanged(PoetsFilterType filter) {
    HapticFeedback.selectionClick();
    if (_selectedFilter == filter) {
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
      backgroundColor:
          isDark ? AppColors.backgroundDark : const Color(0xFFF5F1E8),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppColors.primary,
        backgroundColor: isDark ? const Color(0xFF242424) : Colors.white,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildAppBar(isDark),
            _buildFilterTabs(isDark),
            _buildPoetsList(isDark, paginationState),
            if (paginationState.isLoadingMore)
              SliverToBoxAdapter(
                child: _buildLoadingMore(),
              ),
            if (!paginationState.hasMore &&
                paginationState.poets.isNotEmpty &&
                !paginationState.isLoading)
              SliverToBoxAdapter(
                child: _buildEndOfList(isDark),
              ),
            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 32),
            ),
          ],
        ),
      ),
    );
  }

  // ──── App Bar ────

  Widget _buildAppBar(bool isDark) {
    return SliverAppBar(
      backgroundColor: isDark
          ? const Color(0xFF0F1F1A)
          : const Color(0xFF12372A),
      foregroundColor: Colors.white,
      floating: true,
      snap: true,
      toolbarHeight: 52,
      elevation: 0,
      title: Text(
        'Poets',
        style: GoogleFonts.roboto(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: Colors.white,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, size: 22),
          onPressed: () => context.push('/main/poets-search'),
          tooltip: 'Search poets',
          splashRadius: 20,
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // ──── Filter Tabs ────

  Widget _buildFilterTabs(bool isDark) {
    final filters = [
      ('All', PoetsFilterType.all),
      ('Trending', PoetsFilterType.trending),
      ('Featured', PoetsFilterType.featured),
      ('Top', PoetsFilterType.topByViews),
      ('Classical', PoetsFilterType.classical),
      ('Modern', PoetsFilterType.modern),
      ('Women', PoetsFilterType.women),
    ];

    return SliverToBoxAdapter(
      child: Container(
        color: isDark ? AppColors.backgroundDark : const Color(0xFFF5F1E8),
        padding: const EdgeInsets.only(top: 12, bottom: 4),
        child: SizedBox(
          height: 36,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filters.length,
            itemBuilder: (context, index) {
              final (label, filter) = filters[index];
              final isSelected = _selectedFilter == filter;

              return Padding(
                padding: EdgeInsets.only(
                  right: index < filters.length - 1 ? 6 : 0,
                ),
                child: GestureDetector(
                  onTap: () => _onFilterChanged(filter),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : (isDark
                                ? Colors.white.withValues(alpha: 0.12)
                                : AppColors.primary.withValues(alpha: 0.2)),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      label,
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : (isDark
                                ? Colors.white.withValues(alpha: 0.6)
                                : AppColors.primary.withValues(alpha: 0.7)),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ──── Poets Grid ────

  Widget _buildPoetsList(bool isDark, PoetsPaginationState state) {
    // Initial loading
    if (state.isLoading && state.poets.isEmpty) {
      return _buildSkeletonGrid(isDark);
    }

    // Error
    if (state.error != null && state.poets.isEmpty) {
      return SliverToBoxAdapter(child: _buildErrorState(isDark));
    }

    // Empty
    if (state.poets.isEmpty) {
      return SliverToBoxAdapter(child: _buildEmptyState(isDark));
    }

    // Grid
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final poet = state.poets[index];
            return RepaintBoundary(
              child: PoetCard(
                poet: poet,
                onTap: () => context.push('/main/poets/${poet.publicId}'),
              ),
            );
          },
          childCount: state.poets.length,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.58,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
      ),
    );
  }

  // ──── Skeleton Grid ────

  Widget _buildSkeletonGrid(bool isDark) {
    final baseColor =
        isDark ? const Color(0xFF2C2C2C) : AppColors.shimmerBase;

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (_, __) => Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF242424) : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                // Image placeholder
                Container(
                  height: 90,
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      // Circle avatar placeholder
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: baseColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Name placeholder
                      Container(
                        width: 60,
                        height: 12,
                        decoration: BoxDecoration(
                          color: baseColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Date placeholder
                      Container(
                        width: 40,
                        height: 8,
                        decoration: BoxDecoration(
                          color: baseColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          childCount: 9,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.58,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
      ),
    );
  }

  // ──── Error State ────

  Widget _buildErrorState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 16),
            Text(
              'Could not load poets',
              style: GoogleFonts.roboto(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.5)
                    : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () =>
                  ref.read(poetsPaginationProvider.notifier).loadInitial(),
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(
                'Try again',
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──── Empty State ────

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : AppColors.primary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_search_rounded,
                size: 44,
                color: isDark
                    ? AppColors.primary.withValues(alpha: 0.4)
                    : AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No poets found',
              style: GoogleFonts.roboto(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.7)
                    : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Try a different filter',
              style: GoogleFonts.roboto(
                fontSize: 13,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.4)
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──── Loading More ────

  Widget _buildLoadingMore() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  // ──── End of List ────

  Widget _buildEndOfList(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Container(
          width: 40,
          height: 2,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ),
    );
  }
}
