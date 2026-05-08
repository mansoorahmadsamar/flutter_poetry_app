import 'package:flutter/material.dart';
import '../../design_system/app_colors.dart';
import '../../design_system/app_typography.dart';

enum VerifiedMarkVariant { glyph, chip, both }

/// Custom Sukhan "verified poet" mark — a gold disc with the ۞ ornament.
/// Three variants per the design: glyph-only, chip with "VERIFIED" label,
/// or glyph paired with the Urdu label تصدیق شدہ شاعر.
class VerifiedMark extends StatelessWidget {
  const VerifiedMark({
    super.key,
    this.variant = VerifiedMarkVariant.glyph,
    this.size = 18,
  });

  final VerifiedMarkVariant variant;
  final double size;

  @override
  Widget build(BuildContext context) {
    final glyph = _Glyph(size: size);

    switch (variant) {
      case VerifiedMarkVariant.glyph:
        return glyph;
      case VerifiedMarkVariant.chip:
        return Container(
          padding: const EdgeInsets.fromLTRB(4, 2, 8, 2),
          decoration: BoxDecoration(
            color: AppColors.goldSoft,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.secondary),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 14,
                height: 14,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '۞',
                  style: TextStyle(
                    fontFamily: AppTypography.urduFontFamily,
                    fontSize: 9,
                    color: AppColors.backgroundLight,
                    height: 1,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Text(
                'VERIFIED',
                style: SukhanText.eyebrow(
                  size: 10,
                  color: AppColors.secondaryDark,
                  weight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      case VerifiedMarkVariant.both:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            glyph,
            const SizedBox(width: 6),
            Text(
              'تصدیق شدہ شاعر',
              textDirection: TextDirection.rtl,
              style: SukhanText.nastaleeq(
                size: 12,
                color: AppColors.secondaryDark,
              ),
            ),
          ],
        );
    }
  }
}

class _Glyph extends StatelessWidget {
  const _Glyph({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.secondary, AppColors.secondaryDark],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.backgroundLight,
            blurRadius: 0,
            spreadRadius: 1.5,
          ),
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 1),
            blurRadius: 0,
            spreadRadius: 2.5,
          ),
        ],
      ),
      child: Text(
        '۞',
        style: TextStyle(
          fontFamily: AppTypography.urduFontFamily,
          fontSize: size * 0.62,
          color: AppColors.backgroundLight,
          height: 1,
        ),
      ),
    );
  }
}
