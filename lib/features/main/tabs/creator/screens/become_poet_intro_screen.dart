import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_typography.dart';
import 'package:flutter_poetry_app/core/widgets/sukhan/gold_divider.dart';
import 'package:flutter_poetry_app/core/widgets/sukhan/sukhan_chip.dart';

/// "Are you a poet?" — onboarding split: write new vs claim existing.
/// Reachable from `/main/become-poet`.
class BecomePoetIntroScreen extends StatelessWidget {
  const BecomePoetIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: _buildAppBar(context),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(height: 22),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'STEP 1 OF 2',
                  style: SukhanText.eyebrow(
                    color: AppColors.secondary,
                    size: 10,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Claim your voice',
                  style: SukhanText.display(
                    size: 28,
                    color: AppColors.primary,
                    weight: FontWeight.w500,
                    letterSpacing: -0.42,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'آپ کیسے شاعر ہیں؟',
                  textDirection: TextDirection.rtl,
                  style: SukhanText.nastaleeq(
                    size: 18,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Two paths into the diwan. Pick the one that fits.',
                  style: SukhanText.italic(
                    size: 13,
                    color: AppColors.textSecondaryLight,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _PathCard(
                  eyebrow: 'NEW VOICE',
                  english: 'I write poetry',
                  urdu: 'میں شاعری لکھتا/لکھتی ہوں',
                  description:
                      'Start a new poet page. Instantly verified — your verses go live the moment you compose them.',
                  iconChip: const _IconChip(
                    icon: Icons.edit_note,
                    bg: AppColors.greenSoft,
                    fg: AppColors.primary,
                  ),
                  chips: const [
                    SukhanChip(label: 'Instant verified', variant: SukhanChipVariant.green, fontSize: 10),
                    SukhanChip(label: '~2 min', variant: SukhanChipVariant.ghost, fontSize: 10),
                  ],
                  borderColor: AppColors.primary,
                  borderWidth: 1.5,
                  background: AppColors.surfaceLight,
                  onTap: () => context.push('/main/become-poet/new'),
                ),
                const SizedBox(height: 14),
                _PathCard(
                  eyebrow: 'ALREADY LISTED',
                  english: "I'm already on Sukhan",
                  urdu: 'میں پہلے سے درج ہوں',
                  description:
                      "Find your poet card and submit proof. Editors review within 48 hours.",
                  iconChip: const _IconChip(
                    icon: Icons.menu_book_outlined,
                    bg: AppColors.goldSoft,
                    fg: AppColors.secondaryDark,
                  ),
                  chips: const [
                    SukhanChip(label: '48h review', variant: SukhanChipVariant.gold, fontSize: 10),
                    SukhanChip(label: 'One-time', variant: SukhanChipVariant.ghost, fontSize: 10),
                  ],
                  borderColor: AppColors.dividerLight,
                  borderWidth: 1,
                  background: AppColors.paperSurface,
                  onTap: () => context.push('/main/become-poet/claim'),
                ),
                const SizedBox(height: 22),
                const _GhalibQuote(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.paperSurface,
      surfaceTintColor: AppColors.paperSurface,
      foregroundColor: AppColors.textPrimaryLight,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, size: 22),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Become a poet',
              style: SukhanText.display(
                size: 17,
                color: AppColors.textPrimaryLight,
                weight: FontWeight.w600,
                height: 1.1,
                letterSpacing: -0.17,
              )),
          Text('شاعر بنیں',
              textDirection: TextDirection.rtl,
              style: SukhanText.nastaleeq(
                size: 12,
                color: AppColors.textSecondaryLight,
              )),
        ],
      ),
      titleSpacing: 0,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).maybePop(),
          child: Text(
            'Skip',
            style: SukhanText.italic(size: 13, color: AppColors.secondary),
          ),
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}

class _PathCard extends StatelessWidget {
  const _PathCard({
    required this.eyebrow,
    required this.english,
    required this.urdu,
    required this.description,
    required this.iconChip,
    required this.chips,
    required this.borderColor,
    required this.borderWidth,
    required this.background,
    required this.onTap,
  });

  final String eyebrow;
  final String english;
  final String urdu;
  final String description;
  final _IconChip iconChip;
  final List<SukhanChip> chips;
  final Color borderColor;
  final double borderWidth;
  final Color background;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      eyebrow,
                      style: SukhanText.eyebrow(
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      english,
                      style: SukhanText.display(
                        size: 18,
                        color: AppColors.textPrimaryLight,
                        weight: FontWeight.w600,
                        letterSpacing: -0.18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      urdu,
                      textDirection: TextDirection.rtl,
                      style: SukhanText.nastaleeq(
                        size: 15,
                        color: borderColor == AppColors.primary
                            ? AppColors.primary
                            : AppColors.secondaryDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: SukhanText.italic(
                        size: 12,
                        color: AppColors.textSecondaryLight,
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: chips,
                    ),
                  ],
                ),
              ),
              Positioned(top: 0, right: 0, child: iconChip),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconChip extends StatelessWidget {
  const _IconChip({required this.icon, required this.bg, required this.fg});

  final IconData icon;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Icon(icon, size: 18, color: fg),
    );
  }
}

class _GhalibQuote extends StatelessWidget {
  const _GhalibQuote();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          const GoldDivider(muted: true, width: 140, ornament: null),
          const SizedBox(height: 14),
          Text(
            'ہزاروں خواہشیں ایسی کہ ہر خواہش پہ دم نکلے',
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: SukhanText.nastaleeq(
              size: 16,
              color: AppColors.primary,
              height: 2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '— Mirza Ghalib',
            style: SukhanText.italic(
              size: 11,
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
