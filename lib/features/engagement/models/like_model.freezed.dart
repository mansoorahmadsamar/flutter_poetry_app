// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'like_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LikeModel _$LikeModelFromJson(Map<String, dynamic> json) {
  return _LikeModel.fromJson(json);
}

/// @nodoc
mixin _$LikeModel {
  String get publicId => throw _privateConstructorUsedError;
  String get userPublicId => throw _privateConstructorUsedError;
  String get contentType => throw _privateConstructorUsedError;
  String get contentId => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LikeModelCopyWith<LikeModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LikeModelCopyWith<$Res> {
  factory $LikeModelCopyWith(LikeModel value, $Res Function(LikeModel) then) =
      _$LikeModelCopyWithImpl<$Res, LikeModel>;
  @useResult
  $Res call(
      {String publicId,
      String userPublicId,
      String contentType,
      String contentId,
      bool isActive,
      DateTime createdAt});
}

/// @nodoc
class _$LikeModelCopyWithImpl<$Res, $Val extends LikeModel>
    implements $LikeModelCopyWith<$Res> {
  _$LikeModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? publicId = null,
    Object? userPublicId = null,
    Object? contentType = null,
    Object? contentId = null,
    Object? isActive = null,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      publicId: null == publicId
          ? _value.publicId
          : publicId // ignore: cast_nullable_to_non_nullable
              as String,
      userPublicId: null == userPublicId
          ? _value.userPublicId
          : userPublicId // ignore: cast_nullable_to_non_nullable
              as String,
      contentType: null == contentType
          ? _value.contentType
          : contentType // ignore: cast_nullable_to_non_nullable
              as String,
      contentId: null == contentId
          ? _value.contentId
          : contentId // ignore: cast_nullable_to_non_nullable
              as String,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LikeModelImplCopyWith<$Res>
    implements $LikeModelCopyWith<$Res> {
  factory _$$LikeModelImplCopyWith(
          _$LikeModelImpl value, $Res Function(_$LikeModelImpl) then) =
      __$$LikeModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String publicId,
      String userPublicId,
      String contentType,
      String contentId,
      bool isActive,
      DateTime createdAt});
}

/// @nodoc
class __$$LikeModelImplCopyWithImpl<$Res>
    extends _$LikeModelCopyWithImpl<$Res, _$LikeModelImpl>
    implements _$$LikeModelImplCopyWith<$Res> {
  __$$LikeModelImplCopyWithImpl(
      _$LikeModelImpl _value, $Res Function(_$LikeModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? publicId = null,
    Object? userPublicId = null,
    Object? contentType = null,
    Object? contentId = null,
    Object? isActive = null,
    Object? createdAt = null,
  }) {
    return _then(_$LikeModelImpl(
      publicId: null == publicId
          ? _value.publicId
          : publicId // ignore: cast_nullable_to_non_nullable
              as String,
      userPublicId: null == userPublicId
          ? _value.userPublicId
          : userPublicId // ignore: cast_nullable_to_non_nullable
              as String,
      contentType: null == contentType
          ? _value.contentType
          : contentType // ignore: cast_nullable_to_non_nullable
              as String,
      contentId: null == contentId
          ? _value.contentId
          : contentId // ignore: cast_nullable_to_non_nullable
              as String,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LikeModelImpl implements _LikeModel {
  const _$LikeModelImpl(
      {required this.publicId,
      required this.userPublicId,
      required this.contentType,
      required this.contentId,
      this.isActive = false,
      required this.createdAt});

  factory _$LikeModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$LikeModelImplFromJson(json);

  @override
  final String publicId;
  @override
  final String userPublicId;
  @override
  final String contentType;
  @override
  final String contentId;
  @override
  @JsonKey()
  final bool isActive;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'LikeModel(publicId: $publicId, userPublicId: $userPublicId, contentType: $contentType, contentId: $contentId, isActive: $isActive, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LikeModelImpl &&
            (identical(other.publicId, publicId) ||
                other.publicId == publicId) &&
            (identical(other.userPublicId, userPublicId) ||
                other.userPublicId == userPublicId) &&
            (identical(other.contentType, contentType) ||
                other.contentType == contentType) &&
            (identical(other.contentId, contentId) ||
                other.contentId == contentId) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, publicId, userPublicId,
      contentType, contentId, isActive, createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LikeModelImplCopyWith<_$LikeModelImpl> get copyWith =>
      __$$LikeModelImplCopyWithImpl<_$LikeModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LikeModelImplToJson(
      this,
    );
  }
}

abstract class _LikeModel implements LikeModel {
  const factory _LikeModel(
      {required final String publicId,
      required final String userPublicId,
      required final String contentType,
      required final String contentId,
      final bool isActive,
      required final DateTime createdAt}) = _$LikeModelImpl;

  factory _LikeModel.fromJson(Map<String, dynamic> json) =
      _$LikeModelImpl.fromJson;

  @override
  String get publicId;
  @override
  String get userPublicId;
  @override
  String get contentType;
  @override
  String get contentId;
  @override
  bool get isActive;
  @override
  DateTime get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$LikeModelImplCopyWith<_$LikeModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
