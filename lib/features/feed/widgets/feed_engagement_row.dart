import 'package:flutter/material.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';

/// Reusable engagement button row for feed cards.
/// Displays like, bookmark, and share buttons with counts.
class FeedEngagementRow extends StatelessWidget {
  final int likeCount;
  final int bookmarkCount;
  final int shareCount;
  final bool isLiked;
  final bool isBookmarked;
  final VoidCallback? onLike;
  final VoidCallback? onBookmark;
  final VoidCallback? onShare;

  const FeedEngagementRow({
    super.key,
    this.likeCount = 0,
    this.bookmarkCount = 0,
    this.shareCount = 0,
    this.isLiked = false,
    this.isBookmarked = false,
    this.onLike,
    this.onBookmark,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _EngagementButton(
          icon: isLiked ? Icons.favorite : Icons.favorite_border,
          color: isLiked ? Colors.red : null,
          count: likeCount,
          onTap: onLike,
        ),
        const SizedBox(width: AppSpacing.md),
        _EngagementButton(
          icon: isBookmarked ? Icons.bookmark : Icons.bookmark_border,
          color: isBookmarked ? AppColors.secondary : null,
          count: bookmarkCount,
          onTap: onBookmark,
        ),
        const SizedBox(width: AppSpacing.md),
        _EngagementButton(
          icon: Icons.share_outlined,
          count: shareCount,
          onTap: onShare,
        ),
      ],
    );
  }
}

class _EngagementButton extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final int count;
  final VoidCallback? onTap;

  const _EngagementButton({
    required this.icon,
    this.color,
    required this.count,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color ?? defaultColor),
            if (count > 0) ...[
              const SizedBox(width: 4),
              Text(
                _formatCount(count),
                style: TextStyle(
                  fontSize: 12,
                  color: color ?? defaultColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }
}
