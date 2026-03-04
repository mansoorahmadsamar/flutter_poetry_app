import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_poetry_app/features/image_poetry/editor/models/canvas_state_model.dart';
import 'package:flutter_poetry_app/features/image_poetry/editor/painters/poetry_canvas_painter.dart';
import 'package:flutter_poetry_app/features/image_poetry/editor/providers/poetry_canvas_provider.dart';

class InteractivePoetryCanvas extends ConsumerStatefulWidget {
  final GlobalKey canvasKey;

  const InteractivePoetryCanvas({
    super.key,
    required this.canvasKey,
  });

  @override
  ConsumerState<InteractivePoetryCanvas> createState() =>
      _InteractivePoetryCanvasState();
}

class _InteractivePoetryCanvasState
    extends ConsumerState<InteractivePoetryCanvas> {
  ui.Image? _backgroundImage;
  Offset? _lastFocalPoint;
  double _initialScale = 1.0;
  double _initialRotation = 0.0;

  @override
  Widget build(BuildContext context) {
    final canvasState = ref.watch(poetryCanvasProvider);

    // Load background image if path changed
    if (canvasState.backgroundImagePath != null &&
        _backgroundImage == null) {
      _loadBackgroundImage(canvasState.backgroundImagePath!);
    } else if (canvasState.backgroundImagePath == null) {
      _backgroundImage = null;
    }

    return GestureDetector(
      onTapDown: (details) => _handleTapDown(details, canvasState),
      onScaleStart: (details) => _handleScaleStart(details, canvasState),
      onScaleUpdate: (details) => _handleScaleUpdate(details, canvasState),
      onScaleEnd: _handleScaleEnd,
      child: Container(
        color: Colors.grey[200],
        child: Center(
          child: RepaintBoundary(
            key: widget.canvasKey,
            child: Container(
              width: 360,
              height: 640,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey[300]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: CustomPaint(
                painter: PoetryCanvasPainter(
                  backgroundImage: _backgroundImage,
                  textLayers: canvasState.textLayers,
                  selectedLayerId: canvasState.selectedLayerId,
                ),
                size: const Size(360, 640),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ====== Gesture Handlers ======

  void _handleTapDown(TapDownDetails details, CanvasStateModel canvasState) {
    // Find if user tapped on a text layer
    final tapPosition = details.localPosition;

    // Adjust tap position to canvas coordinates
    final canvasOffset = Offset(
      (MediaQuery.of(context).size.width - 360) / 2,
      (MediaQuery.of(context).size.height - 640) / 2,
    );

    final adjustedTap = tapPosition - canvasOffset;

    // Check each layer (reverse order - top to bottom)
    bool layerTapped = false;
    for (final layer in canvasState.textLayers.reversed) {
      // Simple hit test - check if tap is within layer bounds
      final layerRect = Rect.fromLTWH(
        layer.position.dx,
        layer.position.dy,
        200 * layer.scale, // Approximate width
        100 * layer.scale, // Approximate height
      );

      if (layerRect.contains(adjustedTap)) {
        ref.read(poetryCanvasProvider.notifier).selectLayer(layer.id);
        layerTapped = true;
        break;
      }
    }

    // If no layer tapped, deselect all
    if (!layerTapped) {
      ref.read(poetryCanvasProvider.notifier).selectLayer(null);
    }
  }

  void _handleScaleStart(ScaleStartDetails details, CanvasStateModel canvasState) {
    if (canvasState.selectedLayerId == null) return;

    // Store initial focal point for dragging
    _lastFocalPoint = details.focalPoint;

    final selectedLayer = canvasState.textLayers.firstWhere(
      (l) => l.id == canvasState.selectedLayerId,
    );

    _initialScale = selectedLayer.scale;
    _initialRotation = selectedLayer.rotation;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details, CanvasStateModel canvasState) {
    if (canvasState.selectedLayerId == null) return;

    if (details.pointerCount == 1) {
      // Single-finger gesture: drag/move
      final delta = details.focalPoint - (_lastFocalPoint ?? details.focalPoint);
      _lastFocalPoint = details.focalPoint;

      ref.read(poetryCanvasProvider.notifier).moveLayer(
            canvasState.selectedLayerId!,
            delta,
          );
    } else if (details.pointerCount == 2) {
      // Two-finger gesture: scale and rotate
      // Scale
      final newScale = _initialScale * details.scale;
      ref.read(poetryCanvasProvider.notifier).scaleLayer(
            canvasState.selectedLayerId!,
            newScale,
          );

      // Rotate
      final newRotation = _initialRotation + details.rotation;
      ref.read(poetryCanvasProvider.notifier).rotateLayer(
            canvasState.selectedLayerId!,
            newRotation,
          );
    }
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    // Reset initial values
    _lastFocalPoint = null;
    _initialScale = 1.0;
    _initialRotation = 0.0;
  }

  // ====== Background Image Loading ======

  Future<void> _loadBackgroundImage(String path) async {
    try {
      late ImageProvider imageProvider;

      if (path.startsWith('http')) {
        // Network image
        imageProvider = NetworkImage(path);
      } else {
        // Local file
        imageProvider = FileImage(File(path));
      }

      final ImageStream stream = imageProvider.resolve(ImageConfiguration.empty);

      stream.addListener(
        ImageStreamListener((ImageInfo info, bool _) {
          if (mounted) {
            setState(() {
              _backgroundImage = info.image;
            });
          }
        }),
      );
    } catch (e) {
      debugPrint('Error loading background image: $e');
    }
  }

  @override
  void dispose() {
    _backgroundImage?.dispose();
    super.dispose();
  }
}
