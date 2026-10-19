import 'package:flutter/material.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/network/request_failure.dart';

/// Title and explanation for a feed that failed to load.
({String title, String message, IconData icon}) feedErrorCopy(
  RequestFailureKind kind,
) {
  switch (kind) {
    case RequestFailureKind.offline:
      return (
        title: "You're offline",
        message: 'Check your internet connection and try again.',
        icon: Icons.wifi_off_rounded,
      );
    case RequestFailureKind.timeout:
      return (
        title: 'Connection is slow',
        message: 'The feed took too long to load. Please try again.',
        icon: Icons.hourglass_empty_rounded,
      );
    case RequestFailureKind.sessionExpired:
      return (
        title: 'Your session has expired',
        message: 'Please sign in again to see your feed.',
        icon: Icons.lock_clock_outlined,
      );
    case RequestFailureKind.server:
      return (
        title: 'Could not load feed',
        message: 'Sukhan is having trouble right now. Please try again in a moment.',
        icon: Icons.cloud_off_outlined,
      );
    case RequestFailureKind.other:
      return (
        title: 'Could not load feed',
        message: 'Something went wrong. Please try again.',
        icon: Icons.cloud_off_outlined,
      );
  }
}

/// Full-screen error for a feed with nothing to show, with a retry button.
class FeedErrorView extends StatelessWidget {
  final RequestFailureKind kind;
  final VoidCallback onRetry;
  final bool isDark;

  const FeedErrorView({
    super.key,
    required this.kind,
    required this.onRetry,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final copy = feedErrorCopy(kind);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              copy.icon,
              size: AppSpacing.xxxl,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              copy.title,
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              copy.message,
              style: textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
