import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_typography.dart';
import 'package:flutter_poetry_app/core/widgets/sukhan/diagonal_hatch.dart';
import 'package:flutter_poetry_app/core/widgets/sukhan/portrait.dart';
import 'package:flutter_poetry_app/core/widgets/sukhan/verified_mark.dart';
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
            color: AppColors.secondary.withValues(alpha: 0.22),
            opacity: 0.22,
          ),
          Positioned(
            top: 12,
            right: 14,
            child: Text(
              '۞',
              style: TextStyle(
                fontFamily: AppTypography.urduFontFamily,
                fontSize: 26,
                color: AppColors.secondaryLight.withValues(alpha: 0.78),
                height: 1,
              ),
            ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Portrait(
                  size: 72,
                  initial: poet.displayInitial,
                  hue: PortraitHue.gold,
                  ring: true,
                  imageUrl: poet.profileImageUrl,
                ),
                if (poet.isVerifiedOwner)
                  const Positioned(
                    bottom: -2,
                    right: -2,
                    child: VerifiedMark(size: 22),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    children: [
                      Text(
                        poet.name,
                        style: SukhanText.display(
                          size: 20,
                          color: AppColors.backgroundLight,
                          weight: FontWeight.w500,
                          letterSpacing: -0.2,
                          height: 1.1,
                        ),
                      ),
                      if (poet.penName != null)
                        Text(
                          poet.penName!,
                          textDirection: TextDirection.rtl,
                          style: SukhanText.nastaleeq(
                            size: 18,
                            color: AppColors.secondaryLight,
                            height: 1.1,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (poet.shortBio != null && poet.shortBio!.isNotEmpty)
                    Text(
                      poet.shortBio!,
                      style: SukhanText.italic(
                        size: 12,
                        color: AppColors.backgroundLight.withValues(alpha: 0.78),
                        height: 1.5,
                      ),
                      textDirection: _isRtl(poet.shortBio!)
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _StatBlock(value: _fmt(poet.followerCount), label: 'Followers'),
            const SizedBox(width: 18),
            _StatBlock(value: _fmt(poet.poemCount), label: 'Poems'),
            const SizedBox(width: 18),
            _StatBlock(value: _fmt(poet.viewCount), label: 'Views'),
            const Spacer(),
          ],
        ),
        const SizedBox(height: 14),
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
            const SizedBox(width: 8),
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
  const _StatBlock({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: SukhanText.display(
              size: 20,
              color: AppColors.backgroundLight,
              weight: FontWeight.w600,
              height: 1,
            )),
        const SizedBox(height: 4),
        Text(label.toUpperCase(),
            style: SukhanText.sans(
              size: 10,
              color: AppColors.backgroundLight.withValues(alpha: 0.7),
              letterSpacing: 0.8,
              weight: FontWeight.w500,
            )),
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
      icon: Icon(icon, size: 14),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.backgroundLight,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: SukhanText.sans(
          size: 12,
          weight: FontWeight.w600,
          letterSpacing: 0.4,
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
      icon: Icon(icon, size: 14),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        backgroundColor: AppColors.backgroundLight.withValues(alpha: 0.12),
        foregroundColor: AppColors.backgroundLight,
        side: BorderSide(
          color: AppColors.backgroundLight.withValues(alpha: 0.32),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: SukhanText.sans(
          size: 12,
          weight: FontWeight.w500,
        ),
      ),
    );
  }
}
