// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'image_template_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ImageTemplateModel _$ImageTemplateModelFromJson(Map<String, dynamic> json) {
  return _ImageTemplateModel.fromJson(json);
}

/// @nodoc
mixin _$ImageTemplateModel {
  String get publicId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String get category =>
      throw _privateConstructorUsedError; // NATURE, MINIMAL, ARTISTIC, TRADITIONAL
  String get backgroundImageUrl => throw _privateConstructorUsedError;
  String? get thumbnailUrl => throw _privateConstructorUsedError;
  Map<String, dynamic> get layoutConfig => throw _privateConstructorUsedError;
  bool get isPremium => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  int get displayOrder => throw _privateConstructorUsedError;
  int get usageCount => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this ImageTemplateModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ImageTemplateModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ImageTemplateModelCopyWith<ImageTemplateModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ImageTemplateModelCopyWith<$Res> {
  factory $ImageTemplateModelCopyWith(
          ImageTemplateModel value, $Res Function(ImageTemplateModel) then) =
      _$ImageTemplateModelCopyWithImpl<$Res, ImageTemplateModel>;
  @useResult
  $Res call(
      {String publicId,
      String name,
      String? description,
      String category,
      String backgroundImageUrl,
      String? thumbnailUrl,
      Map<String, dynamic> layoutConfig,
      bool isPremium,
      bool isActive,
      int displayOrder,
      int usageCount,
      DateTime? createdAt});
}

/// @nodoc
class _$ImageTemplateModelCopyWithImpl<$Res, $Val extends ImageTemplateModel>
    implements $ImageTemplateModelCopyWith<$Res> {
  _$ImageTemplateModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ImageTemplateModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? publicId = null,
    Object? name = null,
    Object? description = freezed,
    Object? category = null,
    Object? backgroundImageUrl = null,
    Object? thumbnailUrl = freezed,
    Object? layoutConfig = null,
    Object? isPremium = null,
    Object? isActive = null,
    Object? displayOrder = null,
    Object? usageCount = null,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      publicId: null == publicId
          ? _value.publicId
          : publicId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      backgroundImageUrl: null == backgroundImageUrl
          ? _value.backgroundImageUrl
          : backgroundImageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      thumbnailUrl: freezed == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      layoutConfig: null == layoutConfig
          ? _value.layoutConfig
          : layoutConfig // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      isPremium: null == isPremium
          ? _value.isPremium
          : isPremium // ignore: cast_nullable_to_non_nullable
              as bool,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      displayOrder: null == displayOrder
          ? _value.displayOrder
          : displayOrder // ignore: cast_nullable_to_non_nullable
              as int,
      usageCount: null == usageCount
          ? _value.usageCount
          : usageCount // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ImageTemplateModelImplCopyWith<$Res>
    implements $ImageTemplateModelCopyWith<$Res> {
  factory _$$ImageTemplateModelImplCopyWith(_$ImageTemplateModelImpl value,
          $Res Function(_$ImageTemplateModelImpl) then) =
      __$$ImageTemplateModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String publicId,
      String name,
      String? description,
      String category,
      String backgroundImageUrl,
      String? thumbnailUrl,
      Map<String, dynamic> layoutConfig,
      bool isPremium,
      bool isActive,
      int displayOrder,
      int usageCount,
      DateTime? createdAt});
}

/// @nodoc
class __$$ImageTemplateModelImplCopyWithImpl<$Res>
    extends _$ImageTemplateModelCopyWithImpl<$Res, _$ImageTemplateModelImpl>
    implements _$$ImageTemplateModelImplCopyWith<$Res> {
  __$$ImageTemplateModelImplCopyWithImpl(_$ImageTemplateModelImpl _value,
      $Res Function(_$ImageTemplateModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of ImageTemplateModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? publicId = null,
    Object? name = null,
    Object? description = freezed,
    Object? category = null,
    Object? backgroundImageUrl = null,
    Object? thumbnailUrl = freezed,
    Object? layoutConfig = null,
    Object? isPremium = null,
    Object? isActive = null,
    Object? displayOrder = null,
    Object? usageCount = null,
    Object? createdAt = freezed,
  }) {
    return _then(_$ImageTemplateModelImpl(
      publicId: null == publicId
          ? _value.publicId
          : publicId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      backgroundImageUrl: null == backgroundImageUrl
          ? _value.backgroundImageUrl
          : backgroundImageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      thumbnailUrl: freezed == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      layoutConfig: null == layoutConfig
          ? _value._layoutConfig
          : layoutConfig // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      isPremium: null == isPremium
          ? _value.isPremium
          : isPremium // ignore: cast_nullable_to_non_nullable
              as bool,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      displayOrder: null == displayOrder
          ? _value.displayOrder
          : displayOrder // ignore: cast_nullable_to_non_nullable
              as int,
      usageCount: null == usageCount
          ? _value.usageCount
          : usageCount // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ImageTemplateModelImpl implements _ImageTemplateModel {
  const _$ImageTemplateModelImpl(
      {required this.publicId,
      required this.name,
      this.description,
      required this.category,
      required this.backgroundImageUrl,
      this.thumbnailUrl,
      required final Map<String, dynamic> layoutConfig,
      this.isPremium = false,
      this.isActive = true,
      this.displayOrder = 0,
      this.usageCount = 0,
      this.createdAt})
      : _layoutConfig = layoutConfig;

  factory _$ImageTemplateModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ImageTemplateModelImplFromJson(json);

  @override
  final String publicId;
  @override
  final String name;
  @override
  final String? description;
  @override
  final String category;
// NATURE, MINIMAL, ARTISTIC, TRADITIONAL
  @override
  final String backgroundImageUrl;
  @override
  final String? thumbnailUrl;
  final Map<String, dynamic> _layoutConfig;
  @override
  Map<String, dynamic> get layoutConfig {
    if (_layoutConfig is EqualUnmodifiableMapView) return _layoutConfig;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_layoutConfig);
  }

  @override
  @JsonKey()
  final bool isPremium;
  @override
  @JsonKey()
  final bool isActive;
  @override
  @JsonKey()
  final int displayOrder;
  @override
  @JsonKey()
  final int usageCount;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'ImageTemplateModel(publicId: $publicId, name: $name, description: $description, category: $category, backgroundImageUrl: $backgroundImageUrl, thumbnailUrl: $thumbnailUrl, layoutConfig: $layoutConfig, isPremium: $isPremium, isActive: $isActive, displayOrder: $displayOrder, usageCount: $usageCount, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ImageTemplateModelImpl &&
            (identical(other.publicId, publicId) ||
                other.publicId == publicId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.backgroundImageUrl, backgroundImageUrl) ||
                other.backgroundImageUrl == backgroundImageUrl) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            const DeepCollectionEquality()
                .equals(other._layoutConfig, _layoutConfig) &&
            (identical(other.isPremium, isPremium) ||
                other.isPremium == isPremium) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.displayOrder, displayOrder) ||
                other.displayOrder == displayOrder) &&
            (identical(other.usageCount, usageCount) ||
                other.usageCount == usageCount) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      publicId,
      name,
      description,
      category,
      backgroundImageUrl,
      thumbnailUrl,
      const DeepCollectionEquality().hash(_layoutConfig),
      isPremium,
      isActive,
      displayOrder,
      usageCount,
      createdAt);

  /// Create a copy of ImageTemplateModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ImageTemplateModelImplCopyWith<_$ImageTemplateModelImpl> get copyWith =>
      __$$ImageTemplateModelImplCopyWithImpl<_$ImageTemplateModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ImageTemplateModelImplToJson(
      this,
    );
  }
}

abstract class _ImageTemplateModel implements ImageTemplateModel {
  const factory _ImageTemplateModel(
      {required final String publicId,
      required final String name,
      final String? description,
      required final String category,
      required final String backgroundImageUrl,
      final String? thumbnailUrl,
      required final Map<String, dynamic> layoutConfig,
      final bool isPremium,
      final bool isActive,
      final int displayOrder,
      final int usageCount,
      final DateTime? createdAt}) = _$ImageTemplateModelImpl;

  factory _ImageTemplateModel.fromJson(Map<String, dynamic> json) =
      _$ImageTemplateModelImpl.fromJson;

  @override
  String get publicId;
  @override
  String get name;
  @override
  String? get description;
  @override
  String get category; // NATURE, MINIMAL, ARTISTIC, TRADITIONAL
  @override
  String get backgroundImageUrl;
  @override
  String? get thumbnailUrl;
  @override
  Map<String, dynamic> get layoutConfig;
  @override
  bool get isPremium;
  @override
  bool get isActive;
  @override
  int get displayOrder;
  @override
  int get usageCount;
  @override
  DateTime? get createdAt;

  /// Create a copy of ImageTemplateModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ImageTemplateModelImplCopyWith<_$ImageTemplateModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
