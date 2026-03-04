import 'dart:ui';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_poetry_app/features/image_poetry/editor/models/text_layer_model.dart';

// Export converters from text_layer_model
export 'text_layer_model.dart' show OffsetConverter;

part 'canvas_state_model.freezed.dart';
part 'canvas_state_model.g.dart';

@freezed
class CanvasStateModel with _$CanvasStateModel {
  const factory CanvasStateModel({
    String? backgroundImagePath, // Local file path or URL
    @Default([]) List<TextLayerModel> textLayers, // All text layers
    String? selectedLayerId, // Currently selected layer
    @Default(1.0) double canvasScale, // Zoom level
    @OffsetConverter() @Default(Offset.zero) Offset canvasOffset, // Pan offset
    @SizeConverter() @Default(Size(1080, 1920)) Size canvasSize, // Export dimensions (portrait)
  }) = _CanvasStateModel;

  factory CanvasStateModel.fromJson(Map<String, dynamic> json) =>
      _$CanvasStateModelFromJson(json);
}

// Custom JSON converter for Size
class SizeConverter implements JsonConverter<Size, Map<String, dynamic>> {
  const SizeConverter();

  @override
  Size fromJson(Map<String, dynamic> json) {
    return Size(
      (json['width'] as num).toDouble(),
      (json['height'] as num).toDouble(),
    );
  }

  @override
  Map<String, dynamic> toJson(Size size) {
    return {
      'width': size.width,
      'height': size.height,
    };
  }
}
