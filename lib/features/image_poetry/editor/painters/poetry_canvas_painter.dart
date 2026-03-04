import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_poetry_app/features/image_poetry/editor/models/text_layer_model.dart';

class PoetryCanvasPainter extends CustomPainter {
  final ui.Image? backgroundImage;
  final List<TextLayerModel> textLayers;
  final String? selectedLayerId;

  PoetryCanvasPainter({
    required this.backgroundImage,
    required this.textLayers,
    this.selectedLayerId,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw background (white or image)
    _drawBackground(canvas, size);

    // 2. Draw all text layers (bottom to top)
    for (final layer in textLayers) {
      _drawTextLayer(canvas, size, layer);
    }

    // 3. Draw selection handles for selected layer
    if (selectedLayerId != null) {
      final selectedLayer = textLayers.where((l) => l.id == selectedLayerId);
      if (selectedLayer.isNotEmpty) {
        _drawSelectionHandles(canvas, size, selectedLayer.first);
      }
    }
  }

  void _drawBackground(Canvas canvas, Size size) {
    if (backgroundImage != null) {
      // Draw background image (cover entire canvas)
      final srcRect = Offset.zero & Size(
        backgroundImage!.width.toDouble(),
        backgroundImage!.height.toDouble(),
      );
      final dstRect = Offset.zero & size;

      canvas.drawImageRect(
        backgroundImage!,
        srcRect,
        dstRect,
        Paint()..filterQuality = FilterQuality.high,
      );
    } else {
      // Draw white background
      canvas.drawRect(
        Offset.zero & size,
        Paint()..color = Colors.white,
      );
    }
  }

  void _drawTextLayer(Canvas canvas, Size size, TextLayerModel layer) {
    canvas.save();

    // Apply transformations
    canvas.translate(layer.position.dx, layer.position.dy);
    canvas.rotate(layer.rotation);
    canvas.scale(layer.scale);

    // Create text painter
    final textStyle = TextStyle(
      fontFamily: layer.languageCode == 'ur' ? 'Jameel Noori Nastaleeq' : null,
      fontSize: layer.fontSize,
      color: layer.textColor.withOpacity(layer.opacity),
      height: layer.lineHeight,
      backgroundColor: layer.backgroundColor,
      shadows: layer.shadowColor != null
          ? [
              Shadow(
                color: layer.shadowColor!,
                offset: layer.shadowOffset ?? const Offset(2, 2),
                blurRadius: layer.shadowBlur ?? 4.0,
              ),
            ]
          : null,
    );

    final textSpan = TextSpan(text: layer.text, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: layer.languageCode == 'ur' ? TextDirection.rtl : TextDirection.ltr,
      textAlign: layer.textAlign,
    );

    textPainter.layout(maxWidth: size.width * 0.9);

    // Draw background highlight if specified
    if (layer.backgroundColor != null) {
      final bgRect = Offset.zero & Size(textPainter.width + 16, textPainter.height + 8);
      canvas.drawRRect(
        RRect.fromRectAndRadius(bgRect, const Radius.circular(4)),
        Paint()..color = layer.backgroundColor!.withOpacity(layer.opacity * 0.8),
      );
    }

    // Draw stroke (outline) if specified
    if (layer.strokeColor != null && layer.strokeWidth != null) {
      final strokeTextStyle = textStyle.copyWith(
        foreground: Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = layer.strokeWidth!
          ..color = layer.strokeColor!.withOpacity(layer.opacity),
      );

      final strokeTextSpan = TextSpan(text: layer.text, style: strokeTextStyle);
      final strokeTextPainter = TextPainter(
        text: strokeTextSpan,
        textDirection: layer.languageCode == 'ur' ? TextDirection.rtl : TextDirection.ltr,
        textAlign: layer.textAlign,
      );

      strokeTextPainter.layout(maxWidth: size.width * 0.9);
      strokeTextPainter.paint(canvas, const Offset(8, 4));
    }

    // Draw text
    textPainter.paint(canvas, const Offset(8, 4));

    canvas.restore();
  }

  void _drawSelectionHandles(Canvas canvas, Size size, TextLayerModel layer) {
    canvas.save();

    // Apply transformations to match text position
    canvas.translate(layer.position.dx, layer.position.dy);
    canvas.rotate(layer.rotation);
    canvas.scale(layer.scale);

    // Calculate text bounds
    final textStyle = TextStyle(
      fontFamily: layer.languageCode == 'ur' ? 'Jameel Noori Nastaleeq' : null,
      fontSize: layer.fontSize,
      height: layer.lineHeight,
    );

    final textSpan = TextSpan(text: layer.text, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: layer.languageCode == 'ur' ? TextDirection.rtl : TextDirection.ltr,
      textAlign: layer.textAlign,
    );

    textPainter.layout(maxWidth: size.width * 0.9);

    // Draw selection border
    final selectionRect = Offset.zero & Size(
      textPainter.width + 16,
      textPainter.height + 8,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(selectionRect, const Radius.circular(4)),
      Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    // Draw corner handles
    final handleSize = 12.0;
    final handlePaint = Paint()..color = Colors.blue;

    // Top-left handle
    canvas.drawCircle(
      selectionRect.topLeft,
      handleSize / 2,
      handlePaint,
    );

    // Top-right handle
    canvas.drawCircle(
      selectionRect.topRight,
      handleSize / 2,
      handlePaint,
    );

    // Bottom-left handle
    canvas.drawCircle(
      selectionRect.bottomLeft,
      handleSize / 2,
      handlePaint,
    );

    // Bottom-right handle (scale handle)
    canvas.drawCircle(
      selectionRect.bottomRight,
      handleSize / 2,
      Paint()..color = Colors.green, // Different color for scale handle
    );

    // Rotation handle (above center)
    final rotationHandleOffset = Offset(
      selectionRect.width / 2,
      -20,
    );
    canvas.drawCircle(
      rotationHandleOffset,
      handleSize / 2,
      Paint()..color = Colors.orange,
    );

    // Draw line from center to rotation handle
    canvas.drawLine(
      Offset(selectionRect.width / 2, 0),
      rotationHandleOffset,
      Paint()
        ..color = Colors.orange
        ..strokeWidth = 1.0,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(PoetryCanvasPainter oldDelegate) {
    return oldDelegate.backgroundImage != backgroundImage ||
        oldDelegate.textLayers != textLayers ||
        oldDelegate.selectedLayerId != selectedLayerId;
  }
}
