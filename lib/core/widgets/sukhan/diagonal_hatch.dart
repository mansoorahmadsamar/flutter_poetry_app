import 'package:flutter/material.dart';
import '../../design_system/app_colors.dart';

/// Subtle diagonal hatch overlay used on hero cards (CreatorHero,
/// BecomePoetCard celebratory variant). Mimics the CSS
/// `repeating-linear-gradient(45deg, transparent 0-7px, gold@22% 7-8px)`.
class DiagonalHatchOverlay extends StatelessWidget {
  const DiagonalHatchOverlay({
    super.key,
    this.color,
    this.opacity = 0.18,
    this.spacing = 8,
    this.lineWidth = 1,
    this.radius = BorderRadius.zero,
  });

  final Color? color;
  final double opacity;
  final double spacing;
  final double lineWidth;
  final BorderRadius radius;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ClipRRect(
        borderRadius: radius,
        child: IgnorePointer(
          child: Opacity(
            opacity: opacity,
            child: CustomPaint(
              painter: _HatchPainter(
                color: color ?? AppColors.secondary,
                spacing: spacing,
                lineWidth: lineWidth,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HatchPainter extends CustomPainter {
  _HatchPainter({required this.color, required this.spacing, required this.lineWidth});

  final Color color;
  final double spacing;
  final double lineWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke;

    final diag = size.width + size.height;
    for (var d = -size.height; d < diag; d += spacing) {
      canvas.drawLine(Offset(d, 0), Offset(d + size.height, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _HatchPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.spacing != spacing ||
      oldDelegate.lineWidth != lineWidth;
}
