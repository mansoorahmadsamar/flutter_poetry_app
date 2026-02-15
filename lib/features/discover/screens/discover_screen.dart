import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/app_colors.dart';
import '../../../core/providers/language_provider.dart';
import '../models/discover_bundle_model.dart';
import '../providers/discover_provider.dart';
import '../widgets/category_grid.dart';
import '../widgets/discover_hero.dart';
import '../widgets/discover_shimmer.dart';
import '../widgets/horizontal_content_rail.dart';
import '../widgets/poet_grid.dart';
import '../widgets/trending_chips.dart';

/// Premium discover screen with staggered section entrance animations.
class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _staggerController;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  /// Create a staggered interval for each section index
  Animation<double> _sectionAnimation(int index) {
    final start = (index * 0.12).clamp(0.0, 0.7);
    final end = (start + 0.4).clamp(0.0, 1.0);
    return CurvedAnimation(
      parent: _staggerController,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageCode = ref.watch(selectedLanguageProvider);
    final discoverState = ref.watch(discoverProvider);
    final isRtl = languageCode == 'ur' || languageCode == 'hi';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Trigger stagger animation when data loads
    if (discoverState.status == DiscoverStatus.loaded && !_hasAnimated) {
      _hasAnimated = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _staggerController.forward();
      });
    }

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        body: _buildBody(context, ref, discoverState, languageCode, isRtl, isDark),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    DiscoverState discoverState,
    String languageCode,
    bool isRtl,
    bool isDark,
  ) {
    switch (discoverState.status) {
      case DiscoverStatus.initial:
      case DiscoverStatus.loading:
        return const DiscoverShimmer();

      case DiscoverStatus.error:
        return _buildErrorState(context, ref, discoverState, isRtl, isDark);

      case DiscoverStatus.loaded:
        return RefreshIndicator(
          onRefresh: () async {
            _hasAnimated = false;
            _staggerController.reset();
            await ref.read(discoverProvider.notifier).refresh();
          },
          color: AppColors.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: _buildSlivers(context, ref, discoverState, languageCode, isRtl, isDark),
          ),
        );
    }
  }

  List<Widget> _buildSlivers(
    BuildContext context,
    WidgetRef ref,
    DiscoverState discoverState,
    String languageCode,
    bool isRtl,
    bool isDark,
  ) {
    int sectionIndex = 0;
    final slivers = <Widget>[];

    // Hero section (no stagger — always visible immediately)
    slivers.add(SliverToBoxAdapter(
      child: DiscoverHero(
        isRtl: isRtl,
        languageCode: languageCode,
        onSearchTap: () => context.push('/search'),
      ),
    ));

    // Trending Searches
    if (discoverState.bundle?.trendingSearches != null) {
      final anim = _sectionAnimation(sectionIndex++);
      slivers.add(SliverToBoxAdapter(
        child: _StaggeredSection(
          animation: anim,
          child: TrendingChips(
            trending: discoverState.bundle!.trendingSearches,
            isRtl: isRtl,
            onQueryTap: (query) => context.push('/search', extra: {'query': query}),
          ),
        ),
      ));
    }

    // Editor's Picks
    if (discoverState.bundle != null) {
      final anim = _sectionAnimation(sectionIndex++);
      slivers.add(SliverToBoxAdapter(
        child: _StaggeredSection(
          animation: anim,
          child: HorizontalContentRail(
            title: isRtl ? 'ایڈیٹر کی پسند' : "Editor's Picks",
            icon: Icons.workspace_premium_rounded,
            iconColor: AppColors.secondary,
            items: discoverState.bundle!.editorsPicks.items,
            totalCount: discoverState.bundle!.editorsPicks.totalCount,
            isRtl: isRtl,
            onItemTap: (ctx, item) => _navigateToContent(ctx, item),
            onSeeMore: () =>
                _navigateToSectionListing(context, 'editors-picks', isRtl),
          ),
        ),
      ));
    }

    // Recommended
    if (discoverState.bundle != null &&
        discoverState.bundle!.recommended.items.isNotEmpty) {
      final anim = _sectionAnimation(sectionIndex++);
      slivers.add(SliverToBoxAdapter(
        child: _StaggeredSection(
          animation: anim,
          child: HorizontalContentRail(
            title: isRtl ? 'آپ کے لیے' : 'Recommended For You',
            icon: Icons.auto_awesome_rounded,
            iconColor: AppColors.warning,
            items: discoverState.bundle!.recommended.items,
            totalCount: discoverState.bundle!.recommended.totalCount,
            isRtl: isRtl,
            onItemTap: (ctx, item) => _navigateToContent(ctx, item),
            onSeeMore: () =>
                _navigateToSectionListing(context, 'recommended', isRtl),
          ),
        ),
      ));
    } else if (discoverState.bundle != null &&
        discoverState.bundle!.recommended.items.isEmpty) {
      final anim = _sectionAnimation(sectionIndex++);
      slivers.add(SliverToBoxAdapter(
        child: _StaggeredSection(
          animation: anim,
          child: _buildRecommendedEmpty(context, isRtl, isDark),
        ),
      ));
    }

    // Featured Poets
    if (discoverState.bundle != null &&
        discoverState.bundle!.featuredPoets.items.isNotEmpty) {
      final anim = _sectionAnimation(sectionIndex++);
      slivers.add(SliverToBoxAdapter(
        child: _StaggeredSection(
          animation: anim,
          child: PoetGrid(
            poets: discoverState.bundle!.featuredPoets.items,
            totalCount: discoverState.bundle!.featuredPoets.totalCount,
            isRtl: isRtl,
            onPoetTap: (poet) => context.push('/main/poets/${poet.publicId}'),
            onSeeMore: () =>
                _navigateToSectionListing(context, 'featured-poets', isRtl),
          ),
        ),
      ));
    }

    // Categories
    if (discoverState.bundle != null &&
        discoverState.bundle!.categories.items.isNotEmpty) {
      final anim = _sectionAnimation(sectionIndex++);
      slivers.add(SliverToBoxAdapter(
        child: _StaggeredSection(
          animation: anim,
          child: CategoryGrid(
            categories: discoverState.bundle!.categories.items,
            totalCount: discoverState.bundle!.categories.totalCount,
            isRtl: isRtl,
            onCategoryTap: (cat) => context.push('/search', extra: {
              'query': cat.primaryText,
            }),
            onSeeMore: () =>
                _navigateToSectionListing(context, 'categories', isRtl),
          ),
        ),
      ));
    }

    // Bottom padding
    slivers.add(const SliverPadding(padding: EdgeInsets.only(bottom: 16)));

    return slivers;
  }

  Widget _buildErrorState(
    BuildContext context,
    WidgetRef ref,
    DiscoverState state,
    bool isRtl,
    bool isDark,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 64,
              color: AppColors.textDisabledLight,
            ),
            const SizedBox(height: 20),
            Text(
              isRtl ? 'مواد لوڈ نہیں ہو سکا' : 'Could not load content',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: isRtl ? 'Jameel Noori Nastaleeq' : null,
                fontSize: isRtl ? 20 : 18,
                fontWeight: FontWeight.w600,
                height: isRtl ? 1.8 : 1.4,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.errorMessage ??
                  (isRtl ? 'کچھ غلط ہو گیا' : 'Something went wrong'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: isRtl ? 'Jameel Noori Nastaleeq' : null,
                fontSize: isRtl ? 15 : 14,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                height: isRtl ? 1.6 : 1.4,
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () =>
                  ref.read(discoverProvider.notifier).refresh(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: Text(
                isRtl ? 'دوبارہ کوشش کریں' : 'Try Again',
                style: TextStyle(
                  fontFamily: isRtl ? 'Jameel Noori Nastaleeq' : null,
                  fontSize: isRtl ? 16 : 15,
                  height: isRtl ? 1.6 : 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Glassmorphism empty state for Recommended section.
  Widget _buildRecommendedEmpty(
    BuildContext context,
    bool isRtl,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : AppColors.secondary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : AppColors.secondary.withValues(alpha: 0.15),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.secondary.withValues(alpha: 0.2),
                        AppColors.primary.withValues(alpha: 0.1),
                      ],
                    ),
                  ),
                  child: Icon(
                    Icons.explore_rounded,
                    size: 26,
                    color: AppColors.secondary.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  isRtl
                      ? 'ابھی تک کوئی سفارش نہیں'
                      : 'No recommendations yet',
                  style: TextStyle(
                    fontFamily: isRtl ? 'Jameel Noori Nastaleeq' : null,
                    fontSize: isRtl ? 16 : 14,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                    height: isRtl ? 1.6 : 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isRtl
                      ? 'مقبول مواد دریافت کریں'
                      : 'Explore trending content',
                  style: TextStyle(
                    fontFamily: isRtl ? 'Jameel Noori Nastaleeq' : null,
                    fontSize: isRtl ? 13 : 12,
                    color: AppColors.secondary,
                    height: isRtl ? 1.5 : 1.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToContent(BuildContext context, ContentCard item) {
    switch (item.type) {
      case 'POET':
        context.push('/main/poets/${item.publicId}');
      case 'POEM':
        context.push('/main/poems/${item.publicId}');
      case 'VERSE':
      case 'COUPLET':
        // TODO: Add couplet detail route when available
        context.push('/main/poems/${item.publicId}');
      case 'CATEGORY':
        context.push('/search', extra: {'query': item.primaryText});
      case 'TAG':
        context.push('/search', extra: {'query': item.primaryText});
    }
  }

  void _navigateToSectionListing(
    BuildContext context,
    String sectionKey,
    bool isRtl,
  ) {
    // TODO: Navigate to SectionListingScreen when route is added
    // context.push('/discover/$sectionKey');
  }
}

/// Wraps a child in a fade+slide-up staggered entrance animation.
class _StaggeredSection extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const _StaggeredSection({
    required this.animation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(0, 24 * (1 - animation.value)),
            child: child,
          ),
        );
      },
    );
  }
}
