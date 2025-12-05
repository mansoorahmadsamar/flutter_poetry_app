// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bookmark_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

BookmarkModel _$BookmarkModelFromJson(Map<String, dynamic> json) {
  return _BookmarkModel.fromJson(json);
}

/// @nodoc
mixin _$BookmarkModel {
  String get publicId => throw _privateConstructorUsedError;
  String get userPublicId => throw _privateConstructorUsedError;
  String get contentType => throw _privateConstructorUsedError;
  String get contentId => throw _privateConstructorUsedError;
  String? get contentTitle => throw _privateConstructorUsedError;
  String? get contentExcerpt => throw _privateConstructorUsedError;
  String? get contentImageUrl => throw _privateConstructorUsedError;
  String? get contentMetadata => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this BookmarkModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BookmarkModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BookmarkModelCopyWith<BookmarkModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BookmarkModelCopyWith<$Res> {
  factory $BookmarkModelCopyWith(
          BookmarkModel value, $Res Function(BookmarkModel) then) =
      _$BookmarkModelCopyWithImpl<$Res, BookmarkModel>;
  @useResult
  $Res call(
      {String publicId,
      String userPublicId,
      String contentType,
      String contentId,
      String? contentTitle,
      String? contentExcerpt,
      String? contentImageUrl,
      String? contentMetadata,
      bool isActive,
      DateTime createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$BookmarkModelCopyWithImpl<$Res, $Val extends BookmarkModel>
    implements $BookmarkModelCopyWith<$Res> {
  _$BookmarkModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BookmarkModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? publicId = null,
    Object? userPublicId = null,
    Object? contentType = null,
    Object? contentId = null,
    Object? contentTitle = freezed,
    Object? contentExcerpt = freezed,
    Object? contentImageUrl = freezed,
    Object? contentMetadata = freezed,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
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
      contentTitle: freezed == contentTitle
          ? _value.contentTitle
          : contentTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      contentExcerpt: freezed == contentExcerpt
          ? _value.contentExcerpt
          : contentExcerpt // ignore: cast_nullable_to_non_nullable
              as String?,
      contentImageUrl: freezed == contentImageUrl
          ? _value.contentImageUrl
          : contentImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      contentMetadata: freezed == contentMetadata
          ? _value.contentMetadata
          : contentMetadata // ignore: cast_nullable_to_non_nullable
              as String?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BookmarkModelImplCopyWith<$Res>
    implements $BookmarkModelCopyWith<$Res> {
  factory _$$BookmarkModelImplCopyWith(
          _$BookmarkModelImpl value, $Res Function(_$BookmarkModelImpl) then) =
      __$$BookmarkModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String publicId,
      String userPublicId,
      String contentType,
      String contentId,
      String? contentTitle,
      String? contentExcerpt,
      String? contentImageUrl,
      String? contentMetadata,
      bool isActive,
      DateTime createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$BookmarkModelImplCopyWithImpl<$Res>
    extends _$BookmarkModelCopyWithImpl<$Res, _$BookmarkModelImpl>
    implements _$$BookmarkModelImplCopyWith<$Res> {
  __$$BookmarkModelImplCopyWithImpl(
      _$BookmarkModelImpl _value, $Res Function(_$BookmarkModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of BookmarkModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? publicId = null,
    Object? userPublicId = null,
    Object? contentType = null,
    Object? contentId = null,
    Object? contentTitle = freezed,
    Object? contentExcerpt = freezed,
    Object? contentImageUrl = freezed,
    Object? contentMetadata = freezed,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$BookmarkModelImpl(
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
      contentTitle: freezed == contentTitle
          ? _value.contentTitle
          : contentTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      contentExcerpt: freezed == contentExcerpt
          ? _value.contentExcerpt
          : contentExcerpt // ignore: cast_nullable_to_non_nullable
              as String?,
      contentImageUrl: freezed == contentImageUrl
          ? _value.contentImageUrl
          : contentImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      contentMetadata: freezed == contentMetadata
          ? _value.contentMetadata
          : contentMetadata // ignore: cast_nullable_to_non_nullable
              as String?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BookmarkModelImpl implements _BookmarkModel {
  const _$BookmarkModelImpl(
      {required this.publicId,
      required this.userPublicId,
      required this.contentType,
      required this.contentId,
      this.contentTitle,
      this.contentExcerpt,
      this.contentImageUrl,
      this.contentMetadata,
      this.isActive = false,
      required this.createdAt,
      this.updatedAt});

  factory _$BookmarkModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$BookmarkModelImplFromJson(json);

  @override
  final String publicId;
  @override
  final String userPublicId;
  @override
  final String contentType;
  @override
  final String contentId;
  @override
  final String? contentTitle;
  @override
  final String? contentExcerpt;
  @override
  final String? contentImageUrl;
  @override
  final String? contentMetadata;
  @override
  @JsonKey()
  final bool isActive;
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'BookmarkModel(publicId: $publicId, userPublicId: $userPublicId, contentType: $contentType, contentId: $contentId, contentTitle: $contentTitle, contentExcerpt: $contentExcerpt, contentImageUrl: $contentImageUrl, contentMetadata: $contentMetadata, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookmarkModelImpl &&
            (identical(other.publicId, publicId) ||
                other.publicId == publicId) &&
            (identical(other.userPublicId, userPublicId) ||
                other.userPublicId == userPublicId) &&
            (identical(other.contentType, contentType) ||
                other.contentType == contentType) &&
            (identical(other.contentId, contentId) ||
                other.contentId == contentId) &&
            (identical(other.contentTitle, contentTitle) ||
                other.contentTitle == contentTitle) &&
            (identical(other.contentExcerpt, contentExcerpt) ||
                other.contentExcerpt == contentExcerpt) &&
            (identical(other.contentImageUrl, contentImageUrl) ||
                other.contentImageUrl == contentImageUrl) &&
            (identical(other.contentMetadata, contentMetadata) ||
                other.contentMetadata == contentMetadata) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      publicId,
      userPublicId,
      contentType,
      contentId,
      contentTitle,
      contentExcerpt,
      contentImageUrl,
      contentMetadata,
      isActive,
      createdAt,
      updatedAt);

  /// Create a copy of BookmarkModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BookmarkModelImplCopyWith<_$BookmarkModelImpl> get copyWith =>
      __$$BookmarkModelImplCopyWithImpl<_$BookmarkModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BookmarkModelImplToJson(
      this,
    );
  }
}

abstract class _BookmarkModel implements BookmarkModel {
  const factory _BookmarkModel(
      {required final String publicId,
      required final String userPublicId,
      required final String contentType,
      required final String contentId,
      final String? contentTitle,
      final String? contentExcerpt,
      final String? contentImageUrl,
      final String? contentMetadata,
      final bool isActive,
      required final DateTime createdAt,
      final DateTime? updatedAt}) = _$BookmarkModelImpl;

  factory _BookmarkModel.fromJson(Map<String, dynamic> json) =
      _$BookmarkModelImpl.fromJson;

  @override
  String get publicId;
  @override
  String get userPublicId;
  @override
  String get contentType;
  @override
  String get contentId;
  @override
  String? get contentTitle;
  @override
  String? get contentExcerpt;
  @override
  String? get contentImageUrl;
  @override
  String? get contentMetadata;
  @override
  bool get isActive;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of BookmarkModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BookmarkModelImplCopyWith<_$BookmarkModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
