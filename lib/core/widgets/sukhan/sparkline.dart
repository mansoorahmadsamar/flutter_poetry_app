import 'package:flutter/material.dart';
import '../../design_system/app_colors.dart';

/// Tiny line chart for the analytics tab. Draws a polyline through the
/// passed [data] with an end-point dot.
class Sparkline extends StatelessWidget {
  const Sparkline({
    super.key,
    required this.data,
    this.color,
    this.width = 80,
    this.height = 22,
    this.strokeWidth = 1.5,
  });

  final List<double> data;
  final Color? color;
  final double width;
  final double height;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _SparklinePainter(
        data: data,
        color: color ?? AppColors.primary,
        strokeWidth: strokeWidth,
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({
    required this.data,
    required this.color,
    required this.strokeWidth,
  });

  final List<double> data;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;
    final maxV = data.reduce((a, b) => a > b ? a : b);
    final minV = data.reduce((a, b) => a < b ? a : b);
    final range = (maxV - minV).abs() < 1e-9 ? 1.0 : maxV - minV;

    final w = size.width;
    final h = size.height;
    final path = Path();
    Offset? last;
    for (var i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * w;
      final y = h - ((data[i] - minV) / range) * (h - 4) - 2;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      last = Offset(x, y);
    }

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, stroke);

    if (last != null) {
      final dot = Paint()..color = color;
      canvas.drawCircle(last, 2, dot);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) =>
      oldDelegate.data != data || oldDelegate.color != color;
}
