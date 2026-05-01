import 'package:flutter/material.dart';
import '../../design_system/app_colors.dart';
import '../../design_system/app_typography.dart';

/// Thin horizontal gold rule with optional center ornament (default ۞).
/// Used as a section break between hero and stats, between quote and CTA, etc.
class GoldDivider extends StatelessWidget {
  const GoldDivider({
    super.key,
    this.ornament = '۞',
    this.width,
    this.color,
    this.muted = false,
  });

  final String? ornament;
  final double? width;
  final Color? color;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final lineColor = (color ?? AppColors.secondary).withValues(alpha: muted ? 0.5 : 1);
    final ornamentColor = (color ?? AppColors.secondary).withValues(alpha: muted ? 0.7 : 1);
    final line = Expanded(
      child: Container(
        height: 1,
        color: lineColor,
      ),
    );

    return SizedBox(
      width: width,
      child: Row(
        mainAxisSize: width == null ? MainAxisSize.max : MainAxisSize.max,
        children: [
          line,
          if (ornament != null && ornament!.isNotEmpty) ...[
            const SizedBox(width: 8),
            Text(
              ornament!,
              style: TextStyle(
                fontFamily: AppTypography.urduFontFamily,
                fontSize: 12,
                color: ornamentColor,
                height: 1,
              ),
            ),
            const SizedBox(width: 8),
          ],
          line,
        ],
      ),
    );
  }
}
