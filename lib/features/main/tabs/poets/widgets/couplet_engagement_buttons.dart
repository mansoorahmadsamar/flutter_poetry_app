import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/providers/language_provider.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/models/couplet_model.dart';
import 'package:flutter_poetry_app/features/engagement/providers/couplet_providers.dart';
import 'package:flutter_poetry_app/features/engagement/providers/reaction_providers.dart';
import 'package:flutter_poetry_app/features/engagement/widgets/reaction_button.dart';
import 'package:flutter_poetry_app/features/image_poetry/widgets/share_options_sheet.dart';

class CoupletEngagementButtons extends ConsumerWidget {
  final CoupletModel couplet;
  final String? poemPublicId;

  const CoupletEngagementButtons({
    super.key,
    required this.couplet,
    this.poemPublicId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBookmarked = couplet.isBookmarkedByCurrentUser ?? false;

    // Parse user reaction from couplet's reactions map
    final String? userReaction = _getUserReaction(couplet.reactions);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Reaction button (replaces like)
        ReactionButton(
          userReaction: userReaction,
          totalCount: couplet.likeCount,
          reactionsByType: _parseReactionsByType(couplet.reactions),
          onReact: (reactionType) => _handleReact(context, ref, reactionType),
          size: ReactionButtonSize.expanded,
        ),

        // Bookmark button
        _EngagementButton(
          icon: isBookmarked ? Icons.bookmark : Icons.bookmark_border,
          iconColor: isBookmarked ? AppColors.primary : Colors.grey,
          count: couplet.bookmarkCount,
          label: 'Save',
          onPressed: () => _handleBookmark(context, ref),
        ),

        // Share button
        _EngagementButton(
          icon: Icons.share_outlined,
          iconColor: Colors.grey,
          count: couplet.shareCount,
          label: 'Share',
          onPressed: () => _handleShare(context),
        ),
      ],
    );
  }

  Future<void> _handleReact(BuildContext context, WidgetRef ref, String reactionType) async {
    try {
      await ref.read(reactionActionProvider.notifier).react(
            targetType: 'couplets',
            publicId: couplet.publicId,
            reactionType: reactionType,
          );

      if (poemPublicId != null) {
        ref.invalidate(coupletsProvider(poemPublicId!));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to react'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleBookmark(BuildContext context, WidgetRef ref) async {
    final isBookmarked = couplet.isBookmarkedByCurrentUser ?? false;
    final currentLang = ref.read(selectedLanguageProvider);

    try {
      final enrichedCouplet = await ref
          .read(coupletActionProvider.notifier)
          .toggleBookmark(couplet.publicId, lang: currentLang);

      if (poemPublicId != null) {
        ref.invalidate(coupletsProvider(poemPublicId!));
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              (enrichedCouplet.isBookmarkedByCurrentUser ?? false)
                  ? 'Couplet bookmarked'
                  : 'Couplet removed from bookmarks',
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to ${isBookmarked ? 'remove' : 'add'} bookmark'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleShare(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ShareOptionsSheet(coupletId: couplet.publicId),
    );
  }

  String? _getUserReaction(Map<String, dynamic>? reactions) {
    if (reactions == null) return null;
    return reactions['userReaction'] as String?;
  }

  Map<String, int>? _parseReactionsByType(Map<String, dynamic>? reactions) {
    if (reactions == null) return null;
    final byType = reactions['byType'];
    if (byType == null) return null;
    return Map<String, int>.from(byType as Map);
  }
}

class _EngagementButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final int count;
  final String label;
  final VoidCallback onPressed;

  const _EngagementButton({
    required this.icon,
    required this.iconColor,
    required this.count,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(height: AppSpacing.xs),
            Text(
              count > 0 ? '$count' : label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
