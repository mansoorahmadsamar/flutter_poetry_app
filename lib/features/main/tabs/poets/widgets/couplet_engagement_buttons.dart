import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_poetry_app/core/design_system/app_spacing.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/providers/language_provider.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/models/couplet_model.dart';
import 'package:flutter_poetry_app/features/engagement/providers/couplet_providers.dart';
import 'package:flutter_poetry_app/features/image_poetry/widgets/share_options_sheet.dart';

class CoupletEngagementButtons extends ConsumerWidget {
  final CoupletModel couplet;

  const CoupletEngagementButtons({
    super.key,
    required this.couplet,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Like button
        _EngagementButton(
          icon: couplet.isLikedByCurrentUser == true
              ? Icons.favorite
              : Icons.favorite_border,
          iconColor: couplet.isLikedByCurrentUser == true
              ? Colors.red
              : Colors.grey,
          count: couplet.likeCount,
          label: 'Like',
          onPressed: () => _handleLike(context, ref),
        ),

        // Bookmark button
        _EngagementButton(
          icon: couplet.isBookmarkedByCurrentUser == true
              ? Icons.bookmark
              : Icons.bookmark_border,
          iconColor: couplet.isBookmarkedByCurrentUser == true
              ? AppColors.primary
              : Colors.grey,
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

  Future<void> _handleLike(BuildContext context, WidgetRef ref) async {
    final isLiked = couplet.isLikedByCurrentUser ?? false;

    try {
      await ref.read(coupletActionProvider.notifier).toggleLike(couplet.publicId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isLiked ? 'Couplet unliked' : 'Couplet liked'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to ${isLiked ? 'unlike' : 'like'} couplet'),
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
        padding: EdgeInsets.all(AppSpacing.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 24),
            SizedBox(height: AppSpacing.xs),
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
