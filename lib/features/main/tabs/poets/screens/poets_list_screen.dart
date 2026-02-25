import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/poets_pagination_provider.dart';
import '../providers/poets_discovery_provider.dart';
import '../widgets/poet_card.dart';
import '../widgets/poets_horizontal_section.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';

/// Poets discovery feed screen.
///
/// Layout:
///   [1] Deep muted app bar (#12372A)
///   [2] Horizontal discovery sections (Trending, Featured, Top Read, etc.)
///   [3] "All Poets" header with active filter chip
///   [4] 3-column masonry grid with infinite scroll
///
/// Background: warm beige (#F7F5F1 light / #1A1A1A dark)
class PoetsListScreen extends ConsumerStatefulWidget {
  const PoetsListScreen({super.key});

  @override
  ConsumerState<PoetsListScreen> createState() => _PoetsListScreenState();
}

class _PoetsListScreenState extends ConsumerState<PoetsListScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _allPoetsKey = GlobalKey();
  PoetsFilterType _activeGridFilter = PoetsFilterType.all;
  late final AnimationController _searchPulseController;
  late final Animation<double> _searchPulseAnimation;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _searchPulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _searchPulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchPulseController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      ref.read(poetsPaginationProvider.notifier).loadMore();
    }
  }

  Future<void> _onRefresh() async {
    await Future.wait([
      ref.read(poetsDiscoveryProvider.notifier).refresh(),
      ref.read(poetsPaginationProvider.notifier).refresh(),
    ]);
  }

  void _onSeeAll(PoetsFilterType filter) {
    HapticFeedback.selectionClick();
    setState(() => _activeGridFilter = filter);
    ref.read(poetsPaginationProvider.notifier).setFilter(filter);

    Future.delayed(const Duration(milliseconds: 300), () {
      if (_allPoetsKey.currentContext != null) {
        Scrollable.ensureVisible(
          _allPoetsKey.currentContext!,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _onClearFilter() {
    HapticFeedback.selectionClick();
    setState(() => _activeGridFilter = PoetsFilterType.all);
    ref.read(poetsPaginationProvider.notifier).setFilter(PoetsFilterType.all);
  }

  void _onPoetTap(String publicId) {
    context.push('/main/poets/$publicId');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final discoveryState = ref.watch(poetsDiscoveryProvider);
    final paginationState = ref.watch(poetsPaginationProvider);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppColors.primary,
        backgroundColor: isDark ? const Color(0xFF242424) : Colors.white,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildAppBar(isDark),

            // ── Discovery sections ──
            ..._buildDiscoverySections(discoveryState),

            // ── "All Poets" header ──
            SliverToBoxAdapter(
              key: _allPoetsKey,
              child: _buildAllPoetsHeader(isDark),
            ),

            // ── Masonry grid ──
            _buildPoetsGrid(isDark, paginationState),
            if (paginationState.isLoadingMore)
              SliverToBoxAdapter(child: _buildLoadingMore()),
            if (!paginationState.hasMore &&
                paginationState.poets.isNotEmpty &&
                !paginationState.isLoading)
              SliverToBoxAdapter(child: _buildEndOfList(isDark)),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  // ──── Discovery Sections ────

  List<Widget> _buildDiscoverySections(PoetsDiscoveryState state) {
    if (state.status == PoetsDiscoveryStatus.loading ||
        state.status == PoetsDiscoveryStatus.initial) {
      // Show 3 skeleton sections while loading
      return List.generate(
        3,
        (_) => SliverToBoxAdapter(
          child: PoetsHorizontalSection(
            title: '',
            icon: Icons.circle,
            poets: null,
            onPoetTap: (_) {},
          ),
        ),
      );
    }

    if (state.status == PoetsDiscoveryStatus.error) {
      // On error, skip sections — the grid below still works independently
      return [];
    }

    return [
      SliverToBoxAdapter(
        child: PoetsHorizontalSection(
          title: 'Trending Poets',
          icon: Icons.whatshot_rounded,
          iconColor: Colors.orange,
          poets: state.trending.poets,
          totalCount: state.trending.totalCount,
          onSeeAll: () => _onSeeAll(PoetsFilterType.trending),
          onPoetTap: (p) => _onPoetTap(p.publicId),
        ),
      ),
      SliverToBoxAdapter(
        child: PoetsHorizontalSection(
          title: 'Featured Poets',
          icon: Icons.stars_rounded,
          iconColor: AppColors.secondary,
          poets: state.featured.poets,
          totalCount: state.featured.totalCount,
          onSeeAll: () => _onSeeAll(PoetsFilterType.featured),
          onPoetTap: (p) => _onPoetTap(p.publicId),
        ),
      ),
      SliverToBoxAdapter(
        child: PoetsHorizontalSection(
          title: 'Most Read Poets',
          icon: Icons.visibility_rounded,
          iconColor: AppColors.info,
          poets: state.topRead.poets,
          totalCount: state.topRead.totalCount,
          onSeeAll: () => _onSeeAll(PoetsFilterType.topByViews),
          onPoetTap: (p) => _onPoetTap(p.publicId),
        ),
      ),
      SliverToBoxAdapter(
        child: PoetsHorizontalSection(
          title: 'Classical Poets',
          icon: Icons.auto_stories_rounded,
          iconColor: AppColors.primary,
          poets: state.classical.poets,
          totalCount: state.classical.totalCount,
          onSeeAll: () => _onSeeAll(PoetsFilterType.classical),
          onPoetTap: (p) => _onPoetTap(p.publicId),
        ),
      ),
      SliverToBoxAdapter(
        child: PoetsHorizontalSection(
          title: 'Modern Poets',
          icon: Icons.brush_rounded,
          iconColor: AppColors.urduTextAccent,
          poets: state.modern.poets,
          totalCount: state.modern.totalCount,
          onSeeAll: () => _onSeeAll(PoetsFilterType.modern),
          onPoetTap: (p) => _onPoetTap(p.publicId),
        ),
      ),
      SliverToBoxAdapter(
        child: PoetsHorizontalSection(
          title: 'Women Poets',
          icon: Icons.female_rounded,
          iconColor: AppColors.error,
          poets: state.women.poets,
          totalCount: state.women.totalCount,
          onSeeAll: () => _onSeeAll(PoetsFilterType.women),
          onPoetTap: (p) => _onPoetTap(p.publicId),
        ),
      ),
    ];
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
        AnimatedBuilder(
          animation: _searchPulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _searchPulseAnimation.value,
              child: child,
            );
          },
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              context.push('/main/poets-search');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.25),
                  width: 0.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.search, size: 16, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    'Search',
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  // ──── All Poets Header ────

  Widget _buildAllPoetsHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Row(
        children: [
          Icon(
            Icons.people_rounded,
            size: 20,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
          const SizedBox(width: 8),
          Text(
            'All Poets',
            style: GoogleFonts.roboto(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          if (_activeGridFilter != PoetsFilterType.all) ...[
            const SizedBox(width: 8),
            _buildActiveFilterChip(),
          ],
        ],
      ),
    );
  }

  Widget _buildActiveFilterChip() {
    final label = switch (_activeGridFilter) {
      PoetsFilterType.trending => 'Trending',
      PoetsFilterType.featured => 'Featured',
      PoetsFilterType.topByViews => 'Most Read',
      PoetsFilterType.classical => 'Classical',
      PoetsFilterType.modern => 'Modern',
      PoetsFilterType.women => 'Women',
      PoetsFilterType.all => 'All',
    };

    return GestureDetector(
      onTap: _onClearFilter,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.roboto(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.close, size: 12, color: Colors.white),
          ],
        ),
      ),
    );
  }

  // ──── Masonry Grid ────

  Widget _buildPoetsGrid(bool isDark, PoetsPaginationState state) {
    if (state.isLoading && state.poets.isEmpty) {
      return _buildSkeletonGrid(isDark);
    }

    if (state.error != null && state.poets.isEmpty) {
      return SliverToBoxAdapter(child: _buildErrorState(isDark));
    }

    if (state.poets.isEmpty) {
      return SliverToBoxAdapter(child: _buildEmptyState(isDark));
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 0),
      sliver: SliverMasonryGrid.count(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 8,
        childCount: state.poets.length,
        itemBuilder: (context, index) {
          final poet = state.poets[index];
          return RepaintBoundary(
            child: PoetCard(
              poet: poet,
              onTap: () => _onPoetTap(poet.publicId),
            ),
          );
        },
      ),
    );
  }

  // ──── Skeleton Grid ────

  Widget _buildSkeletonGrid(bool isDark) {
    final baseColor =
        isDark ? const Color(0xFF2C2C2C) : AppColors.shimmerBase;

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 0),
      sliver: SliverMasonryGrid.count(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 8,
        childCount: 6,
        itemBuilder: (_, index) {
          return Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF262626) : const Color(0xFFFCFAF6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? const Color(0xFF3A3A3A) : const Color(0xFFEFE6DA),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 1.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 60,
                        height: 10,
                        decoration: BoxDecoration(
                          color: baseColor,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 40,
                        height: 8,
                        decoration: BoxDecoration(
                          color: baseColor,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(height: 0.5, color: baseColor),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            width: 24,
                            height: 8,
                            decoration: BoxDecoration(
                              color: baseColor,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 24,
                            height: 8,
                            decoration: BoxDecoration(
                              color: baseColor,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
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
