import 'package:flutter/material.dart';
import '../../design_system/app_colors.dart';
import '../../design_system/app_typography.dart';

enum SukhanChipVariant { green, gold, outline, ghost, defaultV }

/// Pill chip with the four variants used across poet-mode screens.
/// - green: filled green-soft background, dark green text — featured tags
/// - gold: filled gold-soft background, dark gold text — type/era markers
/// - outline: transparent with green border — sort/filter
/// - ghost: subtle gray-tinted, low-emphasis — meta tags
class SukhanChip extends StatelessWidget {
  const SukhanChip({
    super.key,
    required this.label,
    this.variant = SukhanChipVariant.defaultV,
    this.icon,
    this.fontSize = 11,
    this.textDirection,
    this.onTap,
    this.fontFamily,
  });

  final String label;
  final SukhanChipVariant variant;
  final IconData? icon;
  final double fontSize;
  final TextDirection? textDirection;
  final VoidCallback? onTap;
  final String? fontFamily;

  @override
  Widget build(BuildContext context) {
    final colors = _colorsFor(variant);
    final body = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors.bg,
        border: colors.border == null ? null : Border.all(color: colors.border!),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 1, color: colors.fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            textDirection: textDirection,
            style: fontFamily == AppTypography.urduFontFamily
                ? SukhanText.nastaleeq(size: fontSize + 1, color: colors.fg)
                : SukhanText.sans(
                    size: fontSize,
                    color: colors.fg,
                    weight: FontWeight.w500,
                  ),
          ),
        ],
      ),
    );

    if (onTap == null) return body;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: body,
    );
  }

  _ChipColors _colorsFor(SukhanChipVariant v) {
    switch (v) {
      case SukhanChipVariant.green:
        return const _ChipColors(bg: AppColors.greenSoft, fg: AppColors.primary);
      case SukhanChipVariant.gold:
        return const _ChipColors(bg: AppColors.goldSoft, fg: AppColors.secondaryDark);
      case SukhanChipVariant.outline:
        return _ChipColors(
          bg: Colors.transparent,
          fg: AppColors.primary,
          border: AppColors.primary.withValues(alpha: 0.4),
        );
      case SukhanChipVariant.ghost:
        return _ChipColors(
          bg: AppColors.dividerLight.withValues(alpha: 0.5),
          fg: AppColors.textSecondaryLight,
        );
      case SukhanChipVariant.defaultV:
        return const _ChipColors(bg: AppColors.paperSurface, fg: AppColors.textPrimaryLight);
    }
  }
}

class _ChipColors {
  const _ChipColors({required this.bg, required this.fg, this.border});
  final Color bg;
  final Color fg;
  final Color? border;
}
