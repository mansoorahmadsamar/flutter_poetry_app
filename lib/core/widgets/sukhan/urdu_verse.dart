import 'package:flutter/material.dart';
import '../../design_system/app_colors.dart';
import '../../design_system/app_typography.dart';

/// RTL-locked verse block with Nastaleeq font, configurable size and line
/// height. Each child is rendered as its own line; pass empty SizedBoxes
/// to create gaps between couplets.
class UrduVerse extends StatelessWidget {
  const UrduVerse({
    super.key,
    required this.lines,
    this.size = 20,
    this.lineHeight = 2.15,
    this.color,
    this.align = TextAlign.center,
  });

  final List<Widget> lines;
  final double size;
  final double lineHeight;
  final Color? color;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DefaultTextStyle.merge(
        style: TextStyle(
          fontFamily: AppTypography.urduFontFamily,
          fontSize: size,
          height: lineHeight,
          color: color ?? AppColors.textPrimaryLight,
        ),
        textAlign: align,
        child: Column(
          crossAxisAlignment: align == TextAlign.center
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.stretch,
          children: lines,
        ),
      ),
    );
  }
}
