import 'package:flutter/material.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/features/engagement/models/reaction_models.dart';

/// Shows top 3 reaction emojis as overlapping circles + total count.
/// Example: ❤️👏🔥 342
///
/// Falls back to nothing when total is 0.
class ReactionSummaryBar extends StatelessWidget {
  final int total;
  final Map<String, int>? byType;
  final List<ReactionType> reactionTypes;

  const ReactionSummaryBar({
    super.key,
    required this.total,
    this.byType,
    required this.reactionTypes,
  });

  @override
  Widget build(BuildContext context) {
    if (total == 0) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Get top 3 reaction types by count
    final sorted = (byType?.entries.toList() ?? [])
      ..sort((a, b) => b.value.compareTo(a.value));
    final topEmojis = sorted.take(3).map((e) => _emojiFor(e.key)).toList();

    // If no breakdown available, show a heart
    if (topEmojis.isEmpty) {
      topEmojis.add('❤️');
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Overlapping emoji circles
        SizedBox(
          width: 14.0 + (topEmojis.length * 14.0),
          height: 22,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              for (int i = 0; i < topEmojis.length; i++)
                Positioned(
                  left: i * 12.0,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : Colors.white,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      topEmojis[i],
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 4),
        // Animated count
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, animation) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.3),
                end: Offset.zero,
              ).animate(animation),
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          child: Text(
            _formatCount(total),
            key: ValueKey(total),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ),
      ],
    );
  }

  String _emojiFor(String key) {
    for (final type in reactionTypes) {
      if (type.key == key) return type.emoji;
    }
    return '❤️';
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }
}
