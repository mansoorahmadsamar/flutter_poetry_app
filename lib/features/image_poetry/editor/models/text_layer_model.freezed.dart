// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'text_layer_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TextLayerModel _$TextLayerModelFromJson(Map<String, dynamic> json) {
  return _TextLayerModel.fromJson(json);
}

/// @nodoc
mixin _$TextLayerModel {
  String get id => throw _privateConstructorUsedError; // Unique identifier
  String get text =>
      throw _privateConstructorUsedError; // Urdu/English text content
  String get languageCode => throw _privateConstructorUsedError; // 'ur' or 'en'
  @OffsetConverter()
  Offset get position => throw _privateConstructorUsedError; // X, Y coordinates
  double get fontSize => throw _privateConstructorUsedError; // Text size
  @ColorConverter()
  Color get textColor => throw _privateConstructorUsedError; // Text color
  @ColorConverter()
  Color? get backgroundColor =>
      throw _privateConstructorUsedError; // Optional highlight
  @ColorConverter()
  Color? get strokeColor =>
      throw _privateConstructorUsedError; // Optional outline
  double? get strokeWidth =>
      throw _privateConstructorUsedError; // Outline width
  @ColorConverter()
  Color? get shadowColor =>
      throw _privateConstructorUsedError; // Optional shadow
  @OffsetConverter()
  Offset? get shadowOffset =>
      throw _privateConstructorUsedError; // Shadow offset
  double? get shadowBlur =>
      throw _privateConstructorUsedError; // Shadow blur radius
  @TextAlignConverter()
  TextAlign get textAlign =>
      throw _privateConstructorUsedError; // left, center, right
  double get rotation =>
      throw _privateConstructorUsedError; // Rotation in radians
  double get scale => throw _privateConstructorUsedError; // Scale factor
  double get opacity => throw _privateConstructorUsedError; // 0.0 to 1.0
  double get lineHeight =>
      throw _privateConstructorUsedError; // For Urdu: 1.8-2.2
  bool get isSelected => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TextLayerModelCopyWith<TextLayerModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TextLayerModelCopyWith<$Res> {
  factory $TextLayerModelCopyWith(
          TextLayerModel value, $Res Function(TextLayerModel) then) =
      _$TextLayerModelCopyWithImpl<$Res, TextLayerModel>;
  @useResult
  $Res call(
      {String id,
      String text,
      String languageCode,
      @OffsetConverter() Offset position,
      double fontSize,
      @ColorConverter() Color textColor,
      @ColorConverter() Color? backgroundColor,
      @ColorConverter() Color? strokeColor,
      double? strokeWidth,
      @ColorConverter() Color? shadowColor,
      @OffsetConverter() Offset? shadowOffset,
      double? shadowBlur,
      @TextAlignConverter() TextAlign textAlign,
      double rotation,
      double scale,
      double opacity,
      double lineHeight,
      bool isSelected});
}

/// @nodoc
class _$TextLayerModelCopyWithImpl<$Res, $Val extends TextLayerModel>
    implements $TextLayerModelCopyWith<$Res> {
  _$TextLayerModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? text = null,
    Object? languageCode = null,
    Object? position = null,
    Object? fontSize = null,
    Object? textColor = null,
    Object? backgroundColor = freezed,
    Object? strokeColor = freezed,
    Object? strokeWidth = freezed,
    Object? shadowColor = freezed,
    Object? shadowOffset = freezed,
    Object? shadowBlur = freezed,
    Object? textAlign = null,
    Object? rotation = null,
    Object? scale = null,
    Object? opacity = null,
    Object? lineHeight = null,
    Object? isSelected = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      languageCode: null == languageCode
          ? _value.languageCode
          : languageCode // ignore: cast_nullable_to_non_nullable
              as String,
      position: null == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as Offset,
      fontSize: null == fontSize
          ? _value.fontSize
          : fontSize // ignore: cast_nullable_to_non_nullable
              as double,
      textColor: null == textColor
          ? _value.textColor
          : textColor // ignore: cast_nullable_to_non_nullable
              as Color,
      backgroundColor: freezed == backgroundColor
          ? _value.backgroundColor
          : backgroundColor // ignore: cast_nullable_to_non_nullable
              as Color?,
      strokeColor: freezed == strokeColor
          ? _value.strokeColor
          : strokeColor // ignore: cast_nullable_to_non_nullable
              as Color?,
      strokeWidth: freezed == strokeWidth
          ? _value.strokeWidth
          : strokeWidth // ignore: cast_nullable_to_non_nullable
              as double?,
      shadowColor: freezed == shadowColor
          ? _value.shadowColor
          : shadowColor // ignore: cast_nullable_to_non_nullable
              as Color?,
      shadowOffset: freezed == shadowOffset
          ? _value.shadowOffset
          : shadowOffset // ignore: cast_nullable_to_non_nullable
              as Offset?,
      shadowBlur: freezed == shadowBlur
          ? _value.shadowBlur
          : shadowBlur // ignore: cast_nullable_to_non_nullable
              as double?,
      textAlign: null == textAlign
          ? _value.textAlign
          : textAlign // ignore: cast_nullable_to_non_nullable
              as TextAlign,
      rotation: null == rotation
          ? _value.rotation
          : rotation // ignore: cast_nullable_to_non_nullable
              as double,
      scale: null == scale
          ? _value.scale
          : scale // ignore: cast_nullable_to_non_nullable
              as double,
      opacity: null == opacity
          ? _value.opacity
          : opacity // ignore: cast_nullable_to_non_nullable
              as double,
      lineHeight: null == lineHeight
          ? _value.lineHeight
          : lineHeight // ignore: cast_nullable_to_non_nullable
              as double,
      isSelected: null == isSelected
          ? _value.isSelected
          : isSelected // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TextLayerModelImplCopyWith<$Res>
    implements $TextLayerModelCopyWith<$Res> {
  factory _$$TextLayerModelImplCopyWith(_$TextLayerModelImpl value,
          $Res Function(_$TextLayerModelImpl) then) =
      __$$TextLayerModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String text,
      String languageCode,
      @OffsetConverter() Offset position,
      double fontSize,
      @ColorConverter() Color textColor,
      @ColorConverter() Color? backgroundColor,
      @ColorConverter() Color? strokeColor,
      double? strokeWidth,
      @ColorConverter() Color? shadowColor,
      @OffsetConverter() Offset? shadowOffset,
      double? shadowBlur,
      @TextAlignConverter() TextAlign textAlign,
      double rotation,
      double scale,
      double opacity,
      double lineHeight,
      bool isSelected});
}

/// @nodoc
class __$$TextLayerModelImplCopyWithImpl<$Res>
    extends _$TextLayerModelCopyWithImpl<$Res, _$TextLayerModelImpl>
    implements _$$TextLayerModelImplCopyWith<$Res> {
  __$$TextLayerModelImplCopyWithImpl(
      _$TextLayerModelImpl _value, $Res Function(_$TextLayerModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? text = null,
    Object? languageCode = null,
    Object? position = null,
    Object? fontSize = null,
    Object? textColor = null,
    Object? backgroundColor = freezed,
    Object? strokeColor = freezed,
    Object? strokeWidth = freezed,
    Object? shadowColor = freezed,
    Object? shadowOffset = freezed,
    Object? shadowBlur = freezed,
    Object? textAlign = null,
    Object? rotation = null,
    Object? scale = null,
    Object? opacity = null,
    Object? lineHeight = null,
    Object? isSelected = null,
  }) {
    return _then(_$TextLayerModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      languageCode: null == languageCode
          ? _value.languageCode
          : languageCode // ignore: cast_nullable_to_non_nullable
              as String,
      position: null == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as Offset,
      fontSize: null == fontSize
          ? _value.fontSize
          : fontSize // ignore: cast_nullable_to_non_nullable
              as double,
      textColor: null == textColor
          ? _value.textColor
          : textColor // ignore: cast_nullable_to_non_nullable
              as Color,
      backgroundColor: freezed == backgroundColor
          ? _value.backgroundColor
          : backgroundColor // ignore: cast_nullable_to_non_nullable
              as Color?,
      strokeColor: freezed == strokeColor
          ? _value.strokeColor
          : strokeColor // ignore: cast_nullable_to_non_nullable
              as Color?,
      strokeWidth: freezed == strokeWidth
          ? _value.strokeWidth
          : strokeWidth // ignore: cast_nullable_to_non_nullable
              as double?,
      shadowColor: freezed == shadowColor
          ? _value.shadowColor
          : shadowColor // ignore: cast_nullable_to_non_nullable
              as Color?,
      shadowOffset: freezed == shadowOffset
          ? _value.shadowOffset
          : shadowOffset // ignore: cast_nullable_to_non_nullable
              as Offset?,
      shadowBlur: freezed == shadowBlur
          ? _value.shadowBlur
          : shadowBlur // ignore: cast_nullable_to_non_nullable
              as double?,
      textAlign: null == textAlign
          ? _value.textAlign
          : textAlign // ignore: cast_nullable_to_non_nullable
              as TextAlign,
      rotation: null == rotation
          ? _value.rotation
          : rotation // ignore: cast_nullable_to_non_nullable
              as double,
      scale: null == scale
          ? _value.scale
          : scale // ignore: cast_nullable_to_non_nullable
              as double,
      opacity: null == opacity
          ? _value.opacity
          : opacity // ignore: cast_nullable_to_non_nullable
              as double,
      lineHeight: null == lineHeight
          ? _value.lineHeight
          : lineHeight // ignore: cast_nullable_to_non_nullable
              as double,
      isSelected: null == isSelected
          ? _value.isSelected
          : isSelected // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TextLayerModelImpl implements _TextLayerModel {
  const _$TextLayerModelImpl(
      {required this.id,
      required this.text,
      required this.languageCode,
      @OffsetConverter() required this.position,
      required this.fontSize,
      @ColorConverter() required this.textColor,
      @ColorConverter() this.backgroundColor,
      @ColorConverter() this.strokeColor,
      this.strokeWidth,
      @ColorConverter() this.shadowColor,
      @OffsetConverter() this.shadowOffset,
      this.shadowBlur,
      @TextAlignConverter() required this.textAlign,
      required this.rotation,
      required this.scale,
      this.opacity = 1.0,
      this.lineHeight = 1.8,
      this.isSelected = false});

  factory _$TextLayerModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TextLayerModelImplFromJson(json);

  @override
  final String id;
// Unique identifier
  @override
  final String text;
// Urdu/English text content
  @override
  final String languageCode;
// 'ur' or 'en'
  @override
  @OffsetConverter()
  final Offset position;
// X, Y coordinates
  @override
  final double fontSize;
// Text size
  @override
  @ColorConverter()
  final Color textColor;
// Text color
  @override
  @ColorConverter()
  final Color? backgroundColor;
// Optional highlight
  @override
  @ColorConverter()
  final Color? strokeColor;
// Optional outline
  @override
  final double? strokeWidth;
// Outline width
  @override
  @ColorConverter()
  final Color? shadowColor;
// Optional shadow
  @override
  @OffsetConverter()
  final Offset? shadowOffset;
// Shadow offset
  @override
  final double? shadowBlur;
// Shadow blur radius
  @override
  @TextAlignConverter()
  final TextAlign textAlign;
// left, center, right
  @override
  final double rotation;
// Rotation in radians
  @override
  final double scale;
// Scale factor
  @override
  @JsonKey()
  final double opacity;
// 0.0 to 1.0
  @override
  @JsonKey()
  final double lineHeight;
// For Urdu: 1.8-2.2
  @override
  @JsonKey()
  final bool isSelected;

  @override
  String toString() {
    return 'TextLayerModel(id: $id, text: $text, languageCode: $languageCode, position: $position, fontSize: $fontSize, textColor: $textColor, backgroundColor: $backgroundColor, strokeColor: $strokeColor, strokeWidth: $strokeWidth, shadowColor: $shadowColor, shadowOffset: $shadowOffset, shadowBlur: $shadowBlur, textAlign: $textAlign, rotation: $rotation, scale: $scale, opacity: $opacity, lineHeight: $lineHeight, isSelected: $isSelected)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TextLayerModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.languageCode, languageCode) ||
                other.languageCode == languageCode) &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.fontSize, fontSize) ||
                other.fontSize == fontSize) &&
            (identical(other.textColor, textColor) ||
                other.textColor == textColor) &&
            (identical(other.backgroundColor, backgroundColor) ||
                other.backgroundColor == backgroundColor) &&
            (identical(other.strokeColor, strokeColor) ||
                other.strokeColor == strokeColor) &&
            (identical(other.strokeWidth, strokeWidth) ||
                other.strokeWidth == strokeWidth) &&
            (identical(other.shadowColor, shadowColor) ||
                other.shadowColor == shadowColor) &&
            (identical(other.shadowOffset, shadowOffset) ||
                other.shadowOffset == shadowOffset) &&
            (identical(other.shadowBlur, shadowBlur) ||
                other.shadowBlur == shadowBlur) &&
            (identical(other.textAlign, textAlign) ||
                other.textAlign == textAlign) &&
            (identical(other.rotation, rotation) ||
                other.rotation == rotation) &&
            (identical(other.scale, scale) || other.scale == scale) &&
            (identical(other.opacity, opacity) || other.opacity == opacity) &&
            (identical(other.lineHeight, lineHeight) ||
                other.lineHeight == lineHeight) &&
            (identical(other.isSelected, isSelected) ||
                other.isSelected == isSelected));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      text,
      languageCode,
      position,
      fontSize,
      textColor,
      backgroundColor,
      strokeColor,
      strokeWidth,
      shadowColor,
      shadowOffset,
      shadowBlur,
      textAlign,
      rotation,
      scale,
      opacity,
      lineHeight,
      isSelected);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TextLayerModelImplCopyWith<_$TextLayerModelImpl> get copyWith =>
      __$$TextLayerModelImplCopyWithImpl<_$TextLayerModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TextLayerModelImplToJson(
      this,
    );
  }
}

abstract class _TextLayerModel implements TextLayerModel {
  const factory _TextLayerModel(
      {required final String id,
      required final String text,
      required final String languageCode,
      @OffsetConverter() required final Offset position,
      required final double fontSize,
      @ColorConverter() required final Color textColor,
      @ColorConverter() final Color? backgroundColor,
      @ColorConverter() final Color? strokeColor,
      final double? strokeWidth,
      @ColorConverter() final Color? shadowColor,
      @OffsetConverter() final Offset? shadowOffset,
      final double? shadowBlur,
      @TextAlignConverter() required final TextAlign textAlign,
      required final double rotation,
      required final double scale,
      final double opacity,
      final double lineHeight,
      final bool isSelected}) = _$TextLayerModelImpl;

  factory _TextLayerModel.fromJson(Map<String, dynamic> json) =
      _$TextLayerModelImpl.fromJson;

  @override
  String get id;
  @override // Unique identifier
  String get text;
  @override // Urdu/English text content
  String get languageCode;
  @override // 'ur' or 'en'
  @OffsetConverter()
  Offset get position;
  @override // X, Y coordinates
  double get fontSize;
  @override // Text size
  @ColorConverter()
  Color get textColor;
  @override // Text color
  @ColorConverter()
  Color? get backgroundColor;
  @override // Optional highlight
  @ColorConverter()
  Color? get strokeColor;
  @override // Optional outline
  double? get strokeWidth;
  @override // Outline width
  @ColorConverter()
  Color? get shadowColor;
  @override // Optional shadow
  @OffsetConverter()
  Offset? get shadowOffset;
  @override // Shadow offset
  double? get shadowBlur;
  @override // Shadow blur radius
  @TextAlignConverter()
  TextAlign get textAlign;
  @override // left, center, right
  double get rotation;
  @override // Rotation in radians
  double get scale;
  @override // Scale factor
  double get opacity;
  @override // 0.0 to 1.0
  double get lineHeight;
  @override // For Urdu: 1.8-2.2
  bool get isSelected;
  @override
  @JsonKey(ignore: true)
  _$$TextLayerModelImplCopyWith<_$TextLayerModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
