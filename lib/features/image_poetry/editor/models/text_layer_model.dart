import 'dart:ui';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'text_layer_model.freezed.dart';
part 'text_layer_model.g.dart';

@freezed
class TextLayerModel with _$TextLayerModel {
  const factory TextLayerModel({
    required String id, // Unique identifier
    required String text, // Urdu/English text content
    required String languageCode, // 'ur' or 'en'
    @OffsetConverter() required Offset position, // X, Y coordinates
    required double fontSize, // Text size
    @ColorConverter() required Color textColor, // Text color
    @ColorConverter() Color? backgroundColor, // Optional highlight
    @ColorConverter() Color? strokeColor, // Optional outline
    double? strokeWidth, // Outline width
    @ColorConverter() Color? shadowColor, // Optional shadow
    @OffsetConverter() Offset? shadowOffset, // Shadow offset
    double? shadowBlur, // Shadow blur radius
    @TextAlignConverter() required TextAlign textAlign, // left, center, right
    required double rotation, // Rotation in radians
    required double scale, // Scale factor
    @Default(1.0) double opacity, // 0.0 to 1.0
    @Default(1.8) double lineHeight, // For Urdu: 1.8-2.2
    @Default(false) bool isSelected, // Selection state
  }) = _TextLayerModel;

  factory TextLayerModel.fromJson(Map<String, dynamic> json) =>
      _$TextLayerModelFromJson(json);

  // Factory method to create a default text layer
  factory TextLayerModel.create({
    required String text,
    required String languageCode,
    Offset? position,
    double? fontSize,
    Color? textColor,
  }) {
    return TextLayerModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      languageCode: languageCode,
      position: position ?? const Offset(100, 200),
      fontSize: fontSize ?? (languageCode == 'ur' ? 32 : 24),
      textColor: textColor ?? const Color(0xFF000000),
      textAlign: languageCode == 'ur' ? TextAlign.right : TextAlign.left,
      rotation: 0.0,
      scale: 1.0,
      lineHeight: languageCode == 'ur' ? 2.0 : 1.2,
    );
  }
}

// Custom JSON converters for Offset and Color
class OffsetConverter implements JsonConverter<Offset, Map<String, dynamic>> {
  const OffsetConverter();

  @override
  Offset fromJson(Map<String, dynamic> json) {
    return Offset(
      (json['dx'] as num).toDouble(),
      (json['dy'] as num).toDouble(),
    );
  }

  @override
  Map<String, dynamic> toJson(Offset offset) {
    return {
      'dx': offset.dx,
      'dy': offset.dy,
    };
  }
}

class ColorConverter implements JsonConverter<Color, int> {
  const ColorConverter();

  @override
  Color fromJson(int json) {
    return Color(json);
  }

  @override
  int toJson(Color color) {
    return color.value;
  }
}

class TextAlignConverter implements JsonConverter<TextAlign, String> {
  const TextAlignConverter();

  @override
  TextAlign fromJson(String json) {
    switch (json) {
      case 'left':
        return TextAlign.left;
      case 'center':
        return TextAlign.center;
      case 'right':
        return TextAlign.right;
      case 'justify':
        return TextAlign.justify;
      default:
        return TextAlign.left;
    }
  }

  @override
  String toJson(TextAlign textAlign) {
    switch (textAlign) {
      case TextAlign.left:
        return 'left';
      case TextAlign.center:
        return 'center';
      case TextAlign.right:
        return 'right';
      case TextAlign.justify:
        return 'justify';
      default:
        return 'left';
    }
  }
}
