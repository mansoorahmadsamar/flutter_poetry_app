// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'canvas_state_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CanvasStateModel _$CanvasStateModelFromJson(Map<String, dynamic> json) {
  return _CanvasStateModel.fromJson(json);
}

/// @nodoc
mixin _$CanvasStateModel {
  String? get backgroundImagePath =>
      throw _privateConstructorUsedError; // Local file path or URL
  List<TextLayerModel> get textLayers =>
      throw _privateConstructorUsedError; // All text layers
  String? get selectedLayerId =>
      throw _privateConstructorUsedError; // Currently selected layer
  double get canvasScale => throw _privateConstructorUsedError; // Zoom level
  @OffsetConverter()
  Offset get canvasOffset => throw _privateConstructorUsedError; // Pan offset
  @SizeConverter()
  Size get canvasSize => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CanvasStateModelCopyWith<CanvasStateModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CanvasStateModelCopyWith<$Res> {
  factory $CanvasStateModelCopyWith(
          CanvasStateModel value, $Res Function(CanvasStateModel) then) =
      _$CanvasStateModelCopyWithImpl<$Res, CanvasStateModel>;
  @useResult
  $Res call(
      {String? backgroundImagePath,
      List<TextLayerModel> textLayers,
      String? selectedLayerId,
      double canvasScale,
      @OffsetConverter() Offset canvasOffset,
      @SizeConverter() Size canvasSize});
}

/// @nodoc
class _$CanvasStateModelCopyWithImpl<$Res, $Val extends CanvasStateModel>
    implements $CanvasStateModelCopyWith<$Res> {
  _$CanvasStateModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? backgroundImagePath = freezed,
    Object? textLayers = null,
    Object? selectedLayerId = freezed,
    Object? canvasScale = null,
    Object? canvasOffset = null,
    Object? canvasSize = null,
  }) {
    return _then(_value.copyWith(
      backgroundImagePath: freezed == backgroundImagePath
          ? _value.backgroundImagePath
          : backgroundImagePath // ignore: cast_nullable_to_non_nullable
              as String?,
      textLayers: null == textLayers
          ? _value.textLayers
          : textLayers // ignore: cast_nullable_to_non_nullable
              as List<TextLayerModel>,
      selectedLayerId: freezed == selectedLayerId
          ? _value.selectedLayerId
          : selectedLayerId // ignore: cast_nullable_to_non_nullable
              as String?,
      canvasScale: null == canvasScale
          ? _value.canvasScale
          : canvasScale // ignore: cast_nullable_to_non_nullable
              as double,
      canvasOffset: null == canvasOffset
          ? _value.canvasOffset
          : canvasOffset // ignore: cast_nullable_to_non_nullable
              as Offset,
      canvasSize: null == canvasSize
          ? _value.canvasSize
          : canvasSize // ignore: cast_nullable_to_non_nullable
              as Size,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CanvasStateModelImplCopyWith<$Res>
    implements $CanvasStateModelCopyWith<$Res> {
  factory _$$CanvasStateModelImplCopyWith(_$CanvasStateModelImpl value,
          $Res Function(_$CanvasStateModelImpl) then) =
      __$$CanvasStateModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? backgroundImagePath,
      List<TextLayerModel> textLayers,
      String? selectedLayerId,
      double canvasScale,
      @OffsetConverter() Offset canvasOffset,
      @SizeConverter() Size canvasSize});
}

/// @nodoc
class __$$CanvasStateModelImplCopyWithImpl<$Res>
    extends _$CanvasStateModelCopyWithImpl<$Res, _$CanvasStateModelImpl>
    implements _$$CanvasStateModelImplCopyWith<$Res> {
  __$$CanvasStateModelImplCopyWithImpl(_$CanvasStateModelImpl _value,
      $Res Function(_$CanvasStateModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? backgroundImagePath = freezed,
    Object? textLayers = null,
    Object? selectedLayerId = freezed,
    Object? canvasScale = null,
    Object? canvasOffset = null,
    Object? canvasSize = null,
  }) {
    return _then(_$CanvasStateModelImpl(
      backgroundImagePath: freezed == backgroundImagePath
          ? _value.backgroundImagePath
          : backgroundImagePath // ignore: cast_nullable_to_non_nullable
              as String?,
      textLayers: null == textLayers
          ? _value._textLayers
          : textLayers // ignore: cast_nullable_to_non_nullable
              as List<TextLayerModel>,
      selectedLayerId: freezed == selectedLayerId
          ? _value.selectedLayerId
          : selectedLayerId // ignore: cast_nullable_to_non_nullable
              as String?,
      canvasScale: null == canvasScale
          ? _value.canvasScale
          : canvasScale // ignore: cast_nullable_to_non_nullable
              as double,
      canvasOffset: null == canvasOffset
          ? _value.canvasOffset
          : canvasOffset // ignore: cast_nullable_to_non_nullable
              as Offset,
      canvasSize: null == canvasSize
          ? _value.canvasSize
          : canvasSize // ignore: cast_nullable_to_non_nullable
              as Size,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CanvasStateModelImpl implements _CanvasStateModel {
  const _$CanvasStateModelImpl(
      {this.backgroundImagePath,
      final List<TextLayerModel> textLayers = const [],
      this.selectedLayerId,
      this.canvasScale = 1.0,
      @OffsetConverter() this.canvasOffset = Offset.zero,
      @SizeConverter() this.canvasSize = const Size(1080, 1920)})
      : _textLayers = textLayers;

  factory _$CanvasStateModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CanvasStateModelImplFromJson(json);

  @override
  final String? backgroundImagePath;
// Local file path or URL
  final List<TextLayerModel> _textLayers;
// Local file path or URL
  @override
  @JsonKey()
  List<TextLayerModel> get textLayers {
    if (_textLayers is EqualUnmodifiableListView) return _textLayers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_textLayers);
  }

// All text layers
  @override
  final String? selectedLayerId;
// Currently selected layer
  @override
  @JsonKey()
  final double canvasScale;
// Zoom level
  @override
  @JsonKey()
  @OffsetConverter()
  final Offset canvasOffset;
// Pan offset
  @override
  @JsonKey()
  @SizeConverter()
  final Size canvasSize;

  @override
  String toString() {
    return 'CanvasStateModel(backgroundImagePath: $backgroundImagePath, textLayers: $textLayers, selectedLayerId: $selectedLayerId, canvasScale: $canvasScale, canvasOffset: $canvasOffset, canvasSize: $canvasSize)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CanvasStateModelImpl &&
            (identical(other.backgroundImagePath, backgroundImagePath) ||
                other.backgroundImagePath == backgroundImagePath) &&
            const DeepCollectionEquality()
                .equals(other._textLayers, _textLayers) &&
            (identical(other.selectedLayerId, selectedLayerId) ||
                other.selectedLayerId == selectedLayerId) &&
            (identical(other.canvasScale, canvasScale) ||
                other.canvasScale == canvasScale) &&
            (identical(other.canvasOffset, canvasOffset) ||
                other.canvasOffset == canvasOffset) &&
            (identical(other.canvasSize, canvasSize) ||
                other.canvasSize == canvasSize));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      backgroundImagePath,
      const DeepCollectionEquality().hash(_textLayers),
      selectedLayerId,
      canvasScale,
      canvasOffset,
      canvasSize);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CanvasStateModelImplCopyWith<_$CanvasStateModelImpl> get copyWith =>
      __$$CanvasStateModelImplCopyWithImpl<_$CanvasStateModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CanvasStateModelImplToJson(
      this,
    );
  }
}

abstract class _CanvasStateModel implements CanvasStateModel {
  const factory _CanvasStateModel(
      {final String? backgroundImagePath,
      final List<TextLayerModel> textLayers,
      final String? selectedLayerId,
      final double canvasScale,
      @OffsetConverter() final Offset canvasOffset,
      @SizeConverter() final Size canvasSize}) = _$CanvasStateModelImpl;

  factory _CanvasStateModel.fromJson(Map<String, dynamic> json) =
      _$CanvasStateModelImpl.fromJson;

  @override
  String? get backgroundImagePath;
  @override // Local file path or URL
  List<TextLayerModel> get textLayers;
  @override // All text layers
  String? get selectedLayerId;
  @override // Currently selected layer
  double get canvasScale;
  @override // Zoom level
  @OffsetConverter()
  Offset get canvasOffset;
  @override // Pan offset
  @SizeConverter()
  Size get canvasSize;
  @override
  @JsonKey(ignore: true)
  _$$CanvasStateModelImplCopyWith<_$CanvasStateModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
