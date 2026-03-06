import 'package:flutter/material.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';

/// Reusable engagement button row for feed cards.
/// Instagram/Rekhta-style layout:
///   [Like+count]  [Share]  ───spacer───  [extraActions?]  [Bookmark]
class FeedEngagementRow extends StatelessWidget {
  final int likeCount;
  final int bookmarkCount;
  final int shareCount;
  final bool isLiked;
  final bool isBookmarked;
  final VoidCallback? onLike;
  final VoidCallback? onBookmark;
  final VoidCallback? onShare;

  /// Optional extra action widgets placed on the right side, before bookmark.
  /// Used for card-specific buttons like the copy button on couplet cards.
  final List<Widget>? extraActions;

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
    this.extraActions,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Like button — only button that shows count
        _EngagementButton(
          icon: isLiked
              ? Icons.favorite_rounded
              : Icons.favorite_border_rounded,
          color: isLiked ? AppColors.feedLiked : null,
          count: likeCount,
          onTap: onLike,
        ),
        const SizedBox(width: AppSpacing.lg),

        // Share button — icon only
        _EngagementButton(
          icon: Icons.share_outlined,
          count: 0,
          onTap: onShare,
        ),

        const Spacer(),

        // Extra actions (e.g. copy button on couplet cards)
        if (extraActions != null)
          ...extraActions!.map((w) => Padding(
                padding: const EdgeInsets.only(right: AppSpacing.md),
                child: w,
              )),

        // Bookmark button — far right, icon only
        _EngagementButton(
          icon: isBookmarked
              ? Icons.bookmark_rounded
              : Icons.bookmark_border_rounded,
          color: isBookmarked ? AppColors.secondary : null,
          count: 0,
          onTap: onBookmark,
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
    final defaultColor =
        isDark ? AppColors.engagementIconDark : AppColors.engagementIcon;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 8,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: AppSpacing.feedEngagementIconSize,
              color: color ?? defaultColor,
            ),
            if (count > 0) ...[
              const SizedBox(width: AppSpacing.xs),
              Text(
                _formatCount(count),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
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
