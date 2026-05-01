import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/design_system/app_typography.dart';
import 'package:flutter_poetry_app/core/widgets/sukhan/corner_frame.dart';
import 'package:flutter_poetry_app/core/widgets/sukhan/diagonal_hatch.dart';
import 'package:flutter_poetry_app/core/widgets/sukhan/gold_divider.dart';

enum BecomePoetCardVariant { celebratory, quiet, manuscript }

/// "Are you a poet?" prompt shown on the profile tab when the user
/// has no `ownedPoet`. Three variants in the design — default to
/// celebratory (gold-on-green hero with hatch + ۞ ornament).
class BecomePoetCard extends StatelessWidget {
  const BecomePoetCard({
    super.key,
    this.variant = BecomePoetCardVariant.celebratory,
    this.margin = const EdgeInsets.symmetric(horizontal: 16),
  });

  final BecomePoetCardVariant variant;
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case BecomePoetCardVariant.celebratory:
        return _Celebratory(margin: margin);
      case BecomePoetCardVariant.quiet:
        return _Quiet(margin: margin);
      case BecomePoetCardVariant.manuscript:
        return _Manuscript(margin: margin);
    }
  }
}

class _Celebratory extends StatelessWidget {
  const _Celebratory({required this.margin});
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => context.push('/main/become-poet'),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [0.0, 0.6, 1.0],
                    colors: [
                      AppColors.primaryDark,
                      AppColors.primary,
                      AppColors.primaryLight,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryDark.withValues(alpha: 0.18),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                child: const _CelebratoryBody(),
              ),
              DiagonalHatchOverlay(
                color: AppColors.secondary.withValues(alpha: 0.22),
                opacity: 0.22,
                radius: BorderRadius.circular(18),
              ),
              Positioned(
                top: 12,
                right: 14,
                child: Text(
                  '۞',
                  style: TextStyle(
                    fontFamily: AppTypography.urduFontFamily,
                    fontSize: 26,
                    height: 1,
                    color: AppColors.secondaryLight.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CelebratoryBody extends StatelessWidget {
  const _CelebratoryBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'FOR POETS',
          style: SukhanText.eyebrow(
            color: AppColors.secondaryLight,
            size: 9,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Claim your voice',
          style: SukhanText.display(
            size: 24,
            color: AppColors.backgroundLight,
            weight: FontWeight.w500,
            letterSpacing: -0.24,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'اپنی آواز کو پہچان دیں',
          textDirection: TextDirection.rtl,
          style: SukhanText.nastaleeq(
            size: 16,
            color: AppColors.secondaryLight,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Become a poet on Sukhan — share your verse, manage your diwan, see who reads you.',
          style: SukhanText.italic(
            size: 13,
            color: AppColors.backgroundLight.withValues(alpha: 0.82),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () => GoRouter.of(context).push('/main/become-poet'),
              icon: const Icon(Icons.edit_note, size: 16),
              label: const Text('Become a poet'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: AppColors.backgroundLight,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
                textStyle: SukhanText.sans(
                  size: 13,
                  weight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                'or claim existing',
                style: SukhanText.italic(
                  size: 12,
                  color: AppColors.secondaryLight,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Quiet extends StatelessWidget {
  const _Quiet({required this.margin});
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => context.push('/main/become-poet'),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.dividerLight),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.greenSoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.edit_note,
                      size: 18, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Are you a poet?',
                              style: SukhanText.display(
                                size: 14,
                                color: AppColors.textPrimaryLight,
                                weight: FontWeight.w600,
                                height: 1.2,
                              )),
                          const SizedBox(width: 4),
                          Text(
                            'کیا آپ شاعر ہیں؟',
                            textDirection: TextDirection.rtl,
                            style: SukhanText.nastaleeq(
                              size: 13,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Claim your page or start a new one.',
                        style: SukhanText.italic(
                          size: 12,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Text('›',
                    style: SukhanText.sans(
                        size: 18,
                        weight: FontWeight.w400,
                        color: AppColors.secondary)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Manuscript extends StatelessWidget {
  const _Manuscript({required this.margin});
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => context.push('/main/become-poet'),
          child: CornerFrame(
            inset: 12,
            length: 18,
            color: AppColors.secondary,
            decoration: BoxDecoration(
              color: AppColors.paperSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.secondary),
            ),
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    '"Verse is not written; it is overheard from the heart."',
                    style: SukhanText.italic(
                      size: 13,
                      color: AppColors.primary,
                      height: 1.55,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 12),
                const GoldDivider(muted: true, width: 120, ornament: null),
                const SizedBox(height: 12),
                Text(
                  'Become a poet on Sukhan',
                  style: SukhanText.display(
                    size: 19,
                    color: AppColors.textPrimaryLight,
                    weight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'سخن کے جہاں میں قدم رکھیں',
                  textDirection: TextDirection.rtl,
                  style: SukhanText.nastaleeq(
                    size: 14,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: () => context.push('/main/become-poet'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.backgroundLight,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                    shape: const StadiumBorder(),
                    elevation: 0,
                    textStyle: SukhanText.sans(
                      size: 12,
                      weight: FontWeight.w600,
                      letterSpacing: 0.4,
                    ),
                  ),
                  child: const Text('BEGIN'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
