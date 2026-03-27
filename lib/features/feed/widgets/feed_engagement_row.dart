import 'package:flutter/material.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/features/engagement/models/reaction_models.dart';
import 'package:flutter_poetry_app/features/engagement/widgets/reaction_button.dart';
import 'package:flutter_poetry_app/features/engagement/widgets/reaction_summary_bar.dart';

/// Reusable engagement button row for feed cards.
/// Instagram/Rekhta-style layout:
///   [Reaction+count]  [Share]  ───spacer───  [extraActions?]  [Bookmark]
///
/// Now supports the unified reactions system with [ReactionButton] and
/// [ReactionSummaryBar] replacing the old heart icon + plain count.
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
  final List<Widget>? extraActions;

  /// Total reactions from socialContext — when non-null and > likeCount,
  /// shows a richer display like "1.8K reactions".
  final int? totalReactions;

  /// The user's current reaction key (e.g. "WAH_WAH", "LOVE").
  /// When provided, the reaction button shows the corresponding emoji.
  final String? userReaction;

  /// Reaction breakdown by type — for the summary bar display.
  final Map<String, int>? reactionsByType;

  /// Callback when user selects a reaction (from picker or quick-tap).
  /// When provided, replaces [onLike] for the reaction button.
  final ValueChanged<String>? onReact;

  /// Cached reaction types for emoji lookup.
  final List<ReactionType> reactionTypes;

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
    this.totalReactions,
    this.userReaction,
    this.reactionsByType,
    this.onReact,
    this.reactionTypes = const [],
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final useReactions = onReact != null;
    final displayTotal = totalReactions ?? likeCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Reaction summary bar (overlapping emojis + count)
        if (useReactions &&
            reactionTypes.isNotEmpty &&
            reactionsByType != null &&
            reactionsByType!.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: ReactionSummaryBar(
              total: displayTotal,
              byType: reactionsByType,
              reactionTypes: reactionTypes,
            ),
          ),
        ] else if (totalReactions != null && totalReactions! > 0) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              '${_formatCount(totalReactions!)} reactions',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
          ),
        ],

        Row(
          children: [
            // Reaction button (replaces heart when reactions are active)
            if (useReactions)
              ReactionButton(
                userReaction: userReaction,
                totalCount: displayTotal,
                reactionsByType: reactionsByType,
                onReact: onReact!,
                size: ReactionButtonSize.compact,
              )
            else
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
}

String _formatCount(int count) {
  if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
  if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
  return count.toString();
}
