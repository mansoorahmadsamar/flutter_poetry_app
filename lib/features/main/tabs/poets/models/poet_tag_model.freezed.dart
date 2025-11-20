// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'poet_tag_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PoetTagModel _$PoetTagModelFromJson(Map<String, dynamic> json) {
  return _PoetTagModel.fromJson(json);
}

/// @nodoc
mixin _$PoetTagModel {
  String get publicId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get slug => throw _privateConstructorUsedError;
  String? get color => throw _privateConstructorUsedError;
  @JsonKey(name: 'tagType')
  String get tagType => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;

  /// Serializes this PoetTagModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PoetTagModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PoetTagModelCopyWith<PoetTagModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PoetTagModelCopyWith<$Res> {
  factory $PoetTagModelCopyWith(
          PoetTagModel value, $Res Function(PoetTagModel) then) =
      _$PoetTagModelCopyWithImpl<$Res, PoetTagModel>;
  @useResult
  $Res call(
      {String publicId,
      String name,
      String slug,
      String? color,
      @JsonKey(name: 'tagType') String tagType,
      String? description});
}

/// @nodoc
class _$PoetTagModelCopyWithImpl<$Res, $Val extends PoetTagModel>
    implements $PoetTagModelCopyWith<$Res> {
  _$PoetTagModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PoetTagModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? publicId = null,
    Object? name = null,
    Object? slug = null,
    Object? color = freezed,
    Object? tagType = null,
    Object? description = freezed,
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
      slug: null == slug
          ? _value.slug
          : slug // ignore: cast_nullable_to_non_nullable
              as String,
      color: freezed == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String?,
      tagType: null == tagType
          ? _value.tagType
          : tagType // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PoetTagModelImplCopyWith<$Res>
    implements $PoetTagModelCopyWith<$Res> {
  factory _$$PoetTagModelImplCopyWith(
          _$PoetTagModelImpl value, $Res Function(_$PoetTagModelImpl) then) =
      __$$PoetTagModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String publicId,
      String name,
      String slug,
      String? color,
      @JsonKey(name: 'tagType') String tagType,
      String? description});
}

/// @nodoc
class __$$PoetTagModelImplCopyWithImpl<$Res>
    extends _$PoetTagModelCopyWithImpl<$Res, _$PoetTagModelImpl>
    implements _$$PoetTagModelImplCopyWith<$Res> {
  __$$PoetTagModelImplCopyWithImpl(
      _$PoetTagModelImpl _value, $Res Function(_$PoetTagModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of PoetTagModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? publicId = null,
    Object? name = null,
    Object? slug = null,
    Object? color = freezed,
    Object? tagType = null,
    Object? description = freezed,
  }) {
    return _then(_$PoetTagModelImpl(
      publicId: null == publicId
          ? _value.publicId
          : publicId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      slug: null == slug
          ? _value.slug
          : slug // ignore: cast_nullable_to_non_nullable
              as String,
      color: freezed == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String?,
      tagType: null == tagType
          ? _value.tagType
          : tagType // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PoetTagModelImpl implements _PoetTagModel {
  const _$PoetTagModelImpl(
      {required this.publicId,
      required this.name,
      required this.slug,
      this.color,
      @JsonKey(name: 'tagType') required this.tagType,
      this.description});

  factory _$PoetTagModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PoetTagModelImplFromJson(json);

  @override
  final String publicId;
  @override
  final String name;
  @override
  final String slug;
  @override
  final String? color;
  @override
  @JsonKey(name: 'tagType')
  final String tagType;
  @override
  final String? description;

  @override
  String toString() {
    return 'PoetTagModel(publicId: $publicId, name: $name, slug: $slug, color: $color, tagType: $tagType, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PoetTagModelImpl &&
            (identical(other.publicId, publicId) ||
                other.publicId == publicId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.slug, slug) || other.slug == slug) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.tagType, tagType) || other.tagType == tagType) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, publicId, name, slug, color, tagType, description);

  /// Create a copy of PoetTagModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PoetTagModelImplCopyWith<_$PoetTagModelImpl> get copyWith =>
      __$$PoetTagModelImplCopyWithImpl<_$PoetTagModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PoetTagModelImplToJson(
      this,
    );
  }
}

abstract class _PoetTagModel implements PoetTagModel {
  const factory _PoetTagModel(
      {required final String publicId,
      required final String name,
      required final String slug,
      final String? color,
      @JsonKey(name: 'tagType') required final String tagType,
      final String? description}) = _$PoetTagModelImpl;

  factory _PoetTagModel.fromJson(Map<String, dynamic> json) =
      _$PoetTagModelImpl.fromJson;

  @override
  String get publicId;
  @override
  String get name;
  @override
  String get slug;
  @override
  String? get color;
  @override
  @JsonKey(name: 'tagType')
  String get tagType;
  @override
  String? get description;

  /// Create a copy of PoetTagModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PoetTagModelImplCopyWith<_$PoetTagModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
