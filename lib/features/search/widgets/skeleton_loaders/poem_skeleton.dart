import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';

/// Skeleton loader for poem cards during search
///
/// Generic poem card structure:
/// - Poem title
/// - Poet name
/// - Couplet count metadata
/// - Shimmer animation for modern UX
class PoemSkeleton extends StatelessWidget {
  const PoemSkeleton({super.key});

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Poem title skeleton (larger, prominent)
              Container(
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              SizedBox(height: AppSpacing.sm),

              // Poet name skeleton
              Container(
                width: 140,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              SizedBox(height: AppSpacing.xs),

              // Metadata skeleton (couplet count, etc)
              Container(
                width: 100,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
