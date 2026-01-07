import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/features/search/models/global_search_state.dart';
import 'package:flutter_poetry_app/features/search/providers/global_search_provider.dart';

/// Discover segment control with 7 pills
///
/// Features:
/// - All, Poets, Poems, Verses, Categories, Dictionary, Watch
/// - Selected: Filled primary green, white text
/// - Unselected: Outlined, transparent background, primary green text
/// - "Coming Soon" badge on Dictionary/Watch
/// - Height: 34px, Full pill border radius
/// - Horizontal scrollable
class DiscoverSegmentControl extends ConsumerWidget {
  const DiscoverSegmentControl({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(globalSearchProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeSegment = searchState.activeSegment;

    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121212) : const Color(0xFFFFFBF7),
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        children: [
          _buildSegmentPill(
            context,
            ref,
            DiscoverSegment.all,
            'All',
            activeSegment,
            isDark,
          ),
          SizedBox(width: AppSpacing.xs),
          _buildSegmentPill(
            context,
            ref,
            DiscoverSegment.poets,
            'Poets',
            activeSegment,
            isDark,
          ),
          SizedBox(width: AppSpacing.xs),
          _buildSegmentPill(
            context,
            ref,
            DiscoverSegment.poems,
            'Poems',
            activeSegment,
            isDark,
          ),
          SizedBox(width: AppSpacing.xs),
          _buildSegmentPill(
            context,
            ref,
            DiscoverSegment.verses,
            'Verses',
            activeSegment,
            isDark,
          ),
          SizedBox(width: AppSpacing.xs),
          _buildSegmentPill(
            context,
            ref,
            DiscoverSegment.categories,
            'Categories',
            activeSegment,
            isDark,
          ),
          SizedBox(width: AppSpacing.xs),
          _buildSegmentPill(
            context,
            ref,
            DiscoverSegment.dictionary,
            'Dictionary',
            activeSegment,
            isDark,
            showBadge: true,
          ),
          SizedBox(width: AppSpacing.xs),
          _buildSegmentPill(
            context,
            ref,
            DiscoverSegment.watch,
            'Watch',
            activeSegment,
            isDark,
            showBadge: true,
          ),
        ],
      ),
    );
  }

  /// Build a single segment pill
  Widget _buildSegmentPill(
    BuildContext context,
    WidgetRef ref,
    DiscoverSegment segment,
    String label,
    DiscoverSegment activeSegment,
    bool isDark, {
    bool showBadge = false,
  }) {
    final isSelected = segment == activeSegment;

    return GestureDetector(
      onTap: () {
        ref.read(globalSearchProvider.notifier).setActiveSegment(segment);
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 34,
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.primary.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : AppColors.primary,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ),
          if (showBadge)
            Positioned(
              top: -4,
              right: -6,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFC5A059), // Gold
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Soon',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Sticky segment control delegate for SliverPersistentHeader
class DiscoverSegmentDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  DiscoverSegmentDelegate({required this.child});

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
    return child;
  }

  @override
  bool shouldRebuild(DiscoverSegmentDelegate oldDelegate) => false;
}
