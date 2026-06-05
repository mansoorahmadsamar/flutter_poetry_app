import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_typography.dart';
import 'package:flutter_poetry_app/core/widgets/sukhan/diagonal_hatch.dart';
import 'package:flutter_poetry_app/core/widgets/sukhan/portrait.dart';
import '../models/owned_poet_model.dart';

/// Green-gradient hero shown at the top of the creator dashboard.
/// Mirrors the "Mansoor Ahmad / منصورؔ" mockup with hatch overlay,
/// ۞ corner mark, verified glyph on portrait, stats row, and the
/// Edit Profile + Share action pair.
class CreatorHero extends StatelessWidget {
  const CreatorHero({super.key, required this.poet});

  final OwnedPoet poet;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.zero,
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.0, 0.6, 1.0],
                colors: [
                  AppColors.primaryDark,
                  AppColors.primary,
                  AppColors.primaryLight,
                ],
              ),
              border: Border(
                bottom: BorderSide(color: AppColors.secondary, width: 1),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            child: _Body(poet: poet),
          ),
          DiagonalHatchOverlay(
            color: AppColors.secondary.withValues(alpha: 0.18),
            opacity: 0.18,
          ),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.poet});
  final OwnedPoet poet;

  @override
  Widget build(BuildContext context) {
    final hasPenName = poet.penName != null && poet.penName!.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // LEFT — tappable portrait pushes the edit-profile screen. A small
            // gold camera badge signals the avatar itself is interactive.
            GestureDetector(
              onTap: () =>
                  GoRouter.of(context).push('/main/creator/profile/edit'),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Portrait(
                    size: 92,
                    initial: poet.displayInitial,
                    hue: PortraitHue.gold,
                    ring: true,
                    imageUrl: poet.profileImageUrl,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primaryDark,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 13,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),

            // RIGHT — title row + gold divider + Urdu bio paragraph.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title row: pen name (right-aligned, Nastaleeq) with the
                  // flower ornament to its right edge.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          hasPenName ? poet.penName! : poet.name,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: SukhanText.nastaleeq(
                            size: 28,
                            color: AppColors.secondaryLight,
                            height: 1.15,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.local_florist_outlined,
                        size: 22,
                        color:
                            AppColors.secondaryLight.withValues(alpha: 0.85),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Thin gold divider line under the title.
                  Container(
                    height: 1,
                    color: AppColors.secondary.withValues(alpha: 0.55),
                  ),
                  const SizedBox(height: 10),
                  // Bio paragraph (clamped to 4 lines).
                  if (poet.shortBio != null && poet.shortBio!.isNotEmpty)
                    Text(
                      poet.shortBio!,
                      textDirection: _isRtl(poet.shortBio!)
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      style: SukhanText.nastaleeq(
                        size: 14,
                        color: AppColors.backgroundLight
                            .withValues(alpha: 0.92),
                        height: 1.6,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Stats row — icon + value + label, evenly distributed.
        Row(
          children: [
            Expanded(
              child: _StatBlock(
                icon: Icons.group_outlined,
                value: _fmt(poet.followerCount),
                label: 'Followers',
              ),
            ),
            Expanded(
              child: _StatBlock(
                icon: Icons.menu_book_outlined,
                value: _fmt(poet.poemCount),
                label: 'Poems',
              ),
            ),
            Expanded(
              child: _StatBlock(
                icon: Icons.visibility_outlined,
                value: _fmt(poet.viewCount),
                label: 'Views',
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        // Action buttons: gold-filled Edit profile + gold-outline Share.
        Row(
          children: [
            Expanded(
              child: _GoldButton(
                icon: Icons.edit_note,
                label: 'Edit profile',
                onPressed: () =>
                    GoRouter.of(context).push('/main/creator/profile/edit'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _GhostButton(
                icon: Icons.ios_share,
                label: 'Share',
                onPressed: () => Share.share(
                  'Read my verses on Sukhan: https://sukhan.app/poets/${poet.publicId}',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  bool _isRtl(String s) {
    if (s.isEmpty) return false;
    final c = s.runes.first;
    // Arabic + Urdu Unicode blocks
    return (c >= 0x0600 && c <= 0x06FF) ||
        (c >= 0x0750 && c <= 0x077F) ||
        (c >= 0xFB50 && c <= 0xFDFF) ||
        (c >= 0xFE70 && c <= 0xFEFF);
  }

  String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}m';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(n >= 10000 ? 0 : 1)}k';
    return '$n';
  }
}

class _StatBlock extends StatelessWidget {
  const _StatBlock({
    required this.icon,
    required this.value,
    required this.label,
  });
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: AppColors.secondaryLight),
            const SizedBox(width: 8),
            Text(
              value,
              style: SukhanText.display(
                size: 22,
                color: AppColors.backgroundLight,
                weight: FontWeight.w600,
                height: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: SukhanText.sans(
            size: 12,
            color: AppColors.backgroundLight.withValues(alpha: 0.75),
            weight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _GoldButton extends StatelessWidget {
  const _GoldButton({required this.icon, required this.label, required this.onPressed});
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.primaryDark,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: SukhanText.sans(
          size: 14,
          weight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _GhostButton extends StatelessWidget {
  const _GhostButton({required this.icon, required this.label, required this.onPressed});
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18, color: AppColors.secondary),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.secondary,
        side: const BorderSide(color: AppColors.secondary, width: 1.2),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: SukhanText.sans(
          size: 14,
          weight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
