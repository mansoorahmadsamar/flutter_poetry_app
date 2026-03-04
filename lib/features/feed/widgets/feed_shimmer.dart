import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';

/// Shimmer loading skeleton for the feed screen.
/// Shows a mix of card shapes mimicking couplet, poem, and spotlight layouts.
class FeedShimmer extends StatelessWidget {
  const FeedShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor =
        isDark ? AppColors.surfaceDark : AppColors.shimmerBase;
    final highlightColor =
        isDark ? AppColors.borderDark : AppColors.shimmerHighlight;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        children: const [
          _CoupletShimmerCard(),
          SizedBox(height: AppSpacing.sm),
          _PoemShimmerCard(),
          SizedBox(height: AppSpacing.sm),
          _SpotlightShimmerCard(),
          SizedBox(height: AppSpacing.sm),
          _ImageShimmerCard(),
        ],
      ),
    );
  }
}

/// Tall card mimicking a couplet with verses
class _CoupletShimmerCard extends StatelessWidget {
  const _CoupletShimmerCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar + name row
          Row(
            children: [
              const CircleAvatar(radius: 18, backgroundColor: Colors.white),
              const SizedBox(width: AppSpacing.sm),
              Container(
                width: 120,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                ),
              ),
              const Spacer(),
              Container(
                width: 60,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          // Verse lines (centered)
          Center(
            child: Container(
              width: 240,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: Container(
              width: 200,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: Container(
              width: 220,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Engagement row
          _ShimmerEngagementRow(),
        ],
      ),
    );
  }
}

/// Shorter card with optional image area for poems
class _PoemShimmerCard extends StatelessWidget {
  const _PoemShimmerCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail placeholder
          Container(
            height: 160,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppSpacing.radiusLg),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar + name row
                Row(
                  children: [
                    const CircleAvatar(
                        radius: 18, backgroundColor: Colors.white),
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      width: 100,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                // Title
                Container(
                  width: 180,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                // Excerpt lines
                Container(
                  width: double.infinity,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Container(
                  width: 260,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _ShimmerEngagementRow(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Card mimicking poet spotlight layout
class _SpotlightShimmerCard extends StatelessWidget {
  const _SpotlightShimmerCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge
          Container(
            width: 70,
            height: 22,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Profile row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 140,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      width: double.infinity,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Container(
                      width: 160,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      width: 90,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Stats row
          Row(
            children: List.generate(
              3,
              (i) => Padding(
                padding: EdgeInsets.only(right: i < 2 ? AppSpacing.md : 0),
                child: Container(
                  width: 70,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Card with large image area for poet images
class _ImageShimmerCard extends StatelessWidget {
  const _ImageShimmerCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Container(
              width: 70,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
              ),
            ),
          ),
          // Image placeholder
          Container(
            height: 220,
            color: Colors.white,
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: _ShimmerEngagementRow(),
          ),
        ],
      ),
    );
  }
}

class _ShimmerEngagementRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        3,
        (i) => Padding(
          padding: EdgeInsets.only(right: i < 2 ? AppSpacing.md : 0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Container(
                width: 24,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
