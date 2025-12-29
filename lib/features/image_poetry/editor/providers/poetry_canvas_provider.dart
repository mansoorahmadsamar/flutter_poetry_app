import 'dart:io';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_poetry_app/features/image_poetry/editor/models/canvas_state_model.dart';
import 'package:flutter_poetry_app/features/image_poetry/editor/models/text_layer_model.dart';
import 'package:logger/logger.dart';

/// Provider for the Poetry Canvas Controller
final poetryCanvasProvider =
    StateNotifierProvider<PoetryCanvasController, CanvasStateModel>((ref) {
  return PoetryCanvasController();
});

/// Canvas Controller - Manages the state of the poetry canvas
class PoetryCanvasController extends StateNotifier<CanvasStateModel> {
  final Logger _logger = Logger();

  PoetryCanvasController() : super(const CanvasStateModel());

  // ====== Layer Management ======

  /// Add a new text layer
  void addTextLayer(String text, String languageCode) {
    final newLayer = TextLayerModel.create(
      text: text,
      languageCode: languageCode,
      position: _calculateNewLayerPosition(),
    );

    state = state.copyWith(
      textLayers: [...state.textLayers, newLayer],
      selectedLayerId: newLayer.id,
    );

    _logger.i('Added text layer: ${newLayer.id}');
  }

  /// Update a specific text layer
  void updateTextLayer(String id, TextLayerModel updatedLayer) {
    state = state.copyWith(
      textLayers: state.textLayers.map((layer) {
        return layer.id == id ? updatedLayer : layer;
      }).toList(),
    );

    _logger.d('Updated text layer: $id');
  }

  /// Delete a text layer
  void deleteTextLayer(String id) {
    state = state.copyWith(
      textLayers: state.textLayers.where((layer) => layer.id != id).toList(),
      selectedLayerId:
          state.selectedLayerId == id ? null : state.selectedLayerId,
    );

    _logger.i('Deleted text layer: $id');
  }

  /// Select a layer
  void selectLayer(String? id) {
    // Deselect all layers first
    state = state.copyWith(
      textLayers: state.textLayers
          .map((layer) => layer.copyWith(isSelected: layer.id == id))
          .toList(),
      selectedLayerId: id,
    );

    _logger.d('Selected layer: $id');
  }

  /// Duplicate a layer
  void duplicateLayer(String id) {
    final layerToDuplicate = state.textLayers.firstWhere(
      (layer) => layer.id == id,
      orElse: () => throw Exception('Layer not found'),
    );

    final duplicatedLayer = layerToDuplicate.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      position: Offset(
        layerToDuplicate.position.dx + 20,
        layerToDuplicate.position.dy + 20,
      ),
      isSelected: false,
    );

    state = state.copyWith(
      textLayers: [...state.textLayers, duplicatedLayer],
    );

    _logger.i('Duplicated layer: $id -> ${duplicatedLayer.id}');
  }

  /// Reorder layers (change z-index)
  void reorderLayers(int oldIndex, int newIndex) {
    final layers = List<TextLayerModel>.from(state.textLayers);
    final layer = layers.removeAt(oldIndex);
    layers.insert(newIndex, layer);

    state = state.copyWith(textLayers: layers);

    _logger.d('Reordered layer from $oldIndex to $newIndex');
  }

  // ====== Layer Transforms ======

  /// Move a layer by delta
  void moveLayer(String id, Offset delta) {
    final layer = state.textLayers.firstWhere((l) => l.id == id);
    final newPosition = layer.position + delta;

    updateTextLayer(
      id,
      layer.copyWith(position: newPosition),
    );
  }

  /// Scale a layer
  void scaleLayer(String id, double scale) {
    final layer = state.textLayers.firstWhere((l) => l.id == id);
    updateTextLayer(
      id,
      layer.copyWith(scale: scale.clamp(0.1, 5.0)), // Limit scale
    );
  }

  /// Rotate a layer
  void rotateLayer(String id, double rotation) {
    final layer = state.textLayers.firstWhere((l) => l.id == id);
    updateTextLayer(
      id,
      layer.copyWith(rotation: rotation),
    );
  }

  // ====== Layer Styling ======

  /// Update text color
  void updateTextColor(String id, Color color) {
    final layer = state.textLayers.firstWhere((l) => l.id == id);
    updateTextLayer(
      id,
      layer.copyWith(textColor: color),
    );
  }

  /// Update background color
  void updateBackgroundColor(String id, Color? color) {
    final layer = state.textLayers.firstWhere((l) => l.id == id);
    updateTextLayer(
      id,
      layer.copyWith(backgroundColor: color),
    );
  }

  /// Update stroke (outline)
  void updateStroke(String id, Color? color, double? width) {
    final layer = state.textLayers.firstWhere((l) => l.id == id);
    updateTextLayer(
      id,
      layer.copyWith(
        strokeColor: color,
        strokeWidth: width,
      ),
    );
  }

  /// Update shadow
  void updateShadow(String id, Color? color, Offset? offset, double? blur) {
    final layer = state.textLayers.firstWhere((l) => l.id == id);
    updateTextLayer(
      id,
      layer.copyWith(
        shadowColor: color,
        shadowOffset: offset,
        shadowBlur: blur,
      ),
    );
  }

  /// Update text style (fontSize, alignment)
  void updateTextStyle(String id, {double? fontSize, TextAlign? align}) {
    final layer = state.textLayers.firstWhere((l) => l.id == id);
    updateTextLayer(
      id,
      layer.copyWith(
        fontSize: fontSize ?? layer.fontSize,
        textAlign: align ?? layer.textAlign,
      ),
    );
  }

  /// Update text content
  void updateText(String id, String newText) {
    final layer = state.textLayers.firstWhere((l) => l.id == id);
    updateTextLayer(
      id,
      layer.copyWith(text: newText),
    );
  }

  /// Update opacity
  void updateOpacity(String id, double opacity) {
    final layer = state.textLayers.firstWhere((l) => l.id == id);
    updateTextLayer(
      id,
      layer.copyWith(opacity: opacity.clamp(0.0, 1.0)),
    );
  }

  // ====== Background Management ======

  /// Set background from file
  Future<void> setBackgroundFromFile(File file) async {
    state = state.copyWith(backgroundImagePath: file.path);
    _logger.i('Set background from file: ${file.path}');
  }

  /// Set background from URL
  Future<void> setBackgroundFromUrl(String url) async {
    state = state.copyWith(backgroundImagePath: url);
    _logger.i('Set background from URL: $url');
  }

  /// Clear background
  void clearBackground() {
    state = state.copyWith(backgroundImagePath: null);
    _logger.i('Cleared background');
  }

  // ====== Canvas Operations ======

  /// Reset the entire canvas
  void resetCanvas() {
    state = const CanvasStateModel();
    _logger.i('Reset canvas');
  }

  /// Load initial layers (for couplet flow)
  void loadInitialLayers(List<TextLayerModel> layers) {
    state = state.copyWith(textLayers: layers);
    _logger.i('Loaded ${layers.length} initial layers');
  }

  // ====== Helper Methods ======

  /// Calculate position for new layer (avoid overlap)
  Offset _calculateNewLayerPosition() {
    if (state.textLayers.isEmpty) {
      return const Offset(100, 200);
    }

    // Place new layer slightly below and to the right of the last layer
    final lastLayer = state.textLayers.last;
    return Offset(
      lastLayer.position.dx + 20,
      lastLayer.position.dy + 60,
    );
  }
}
