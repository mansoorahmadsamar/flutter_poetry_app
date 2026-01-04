import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';

/// Skeleton loader for couplet cards during search
///
/// Matches the exact dimensions of CoupletCard:
/// - Card with padding
/// - Type badge placeholder
/// - 2 verse lines
/// - Shimmer animation for modern UX
class CoupletSkeleton extends StatelessWidget {
  const CoupletSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Shimmer.fromColors(
          baseColor: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : const Color(0xFFE8E8DC),
          highlightColor: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : const Color(0xFFF5F5DC),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Type badge skeleton
              Align(
                alignment: Alignment.topLeft,
                child: Container(
                  width: 80,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              SizedBox(height: AppSpacing.sm),

              // First verse line skeleton
              Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Container(
                  height: 32, // Matches fontSize 20 with 1.8 line height
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),

              // Second verse line skeleton
              Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Container(
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
