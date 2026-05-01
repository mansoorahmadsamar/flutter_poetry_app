import 'package:flutter/material.dart';
import '../../design_system/app_colors.dart';

/// Wraps a child with four L-shaped gold corner ornaments. Used in
/// manuscript-style cards (become-poet manuscript variant, public-page
/// featured verse, books empty state).
class CornerFrame extends StatelessWidget {
  const CornerFrame({
    super.key,
    required this.child,
    this.color,
    this.inset = 10,
    this.length = 14,
    this.thickness = 1,
    this.padding,
    this.decoration,
  });

  final Widget child;
  final Color? color;
  final double inset;
  final double length;
  final double thickness;
  final EdgeInsets? padding;
  final BoxDecoration? decoration;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.secondary;
    return Container(
      decoration: decoration,
      padding: padding,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          child,
          Positioned(
            top: inset,
            left: inset,
            child: _Corner(color: c, length: length, thickness: thickness, anchor: _Anchor.topLeft),
          ),
          Positioned(
            top: inset,
            right: inset,
            child: _Corner(color: c, length: length, thickness: thickness, anchor: _Anchor.topRight),
          ),
          Positioned(
            bottom: inset,
            left: inset,
            child: _Corner(color: c, length: length, thickness: thickness, anchor: _Anchor.bottomLeft),
          ),
          Positioned(
            bottom: inset,
            right: inset,
            child: _Corner(color: c, length: length, thickness: thickness, anchor: _Anchor.bottomRight),
          ),
        ],
      ),
    );
  }
}

enum _Anchor { topLeft, topRight, bottomLeft, bottomRight }

class _Corner extends StatelessWidget {
  const _Corner({
    required this.color,
    required this.length,
    required this.thickness,
    required this.anchor,
  });

  final Color color;
  final double length;
  final double thickness;
  final _Anchor anchor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(length, length),
      painter: _CornerPainter(color: color, thickness: thickness, anchor: anchor),
    );
  }
}

class _CornerPainter extends CustomPainter {
  _CornerPainter({required this.color, required this.thickness, required this.anchor});

  final Color color;
  final double thickness;
  final _Anchor anchor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke;

    switch (anchor) {
      case _Anchor.topLeft:
        canvas.drawLine(Offset.zero, Offset(size.width, 0), paint);
        canvas.drawLine(Offset.zero, Offset(0, size.height), paint);
        break;
      case _Anchor.topRight:
        canvas.drawLine(Offset(0, 0), Offset(size.width, 0), paint);
        canvas.drawLine(Offset(size.width, 0), Offset(size.width, size.height), paint);
        break;
      case _Anchor.bottomLeft:
        canvas.drawLine(Offset(0, 0), Offset(0, size.height), paint);
        canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), paint);
        break;
      case _Anchor.bottomRight:
        canvas.drawLine(Offset(size.width, 0), Offset(size.width, size.height), paint);
        canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), paint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _CornerPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.thickness != thickness ||
      oldDelegate.anchor != anchor;
}
