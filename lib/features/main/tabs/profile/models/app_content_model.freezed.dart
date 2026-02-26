// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_content_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AppContentModel _$AppContentModelFromJson(Map<String, dynamic> json) {
  return _AppContentModel.fromJson(json);
}

/// @nodoc
mixin _$AppContentModel {
  String get publicId => throw _privateConstructorUsedError;
  String get contentKey => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  String get languageCode => throw _privateConstructorUsedError;
  int? get displayOrder => throw _privateConstructorUsedError;
  String? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AppContentModelCopyWith<AppContentModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppContentModelCopyWith<$Res> {
  factory $AppContentModelCopyWith(
          AppContentModel value, $Res Function(AppContentModel) then) =
      _$AppContentModelCopyWithImpl<$Res, AppContentModel>;
  @useResult
  $Res call(
      {String publicId,
      String contentKey,
      String title,
      String content,
      String languageCode,
      int? displayOrder,
      String? updatedAt});
}

/// @nodoc
class _$AppContentModelCopyWithImpl<$Res, $Val extends AppContentModel>
    implements $AppContentModelCopyWith<$Res> {
  _$AppContentModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? publicId = null,
    Object? contentKey = null,
    Object? title = null,
    Object? content = null,
    Object? languageCode = null,
    Object? displayOrder = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      publicId: null == publicId
          ? _value.publicId
          : publicId // ignore: cast_nullable_to_non_nullable
              as String,
      contentKey: null == contentKey
          ? _value.contentKey
          : contentKey // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      languageCode: null == languageCode
          ? _value.languageCode
          : languageCode // ignore: cast_nullable_to_non_nullable
              as String,
      displayOrder: freezed == displayOrder
          ? _value.displayOrder
          : displayOrder // ignore: cast_nullable_to_non_nullable
              as int?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AppContentModelImplCopyWith<$Res>
    implements $AppContentModelCopyWith<$Res> {
  factory _$$AppContentModelImplCopyWith(_$AppContentModelImpl value,
          $Res Function(_$AppContentModelImpl) then) =
      __$$AppContentModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String publicId,
      String contentKey,
      String title,
      String content,
      String languageCode,
      int? displayOrder,
      String? updatedAt});
}

/// @nodoc
class __$$AppContentModelImplCopyWithImpl<$Res>
    extends _$AppContentModelCopyWithImpl<$Res, _$AppContentModelImpl>
    implements _$$AppContentModelImplCopyWith<$Res> {
  __$$AppContentModelImplCopyWithImpl(
      _$AppContentModelImpl _value, $Res Function(_$AppContentModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? publicId = null,
    Object? contentKey = null,
    Object? title = null,
    Object? content = null,
    Object? languageCode = null,
    Object? displayOrder = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$AppContentModelImpl(
      publicId: null == publicId
          ? _value.publicId
          : publicId // ignore: cast_nullable_to_non_nullable
              as String,
      contentKey: null == contentKey
          ? _value.contentKey
          : contentKey // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      languageCode: null == languageCode
          ? _value.languageCode
          : languageCode // ignore: cast_nullable_to_non_nullable
              as String,
      displayOrder: freezed == displayOrder
          ? _value.displayOrder
          : displayOrder // ignore: cast_nullable_to_non_nullable
              as int?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AppContentModelImpl implements _AppContentModel {
  const _$AppContentModelImpl(
      {required this.publicId,
      required this.contentKey,
      required this.title,
      required this.content,
      required this.languageCode,
      this.displayOrder,
      this.updatedAt});

  factory _$AppContentModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppContentModelImplFromJson(json);

  @override
  final String publicId;
  @override
  final String contentKey;
  @override
  final String title;
  @override
  final String content;
  @override
  final String languageCode;
  @override
  final int? displayOrder;
  @override
  final String? updatedAt;

  @override
  String toString() {
    return 'AppContentModel(publicId: $publicId, contentKey: $contentKey, title: $title, content: $content, languageCode: $languageCode, displayOrder: $displayOrder, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppContentModelImpl &&
            (identical(other.publicId, publicId) ||
                other.publicId == publicId) &&
            (identical(other.contentKey, contentKey) ||
                other.contentKey == contentKey) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.languageCode, languageCode) ||
                other.languageCode == languageCode) &&
            (identical(other.displayOrder, displayOrder) ||
                other.displayOrder == displayOrder) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, publicId, contentKey, title,
      content, languageCode, displayOrder, updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AppContentModelImplCopyWith<_$AppContentModelImpl> get copyWith =>
      __$$AppContentModelImplCopyWithImpl<_$AppContentModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AppContentModelImplToJson(
      this,
    );
  }
}

abstract class _AppContentModel implements AppContentModel {
  const factory _AppContentModel(
      {required final String publicId,
      required final String contentKey,
      required final String title,
      required final String content,
      required final String languageCode,
      final int? displayOrder,
      final String? updatedAt}) = _$AppContentModelImpl;

  factory _AppContentModel.fromJson(Map<String, dynamic> json) =
      _$AppContentModelImpl.fromJson;

  @override
  String get publicId;
  @override
  String get contentKey;
  @override
  String get title;
  @override
  String get content;
  @override
  String get languageCode;
  @override
  int? get displayOrder;
  @override
  String? get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$AppContentModelImplCopyWith<_$AppContentModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
