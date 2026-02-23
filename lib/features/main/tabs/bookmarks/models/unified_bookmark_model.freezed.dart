// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'unified_bookmark_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$UnifiedBookmark {
  String get bookmarkId => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError; // POEM, COUPLET, IMAGE
  String get contentId => throw _privateConstructorUsedError;
  String get languageCode => throw _privateConstructorUsedError;
  DateTime get bookmarkedAt => throw _privateConstructorUsedError;
  String? get notes =>
      throw _privateConstructorUsedError; // POEM + COUPLET shared fields
  String? get poetName => throw _privateConstructorUsedError;
  String? get poetId => throw _privateConstructorUsedError;
  String? get poetProfileImageUrl =>
      throw _privateConstructorUsedError; // 36x36 poet avatar thumbnail
  String? get contentSubType =>
      throw _privateConstructorUsedError; // e.g. "GHAZAL", "NAZM"
  String? get contentSubTypeUrdu =>
      throw _privateConstructorUsedError; // e.g. "غزل", "نظم"
// POEM fields
  String? get poemTitle => throw _privateConstructorUsedError; // COUPLET fields
  @JsonKey(name: 'coupletFirstVerse')
  String? get coupletVerse1 => throw _privateConstructorUsedError;
  @JsonKey(name: 'coupletSecondVerse')
  String? get coupletVerse2 => throw _privateConstructorUsedError;
  @JsonKey(name: 'parentPoemTitle')
  String? get coupletPoemTitle => throw _privateConstructorUsedError;
  @JsonKey(name: 'parentPoemId')
  String? get coupletPoemPublicId =>
      throw _privateConstructorUsedError; // IMAGE fields
  String? get imageUrl => throw _privateConstructorUsedError;
  String? get thumbnailUrl => throw _privateConstructorUsedError;
  String? get templateName =>
      throw _privateConstructorUsedError; // Engagement metrics
  int get likeCount => throw _privateConstructorUsedError;
  int? get bookmarkCount => throw _privateConstructorUsedError;
  int get shareCount => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $UnifiedBookmarkCopyWith<UnifiedBookmark> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UnifiedBookmarkCopyWith<$Res> {
  factory $UnifiedBookmarkCopyWith(
          UnifiedBookmark value, $Res Function(UnifiedBookmark) then) =
      _$UnifiedBookmarkCopyWithImpl<$Res, UnifiedBookmark>;
  @useResult
  $Res call(
      {String bookmarkId,
      String type,
      String contentId,
      String languageCode,
      DateTime bookmarkedAt,
      String? notes,
      String? poetName,
      String? poetId,
      String? poetProfileImageUrl,
      String? contentSubType,
      String? contentSubTypeUrdu,
      String? poemTitle,
      @JsonKey(name: 'coupletFirstVerse') String? coupletVerse1,
      @JsonKey(name: 'coupletSecondVerse') String? coupletVerse2,
      @JsonKey(name: 'parentPoemTitle') String? coupletPoemTitle,
      @JsonKey(name: 'parentPoemId') String? coupletPoemPublicId,
      String? imageUrl,
      String? thumbnailUrl,
      String? templateName,
      int likeCount,
      int? bookmarkCount,
      int shareCount});
}

/// @nodoc
class _$UnifiedBookmarkCopyWithImpl<$Res, $Val extends UnifiedBookmark>
    implements $UnifiedBookmarkCopyWith<$Res> {
  _$UnifiedBookmarkCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bookmarkId = null,
    Object? type = null,
    Object? contentId = null,
    Object? languageCode = null,
    Object? bookmarkedAt = null,
    Object? notes = freezed,
    Object? poetName = freezed,
    Object? poetId = freezed,
    Object? poetProfileImageUrl = freezed,
    Object? contentSubType = freezed,
    Object? contentSubTypeUrdu = freezed,
    Object? poemTitle = freezed,
    Object? coupletVerse1 = freezed,
    Object? coupletVerse2 = freezed,
    Object? coupletPoemTitle = freezed,
    Object? coupletPoemPublicId = freezed,
    Object? imageUrl = freezed,
    Object? thumbnailUrl = freezed,
    Object? templateName = freezed,
    Object? likeCount = null,
    Object? bookmarkCount = freezed,
    Object? shareCount = null,
  }) {
    return _then(_value.copyWith(
      bookmarkId: null == bookmarkId
          ? _value.bookmarkId
          : bookmarkId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      contentId: null == contentId
          ? _value.contentId
          : contentId // ignore: cast_nullable_to_non_nullable
              as String,
      languageCode: null == languageCode
          ? _value.languageCode
          : languageCode // ignore: cast_nullable_to_non_nullable
              as String,
      bookmarkedAt: null == bookmarkedAt
          ? _value.bookmarkedAt
          : bookmarkedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      poetName: freezed == poetName
          ? _value.poetName
          : poetName // ignore: cast_nullable_to_non_nullable
              as String?,
      poetId: freezed == poetId
          ? _value.poetId
          : poetId // ignore: cast_nullable_to_non_nullable
              as String?,
      poetProfileImageUrl: freezed == poetProfileImageUrl
          ? _value.poetProfileImageUrl
          : poetProfileImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      contentSubType: freezed == contentSubType
          ? _value.contentSubType
          : contentSubType // ignore: cast_nullable_to_non_nullable
              as String?,
      contentSubTypeUrdu: freezed == contentSubTypeUrdu
          ? _value.contentSubTypeUrdu
          : contentSubTypeUrdu // ignore: cast_nullable_to_non_nullable
              as String?,
      poemTitle: freezed == poemTitle
          ? _value.poemTitle
          : poemTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      coupletVerse1: freezed == coupletVerse1
          ? _value.coupletVerse1
          : coupletVerse1 // ignore: cast_nullable_to_non_nullable
              as String?,
      coupletVerse2: freezed == coupletVerse2
          ? _value.coupletVerse2
          : coupletVerse2 // ignore: cast_nullable_to_non_nullable
              as String?,
      coupletPoemTitle: freezed == coupletPoemTitle
          ? _value.coupletPoemTitle
          : coupletPoemTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      coupletPoemPublicId: freezed == coupletPoemPublicId
          ? _value.coupletPoemPublicId
          : coupletPoemPublicId // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      thumbnailUrl: freezed == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      templateName: freezed == templateName
          ? _value.templateName
          : templateName // ignore: cast_nullable_to_non_nullable
              as String?,
      likeCount: null == likeCount
          ? _value.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int,
      bookmarkCount: freezed == bookmarkCount
          ? _value.bookmarkCount
          : bookmarkCount // ignore: cast_nullable_to_non_nullable
              as int?,
      shareCount: null == shareCount
          ? _value.shareCount
          : shareCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UnifiedBookmarkImplCopyWith<$Res>
    implements $UnifiedBookmarkCopyWith<$Res> {
  factory _$$UnifiedBookmarkImplCopyWith(_$UnifiedBookmarkImpl value,
          $Res Function(_$UnifiedBookmarkImpl) then) =
      __$$UnifiedBookmarkImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String bookmarkId,
      String type,
      String contentId,
      String languageCode,
      DateTime bookmarkedAt,
      String? notes,
      String? poetName,
      String? poetId,
      String? poetProfileImageUrl,
      String? contentSubType,
      String? contentSubTypeUrdu,
      String? poemTitle,
      @JsonKey(name: 'coupletFirstVerse') String? coupletVerse1,
      @JsonKey(name: 'coupletSecondVerse') String? coupletVerse2,
      @JsonKey(name: 'parentPoemTitle') String? coupletPoemTitle,
      @JsonKey(name: 'parentPoemId') String? coupletPoemPublicId,
      String? imageUrl,
      String? thumbnailUrl,
      String? templateName,
      int likeCount,
      int? bookmarkCount,
      int shareCount});
}

/// @nodoc
class __$$UnifiedBookmarkImplCopyWithImpl<$Res>
    extends _$UnifiedBookmarkCopyWithImpl<$Res, _$UnifiedBookmarkImpl>
    implements _$$UnifiedBookmarkImplCopyWith<$Res> {
  __$$UnifiedBookmarkImplCopyWithImpl(
      _$UnifiedBookmarkImpl _value, $Res Function(_$UnifiedBookmarkImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bookmarkId = null,
    Object? type = null,
    Object? contentId = null,
    Object? languageCode = null,
    Object? bookmarkedAt = null,
    Object? notes = freezed,
    Object? poetName = freezed,
    Object? poetId = freezed,
    Object? poetProfileImageUrl = freezed,
    Object? contentSubType = freezed,
    Object? contentSubTypeUrdu = freezed,
    Object? poemTitle = freezed,
    Object? coupletVerse1 = freezed,
    Object? coupletVerse2 = freezed,
    Object? coupletPoemTitle = freezed,
    Object? coupletPoemPublicId = freezed,
    Object? imageUrl = freezed,
    Object? thumbnailUrl = freezed,
    Object? templateName = freezed,
    Object? likeCount = null,
    Object? bookmarkCount = freezed,
    Object? shareCount = null,
  }) {
    return _then(_$UnifiedBookmarkImpl(
      bookmarkId: null == bookmarkId
          ? _value.bookmarkId
          : bookmarkId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      contentId: null == contentId
          ? _value.contentId
          : contentId // ignore: cast_nullable_to_non_nullable
              as String,
      languageCode: null == languageCode
          ? _value.languageCode
          : languageCode // ignore: cast_nullable_to_non_nullable
              as String,
      bookmarkedAt: null == bookmarkedAt
          ? _value.bookmarkedAt
          : bookmarkedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      poetName: freezed == poetName
          ? _value.poetName
          : poetName // ignore: cast_nullable_to_non_nullable
              as String?,
      poetId: freezed == poetId
          ? _value.poetId
          : poetId // ignore: cast_nullable_to_non_nullable
              as String?,
      poetProfileImageUrl: freezed == poetProfileImageUrl
          ? _value.poetProfileImageUrl
          : poetProfileImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      contentSubType: freezed == contentSubType
          ? _value.contentSubType
          : contentSubType // ignore: cast_nullable_to_non_nullable
              as String?,
      contentSubTypeUrdu: freezed == contentSubTypeUrdu
          ? _value.contentSubTypeUrdu
          : contentSubTypeUrdu // ignore: cast_nullable_to_non_nullable
              as String?,
      poemTitle: freezed == poemTitle
          ? _value.poemTitle
          : poemTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      coupletVerse1: freezed == coupletVerse1
          ? _value.coupletVerse1
          : coupletVerse1 // ignore: cast_nullable_to_non_nullable
              as String?,
      coupletVerse2: freezed == coupletVerse2
          ? _value.coupletVerse2
          : coupletVerse2 // ignore: cast_nullable_to_non_nullable
              as String?,
      coupletPoemTitle: freezed == coupletPoemTitle
          ? _value.coupletPoemTitle
          : coupletPoemTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      coupletPoemPublicId: freezed == coupletPoemPublicId
          ? _value.coupletPoemPublicId
          : coupletPoemPublicId // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      thumbnailUrl: freezed == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      templateName: freezed == templateName
          ? _value.templateName
          : templateName // ignore: cast_nullable_to_non_nullable
              as String?,
      likeCount: null == likeCount
          ? _value.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int,
      bookmarkCount: freezed == bookmarkCount
          ? _value.bookmarkCount
          : bookmarkCount // ignore: cast_nullable_to_non_nullable
              as int?,
      shareCount: null == shareCount
          ? _value.shareCount
          : shareCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$UnifiedBookmarkImpl extends _UnifiedBookmark {
  const _$UnifiedBookmarkImpl(
      {required this.bookmarkId,
      required this.type,
      required this.contentId,
      required this.languageCode,
      required this.bookmarkedAt,
      this.notes,
      this.poetName,
      this.poetId,
      this.poetProfileImageUrl,
      this.contentSubType,
      this.contentSubTypeUrdu,
      this.poemTitle,
      @JsonKey(name: 'coupletFirstVerse') this.coupletVerse1,
      @JsonKey(name: 'coupletSecondVerse') this.coupletVerse2,
      @JsonKey(name: 'parentPoemTitle') this.coupletPoemTitle,
      @JsonKey(name: 'parentPoemId') this.coupletPoemPublicId,
      this.imageUrl,
      this.thumbnailUrl,
      this.templateName,
      this.likeCount = 0,
      this.bookmarkCount,
      this.shareCount = 0})
      : super._();

  @override
  final String bookmarkId;
  @override
  final String type;
// POEM, COUPLET, IMAGE
  @override
  final String contentId;
  @override
  final String languageCode;
  @override
  final DateTime bookmarkedAt;
  @override
  final String? notes;
// POEM + COUPLET shared fields
  @override
  final String? poetName;
  @override
  final String? poetId;
  @override
  final String? poetProfileImageUrl;
// 36x36 poet avatar thumbnail
  @override
  final String? contentSubType;
// e.g. "GHAZAL", "NAZM"
  @override
  final String? contentSubTypeUrdu;
// e.g. "غزل", "نظم"
// POEM fields
  @override
  final String? poemTitle;
// COUPLET fields
  @override
  @JsonKey(name: 'coupletFirstVerse')
  final String? coupletVerse1;
  @override
  @JsonKey(name: 'coupletSecondVerse')
  final String? coupletVerse2;
  @override
  @JsonKey(name: 'parentPoemTitle')
  final String? coupletPoemTitle;
  @override
  @JsonKey(name: 'parentPoemId')
  final String? coupletPoemPublicId;
// IMAGE fields
  @override
  final String? imageUrl;
  @override
  final String? thumbnailUrl;
  @override
  final String? templateName;
// Engagement metrics
  @override
  @JsonKey()
  final int likeCount;
  @override
  final int? bookmarkCount;
  @override
  @JsonKey()
  final int shareCount;

  @override
  String toString() {
    return 'UnifiedBookmark(bookmarkId: $bookmarkId, type: $type, contentId: $contentId, languageCode: $languageCode, bookmarkedAt: $bookmarkedAt, notes: $notes, poetName: $poetName, poetId: $poetId, poetProfileImageUrl: $poetProfileImageUrl, contentSubType: $contentSubType, contentSubTypeUrdu: $contentSubTypeUrdu, poemTitle: $poemTitle, coupletVerse1: $coupletVerse1, coupletVerse2: $coupletVerse2, coupletPoemTitle: $coupletPoemTitle, coupletPoemPublicId: $coupletPoemPublicId, imageUrl: $imageUrl, thumbnailUrl: $thumbnailUrl, templateName: $templateName, likeCount: $likeCount, bookmarkCount: $bookmarkCount, shareCount: $shareCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UnifiedBookmarkImpl &&
            (identical(other.bookmarkId, bookmarkId) ||
                other.bookmarkId == bookmarkId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.contentId, contentId) ||
                other.contentId == contentId) &&
            (identical(other.languageCode, languageCode) ||
                other.languageCode == languageCode) &&
            (identical(other.bookmarkedAt, bookmarkedAt) ||
                other.bookmarkedAt == bookmarkedAt) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.poetName, poetName) ||
                other.poetName == poetName) &&
            (identical(other.poetId, poetId) || other.poetId == poetId) &&
            (identical(other.poetProfileImageUrl, poetProfileImageUrl) ||
                other.poetProfileImageUrl == poetProfileImageUrl) &&
            (identical(other.contentSubType, contentSubType) ||
                other.contentSubType == contentSubType) &&
            (identical(other.contentSubTypeUrdu, contentSubTypeUrdu) ||
                other.contentSubTypeUrdu == contentSubTypeUrdu) &&
            (identical(other.poemTitle, poemTitle) ||
                other.poemTitle == poemTitle) &&
            (identical(other.coupletVerse1, coupletVerse1) ||
                other.coupletVerse1 == coupletVerse1) &&
            (identical(other.coupletVerse2, coupletVerse2) ||
                other.coupletVerse2 == coupletVerse2) &&
            (identical(other.coupletPoemTitle, coupletPoemTitle) ||
                other.coupletPoemTitle == coupletPoemTitle) &&
            (identical(other.coupletPoemPublicId, coupletPoemPublicId) ||
                other.coupletPoemPublicId == coupletPoemPublicId) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            (identical(other.templateName, templateName) ||
                other.templateName == templateName) &&
            (identical(other.likeCount, likeCount) ||
                other.likeCount == likeCount) &&
            (identical(other.bookmarkCount, bookmarkCount) ||
                other.bookmarkCount == bookmarkCount) &&
            (identical(other.shareCount, shareCount) ||
                other.shareCount == shareCount));
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        bookmarkId,
        type,
        contentId,
        languageCode,
        bookmarkedAt,
        notes,
        poetName,
        poetId,
        poetProfileImageUrl,
        contentSubType,
        contentSubTypeUrdu,
        poemTitle,
        coupletVerse1,
        coupletVerse2,
        coupletPoemTitle,
        coupletPoemPublicId,
        imageUrl,
        thumbnailUrl,
        templateName,
        likeCount,
        bookmarkCount,
        shareCount
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UnifiedBookmarkImplCopyWith<_$UnifiedBookmarkImpl> get copyWith =>
      __$$UnifiedBookmarkImplCopyWithImpl<_$UnifiedBookmarkImpl>(
          this, _$identity);
}

abstract class _UnifiedBookmark extends UnifiedBookmark {
  const factory _UnifiedBookmark(
      {required final String bookmarkId,
      required final String type,
      required final String contentId,
      required final String languageCode,
      required final DateTime bookmarkedAt,
      final String? notes,
      final String? poetName,
      final String? poetId,
      final String? poetProfileImageUrl,
      final String? contentSubType,
      final String? contentSubTypeUrdu,
      final String? poemTitle,
      @JsonKey(name: 'coupletFirstVerse') final String? coupletVerse1,
      @JsonKey(name: 'coupletSecondVerse') final String? coupletVerse2,
      @JsonKey(name: 'parentPoemTitle') final String? coupletPoemTitle,
      @JsonKey(name: 'parentPoemId') final String? coupletPoemPublicId,
      final String? imageUrl,
      final String? thumbnailUrl,
      final String? templateName,
      final int likeCount,
      final int? bookmarkCount,
      final int shareCount}) = _$UnifiedBookmarkImpl;
  const _UnifiedBookmark._() : super._();

  @override
  String get bookmarkId;
  @override
  String get type;
  @override // POEM, COUPLET, IMAGE
  String get contentId;
  @override
  String get languageCode;
  @override
  DateTime get bookmarkedAt;
  @override
  String? get notes;
  @override // POEM + COUPLET shared fields
  String? get poetName;
  @override
  String? get poetId;
  @override
  String? get poetProfileImageUrl;
  @override // 36x36 poet avatar thumbnail
  String? get contentSubType;
  @override // e.g. "GHAZAL", "NAZM"
  String? get contentSubTypeUrdu;
  @override // e.g. "غزل", "نظم"
// POEM fields
  String? get poemTitle;
  @override // COUPLET fields
  @JsonKey(name: 'coupletFirstVerse')
  String? get coupletVerse1;
  @override
  @JsonKey(name: 'coupletSecondVerse')
  String? get coupletVerse2;
  @override
  @JsonKey(name: 'parentPoemTitle')
  String? get coupletPoemTitle;
  @override
  @JsonKey(name: 'parentPoemId')
  String? get coupletPoemPublicId;
  @override // IMAGE fields
  String? get imageUrl;
  @override
  String? get thumbnailUrl;
  @override
  String? get templateName;
  @override // Engagement metrics
  int get likeCount;
  @override
  int? get bookmarkCount;
  @override
  int get shareCount;
  @override
  @JsonKey(ignore: true)
  _$$UnifiedBookmarkImplCopyWith<_$UnifiedBookmarkImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$UnifiedBookmarksResponse {
  List<UnifiedBookmark> get content => throw _privateConstructorUsedError;
  int get totalElements => throw _privateConstructorUsedError;
  int get totalPages => throw _privateConstructorUsedError;
  int get number => throw _privateConstructorUsedError;
  int get size => throw _privateConstructorUsedError;
  bool get first => throw _privateConstructorUsedError;
  bool get last => throw _privateConstructorUsedError;
  bool get empty => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $UnifiedBookmarksResponseCopyWith<UnifiedBookmarksResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UnifiedBookmarksResponseCopyWith<$Res> {
  factory $UnifiedBookmarksResponseCopyWith(UnifiedBookmarksResponse value,
          $Res Function(UnifiedBookmarksResponse) then) =
      _$UnifiedBookmarksResponseCopyWithImpl<$Res, UnifiedBookmarksResponse>;
  @useResult
  $Res call(
      {List<UnifiedBookmark> content,
      int totalElements,
      int totalPages,
      int number,
      int size,
      bool first,
      bool last,
      bool empty});
}

/// @nodoc
class _$UnifiedBookmarksResponseCopyWithImpl<$Res,
        $Val extends UnifiedBookmarksResponse>
    implements $UnifiedBookmarksResponseCopyWith<$Res> {
  _$UnifiedBookmarksResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? content = null,
    Object? totalElements = null,
    Object? totalPages = null,
    Object? number = null,
    Object? size = null,
    Object? first = null,
    Object? last = null,
    Object? empty = null,
  }) {
    return _then(_value.copyWith(
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as List<UnifiedBookmark>,
      totalElements: null == totalElements
          ? _value.totalElements
          : totalElements // ignore: cast_nullable_to_non_nullable
              as int,
      totalPages: null == totalPages
          ? _value.totalPages
          : totalPages // ignore: cast_nullable_to_non_nullable
              as int,
      number: null == number
          ? _value.number
          : number // ignore: cast_nullable_to_non_nullable
              as int,
      size: null == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as int,
      first: null == first
          ? _value.first
          : first // ignore: cast_nullable_to_non_nullable
              as bool,
      last: null == last
          ? _value.last
          : last // ignore: cast_nullable_to_non_nullable
              as bool,
      empty: null == empty
          ? _value.empty
          : empty // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UnifiedBookmarksResponseImplCopyWith<$Res>
    implements $UnifiedBookmarksResponseCopyWith<$Res> {
  factory _$$UnifiedBookmarksResponseImplCopyWith(
          _$UnifiedBookmarksResponseImpl value,
          $Res Function(_$UnifiedBookmarksResponseImpl) then) =
      __$$UnifiedBookmarksResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<UnifiedBookmark> content,
      int totalElements,
      int totalPages,
      int number,
      int size,
      bool first,
      bool last,
      bool empty});
}

/// @nodoc
class __$$UnifiedBookmarksResponseImplCopyWithImpl<$Res>
    extends _$UnifiedBookmarksResponseCopyWithImpl<$Res,
        _$UnifiedBookmarksResponseImpl>
    implements _$$UnifiedBookmarksResponseImplCopyWith<$Res> {
  __$$UnifiedBookmarksResponseImplCopyWithImpl(
      _$UnifiedBookmarksResponseImpl _value,
      $Res Function(_$UnifiedBookmarksResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? content = null,
    Object? totalElements = null,
    Object? totalPages = null,
    Object? number = null,
    Object? size = null,
    Object? first = null,
    Object? last = null,
    Object? empty = null,
  }) {
    return _then(_$UnifiedBookmarksResponseImpl(
      content: null == content
          ? _value._content
          : content // ignore: cast_nullable_to_non_nullable
              as List<UnifiedBookmark>,
      totalElements: null == totalElements
          ? _value.totalElements
          : totalElements // ignore: cast_nullable_to_non_nullable
              as int,
      totalPages: null == totalPages
          ? _value.totalPages
          : totalPages // ignore: cast_nullable_to_non_nullable
              as int,
      number: null == number
          ? _value.number
          : number // ignore: cast_nullable_to_non_nullable
              as int,
      size: null == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as int,
      first: null == first
          ? _value.first
          : first // ignore: cast_nullable_to_non_nullable
              as bool,
      last: null == last
          ? _value.last
          : last // ignore: cast_nullable_to_non_nullable
              as bool,
      empty: null == empty
          ? _value.empty
          : empty // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$UnifiedBookmarksResponseImpl implements _UnifiedBookmarksResponse {
  const _$UnifiedBookmarksResponseImpl(
      {required final List<UnifiedBookmark> content,
      required this.totalElements,
      required this.totalPages,
      required this.number,
      required this.size,
      this.first = true,
      this.last = true,
      this.empty = false})
      : _content = content;

  final List<UnifiedBookmark> _content;
  @override
  List<UnifiedBookmark> get content {
    if (_content is EqualUnmodifiableListView) return _content;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_content);
  }

  @override
  final int totalElements;
  @override
  final int totalPages;
  @override
  final int number;
  @override
  final int size;
  @override
  @JsonKey()
  final bool first;
  @override
  @JsonKey()
  final bool last;
  @override
  @JsonKey()
  final bool empty;

  @override
  String toString() {
    return 'UnifiedBookmarksResponse(content: $content, totalElements: $totalElements, totalPages: $totalPages, number: $number, size: $size, first: $first, last: $last, empty: $empty)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UnifiedBookmarksResponseImpl &&
            const DeepCollectionEquality().equals(other._content, _content) &&
            (identical(other.totalElements, totalElements) ||
                other.totalElements == totalElements) &&
            (identical(other.totalPages, totalPages) ||
                other.totalPages == totalPages) &&
            (identical(other.number, number) || other.number == number) &&
            (identical(other.size, size) || other.size == size) &&
            (identical(other.first, first) || other.first == first) &&
            (identical(other.last, last) || other.last == last) &&
            (identical(other.empty, empty) || other.empty == empty));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_content),
      totalElements,
      totalPages,
      number,
      size,
      first,
      last,
      empty);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UnifiedBookmarksResponseImplCopyWith<_$UnifiedBookmarksResponseImpl>
      get copyWith => __$$UnifiedBookmarksResponseImplCopyWithImpl<
          _$UnifiedBookmarksResponseImpl>(this, _$identity);
}

abstract class _UnifiedBookmarksResponse implements UnifiedBookmarksResponse {
  const factory _UnifiedBookmarksResponse(
      {required final List<UnifiedBookmark> content,
      required final int totalElements,
      required final int totalPages,
      required final int number,
      required final int size,
      final bool first,
      final bool last,
      final bool empty}) = _$UnifiedBookmarksResponseImpl;

  @override
  List<UnifiedBookmark> get content;
  @override
  int get totalElements;
  @override
  int get totalPages;
  @override
  int get number;
  @override
  int get size;
  @override
  bool get first;
  @override
  bool get last;
  @override
  bool get empty;
  @override
  @JsonKey(ignore: true)
  _$$UnifiedBookmarksResponseImplCopyWith<_$UnifiedBookmarksResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$BookmarkFilters {
  String get type =>
      throw _privateConstructorUsedError; // ALL, POEM, COUPLET, IMAGE
  String get language => throw _privateConstructorUsedError; // ALL, ur, en, hi
  String? get searchQuery => throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  int get size => throw _privateConstructorUsedError;
  String get sortBy =>
      throw _privateConstructorUsedError; // bookmarkedAt, likeCount, shareCount
  String get sortDir => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $BookmarkFiltersCopyWith<BookmarkFilters> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BookmarkFiltersCopyWith<$Res> {
  factory $BookmarkFiltersCopyWith(
          BookmarkFilters value, $Res Function(BookmarkFilters) then) =
      _$BookmarkFiltersCopyWithImpl<$Res, BookmarkFilters>;
  @useResult
  $Res call(
      {String type,
      String language,
      String? searchQuery,
      int page,
      int size,
      String sortBy,
      String sortDir});
}

/// @nodoc
class _$BookmarkFiltersCopyWithImpl<$Res, $Val extends BookmarkFilters>
    implements $BookmarkFiltersCopyWith<$Res> {
  _$BookmarkFiltersCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? language = null,
    Object? searchQuery = freezed,
    Object? page = null,
    Object? size = null,
    Object? sortBy = null,
    Object? sortDir = null,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      language: null == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String,
      searchQuery: freezed == searchQuery
          ? _value.searchQuery
          : searchQuery // ignore: cast_nullable_to_non_nullable
              as String?,
      page: null == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      size: null == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as int,
      sortBy: null == sortBy
          ? _value.sortBy
          : sortBy // ignore: cast_nullable_to_non_nullable
              as String,
      sortDir: null == sortDir
          ? _value.sortDir
          : sortDir // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BookmarkFiltersImplCopyWith<$Res>
    implements $BookmarkFiltersCopyWith<$Res> {
  factory _$$BookmarkFiltersImplCopyWith(_$BookmarkFiltersImpl value,
          $Res Function(_$BookmarkFiltersImpl) then) =
      __$$BookmarkFiltersImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String type,
      String language,
      String? searchQuery,
      int page,
      int size,
      String sortBy,
      String sortDir});
}

/// @nodoc
class __$$BookmarkFiltersImplCopyWithImpl<$Res>
    extends _$BookmarkFiltersCopyWithImpl<$Res, _$BookmarkFiltersImpl>
    implements _$$BookmarkFiltersImplCopyWith<$Res> {
  __$$BookmarkFiltersImplCopyWithImpl(
      _$BookmarkFiltersImpl _value, $Res Function(_$BookmarkFiltersImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? language = null,
    Object? searchQuery = freezed,
    Object? page = null,
    Object? size = null,
    Object? sortBy = null,
    Object? sortDir = null,
  }) {
    return _then(_$BookmarkFiltersImpl(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      language: null == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String,
      searchQuery: freezed == searchQuery
          ? _value.searchQuery
          : searchQuery // ignore: cast_nullable_to_non_nullable
              as String?,
      page: null == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      size: null == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as int,
      sortBy: null == sortBy
          ? _value.sortBy
          : sortBy // ignore: cast_nullable_to_non_nullable
              as String,
      sortDir: null == sortDir
          ? _value.sortDir
          : sortDir // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$BookmarkFiltersImpl implements _BookmarkFilters {
  const _$BookmarkFiltersImpl(
      {this.type = 'ALL',
      this.language = 'ALL',
      this.searchQuery,
      this.page = 0,
      this.size = 20,
      this.sortBy = 'bookmarkedAt',
      this.sortDir = 'desc'});

  @override
  @JsonKey()
  final String type;
// ALL, POEM, COUPLET, IMAGE
  @override
  @JsonKey()
  final String language;
// ALL, ur, en, hi
  @override
  final String? searchQuery;
  @override
  @JsonKey()
  final int page;
  @override
  @JsonKey()
  final int size;
  @override
  @JsonKey()
  final String sortBy;
// bookmarkedAt, likeCount, shareCount
  @override
  @JsonKey()
  final String sortDir;

  @override
  String toString() {
    return 'BookmarkFilters(type: $type, language: $language, searchQuery: $searchQuery, page: $page, size: $size, sortBy: $sortBy, sortDir: $sortDir)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookmarkFiltersImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.searchQuery, searchQuery) ||
                other.searchQuery == searchQuery) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.size, size) || other.size == size) &&
            (identical(other.sortBy, sortBy) || other.sortBy == sortBy) &&
            (identical(other.sortDir, sortDir) || other.sortDir == sortDir));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, type, language, searchQuery, page, size, sortBy, sortDir);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BookmarkFiltersImplCopyWith<_$BookmarkFiltersImpl> get copyWith =>
      __$$BookmarkFiltersImplCopyWithImpl<_$BookmarkFiltersImpl>(
          this, _$identity);
}

abstract class _BookmarkFilters implements BookmarkFilters {
  const factory _BookmarkFilters(
      {final String type,
      final String language,
      final String? searchQuery,
      final int page,
      final int size,
      final String sortBy,
      final String sortDir}) = _$BookmarkFiltersImpl;

  @override
  String get type;
  @override // ALL, POEM, COUPLET, IMAGE
  String get language;
  @override // ALL, ur, en, hi
  String? get searchQuery;
  @override
  int get page;
  @override
  int get size;
  @override
  String get sortBy;
  @override // bookmarkedAt, likeCount, shareCount
  String get sortDir;
  @override
  @JsonKey(ignore: true)
  _$$BookmarkFiltersImplCopyWith<_$BookmarkFiltersImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$BookmarkStats {
  int get totalBookmarks => throw _privateConstructorUsedError;
  int get poemBookmarks => throw _privateConstructorUsedError;
  int get coupletBookmarks => throw _privateConstructorUsedError;
  int get imageBookmarks => throw _privateConstructorUsedError;
  Map<String, int> get byLanguage => throw _privateConstructorUsedError;
  List<TopPoet> get topPoets => throw _privateConstructorUsedError;
  int get recentBookmarks => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $BookmarkStatsCopyWith<BookmarkStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BookmarkStatsCopyWith<$Res> {
  factory $BookmarkStatsCopyWith(
          BookmarkStats value, $Res Function(BookmarkStats) then) =
      _$BookmarkStatsCopyWithImpl<$Res, BookmarkStats>;
  @useResult
  $Res call(
      {int totalBookmarks,
      int poemBookmarks,
      int coupletBookmarks,
      int imageBookmarks,
      Map<String, int> byLanguage,
      List<TopPoet> topPoets,
      int recentBookmarks});
}

/// @nodoc
class _$BookmarkStatsCopyWithImpl<$Res, $Val extends BookmarkStats>
    implements $BookmarkStatsCopyWith<$Res> {
  _$BookmarkStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalBookmarks = null,
    Object? poemBookmarks = null,
    Object? coupletBookmarks = null,
    Object? imageBookmarks = null,
    Object? byLanguage = null,
    Object? topPoets = null,
    Object? recentBookmarks = null,
  }) {
    return _then(_value.copyWith(
      totalBookmarks: null == totalBookmarks
          ? _value.totalBookmarks
          : totalBookmarks // ignore: cast_nullable_to_non_nullable
              as int,
      poemBookmarks: null == poemBookmarks
          ? _value.poemBookmarks
          : poemBookmarks // ignore: cast_nullable_to_non_nullable
              as int,
      coupletBookmarks: null == coupletBookmarks
          ? _value.coupletBookmarks
          : coupletBookmarks // ignore: cast_nullable_to_non_nullable
              as int,
      imageBookmarks: null == imageBookmarks
          ? _value.imageBookmarks
          : imageBookmarks // ignore: cast_nullable_to_non_nullable
              as int,
      byLanguage: null == byLanguage
          ? _value.byLanguage
          : byLanguage // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      topPoets: null == topPoets
          ? _value.topPoets
          : topPoets // ignore: cast_nullable_to_non_nullable
              as List<TopPoet>,
      recentBookmarks: null == recentBookmarks
          ? _value.recentBookmarks
          : recentBookmarks // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BookmarkStatsImplCopyWith<$Res>
    implements $BookmarkStatsCopyWith<$Res> {
  factory _$$BookmarkStatsImplCopyWith(
          _$BookmarkStatsImpl value, $Res Function(_$BookmarkStatsImpl) then) =
      __$$BookmarkStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int totalBookmarks,
      int poemBookmarks,
      int coupletBookmarks,
      int imageBookmarks,
      Map<String, int> byLanguage,
      List<TopPoet> topPoets,
      int recentBookmarks});
}

/// @nodoc
class __$$BookmarkStatsImplCopyWithImpl<$Res>
    extends _$BookmarkStatsCopyWithImpl<$Res, _$BookmarkStatsImpl>
    implements _$$BookmarkStatsImplCopyWith<$Res> {
  __$$BookmarkStatsImplCopyWithImpl(
      _$BookmarkStatsImpl _value, $Res Function(_$BookmarkStatsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalBookmarks = null,
    Object? poemBookmarks = null,
    Object? coupletBookmarks = null,
    Object? imageBookmarks = null,
    Object? byLanguage = null,
    Object? topPoets = null,
    Object? recentBookmarks = null,
  }) {
    return _then(_$BookmarkStatsImpl(
      totalBookmarks: null == totalBookmarks
          ? _value.totalBookmarks
          : totalBookmarks // ignore: cast_nullable_to_non_nullable
              as int,
      poemBookmarks: null == poemBookmarks
          ? _value.poemBookmarks
          : poemBookmarks // ignore: cast_nullable_to_non_nullable
              as int,
      coupletBookmarks: null == coupletBookmarks
          ? _value.coupletBookmarks
          : coupletBookmarks // ignore: cast_nullable_to_non_nullable
              as int,
      imageBookmarks: null == imageBookmarks
          ? _value.imageBookmarks
          : imageBookmarks // ignore: cast_nullable_to_non_nullable
              as int,
      byLanguage: null == byLanguage
          ? _value._byLanguage
          : byLanguage // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      topPoets: null == topPoets
          ? _value._topPoets
          : topPoets // ignore: cast_nullable_to_non_nullable
              as List<TopPoet>,
      recentBookmarks: null == recentBookmarks
          ? _value.recentBookmarks
          : recentBookmarks // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$BookmarkStatsImpl implements _BookmarkStats {
  const _$BookmarkStatsImpl(
      {this.totalBookmarks = 0,
      this.poemBookmarks = 0,
      this.coupletBookmarks = 0,
      this.imageBookmarks = 0,
      final Map<String, int> byLanguage = const {},
      final List<TopPoet> topPoets = const [],
      this.recentBookmarks = 0})
      : _byLanguage = byLanguage,
        _topPoets = topPoets;

  @override
  @JsonKey()
  final int totalBookmarks;
  @override
  @JsonKey()
  final int poemBookmarks;
  @override
  @JsonKey()
  final int coupletBookmarks;
  @override
  @JsonKey()
  final int imageBookmarks;
  final Map<String, int> _byLanguage;
  @override
  @JsonKey()
  Map<String, int> get byLanguage {
    if (_byLanguage is EqualUnmodifiableMapView) return _byLanguage;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_byLanguage);
  }

  final List<TopPoet> _topPoets;
  @override
  @JsonKey()
  List<TopPoet> get topPoets {
    if (_topPoets is EqualUnmodifiableListView) return _topPoets;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_topPoets);
  }

  @override
  @JsonKey()
  final int recentBookmarks;

  @override
  String toString() {
    return 'BookmarkStats(totalBookmarks: $totalBookmarks, poemBookmarks: $poemBookmarks, coupletBookmarks: $coupletBookmarks, imageBookmarks: $imageBookmarks, byLanguage: $byLanguage, topPoets: $topPoets, recentBookmarks: $recentBookmarks)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookmarkStatsImpl &&
            (identical(other.totalBookmarks, totalBookmarks) ||
                other.totalBookmarks == totalBookmarks) &&
            (identical(other.poemBookmarks, poemBookmarks) ||
                other.poemBookmarks == poemBookmarks) &&
            (identical(other.coupletBookmarks, coupletBookmarks) ||
                other.coupletBookmarks == coupletBookmarks) &&
            (identical(other.imageBookmarks, imageBookmarks) ||
                other.imageBookmarks == imageBookmarks) &&
            const DeepCollectionEquality()
                .equals(other._byLanguage, _byLanguage) &&
            const DeepCollectionEquality().equals(other._topPoets, _topPoets) &&
            (identical(other.recentBookmarks, recentBookmarks) ||
                other.recentBookmarks == recentBookmarks));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      totalBookmarks,
      poemBookmarks,
      coupletBookmarks,
      imageBookmarks,
      const DeepCollectionEquality().hash(_byLanguage),
      const DeepCollectionEquality().hash(_topPoets),
      recentBookmarks);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BookmarkStatsImplCopyWith<_$BookmarkStatsImpl> get copyWith =>
      __$$BookmarkStatsImplCopyWithImpl<_$BookmarkStatsImpl>(this, _$identity);
}

abstract class _BookmarkStats implements BookmarkStats {
  const factory _BookmarkStats(
      {final int totalBookmarks,
      final int poemBookmarks,
      final int coupletBookmarks,
      final int imageBookmarks,
      final Map<String, int> byLanguage,
      final List<TopPoet> topPoets,
      final int recentBookmarks}) = _$BookmarkStatsImpl;

  @override
  int get totalBookmarks;
  @override
  int get poemBookmarks;
  @override
  int get coupletBookmarks;
  @override
  int get imageBookmarks;
  @override
  Map<String, int> get byLanguage;
  @override
  List<TopPoet> get topPoets;
  @override
  int get recentBookmarks;
  @override
  @JsonKey(ignore: true)
  _$$BookmarkStatsImplCopyWith<_$BookmarkStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TopPoet _$TopPoetFromJson(Map<String, dynamic> json) {
  return _TopPoet.fromJson(json);
}

/// @nodoc
mixin _$TopPoet {
  String get poetId => throw _privateConstructorUsedError;
  String get poetName => throw _privateConstructorUsedError;
  int get bookmarkCount => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TopPoetCopyWith<TopPoet> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TopPoetCopyWith<$Res> {
  factory $TopPoetCopyWith(TopPoet value, $Res Function(TopPoet) then) =
      _$TopPoetCopyWithImpl<$Res, TopPoet>;
  @useResult
  $Res call({String poetId, String poetName, int bookmarkCount});
}

/// @nodoc
class _$TopPoetCopyWithImpl<$Res, $Val extends TopPoet>
    implements $TopPoetCopyWith<$Res> {
  _$TopPoetCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? poetId = null,
    Object? poetName = null,
    Object? bookmarkCount = null,
  }) {
    return _then(_value.copyWith(
      poetId: null == poetId
          ? _value.poetId
          : poetId // ignore: cast_nullable_to_non_nullable
              as String,
      poetName: null == poetName
          ? _value.poetName
          : poetName // ignore: cast_nullable_to_non_nullable
              as String,
      bookmarkCount: null == bookmarkCount
          ? _value.bookmarkCount
          : bookmarkCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TopPoetImplCopyWith<$Res> implements $TopPoetCopyWith<$Res> {
  factory _$$TopPoetImplCopyWith(
          _$TopPoetImpl value, $Res Function(_$TopPoetImpl) then) =
      __$$TopPoetImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String poetId, String poetName, int bookmarkCount});
}

/// @nodoc
class __$$TopPoetImplCopyWithImpl<$Res>
    extends _$TopPoetCopyWithImpl<$Res, _$TopPoetImpl>
    implements _$$TopPoetImplCopyWith<$Res> {
  __$$TopPoetImplCopyWithImpl(
      _$TopPoetImpl _value, $Res Function(_$TopPoetImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? poetId = null,
    Object? poetName = null,
    Object? bookmarkCount = null,
  }) {
    return _then(_$TopPoetImpl(
      poetId: null == poetId
          ? _value.poetId
          : poetId // ignore: cast_nullable_to_non_nullable
              as String,
      poetName: null == poetName
          ? _value.poetName
          : poetName // ignore: cast_nullable_to_non_nullable
              as String,
      bookmarkCount: null == bookmarkCount
          ? _value.bookmarkCount
          : bookmarkCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TopPoetImpl implements _TopPoet {
  const _$TopPoetImpl(
      {required this.poetId, required this.poetName, this.bookmarkCount = 0});

  factory _$TopPoetImpl.fromJson(Map<String, dynamic> json) =>
      _$$TopPoetImplFromJson(json);

  @override
  final String poetId;
  @override
  final String poetName;
  @override
  @JsonKey()
  final int bookmarkCount;

  @override
  String toString() {
    return 'TopPoet(poetId: $poetId, poetName: $poetName, bookmarkCount: $bookmarkCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TopPoetImpl &&
            (identical(other.poetId, poetId) || other.poetId == poetId) &&
            (identical(other.poetName, poetName) ||
                other.poetName == poetName) &&
            (identical(other.bookmarkCount, bookmarkCount) ||
                other.bookmarkCount == bookmarkCount));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, poetId, poetName, bookmarkCount);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TopPoetImplCopyWith<_$TopPoetImpl> get copyWith =>
      __$$TopPoetImplCopyWithImpl<_$TopPoetImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TopPoetImplToJson(
      this,
    );
  }
}

abstract class _TopPoet implements TopPoet {
  const factory _TopPoet(
      {required final String poetId,
      required final String poetName,
      final int bookmarkCount}) = _$TopPoetImpl;

  factory _TopPoet.fromJson(Map<String, dynamic> json) = _$TopPoetImpl.fromJson;

  @override
  String get poetId;
  @override
  String get poetName;
  @override
  int get bookmarkCount;
  @override
  @JsonKey(ignore: true)
  _$$TopPoetImplCopyWith<_$TopPoetImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
