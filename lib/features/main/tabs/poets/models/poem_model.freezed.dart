// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'poem_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PoemModel _$PoemModelFromJson(Map<String, dynamic> json) {
  return _PoemModel.fromJson(json);
}

/// @nodoc
mixin _$PoemModel {
  String get publicId => throw _privateConstructorUsedError;
  String get poetPublicId => throw _privateConstructorUsedError;
  String get poetName => throw _privateConstructorUsedError;
  String? get poetProfileImageUrl => throw _privateConstructorUsedError;
  String? get categoryPublicId => throw _privateConstructorUsedError;
  String? get categoryName => throw _privateConstructorUsedError;
  String get poetryType => throw _privateConstructorUsedError;
  @JsonKey(name: 'poetryTypeName')
  String? get poetryTypeName => throw _privateConstructorUsedError;
  String? get poetryTypeUrduName => throw _privateConstructorUsedError;
  String? get poetryTypeEnglishName => throw _privateConstructorUsedError;
  String get contentType => throw _privateConstructorUsedError;
  bool? get requiresStructuredParsing => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  String? get thumbnailUrl => throw _privateConstructorUsedError;
  int? get yearWritten => throw _privateConstructorUsedError;
  String? get source => throw _privateConstructorUsedError;
  String? get license => throw _privateConstructorUsedError;
  String? get uploadedByUsername => throw _privateConstructorUsedError;
  bool get isPublic => throw _privateConstructorUsedError;
  bool get isFeatured => throw _privateConstructorUsedError;
  int get viewCount => throw _privateConstructorUsedError;
  int get likeCount => throw _privateConstructorUsedError;
  int get shareCount => throw _privateConstructorUsedError;
  bool? get isLikedByCurrentUser => throw _privateConstructorUsedError;
  bool? get isBookmarkedByCurrentUser => throw _privateConstructorUsedError;
  int? get commentCount => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  DateTime? get bookmarkedAt => throw _privateConstructorUsedError;
  DateTime? get likedAt => throw _privateConstructorUsedError;
  List<TagModel> get tags => throw _privateConstructorUsedError;
  List<PoemContentModel> get contents => throw _privateConstructorUsedError;
  PoemContentModel? get originalContent =>
      throw _privateConstructorUsedError; // Simple list API fields (for backward compatibility)
  String? get title => throw _privateConstructorUsedError;
  String? get excerpt => throw _privateConstructorUsedError;

  /// Serializes this PoemModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PoemModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PoemModelCopyWith<PoemModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PoemModelCopyWith<$Res> {
  factory $PoemModelCopyWith(PoemModel value, $Res Function(PoemModel) then) =
      _$PoemModelCopyWithImpl<$Res, PoemModel>;
  @useResult
  $Res call(
      {String publicId,
      String poetPublicId,
      String poetName,
      String? poetProfileImageUrl,
      String? categoryPublicId,
      String? categoryName,
      String poetryType,
      @JsonKey(name: 'poetryTypeName') String? poetryTypeName,
      String? poetryTypeUrduName,
      String? poetryTypeEnglishName,
      String contentType,
      bool? requiresStructuredParsing,
      String? imageUrl,
      String? thumbnailUrl,
      int? yearWritten,
      String? source,
      String? license,
      String? uploadedByUsername,
      bool isPublic,
      bool isFeatured,
      int viewCount,
      int likeCount,
      int shareCount,
      bool? isLikedByCurrentUser,
      bool? isBookmarkedByCurrentUser,
      int? commentCount,
      DateTime? createdAt,
      DateTime? updatedAt,
      DateTime? bookmarkedAt,
      DateTime? likedAt,
      List<TagModel> tags,
      List<PoemContentModel> contents,
      PoemContentModel? originalContent,
      String? title,
      String? excerpt});

  $PoemContentModelCopyWith<$Res>? get originalContent;
}

/// @nodoc
class _$PoemModelCopyWithImpl<$Res, $Val extends PoemModel>
    implements $PoemModelCopyWith<$Res> {
  _$PoemModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PoemModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? publicId = null,
    Object? poetPublicId = null,
    Object? poetName = null,
    Object? poetProfileImageUrl = freezed,
    Object? categoryPublicId = freezed,
    Object? categoryName = freezed,
    Object? poetryType = null,
    Object? poetryTypeName = freezed,
    Object? poetryTypeUrduName = freezed,
    Object? poetryTypeEnglishName = freezed,
    Object? contentType = null,
    Object? requiresStructuredParsing = freezed,
    Object? imageUrl = freezed,
    Object? thumbnailUrl = freezed,
    Object? yearWritten = freezed,
    Object? source = freezed,
    Object? license = freezed,
    Object? uploadedByUsername = freezed,
    Object? isPublic = null,
    Object? isFeatured = null,
    Object? viewCount = null,
    Object? likeCount = null,
    Object? shareCount = null,
    Object? isLikedByCurrentUser = freezed,
    Object? isBookmarkedByCurrentUser = freezed,
    Object? commentCount = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? bookmarkedAt = freezed,
    Object? likedAt = freezed,
    Object? tags = null,
    Object? contents = null,
    Object? originalContent = freezed,
    Object? title = freezed,
    Object? excerpt = freezed,
  }) {
    return _then(_value.copyWith(
      publicId: null == publicId
          ? _value.publicId
          : publicId // ignore: cast_nullable_to_non_nullable
              as String,
      poetPublicId: null == poetPublicId
          ? _value.poetPublicId
          : poetPublicId // ignore: cast_nullable_to_non_nullable
              as String,
      poetName: null == poetName
          ? _value.poetName
          : poetName // ignore: cast_nullable_to_non_nullable
              as String,
      poetProfileImageUrl: freezed == poetProfileImageUrl
          ? _value.poetProfileImageUrl
          : poetProfileImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      categoryPublicId: freezed == categoryPublicId
          ? _value.categoryPublicId
          : categoryPublicId // ignore: cast_nullable_to_non_nullable
              as String?,
      categoryName: freezed == categoryName
          ? _value.categoryName
          : categoryName // ignore: cast_nullable_to_non_nullable
              as String?,
      poetryType: null == poetryType
          ? _value.poetryType
          : poetryType // ignore: cast_nullable_to_non_nullable
              as String,
      poetryTypeName: freezed == poetryTypeName
          ? _value.poetryTypeName
          : poetryTypeName // ignore: cast_nullable_to_non_nullable
              as String?,
      poetryTypeUrduName: freezed == poetryTypeUrduName
          ? _value.poetryTypeUrduName
          : poetryTypeUrduName // ignore: cast_nullable_to_non_nullable
              as String?,
      poetryTypeEnglishName: freezed == poetryTypeEnglishName
          ? _value.poetryTypeEnglishName
          : poetryTypeEnglishName // ignore: cast_nullable_to_non_nullable
              as String?,
      contentType: null == contentType
          ? _value.contentType
          : contentType // ignore: cast_nullable_to_non_nullable
              as String,
      requiresStructuredParsing: freezed == requiresStructuredParsing
          ? _value.requiresStructuredParsing
          : requiresStructuredParsing // ignore: cast_nullable_to_non_nullable
              as bool?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      thumbnailUrl: freezed == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      yearWritten: freezed == yearWritten
          ? _value.yearWritten
          : yearWritten // ignore: cast_nullable_to_non_nullable
              as int?,
      source: freezed == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as String?,
      license: freezed == license
          ? _value.license
          : license // ignore: cast_nullable_to_non_nullable
              as String?,
      uploadedByUsername: freezed == uploadedByUsername
          ? _value.uploadedByUsername
          : uploadedByUsername // ignore: cast_nullable_to_non_nullable
              as String?,
      isPublic: null == isPublic
          ? _value.isPublic
          : isPublic // ignore: cast_nullable_to_non_nullable
              as bool,
      isFeatured: null == isFeatured
          ? _value.isFeatured
          : isFeatured // ignore: cast_nullable_to_non_nullable
              as bool,
      viewCount: null == viewCount
          ? _value.viewCount
          : viewCount // ignore: cast_nullable_to_non_nullable
              as int,
      likeCount: null == likeCount
          ? _value.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int,
      shareCount: null == shareCount
          ? _value.shareCount
          : shareCount // ignore: cast_nullable_to_non_nullable
              as int,
      isLikedByCurrentUser: freezed == isLikedByCurrentUser
          ? _value.isLikedByCurrentUser
          : isLikedByCurrentUser // ignore: cast_nullable_to_non_nullable
              as bool?,
      isBookmarkedByCurrentUser: freezed == isBookmarkedByCurrentUser
          ? _value.isBookmarkedByCurrentUser
          : isBookmarkedByCurrentUser // ignore: cast_nullable_to_non_nullable
              as bool?,
      commentCount: freezed == commentCount
          ? _value.commentCount
          : commentCount // ignore: cast_nullable_to_non_nullable
              as int?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      bookmarkedAt: freezed == bookmarkedAt
          ? _value.bookmarkedAt
          : bookmarkedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      likedAt: freezed == likedAt
          ? _value.likedAt
          : likedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<TagModel>,
      contents: null == contents
          ? _value.contents
          : contents // ignore: cast_nullable_to_non_nullable
              as List<PoemContentModel>,
      originalContent: freezed == originalContent
          ? _value.originalContent
          : originalContent // ignore: cast_nullable_to_non_nullable
              as PoemContentModel?,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      excerpt: freezed == excerpt
          ? _value.excerpt
          : excerpt // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  /// Create a copy of PoemModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PoemContentModelCopyWith<$Res>? get originalContent {
    if (_value.originalContent == null) {
      return null;
    }

    return $PoemContentModelCopyWith<$Res>(_value.originalContent!, (value) {
      return _then(_value.copyWith(originalContent: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PoemModelImplCopyWith<$Res>
    implements $PoemModelCopyWith<$Res> {
  factory _$$PoemModelImplCopyWith(
          _$PoemModelImpl value, $Res Function(_$PoemModelImpl) then) =
      __$$PoemModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String publicId,
      String poetPublicId,
      String poetName,
      String? poetProfileImageUrl,
      String? categoryPublicId,
      String? categoryName,
      String poetryType,
      @JsonKey(name: 'poetryTypeName') String? poetryTypeName,
      String? poetryTypeUrduName,
      String? poetryTypeEnglishName,
      String contentType,
      bool? requiresStructuredParsing,
      String? imageUrl,
      String? thumbnailUrl,
      int? yearWritten,
      String? source,
      String? license,
      String? uploadedByUsername,
      bool isPublic,
      bool isFeatured,
      int viewCount,
      int likeCount,
      int shareCount,
      bool? isLikedByCurrentUser,
      bool? isBookmarkedByCurrentUser,
      int? commentCount,
      DateTime? createdAt,
      DateTime? updatedAt,
      DateTime? bookmarkedAt,
      DateTime? likedAt,
      List<TagModel> tags,
      List<PoemContentModel> contents,
      PoemContentModel? originalContent,
      String? title,
      String? excerpt});

  @override
  $PoemContentModelCopyWith<$Res>? get originalContent;
}

/// @nodoc
class __$$PoemModelImplCopyWithImpl<$Res>
    extends _$PoemModelCopyWithImpl<$Res, _$PoemModelImpl>
    implements _$$PoemModelImplCopyWith<$Res> {
  __$$PoemModelImplCopyWithImpl(
      _$PoemModelImpl _value, $Res Function(_$PoemModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of PoemModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? publicId = null,
    Object? poetPublicId = null,
    Object? poetName = null,
    Object? poetProfileImageUrl = freezed,
    Object? categoryPublicId = freezed,
    Object? categoryName = freezed,
    Object? poetryType = null,
    Object? poetryTypeName = freezed,
    Object? poetryTypeUrduName = freezed,
    Object? poetryTypeEnglishName = freezed,
    Object? contentType = null,
    Object? requiresStructuredParsing = freezed,
    Object? imageUrl = freezed,
    Object? thumbnailUrl = freezed,
    Object? yearWritten = freezed,
    Object? source = freezed,
    Object? license = freezed,
    Object? uploadedByUsername = freezed,
    Object? isPublic = null,
    Object? isFeatured = null,
    Object? viewCount = null,
    Object? likeCount = null,
    Object? shareCount = null,
    Object? isLikedByCurrentUser = freezed,
    Object? isBookmarkedByCurrentUser = freezed,
    Object? commentCount = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? bookmarkedAt = freezed,
    Object? likedAt = freezed,
    Object? tags = null,
    Object? contents = null,
    Object? originalContent = freezed,
    Object? title = freezed,
    Object? excerpt = freezed,
  }) {
    return _then(_$PoemModelImpl(
      publicId: null == publicId
          ? _value.publicId
          : publicId // ignore: cast_nullable_to_non_nullable
              as String,
      poetPublicId: null == poetPublicId
          ? _value.poetPublicId
          : poetPublicId // ignore: cast_nullable_to_non_nullable
              as String,
      poetName: null == poetName
          ? _value.poetName
          : poetName // ignore: cast_nullable_to_non_nullable
              as String,
      poetProfileImageUrl: freezed == poetProfileImageUrl
          ? _value.poetProfileImageUrl
          : poetProfileImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      categoryPublicId: freezed == categoryPublicId
          ? _value.categoryPublicId
          : categoryPublicId // ignore: cast_nullable_to_non_nullable
              as String?,
      categoryName: freezed == categoryName
          ? _value.categoryName
          : categoryName // ignore: cast_nullable_to_non_nullable
              as String?,
      poetryType: null == poetryType
          ? _value.poetryType
          : poetryType // ignore: cast_nullable_to_non_nullable
              as String,
      poetryTypeName: freezed == poetryTypeName
          ? _value.poetryTypeName
          : poetryTypeName // ignore: cast_nullable_to_non_nullable
              as String?,
      poetryTypeUrduName: freezed == poetryTypeUrduName
          ? _value.poetryTypeUrduName
          : poetryTypeUrduName // ignore: cast_nullable_to_non_nullable
              as String?,
      poetryTypeEnglishName: freezed == poetryTypeEnglishName
          ? _value.poetryTypeEnglishName
          : poetryTypeEnglishName // ignore: cast_nullable_to_non_nullable
              as String?,
      contentType: null == contentType
          ? _value.contentType
          : contentType // ignore: cast_nullable_to_non_nullable
              as String,
      requiresStructuredParsing: freezed == requiresStructuredParsing
          ? _value.requiresStructuredParsing
          : requiresStructuredParsing // ignore: cast_nullable_to_non_nullable
              as bool?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      thumbnailUrl: freezed == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      yearWritten: freezed == yearWritten
          ? _value.yearWritten
          : yearWritten // ignore: cast_nullable_to_non_nullable
              as int?,
      source: freezed == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as String?,
      license: freezed == license
          ? _value.license
          : license // ignore: cast_nullable_to_non_nullable
              as String?,
      uploadedByUsername: freezed == uploadedByUsername
          ? _value.uploadedByUsername
          : uploadedByUsername // ignore: cast_nullable_to_non_nullable
              as String?,
      isPublic: null == isPublic
          ? _value.isPublic
          : isPublic // ignore: cast_nullable_to_non_nullable
              as bool,
      isFeatured: null == isFeatured
          ? _value.isFeatured
          : isFeatured // ignore: cast_nullable_to_non_nullable
              as bool,
      viewCount: null == viewCount
          ? _value.viewCount
          : viewCount // ignore: cast_nullable_to_non_nullable
              as int,
      likeCount: null == likeCount
          ? _value.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int,
      shareCount: null == shareCount
          ? _value.shareCount
          : shareCount // ignore: cast_nullable_to_non_nullable
              as int,
      isLikedByCurrentUser: freezed == isLikedByCurrentUser
          ? _value.isLikedByCurrentUser
          : isLikedByCurrentUser // ignore: cast_nullable_to_non_nullable
              as bool?,
      isBookmarkedByCurrentUser: freezed == isBookmarkedByCurrentUser
          ? _value.isBookmarkedByCurrentUser
          : isBookmarkedByCurrentUser // ignore: cast_nullable_to_non_nullable
              as bool?,
      commentCount: freezed == commentCount
          ? _value.commentCount
          : commentCount // ignore: cast_nullable_to_non_nullable
              as int?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      bookmarkedAt: freezed == bookmarkedAt
          ? _value.bookmarkedAt
          : bookmarkedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      likedAt: freezed == likedAt
          ? _value.likedAt
          : likedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<TagModel>,
      contents: null == contents
          ? _value._contents
          : contents // ignore: cast_nullable_to_non_nullable
              as List<PoemContentModel>,
      originalContent: freezed == originalContent
          ? _value.originalContent
          : originalContent // ignore: cast_nullable_to_non_nullable
              as PoemContentModel?,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      excerpt: freezed == excerpt
          ? _value.excerpt
          : excerpt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PoemModelImpl implements _PoemModel {
  const _$PoemModelImpl(
      {required this.publicId,
      required this.poetPublicId,
      required this.poetName,
      this.poetProfileImageUrl,
      this.categoryPublicId,
      this.categoryName,
      required this.poetryType,
      @JsonKey(name: 'poetryTypeName') this.poetryTypeName,
      this.poetryTypeUrduName,
      this.poetryTypeEnglishName,
      required this.contentType,
      this.requiresStructuredParsing,
      this.imageUrl,
      this.thumbnailUrl,
      this.yearWritten,
      this.source,
      this.license,
      this.uploadedByUsername,
      this.isPublic = true,
      this.isFeatured = false,
      this.viewCount = 0,
      this.likeCount = 0,
      this.shareCount = 0,
      this.isLikedByCurrentUser,
      this.isBookmarkedByCurrentUser,
      this.commentCount,
      this.createdAt,
      this.updatedAt,
      this.bookmarkedAt,
      this.likedAt,
      final List<TagModel> tags = const [],
      final List<PoemContentModel> contents = const [],
      this.originalContent,
      this.title,
      this.excerpt})
      : _tags = tags,
        _contents = contents;

  factory _$PoemModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PoemModelImplFromJson(json);

  @override
  final String publicId;
  @override
  final String poetPublicId;
  @override
  final String poetName;
  @override
  final String? poetProfileImageUrl;
  @override
  final String? categoryPublicId;
  @override
  final String? categoryName;
  @override
  final String poetryType;
  @override
  @JsonKey(name: 'poetryTypeName')
  final String? poetryTypeName;
  @override
  final String? poetryTypeUrduName;
  @override
  final String? poetryTypeEnglishName;
  @override
  final String contentType;
  @override
  final bool? requiresStructuredParsing;
  @override
  final String? imageUrl;
  @override
  final String? thumbnailUrl;
  @override
  final int? yearWritten;
  @override
  final String? source;
  @override
  final String? license;
  @override
  final String? uploadedByUsername;
  @override
  @JsonKey()
  final bool isPublic;
  @override
  @JsonKey()
  final bool isFeatured;
  @override
  @JsonKey()
  final int viewCount;
  @override
  @JsonKey()
  final int likeCount;
  @override
  @JsonKey()
  final int shareCount;
  @override
  final bool? isLikedByCurrentUser;
  @override
  final bool? isBookmarkedByCurrentUser;
  @override
  final int? commentCount;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  @override
  final DateTime? bookmarkedAt;
  @override
  final DateTime? likedAt;
  final List<TagModel> _tags;
  @override
  @JsonKey()
  List<TagModel> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  final List<PoemContentModel> _contents;
  @override
  @JsonKey()
  List<PoemContentModel> get contents {
    if (_contents is EqualUnmodifiableListView) return _contents;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_contents);
  }

  @override
  final PoemContentModel? originalContent;
// Simple list API fields (for backward compatibility)
  @override
  final String? title;
  @override
  final String? excerpt;

  @override
  String toString() {
    return 'PoemModel(publicId: $publicId, poetPublicId: $poetPublicId, poetName: $poetName, poetProfileImageUrl: $poetProfileImageUrl, categoryPublicId: $categoryPublicId, categoryName: $categoryName, poetryType: $poetryType, poetryTypeName: $poetryTypeName, poetryTypeUrduName: $poetryTypeUrduName, poetryTypeEnglishName: $poetryTypeEnglishName, contentType: $contentType, requiresStructuredParsing: $requiresStructuredParsing, imageUrl: $imageUrl, thumbnailUrl: $thumbnailUrl, yearWritten: $yearWritten, source: $source, license: $license, uploadedByUsername: $uploadedByUsername, isPublic: $isPublic, isFeatured: $isFeatured, viewCount: $viewCount, likeCount: $likeCount, shareCount: $shareCount, isLikedByCurrentUser: $isLikedByCurrentUser, isBookmarkedByCurrentUser: $isBookmarkedByCurrentUser, commentCount: $commentCount, createdAt: $createdAt, updatedAt: $updatedAt, bookmarkedAt: $bookmarkedAt, likedAt: $likedAt, tags: $tags, contents: $contents, originalContent: $originalContent, title: $title, excerpt: $excerpt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PoemModelImpl &&
            (identical(other.publicId, publicId) ||
                other.publicId == publicId) &&
            (identical(other.poetPublicId, poetPublicId) ||
                other.poetPublicId == poetPublicId) &&
            (identical(other.poetName, poetName) ||
                other.poetName == poetName) &&
            (identical(other.poetProfileImageUrl, poetProfileImageUrl) ||
                other.poetProfileImageUrl == poetProfileImageUrl) &&
            (identical(other.categoryPublicId, categoryPublicId) ||
                other.categoryPublicId == categoryPublicId) &&
            (identical(other.categoryName, categoryName) ||
                other.categoryName == categoryName) &&
            (identical(other.poetryType, poetryType) ||
                other.poetryType == poetryType) &&
            (identical(other.poetryTypeName, poetryTypeName) ||
                other.poetryTypeName == poetryTypeName) &&
            (identical(other.poetryTypeUrduName, poetryTypeUrduName) ||
                other.poetryTypeUrduName == poetryTypeUrduName) &&
            (identical(other.poetryTypeEnglishName, poetryTypeEnglishName) ||
                other.poetryTypeEnglishName == poetryTypeEnglishName) &&
            (identical(other.contentType, contentType) ||
                other.contentType == contentType) &&
            (identical(other.requiresStructuredParsing,
                    requiresStructuredParsing) ||
                other.requiresStructuredParsing == requiresStructuredParsing) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            (identical(other.yearWritten, yearWritten) ||
                other.yearWritten == yearWritten) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.license, license) || other.license == license) &&
            (identical(other.uploadedByUsername, uploadedByUsername) ||
                other.uploadedByUsername == uploadedByUsername) &&
            (identical(other.isPublic, isPublic) ||
                other.isPublic == isPublic) &&
            (identical(other.isFeatured, isFeatured) ||
                other.isFeatured == isFeatured) &&
            (identical(other.viewCount, viewCount) ||
                other.viewCount == viewCount) &&
            (identical(other.likeCount, likeCount) ||
                other.likeCount == likeCount) &&
            (identical(other.shareCount, shareCount) ||
                other.shareCount == shareCount) &&
            (identical(other.isLikedByCurrentUser, isLikedByCurrentUser) ||
                other.isLikedByCurrentUser == isLikedByCurrentUser) &&
            (identical(other.isBookmarkedByCurrentUser,
                    isBookmarkedByCurrentUser) ||
                other.isBookmarkedByCurrentUser == isBookmarkedByCurrentUser) &&
            (identical(other.commentCount, commentCount) ||
                other.commentCount == commentCount) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.bookmarkedAt, bookmarkedAt) ||
                other.bookmarkedAt == bookmarkedAt) &&
            (identical(other.likedAt, likedAt) || other.likedAt == likedAt) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            const DeepCollectionEquality().equals(other._contents, _contents) &&
            (identical(other.originalContent, originalContent) ||
                other.originalContent == originalContent) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.excerpt, excerpt) || other.excerpt == excerpt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        publicId,
        poetPublicId,
        poetName,
        poetProfileImageUrl,
        categoryPublicId,
        categoryName,
        poetryType,
        poetryTypeName,
        poetryTypeUrduName,
        poetryTypeEnglishName,
        contentType,
        requiresStructuredParsing,
        imageUrl,
        thumbnailUrl,
        yearWritten,
        source,
        license,
        uploadedByUsername,
        isPublic,
        isFeatured,
        viewCount,
        likeCount,
        shareCount,
        isLikedByCurrentUser,
        isBookmarkedByCurrentUser,
        commentCount,
        createdAt,
        updatedAt,
        bookmarkedAt,
        likedAt,
        const DeepCollectionEquality().hash(_tags),
        const DeepCollectionEquality().hash(_contents),
        originalContent,
        title,
        excerpt
      ]);

  /// Create a copy of PoemModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PoemModelImplCopyWith<_$PoemModelImpl> get copyWith =>
      __$$PoemModelImplCopyWithImpl<_$PoemModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PoemModelImplToJson(
      this,
    );
  }
}

abstract class _PoemModel implements PoemModel {
  const factory _PoemModel(
      {required final String publicId,
      required final String poetPublicId,
      required final String poetName,
      final String? poetProfileImageUrl,
      final String? categoryPublicId,
      final String? categoryName,
      required final String poetryType,
      @JsonKey(name: 'poetryTypeName') final String? poetryTypeName,
      final String? poetryTypeUrduName,
      final String? poetryTypeEnglishName,
      required final String contentType,
      final bool? requiresStructuredParsing,
      final String? imageUrl,
      final String? thumbnailUrl,
      final int? yearWritten,
      final String? source,
      final String? license,
      final String? uploadedByUsername,
      final bool isPublic,
      final bool isFeatured,
      final int viewCount,
      final int likeCount,
      final int shareCount,
      final bool? isLikedByCurrentUser,
      final bool? isBookmarkedByCurrentUser,
      final int? commentCount,
      final DateTime? createdAt,
      final DateTime? updatedAt,
      final DateTime? bookmarkedAt,
      final DateTime? likedAt,
      final List<TagModel> tags,
      final List<PoemContentModel> contents,
      final PoemContentModel? originalContent,
      final String? title,
      final String? excerpt}) = _$PoemModelImpl;

  factory _PoemModel.fromJson(Map<String, dynamic> json) =
      _$PoemModelImpl.fromJson;

  @override
  String get publicId;
  @override
  String get poetPublicId;
  @override
  String get poetName;
  @override
  String? get poetProfileImageUrl;
  @override
  String? get categoryPublicId;
  @override
  String? get categoryName;
  @override
  String get poetryType;
  @override
  @JsonKey(name: 'poetryTypeName')
  String? get poetryTypeName;
  @override
  String? get poetryTypeUrduName;
  @override
  String? get poetryTypeEnglishName;
  @override
  String get contentType;
  @override
  bool? get requiresStructuredParsing;
  @override
  String? get imageUrl;
  @override
  String? get thumbnailUrl;
  @override
  int? get yearWritten;
  @override
  String? get source;
  @override
  String? get license;
  @override
  String? get uploadedByUsername;
  @override
  bool get isPublic;
  @override
  bool get isFeatured;
  @override
  int get viewCount;
  @override
  int get likeCount;
  @override
  int get shareCount;
  @override
  bool? get isLikedByCurrentUser;
  @override
  bool? get isBookmarkedByCurrentUser;
  @override
  int? get commentCount;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  DateTime? get bookmarkedAt;
  @override
  DateTime? get likedAt;
  @override
  List<TagModel> get tags;
  @override
  List<PoemContentModel> get contents;
  @override
  PoemContentModel?
      get originalContent; // Simple list API fields (for backward compatibility)
  @override
  String? get title;
  @override
  String? get excerpt;

  /// Create a copy of PoemModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PoemModelImplCopyWith<_$PoemModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PoemContentModel _$PoemContentModelFromJson(Map<String, dynamic> json) {
  return _PoemContentModel.fromJson(json);
}

/// @nodoc
mixin _$PoemContentModel {
  String get publicId => throw _privateConstructorUsedError;
  String get languageCode => throw _privateConstructorUsedError;
  String get languageName => throw _privateConstructorUsedError;
  String get languageNativeName => throw _privateConstructorUsedError;
  String get script => throw _privateConstructorUsedError;
  String? get scriptUrduName => throw _privateConstructorUsedError;
  String? get scriptEnglishName => throw _privateConstructorUsedError;
  String? get scriptDirection => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get fullText => throw _privateConstructorUsedError;
  bool get isOriginal => throw _privateConstructorUsedError;
  String? get translatedBy => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  List<VerseModel> get verses => throw _privateConstructorUsedError;
  int get totalVerses => throw _privateConstructorUsedError;
  int get totalCouplets => throw _privateConstructorUsedError;

  /// Serializes this PoemContentModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PoemContentModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PoemContentModelCopyWith<PoemContentModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PoemContentModelCopyWith<$Res> {
  factory $PoemContentModelCopyWith(
          PoemContentModel value, $Res Function(PoemContentModel) then) =
      _$PoemContentModelCopyWithImpl<$Res, PoemContentModel>;
  @useResult
  $Res call(
      {String publicId,
      String languageCode,
      String languageName,
      String languageNativeName,
      String script,
      String? scriptUrduName,
      String? scriptEnglishName,
      String? scriptDirection,
      String title,
      String fullText,
      bool isOriginal,
      String? translatedBy,
      String? notes,
      List<VerseModel> verses,
      int totalVerses,
      int totalCouplets});
}

/// @nodoc
class _$PoemContentModelCopyWithImpl<$Res, $Val extends PoemContentModel>
    implements $PoemContentModelCopyWith<$Res> {
  _$PoemContentModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PoemContentModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? publicId = null,
    Object? languageCode = null,
    Object? languageName = null,
    Object? languageNativeName = null,
    Object? script = null,
    Object? scriptUrduName = freezed,
    Object? scriptEnglishName = freezed,
    Object? scriptDirection = freezed,
    Object? title = null,
    Object? fullText = null,
    Object? isOriginal = null,
    Object? translatedBy = freezed,
    Object? notes = freezed,
    Object? verses = null,
    Object? totalVerses = null,
    Object? totalCouplets = null,
  }) {
    return _then(_value.copyWith(
      publicId: null == publicId
          ? _value.publicId
          : publicId // ignore: cast_nullable_to_non_nullable
              as String,
      languageCode: null == languageCode
          ? _value.languageCode
          : languageCode // ignore: cast_nullable_to_non_nullable
              as String,
      languageName: null == languageName
          ? _value.languageName
          : languageName // ignore: cast_nullable_to_non_nullable
              as String,
      languageNativeName: null == languageNativeName
          ? _value.languageNativeName
          : languageNativeName // ignore: cast_nullable_to_non_nullable
              as String,
      script: null == script
          ? _value.script
          : script // ignore: cast_nullable_to_non_nullable
              as String,
      scriptUrduName: freezed == scriptUrduName
          ? _value.scriptUrduName
          : scriptUrduName // ignore: cast_nullable_to_non_nullable
              as String?,
      scriptEnglishName: freezed == scriptEnglishName
          ? _value.scriptEnglishName
          : scriptEnglishName // ignore: cast_nullable_to_non_nullable
              as String?,
      scriptDirection: freezed == scriptDirection
          ? _value.scriptDirection
          : scriptDirection // ignore: cast_nullable_to_non_nullable
              as String?,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      fullText: null == fullText
          ? _value.fullText
          : fullText // ignore: cast_nullable_to_non_nullable
              as String,
      isOriginal: null == isOriginal
          ? _value.isOriginal
          : isOriginal // ignore: cast_nullable_to_non_nullable
              as bool,
      translatedBy: freezed == translatedBy
          ? _value.translatedBy
          : translatedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      verses: null == verses
          ? _value.verses
          : verses // ignore: cast_nullable_to_non_nullable
              as List<VerseModel>,
      totalVerses: null == totalVerses
          ? _value.totalVerses
          : totalVerses // ignore: cast_nullable_to_non_nullable
              as int,
      totalCouplets: null == totalCouplets
          ? _value.totalCouplets
          : totalCouplets // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PoemContentModelImplCopyWith<$Res>
    implements $PoemContentModelCopyWith<$Res> {
  factory _$$PoemContentModelImplCopyWith(_$PoemContentModelImpl value,
          $Res Function(_$PoemContentModelImpl) then) =
      __$$PoemContentModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String publicId,
      String languageCode,
      String languageName,
      String languageNativeName,
      String script,
      String? scriptUrduName,
      String? scriptEnglishName,
      String? scriptDirection,
      String title,
      String fullText,
      bool isOriginal,
      String? translatedBy,
      String? notes,
      List<VerseModel> verses,
      int totalVerses,
      int totalCouplets});
}

/// @nodoc
class __$$PoemContentModelImplCopyWithImpl<$Res>
    extends _$PoemContentModelCopyWithImpl<$Res, _$PoemContentModelImpl>
    implements _$$PoemContentModelImplCopyWith<$Res> {
  __$$PoemContentModelImplCopyWithImpl(_$PoemContentModelImpl _value,
      $Res Function(_$PoemContentModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of PoemContentModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? publicId = null,
    Object? languageCode = null,
    Object? languageName = null,
    Object? languageNativeName = null,
    Object? script = null,
    Object? scriptUrduName = freezed,
    Object? scriptEnglishName = freezed,
    Object? scriptDirection = freezed,
    Object? title = null,
    Object? fullText = null,
    Object? isOriginal = null,
    Object? translatedBy = freezed,
    Object? notes = freezed,
    Object? verses = null,
    Object? totalVerses = null,
    Object? totalCouplets = null,
  }) {
    return _then(_$PoemContentModelImpl(
      publicId: null == publicId
          ? _value.publicId
          : publicId // ignore: cast_nullable_to_non_nullable
              as String,
      languageCode: null == languageCode
          ? _value.languageCode
          : languageCode // ignore: cast_nullable_to_non_nullable
              as String,
      languageName: null == languageName
          ? _value.languageName
          : languageName // ignore: cast_nullable_to_non_nullable
              as String,
      languageNativeName: null == languageNativeName
          ? _value.languageNativeName
          : languageNativeName // ignore: cast_nullable_to_non_nullable
              as String,
      script: null == script
          ? _value.script
          : script // ignore: cast_nullable_to_non_nullable
              as String,
      scriptUrduName: freezed == scriptUrduName
          ? _value.scriptUrduName
          : scriptUrduName // ignore: cast_nullable_to_non_nullable
              as String?,
      scriptEnglishName: freezed == scriptEnglishName
          ? _value.scriptEnglishName
          : scriptEnglishName // ignore: cast_nullable_to_non_nullable
              as String?,
      scriptDirection: freezed == scriptDirection
          ? _value.scriptDirection
          : scriptDirection // ignore: cast_nullable_to_non_nullable
              as String?,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      fullText: null == fullText
          ? _value.fullText
          : fullText // ignore: cast_nullable_to_non_nullable
              as String,
      isOriginal: null == isOriginal
          ? _value.isOriginal
          : isOriginal // ignore: cast_nullable_to_non_nullable
              as bool,
      translatedBy: freezed == translatedBy
          ? _value.translatedBy
          : translatedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      verses: null == verses
          ? _value._verses
          : verses // ignore: cast_nullable_to_non_nullable
              as List<VerseModel>,
      totalVerses: null == totalVerses
          ? _value.totalVerses
          : totalVerses // ignore: cast_nullable_to_non_nullable
              as int,
      totalCouplets: null == totalCouplets
          ? _value.totalCouplets
          : totalCouplets // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PoemContentModelImpl implements _PoemContentModel {
  const _$PoemContentModelImpl(
      {required this.publicId,
      required this.languageCode,
      required this.languageName,
      required this.languageNativeName,
      required this.script,
      this.scriptUrduName,
      this.scriptEnglishName,
      this.scriptDirection,
      required this.title,
      required this.fullText,
      this.isOriginal = true,
      this.translatedBy,
      this.notes,
      final List<VerseModel> verses = const [],
      this.totalVerses = 0,
      this.totalCouplets = 0})
      : _verses = verses;

  factory _$PoemContentModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PoemContentModelImplFromJson(json);

  @override
  final String publicId;
  @override
  final String languageCode;
  @override
  final String languageName;
  @override
  final String languageNativeName;
  @override
  final String script;
  @override
  final String? scriptUrduName;
  @override
  final String? scriptEnglishName;
  @override
  final String? scriptDirection;
  @override
  final String title;
  @override
  final String fullText;
  @override
  @JsonKey()
  final bool isOriginal;
  @override
  final String? translatedBy;
  @override
  final String? notes;
  final List<VerseModel> _verses;
  @override
  @JsonKey()
  List<VerseModel> get verses {
    if (_verses is EqualUnmodifiableListView) return _verses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_verses);
  }

  @override
  @JsonKey()
  final int totalVerses;
  @override
  @JsonKey()
  final int totalCouplets;

  @override
  String toString() {
    return 'PoemContentModel(publicId: $publicId, languageCode: $languageCode, languageName: $languageName, languageNativeName: $languageNativeName, script: $script, scriptUrduName: $scriptUrduName, scriptEnglishName: $scriptEnglishName, scriptDirection: $scriptDirection, title: $title, fullText: $fullText, isOriginal: $isOriginal, translatedBy: $translatedBy, notes: $notes, verses: $verses, totalVerses: $totalVerses, totalCouplets: $totalCouplets)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PoemContentModelImpl &&
            (identical(other.publicId, publicId) ||
                other.publicId == publicId) &&
            (identical(other.languageCode, languageCode) ||
                other.languageCode == languageCode) &&
            (identical(other.languageName, languageName) ||
                other.languageName == languageName) &&
            (identical(other.languageNativeName, languageNativeName) ||
                other.languageNativeName == languageNativeName) &&
            (identical(other.script, script) || other.script == script) &&
            (identical(other.scriptUrduName, scriptUrduName) ||
                other.scriptUrduName == scriptUrduName) &&
            (identical(other.scriptEnglishName, scriptEnglishName) ||
                other.scriptEnglishName == scriptEnglishName) &&
            (identical(other.scriptDirection, scriptDirection) ||
                other.scriptDirection == scriptDirection) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.fullText, fullText) ||
                other.fullText == fullText) &&
            (identical(other.isOriginal, isOriginal) ||
                other.isOriginal == isOriginal) &&
            (identical(other.translatedBy, translatedBy) ||
                other.translatedBy == translatedBy) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            const DeepCollectionEquality().equals(other._verses, _verses) &&
            (identical(other.totalVerses, totalVerses) ||
                other.totalVerses == totalVerses) &&
            (identical(other.totalCouplets, totalCouplets) ||
                other.totalCouplets == totalCouplets));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      publicId,
      languageCode,
      languageName,
      languageNativeName,
      script,
      scriptUrduName,
      scriptEnglishName,
      scriptDirection,
      title,
      fullText,
      isOriginal,
      translatedBy,
      notes,
      const DeepCollectionEquality().hash(_verses),
      totalVerses,
      totalCouplets);

  /// Create a copy of PoemContentModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PoemContentModelImplCopyWith<_$PoemContentModelImpl> get copyWith =>
      __$$PoemContentModelImplCopyWithImpl<_$PoemContentModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PoemContentModelImplToJson(
      this,
    );
  }
}

abstract class _PoemContentModel implements PoemContentModel {
  const factory _PoemContentModel(
      {required final String publicId,
      required final String languageCode,
      required final String languageName,
      required final String languageNativeName,
      required final String script,
      final String? scriptUrduName,
      final String? scriptEnglishName,
      final String? scriptDirection,
      required final String title,
      required final String fullText,
      final bool isOriginal,
      final String? translatedBy,
      final String? notes,
      final List<VerseModel> verses,
      final int totalVerses,
      final int totalCouplets}) = _$PoemContentModelImpl;

  factory _PoemContentModel.fromJson(Map<String, dynamic> json) =
      _$PoemContentModelImpl.fromJson;

  @override
  String get publicId;
  @override
  String get languageCode;
  @override
  String get languageName;
  @override
  String get languageNativeName;
  @override
  String get script;
  @override
  String? get scriptUrduName;
  @override
  String? get scriptEnglishName;
  @override
  String? get scriptDirection;
  @override
  String get title;
  @override
  String get fullText;
  @override
  bool get isOriginal;
  @override
  String? get translatedBy;
  @override
  String? get notes;
  @override
  List<VerseModel> get verses;
  @override
  int get totalVerses;
  @override
  int get totalCouplets;

  /// Create a copy of PoemContentModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PoemContentModelImplCopyWith<_$PoemContentModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TagModel _$TagModelFromJson(Map<String, dynamic> json) {
  return _TagModel.fromJson(json);
}

/// @nodoc
mixin _$TagModel {
  String get publicId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get slug => throw _privateConstructorUsedError;
  String? get color => throw _privateConstructorUsedError;
  String get tagType => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;

  /// Serializes this TagModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TagModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TagModelCopyWith<TagModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TagModelCopyWith<$Res> {
  factory $TagModelCopyWith(TagModel value, $Res Function(TagModel) then) =
      _$TagModelCopyWithImpl<$Res, TagModel>;
  @useResult
  $Res call(
      {String publicId,
      String name,
      String slug,
      String? color,
      String tagType,
      String? description});
}

/// @nodoc
class _$TagModelCopyWithImpl<$Res, $Val extends TagModel>
    implements $TagModelCopyWith<$Res> {
  _$TagModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TagModel
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
abstract class _$$TagModelImplCopyWith<$Res>
    implements $TagModelCopyWith<$Res> {
  factory _$$TagModelImplCopyWith(
          _$TagModelImpl value, $Res Function(_$TagModelImpl) then) =
      __$$TagModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String publicId,
      String name,
      String slug,
      String? color,
      String tagType,
      String? description});
}

/// @nodoc
class __$$TagModelImplCopyWithImpl<$Res>
    extends _$TagModelCopyWithImpl<$Res, _$TagModelImpl>
    implements _$$TagModelImplCopyWith<$Res> {
  __$$TagModelImplCopyWithImpl(
      _$TagModelImpl _value, $Res Function(_$TagModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of TagModel
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
    return _then(_$TagModelImpl(
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
class _$TagModelImpl implements _TagModel {
  const _$TagModelImpl(
      {required this.publicId,
      required this.name,
      required this.slug,
      this.color,
      required this.tagType,
      this.description});

  factory _$TagModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TagModelImplFromJson(json);

  @override
  final String publicId;
  @override
  final String name;
  @override
  final String slug;
  @override
  final String? color;
  @override
  final String tagType;
  @override
  final String? description;

  @override
  String toString() {
    return 'TagModel(publicId: $publicId, name: $name, slug: $slug, color: $color, tagType: $tagType, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TagModelImpl &&
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

  /// Create a copy of TagModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TagModelImplCopyWith<_$TagModelImpl> get copyWith =>
      __$$TagModelImplCopyWithImpl<_$TagModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TagModelImplToJson(
      this,
    );
  }
}

abstract class _TagModel implements TagModel {
  const factory _TagModel(
      {required final String publicId,
      required final String name,
      required final String slug,
      final String? color,
      required final String tagType,
      final String? description}) = _$TagModelImpl;

  factory _TagModel.fromJson(Map<String, dynamic> json) =
      _$TagModelImpl.fromJson;

  @override
  String get publicId;
  @override
  String get name;
  @override
  String get slug;
  @override
  String? get color;
  @override
  String get tagType;
  @override
  String? get description;

  /// Create a copy of TagModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TagModelImplCopyWith<_$TagModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

VerseModel _$VerseModelFromJson(Map<String, dynamic> json) {
  return _VerseModel.fromJson(json);
}

/// @nodoc
mixin _$VerseModel {
  String get publicId => throw _privateConstructorUsedError;
  @JsonKey(name: 'verseText')
  String get text => throw _privateConstructorUsedError;
  String? get verseType => throw _privateConstructorUsedError;
  int? get verseNumber => throw _privateConstructorUsedError;

  /// Serializes this VerseModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VerseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VerseModelCopyWith<VerseModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VerseModelCopyWith<$Res> {
  factory $VerseModelCopyWith(
          VerseModel value, $Res Function(VerseModel) then) =
      _$VerseModelCopyWithImpl<$Res, VerseModel>;
  @useResult
  $Res call(
      {String publicId,
      @JsonKey(name: 'verseText') String text,
      String? verseType,
      int? verseNumber});
}

/// @nodoc
class _$VerseModelCopyWithImpl<$Res, $Val extends VerseModel>
    implements $VerseModelCopyWith<$Res> {
  _$VerseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VerseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? publicId = null,
    Object? text = null,
    Object? verseType = freezed,
    Object? verseNumber = freezed,
  }) {
    return _then(_value.copyWith(
      publicId: null == publicId
          ? _value.publicId
          : publicId // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      verseType: freezed == verseType
          ? _value.verseType
          : verseType // ignore: cast_nullable_to_non_nullable
              as String?,
      verseNumber: freezed == verseNumber
          ? _value.verseNumber
          : verseNumber // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VerseModelImplCopyWith<$Res>
    implements $VerseModelCopyWith<$Res> {
  factory _$$VerseModelImplCopyWith(
          _$VerseModelImpl value, $Res Function(_$VerseModelImpl) then) =
      __$$VerseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String publicId,
      @JsonKey(name: 'verseText') String text,
      String? verseType,
      int? verseNumber});
}

/// @nodoc
class __$$VerseModelImplCopyWithImpl<$Res>
    extends _$VerseModelCopyWithImpl<$Res, _$VerseModelImpl>
    implements _$$VerseModelImplCopyWith<$Res> {
  __$$VerseModelImplCopyWithImpl(
      _$VerseModelImpl _value, $Res Function(_$VerseModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of VerseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? publicId = null,
    Object? text = null,
    Object? verseType = freezed,
    Object? verseNumber = freezed,
  }) {
    return _then(_$VerseModelImpl(
      publicId: null == publicId
          ? _value.publicId
          : publicId // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      verseType: freezed == verseType
          ? _value.verseType
          : verseType // ignore: cast_nullable_to_non_nullable
              as String?,
      verseNumber: freezed == verseNumber
          ? _value.verseNumber
          : verseNumber // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VerseModelImpl implements _VerseModel {
  const _$VerseModelImpl(
      {required this.publicId,
      @JsonKey(name: 'verseText') required this.text,
      this.verseType,
      this.verseNumber});

  factory _$VerseModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$VerseModelImplFromJson(json);

  @override
  final String publicId;
  @override
  @JsonKey(name: 'verseText')
  final String text;
  @override
  final String? verseType;
  @override
  final int? verseNumber;

  @override
  String toString() {
    return 'VerseModel(publicId: $publicId, text: $text, verseType: $verseType, verseNumber: $verseNumber)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VerseModelImpl &&
            (identical(other.publicId, publicId) ||
                other.publicId == publicId) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.verseType, verseType) ||
                other.verseType == verseType) &&
            (identical(other.verseNumber, verseNumber) ||
                other.verseNumber == verseNumber));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, publicId, text, verseType, verseNumber);

  /// Create a copy of VerseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VerseModelImplCopyWith<_$VerseModelImpl> get copyWith =>
      __$$VerseModelImplCopyWithImpl<_$VerseModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VerseModelImplToJson(
      this,
    );
  }
}

abstract class _VerseModel implements VerseModel {
  const factory _VerseModel(
      {required final String publicId,
      @JsonKey(name: 'verseText') required final String text,
      final String? verseType,
      final int? verseNumber}) = _$VerseModelImpl;

  factory _VerseModel.fromJson(Map<String, dynamic> json) =
      _$VerseModelImpl.fromJson;

  @override
  String get publicId;
  @override
  @JsonKey(name: 'verseText')
  String get text;
  @override
  String? get verseType;
  @override
  int? get verseNumber;

  /// Create a copy of VerseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VerseModelImplCopyWith<_$VerseModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
