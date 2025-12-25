// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'couplet_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CoupletModel _$CoupletModelFromJson(Map<String, dynamic> json) {
  return _CoupletModel.fromJson(json);
}

/// @nodoc
mixin _$CoupletModel {
  String get publicId => throw _privateConstructorUsedError;
  int get coupletNumber => throw _privateConstructorUsedError;
  String get coupletType => throw _privateConstructorUsedError;
  String? get coupletTypeName => throw _privateConstructorUsedError;
  List<VerseModel> get verses => throw _privateConstructorUsedError;
  int get likeCount => throw _privateConstructorUsedError;
  int get bookmarkCount => throw _privateConstructorUsedError;
  int get shareCount => throw _privateConstructorUsedError;
  bool? get isLikedByCurrentUser => throw _privateConstructorUsedError;
  bool? get isBookmarkedByCurrentUser => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this CoupletModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CoupletModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CoupletModelCopyWith<CoupletModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CoupletModelCopyWith<$Res> {
  factory $CoupletModelCopyWith(
          CoupletModel value, $Res Function(CoupletModel) then) =
      _$CoupletModelCopyWithImpl<$Res, CoupletModel>;
  @useResult
  $Res call(
      {String publicId,
      int coupletNumber,
      String coupletType,
      String? coupletTypeName,
      List<VerseModel> verses,
      int likeCount,
      int bookmarkCount,
      int shareCount,
      bool? isLikedByCurrentUser,
      bool? isBookmarkedByCurrentUser,
      DateTime? createdAt});
}

/// @nodoc
class _$CoupletModelCopyWithImpl<$Res, $Val extends CoupletModel>
    implements $CoupletModelCopyWith<$Res> {
  _$CoupletModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CoupletModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? publicId = null,
    Object? coupletNumber = null,
    Object? coupletType = null,
    Object? coupletTypeName = freezed,
    Object? verses = null,
    Object? likeCount = null,
    Object? bookmarkCount = null,
    Object? shareCount = null,
    Object? isLikedByCurrentUser = freezed,
    Object? isBookmarkedByCurrentUser = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      publicId: null == publicId
          ? _value.publicId
          : publicId // ignore: cast_nullable_to_non_nullable
              as String,
      coupletNumber: null == coupletNumber
          ? _value.coupletNumber
          : coupletNumber // ignore: cast_nullable_to_non_nullable
              as int,
      coupletType: null == coupletType
          ? _value.coupletType
          : coupletType // ignore: cast_nullable_to_non_nullable
              as String,
      coupletTypeName: freezed == coupletTypeName
          ? _value.coupletTypeName
          : coupletTypeName // ignore: cast_nullable_to_non_nullable
              as String?,
      verses: null == verses
          ? _value.verses
          : verses // ignore: cast_nullable_to_non_nullable
              as List<VerseModel>,
      likeCount: null == likeCount
          ? _value.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int,
      bookmarkCount: null == bookmarkCount
          ? _value.bookmarkCount
          : bookmarkCount // ignore: cast_nullable_to_non_nullable
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
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CoupletModelImplCopyWith<$Res>
    implements $CoupletModelCopyWith<$Res> {
  factory _$$CoupletModelImplCopyWith(
          _$CoupletModelImpl value, $Res Function(_$CoupletModelImpl) then) =
      __$$CoupletModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String publicId,
      int coupletNumber,
      String coupletType,
      String? coupletTypeName,
      List<VerseModel> verses,
      int likeCount,
      int bookmarkCount,
      int shareCount,
      bool? isLikedByCurrentUser,
      bool? isBookmarkedByCurrentUser,
      DateTime? createdAt});
}

/// @nodoc
class __$$CoupletModelImplCopyWithImpl<$Res>
    extends _$CoupletModelCopyWithImpl<$Res, _$CoupletModelImpl>
    implements _$$CoupletModelImplCopyWith<$Res> {
  __$$CoupletModelImplCopyWithImpl(
      _$CoupletModelImpl _value, $Res Function(_$CoupletModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of CoupletModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? publicId = null,
    Object? coupletNumber = null,
    Object? coupletType = null,
    Object? coupletTypeName = freezed,
    Object? verses = null,
    Object? likeCount = null,
    Object? bookmarkCount = null,
    Object? shareCount = null,
    Object? isLikedByCurrentUser = freezed,
    Object? isBookmarkedByCurrentUser = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_$CoupletModelImpl(
      publicId: null == publicId
          ? _value.publicId
          : publicId // ignore: cast_nullable_to_non_nullable
              as String,
      coupletNumber: null == coupletNumber
          ? _value.coupletNumber
          : coupletNumber // ignore: cast_nullable_to_non_nullable
              as int,
      coupletType: null == coupletType
          ? _value.coupletType
          : coupletType // ignore: cast_nullable_to_non_nullable
              as String,
      coupletTypeName: freezed == coupletTypeName
          ? _value.coupletTypeName
          : coupletTypeName // ignore: cast_nullable_to_non_nullable
              as String?,
      verses: null == verses
          ? _value._verses
          : verses // ignore: cast_nullable_to_non_nullable
              as List<VerseModel>,
      likeCount: null == likeCount
          ? _value.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int,
      bookmarkCount: null == bookmarkCount
          ? _value.bookmarkCount
          : bookmarkCount // ignore: cast_nullable_to_non_nullable
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
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CoupletModelImpl implements _CoupletModel {
  const _$CoupletModelImpl(
      {required this.publicId,
      required this.coupletNumber,
      required this.coupletType,
      this.coupletTypeName,
      required final List<VerseModel> verses,
      this.likeCount = 0,
      this.bookmarkCount = 0,
      this.shareCount = 0,
      this.isLikedByCurrentUser,
      this.isBookmarkedByCurrentUser,
      this.createdAt})
      : _verses = verses;

  factory _$CoupletModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CoupletModelImplFromJson(json);

  @override
  final String publicId;
  @override
  final int coupletNumber;
  @override
  final String coupletType;
  @override
  final String? coupletTypeName;
  final List<VerseModel> _verses;
  @override
  List<VerseModel> get verses {
    if (_verses is EqualUnmodifiableListView) return _verses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_verses);
  }

  @override
  @JsonKey()
  final int likeCount;
  @override
  @JsonKey()
  final int bookmarkCount;
  @override
  @JsonKey()
  final int shareCount;
  @override
  final bool? isLikedByCurrentUser;
  @override
  final bool? isBookmarkedByCurrentUser;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'CoupletModel(publicId: $publicId, coupletNumber: $coupletNumber, coupletType: $coupletType, coupletTypeName: $coupletTypeName, verses: $verses, likeCount: $likeCount, bookmarkCount: $bookmarkCount, shareCount: $shareCount, isLikedByCurrentUser: $isLikedByCurrentUser, isBookmarkedByCurrentUser: $isBookmarkedByCurrentUser, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CoupletModelImpl &&
            (identical(other.publicId, publicId) ||
                other.publicId == publicId) &&
            (identical(other.coupletNumber, coupletNumber) ||
                other.coupletNumber == coupletNumber) &&
            (identical(other.coupletType, coupletType) ||
                other.coupletType == coupletType) &&
            (identical(other.coupletTypeName, coupletTypeName) ||
                other.coupletTypeName == coupletTypeName) &&
            const DeepCollectionEquality().equals(other._verses, _verses) &&
            (identical(other.likeCount, likeCount) ||
                other.likeCount == likeCount) &&
            (identical(other.bookmarkCount, bookmarkCount) ||
                other.bookmarkCount == bookmarkCount) &&
            (identical(other.shareCount, shareCount) ||
                other.shareCount == shareCount) &&
            (identical(other.isLikedByCurrentUser, isLikedByCurrentUser) ||
                other.isLikedByCurrentUser == isLikedByCurrentUser) &&
            (identical(other.isBookmarkedByCurrentUser,
                    isBookmarkedByCurrentUser) ||
                other.isBookmarkedByCurrentUser == isBookmarkedByCurrentUser) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      publicId,
      coupletNumber,
      coupletType,
      coupletTypeName,
      const DeepCollectionEquality().hash(_verses),
      likeCount,
      bookmarkCount,
      shareCount,
      isLikedByCurrentUser,
      isBookmarkedByCurrentUser,
      createdAt);

  /// Create a copy of CoupletModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CoupletModelImplCopyWith<_$CoupletModelImpl> get copyWith =>
      __$$CoupletModelImplCopyWithImpl<_$CoupletModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CoupletModelImplToJson(
      this,
    );
  }
}

abstract class _CoupletModel implements CoupletModel {
  const factory _CoupletModel(
      {required final String publicId,
      required final int coupletNumber,
      required final String coupletType,
      final String? coupletTypeName,
      required final List<VerseModel> verses,
      final int likeCount,
      final int bookmarkCount,
      final int shareCount,
      final bool? isLikedByCurrentUser,
      final bool? isBookmarkedByCurrentUser,
      final DateTime? createdAt}) = _$CoupletModelImpl;

  factory _CoupletModel.fromJson(Map<String, dynamic> json) =
      _$CoupletModelImpl.fromJson;

  @override
  String get publicId;
  @override
  int get coupletNumber;
  @override
  String get coupletType;
  @override
  String? get coupletTypeName;
  @override
  List<VerseModel> get verses;
  @override
  int get likeCount;
  @override
  int get bookmarkCount;
  @override
  int get shareCount;
  @override
  bool? get isLikedByCurrentUser;
  @override
  bool? get isBookmarkedByCurrentUser;
  @override
  DateTime? get createdAt;

  /// Create a copy of CoupletModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CoupletModelImplCopyWith<_$CoupletModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CoupletDetailResponse _$CoupletDetailResponseFromJson(
    Map<String, dynamic> json) {
  return _CoupletDetailResponse.fromJson(json);
}

/// @nodoc
mixin _$CoupletDetailResponse {
  String get publicId => throw _privateConstructorUsedError;
  int get coupletNumber => throw _privateConstructorUsedError;
  String get coupletType => throw _privateConstructorUsedError;
  String? get coupletTypeName => throw _privateConstructorUsedError;
  List<VerseModel> get verses =>
      throw _privateConstructorUsedError; // Poem context
  String get poemPublicId => throw _privateConstructorUsedError;
  String? get poemTitle => throw _privateConstructorUsedError;
  int? get totalCoupletsInPoem => throw _privateConstructorUsedError;
  String? get poetryType => throw _privateConstructorUsedError; // Poet context
  String get poetPublicId => throw _privateConstructorUsedError;
  String get poetName => throw _privateConstructorUsedError;
  String? get poetProfileImageUrl =>
      throw _privateConstructorUsedError; // Engagement
  int get likeCount => throw _privateConstructorUsedError;
  int get bookmarkCount => throw _privateConstructorUsedError;
  int get shareCount => throw _privateConstructorUsedError;
  bool? get isLikedByCurrentUser => throw _privateConstructorUsedError;
  bool? get isBookmarkedByCurrentUser => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this CoupletDetailResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CoupletDetailResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CoupletDetailResponseCopyWith<CoupletDetailResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CoupletDetailResponseCopyWith<$Res> {
  factory $CoupletDetailResponseCopyWith(CoupletDetailResponse value,
          $Res Function(CoupletDetailResponse) then) =
      _$CoupletDetailResponseCopyWithImpl<$Res, CoupletDetailResponse>;
  @useResult
  $Res call(
      {String publicId,
      int coupletNumber,
      String coupletType,
      String? coupletTypeName,
      List<VerseModel> verses,
      String poemPublicId,
      String? poemTitle,
      int? totalCoupletsInPoem,
      String? poetryType,
      String poetPublicId,
      String poetName,
      String? poetProfileImageUrl,
      int likeCount,
      int bookmarkCount,
      int shareCount,
      bool? isLikedByCurrentUser,
      bool? isBookmarkedByCurrentUser,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$CoupletDetailResponseCopyWithImpl<$Res,
        $Val extends CoupletDetailResponse>
    implements $CoupletDetailResponseCopyWith<$Res> {
  _$CoupletDetailResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CoupletDetailResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? publicId = null,
    Object? coupletNumber = null,
    Object? coupletType = null,
    Object? coupletTypeName = freezed,
    Object? verses = null,
    Object? poemPublicId = null,
    Object? poemTitle = freezed,
    Object? totalCoupletsInPoem = freezed,
    Object? poetryType = freezed,
    Object? poetPublicId = null,
    Object? poetName = null,
    Object? poetProfileImageUrl = freezed,
    Object? likeCount = null,
    Object? bookmarkCount = null,
    Object? shareCount = null,
    Object? isLikedByCurrentUser = freezed,
    Object? isBookmarkedByCurrentUser = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      publicId: null == publicId
          ? _value.publicId
          : publicId // ignore: cast_nullable_to_non_nullable
              as String,
      coupletNumber: null == coupletNumber
          ? _value.coupletNumber
          : coupletNumber // ignore: cast_nullable_to_non_nullable
              as int,
      coupletType: null == coupletType
          ? _value.coupletType
          : coupletType // ignore: cast_nullable_to_non_nullable
              as String,
      coupletTypeName: freezed == coupletTypeName
          ? _value.coupletTypeName
          : coupletTypeName // ignore: cast_nullable_to_non_nullable
              as String?,
      verses: null == verses
          ? _value.verses
          : verses // ignore: cast_nullable_to_non_nullable
              as List<VerseModel>,
      poemPublicId: null == poemPublicId
          ? _value.poemPublicId
          : poemPublicId // ignore: cast_nullable_to_non_nullable
              as String,
      poemTitle: freezed == poemTitle
          ? _value.poemTitle
          : poemTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      totalCoupletsInPoem: freezed == totalCoupletsInPoem
          ? _value.totalCoupletsInPoem
          : totalCoupletsInPoem // ignore: cast_nullable_to_non_nullable
              as int?,
      poetryType: freezed == poetryType
          ? _value.poetryType
          : poetryType // ignore: cast_nullable_to_non_nullable
              as String?,
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
      likeCount: null == likeCount
          ? _value.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int,
      bookmarkCount: null == bookmarkCount
          ? _value.bookmarkCount
          : bookmarkCount // ignore: cast_nullable_to_non_nullable
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
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CoupletDetailResponseImplCopyWith<$Res>
    implements $CoupletDetailResponseCopyWith<$Res> {
  factory _$$CoupletDetailResponseImplCopyWith(
          _$CoupletDetailResponseImpl value,
          $Res Function(_$CoupletDetailResponseImpl) then) =
      __$$CoupletDetailResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String publicId,
      int coupletNumber,
      String coupletType,
      String? coupletTypeName,
      List<VerseModel> verses,
      String poemPublicId,
      String? poemTitle,
      int? totalCoupletsInPoem,
      String? poetryType,
      String poetPublicId,
      String poetName,
      String? poetProfileImageUrl,
      int likeCount,
      int bookmarkCount,
      int shareCount,
      bool? isLikedByCurrentUser,
      bool? isBookmarkedByCurrentUser,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$CoupletDetailResponseImplCopyWithImpl<$Res>
    extends _$CoupletDetailResponseCopyWithImpl<$Res,
        _$CoupletDetailResponseImpl>
    implements _$$CoupletDetailResponseImplCopyWith<$Res> {
  __$$CoupletDetailResponseImplCopyWithImpl(_$CoupletDetailResponseImpl _value,
      $Res Function(_$CoupletDetailResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of CoupletDetailResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? publicId = null,
    Object? coupletNumber = null,
    Object? coupletType = null,
    Object? coupletTypeName = freezed,
    Object? verses = null,
    Object? poemPublicId = null,
    Object? poemTitle = freezed,
    Object? totalCoupletsInPoem = freezed,
    Object? poetryType = freezed,
    Object? poetPublicId = null,
    Object? poetName = null,
    Object? poetProfileImageUrl = freezed,
    Object? likeCount = null,
    Object? bookmarkCount = null,
    Object? shareCount = null,
    Object? isLikedByCurrentUser = freezed,
    Object? isBookmarkedByCurrentUser = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$CoupletDetailResponseImpl(
      publicId: null == publicId
          ? _value.publicId
          : publicId // ignore: cast_nullable_to_non_nullable
              as String,
      coupletNumber: null == coupletNumber
          ? _value.coupletNumber
          : coupletNumber // ignore: cast_nullable_to_non_nullable
              as int,
      coupletType: null == coupletType
          ? _value.coupletType
          : coupletType // ignore: cast_nullable_to_non_nullable
              as String,
      coupletTypeName: freezed == coupletTypeName
          ? _value.coupletTypeName
          : coupletTypeName // ignore: cast_nullable_to_non_nullable
              as String?,
      verses: null == verses
          ? _value._verses
          : verses // ignore: cast_nullable_to_non_nullable
              as List<VerseModel>,
      poemPublicId: null == poemPublicId
          ? _value.poemPublicId
          : poemPublicId // ignore: cast_nullable_to_non_nullable
              as String,
      poemTitle: freezed == poemTitle
          ? _value.poemTitle
          : poemTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      totalCoupletsInPoem: freezed == totalCoupletsInPoem
          ? _value.totalCoupletsInPoem
          : totalCoupletsInPoem // ignore: cast_nullable_to_non_nullable
              as int?,
      poetryType: freezed == poetryType
          ? _value.poetryType
          : poetryType // ignore: cast_nullable_to_non_nullable
              as String?,
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
      likeCount: null == likeCount
          ? _value.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int,
      bookmarkCount: null == bookmarkCount
          ? _value.bookmarkCount
          : bookmarkCount // ignore: cast_nullable_to_non_nullable
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
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CoupletDetailResponseImpl implements _CoupletDetailResponse {
  const _$CoupletDetailResponseImpl(
      {required this.publicId,
      required this.coupletNumber,
      required this.coupletType,
      this.coupletTypeName,
      required final List<VerseModel> verses,
      required this.poemPublicId,
      this.poemTitle,
      this.totalCoupletsInPoem,
      this.poetryType,
      required this.poetPublicId,
      required this.poetName,
      this.poetProfileImageUrl,
      this.likeCount = 0,
      this.bookmarkCount = 0,
      this.shareCount = 0,
      this.isLikedByCurrentUser,
      this.isBookmarkedByCurrentUser,
      this.createdAt,
      this.updatedAt})
      : _verses = verses;

  factory _$CoupletDetailResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$CoupletDetailResponseImplFromJson(json);

  @override
  final String publicId;
  @override
  final int coupletNumber;
  @override
  final String coupletType;
  @override
  final String? coupletTypeName;
  final List<VerseModel> _verses;
  @override
  List<VerseModel> get verses {
    if (_verses is EqualUnmodifiableListView) return _verses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_verses);
  }

// Poem context
  @override
  final String poemPublicId;
  @override
  final String? poemTitle;
  @override
  final int? totalCoupletsInPoem;
  @override
  final String? poetryType;
// Poet context
  @override
  final String poetPublicId;
  @override
  final String poetName;
  @override
  final String? poetProfileImageUrl;
// Engagement
  @override
  @JsonKey()
  final int likeCount;
  @override
  @JsonKey()
  final int bookmarkCount;
  @override
  @JsonKey()
  final int shareCount;
  @override
  final bool? isLikedByCurrentUser;
  @override
  final bool? isBookmarkedByCurrentUser;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'CoupletDetailResponse(publicId: $publicId, coupletNumber: $coupletNumber, coupletType: $coupletType, coupletTypeName: $coupletTypeName, verses: $verses, poemPublicId: $poemPublicId, poemTitle: $poemTitle, totalCoupletsInPoem: $totalCoupletsInPoem, poetryType: $poetryType, poetPublicId: $poetPublicId, poetName: $poetName, poetProfileImageUrl: $poetProfileImageUrl, likeCount: $likeCount, bookmarkCount: $bookmarkCount, shareCount: $shareCount, isLikedByCurrentUser: $isLikedByCurrentUser, isBookmarkedByCurrentUser: $isBookmarkedByCurrentUser, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CoupletDetailResponseImpl &&
            (identical(other.publicId, publicId) ||
                other.publicId == publicId) &&
            (identical(other.coupletNumber, coupletNumber) ||
                other.coupletNumber == coupletNumber) &&
            (identical(other.coupletType, coupletType) ||
                other.coupletType == coupletType) &&
            (identical(other.coupletTypeName, coupletTypeName) ||
                other.coupletTypeName == coupletTypeName) &&
            const DeepCollectionEquality().equals(other._verses, _verses) &&
            (identical(other.poemPublicId, poemPublicId) ||
                other.poemPublicId == poemPublicId) &&
            (identical(other.poemTitle, poemTitle) ||
                other.poemTitle == poemTitle) &&
            (identical(other.totalCoupletsInPoem, totalCoupletsInPoem) ||
                other.totalCoupletsInPoem == totalCoupletsInPoem) &&
            (identical(other.poetryType, poetryType) ||
                other.poetryType == poetryType) &&
            (identical(other.poetPublicId, poetPublicId) ||
                other.poetPublicId == poetPublicId) &&
            (identical(other.poetName, poetName) ||
                other.poetName == poetName) &&
            (identical(other.poetProfileImageUrl, poetProfileImageUrl) ||
                other.poetProfileImageUrl == poetProfileImageUrl) &&
            (identical(other.likeCount, likeCount) ||
                other.likeCount == likeCount) &&
            (identical(other.bookmarkCount, bookmarkCount) ||
                other.bookmarkCount == bookmarkCount) &&
            (identical(other.shareCount, shareCount) ||
                other.shareCount == shareCount) &&
            (identical(other.isLikedByCurrentUser, isLikedByCurrentUser) ||
                other.isLikedByCurrentUser == isLikedByCurrentUser) &&
            (identical(other.isBookmarkedByCurrentUser,
                    isBookmarkedByCurrentUser) ||
                other.isBookmarkedByCurrentUser == isBookmarkedByCurrentUser) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        publicId,
        coupletNumber,
        coupletType,
        coupletTypeName,
        const DeepCollectionEquality().hash(_verses),
        poemPublicId,
        poemTitle,
        totalCoupletsInPoem,
        poetryType,
        poetPublicId,
        poetName,
        poetProfileImageUrl,
        likeCount,
        bookmarkCount,
        shareCount,
        isLikedByCurrentUser,
        isBookmarkedByCurrentUser,
        createdAt,
        updatedAt
      ]);

  /// Create a copy of CoupletDetailResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CoupletDetailResponseImplCopyWith<_$CoupletDetailResponseImpl>
      get copyWith => __$$CoupletDetailResponseImplCopyWithImpl<
          _$CoupletDetailResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CoupletDetailResponseImplToJson(
      this,
    );
  }
}

abstract class _CoupletDetailResponse implements CoupletDetailResponse {
  const factory _CoupletDetailResponse(
      {required final String publicId,
      required final int coupletNumber,
      required final String coupletType,
      final String? coupletTypeName,
      required final List<VerseModel> verses,
      required final String poemPublicId,
      final String? poemTitle,
      final int? totalCoupletsInPoem,
      final String? poetryType,
      required final String poetPublicId,
      required final String poetName,
      final String? poetProfileImageUrl,
      final int likeCount,
      final int bookmarkCount,
      final int shareCount,
      final bool? isLikedByCurrentUser,
      final bool? isBookmarkedByCurrentUser,
      final DateTime? createdAt,
      final DateTime? updatedAt}) = _$CoupletDetailResponseImpl;

  factory _CoupletDetailResponse.fromJson(Map<String, dynamic> json) =
      _$CoupletDetailResponseImpl.fromJson;

  @override
  String get publicId;
  @override
  int get coupletNumber;
  @override
  String get coupletType;
  @override
  String? get coupletTypeName;
  @override
  List<VerseModel> get verses; // Poem context
  @override
  String get poemPublicId;
  @override
  String? get poemTitle;
  @override
  int? get totalCoupletsInPoem;
  @override
  String? get poetryType; // Poet context
  @override
  String get poetPublicId;
  @override
  String get poetName;
  @override
  String? get poetProfileImageUrl; // Engagement
  @override
  int get likeCount;
  @override
  int get bookmarkCount;
  @override
  int get shareCount;
  @override
  bool? get isLikedByCurrentUser;
  @override
  bool? get isBookmarkedByCurrentUser;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of CoupletDetailResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CoupletDetailResponseImplCopyWith<_$CoupletDetailResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}

BookmarkedCoupletResponse _$BookmarkedCoupletResponseFromJson(
    Map<String, dynamic> json) {
  return _BookmarkedCoupletResponse.fromJson(json);
}

/// @nodoc
mixin _$BookmarkedCoupletResponse {
  String get coupletPublicId => throw _privateConstructorUsedError;
  int get coupletNumber => throw _privateConstructorUsedError;
  String get coupletType => throw _privateConstructorUsedError;
  String? get coupletTypeName => throw _privateConstructorUsedError;
  List<VerseModel> get verses =>
      throw _privateConstructorUsedError; // Poem context
  String get poemPublicId => throw _privateConstructorUsedError;
  String? get poemTitle => throw _privateConstructorUsedError;
  String? get poemExcerpt => throw _privateConstructorUsedError;
  String? get poetryType => throw _privateConstructorUsedError;
  int? get totalCoupletsInPoem =>
      throw _privateConstructorUsedError; // Poet context
  String get poetPublicId => throw _privateConstructorUsedError;
  String get poetName => throw _privateConstructorUsedError;
  String? get poetProfileImageUrl =>
      throw _privateConstructorUsedError; // Engagement
  int get likeCount => throw _privateConstructorUsedError;
  int get bookmarkCount => throw _privateConstructorUsedError;
  bool? get isLikedByCurrentUser => throw _privateConstructorUsedError;
  bool? get isBookmarkedByCurrentUser => throw _privateConstructorUsedError;
  DateTime? get bookmarkedAt => throw _privateConstructorUsedError;

  /// Serializes this BookmarkedCoupletResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BookmarkedCoupletResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BookmarkedCoupletResponseCopyWith<BookmarkedCoupletResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BookmarkedCoupletResponseCopyWith<$Res> {
  factory $BookmarkedCoupletResponseCopyWith(BookmarkedCoupletResponse value,
          $Res Function(BookmarkedCoupletResponse) then) =
      _$BookmarkedCoupletResponseCopyWithImpl<$Res, BookmarkedCoupletResponse>;
  @useResult
  $Res call(
      {String coupletPublicId,
      int coupletNumber,
      String coupletType,
      String? coupletTypeName,
      List<VerseModel> verses,
      String poemPublicId,
      String? poemTitle,
      String? poemExcerpt,
      String? poetryType,
      int? totalCoupletsInPoem,
      String poetPublicId,
      String poetName,
      String? poetProfileImageUrl,
      int likeCount,
      int bookmarkCount,
      bool? isLikedByCurrentUser,
      bool? isBookmarkedByCurrentUser,
      DateTime? bookmarkedAt});
}

/// @nodoc
class _$BookmarkedCoupletResponseCopyWithImpl<$Res,
        $Val extends BookmarkedCoupletResponse>
    implements $BookmarkedCoupletResponseCopyWith<$Res> {
  _$BookmarkedCoupletResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BookmarkedCoupletResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? coupletPublicId = null,
    Object? coupletNumber = null,
    Object? coupletType = null,
    Object? coupletTypeName = freezed,
    Object? verses = null,
    Object? poemPublicId = null,
    Object? poemTitle = freezed,
    Object? poemExcerpt = freezed,
    Object? poetryType = freezed,
    Object? totalCoupletsInPoem = freezed,
    Object? poetPublicId = null,
    Object? poetName = null,
    Object? poetProfileImageUrl = freezed,
    Object? likeCount = null,
    Object? bookmarkCount = null,
    Object? isLikedByCurrentUser = freezed,
    Object? isBookmarkedByCurrentUser = freezed,
    Object? bookmarkedAt = freezed,
  }) {
    return _then(_value.copyWith(
      coupletPublicId: null == coupletPublicId
          ? _value.coupletPublicId
          : coupletPublicId // ignore: cast_nullable_to_non_nullable
              as String,
      coupletNumber: null == coupletNumber
          ? _value.coupletNumber
          : coupletNumber // ignore: cast_nullable_to_non_nullable
              as int,
      coupletType: null == coupletType
          ? _value.coupletType
          : coupletType // ignore: cast_nullable_to_non_nullable
              as String,
      coupletTypeName: freezed == coupletTypeName
          ? _value.coupletTypeName
          : coupletTypeName // ignore: cast_nullable_to_non_nullable
              as String?,
      verses: null == verses
          ? _value.verses
          : verses // ignore: cast_nullable_to_non_nullable
              as List<VerseModel>,
      poemPublicId: null == poemPublicId
          ? _value.poemPublicId
          : poemPublicId // ignore: cast_nullable_to_non_nullable
              as String,
      poemTitle: freezed == poemTitle
          ? _value.poemTitle
          : poemTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      poemExcerpt: freezed == poemExcerpt
          ? _value.poemExcerpt
          : poemExcerpt // ignore: cast_nullable_to_non_nullable
              as String?,
      poetryType: freezed == poetryType
          ? _value.poetryType
          : poetryType // ignore: cast_nullable_to_non_nullable
              as String?,
      totalCoupletsInPoem: freezed == totalCoupletsInPoem
          ? _value.totalCoupletsInPoem
          : totalCoupletsInPoem // ignore: cast_nullable_to_non_nullable
              as int?,
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
      likeCount: null == likeCount
          ? _value.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int,
      bookmarkCount: null == bookmarkCount
          ? _value.bookmarkCount
          : bookmarkCount // ignore: cast_nullable_to_non_nullable
              as int,
      isLikedByCurrentUser: freezed == isLikedByCurrentUser
          ? _value.isLikedByCurrentUser
          : isLikedByCurrentUser // ignore: cast_nullable_to_non_nullable
              as bool?,
      isBookmarkedByCurrentUser: freezed == isBookmarkedByCurrentUser
          ? _value.isBookmarkedByCurrentUser
          : isBookmarkedByCurrentUser // ignore: cast_nullable_to_non_nullable
              as bool?,
      bookmarkedAt: freezed == bookmarkedAt
          ? _value.bookmarkedAt
          : bookmarkedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BookmarkedCoupletResponseImplCopyWith<$Res>
    implements $BookmarkedCoupletResponseCopyWith<$Res> {
  factory _$$BookmarkedCoupletResponseImplCopyWith(
          _$BookmarkedCoupletResponseImpl value,
          $Res Function(_$BookmarkedCoupletResponseImpl) then) =
      __$$BookmarkedCoupletResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String coupletPublicId,
      int coupletNumber,
      String coupletType,
      String? coupletTypeName,
      List<VerseModel> verses,
      String poemPublicId,
      String? poemTitle,
      String? poemExcerpt,
      String? poetryType,
      int? totalCoupletsInPoem,
      String poetPublicId,
      String poetName,
      String? poetProfileImageUrl,
      int likeCount,
      int bookmarkCount,
      bool? isLikedByCurrentUser,
      bool? isBookmarkedByCurrentUser,
      DateTime? bookmarkedAt});
}

/// @nodoc
class __$$BookmarkedCoupletResponseImplCopyWithImpl<$Res>
    extends _$BookmarkedCoupletResponseCopyWithImpl<$Res,
        _$BookmarkedCoupletResponseImpl>
    implements _$$BookmarkedCoupletResponseImplCopyWith<$Res> {
  __$$BookmarkedCoupletResponseImplCopyWithImpl(
      _$BookmarkedCoupletResponseImpl _value,
      $Res Function(_$BookmarkedCoupletResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of BookmarkedCoupletResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? coupletPublicId = null,
    Object? coupletNumber = null,
    Object? coupletType = null,
    Object? coupletTypeName = freezed,
    Object? verses = null,
    Object? poemPublicId = null,
    Object? poemTitle = freezed,
    Object? poemExcerpt = freezed,
    Object? poetryType = freezed,
    Object? totalCoupletsInPoem = freezed,
    Object? poetPublicId = null,
    Object? poetName = null,
    Object? poetProfileImageUrl = freezed,
    Object? likeCount = null,
    Object? bookmarkCount = null,
    Object? isLikedByCurrentUser = freezed,
    Object? isBookmarkedByCurrentUser = freezed,
    Object? bookmarkedAt = freezed,
  }) {
    return _then(_$BookmarkedCoupletResponseImpl(
      coupletPublicId: null == coupletPublicId
          ? _value.coupletPublicId
          : coupletPublicId // ignore: cast_nullable_to_non_nullable
              as String,
      coupletNumber: null == coupletNumber
          ? _value.coupletNumber
          : coupletNumber // ignore: cast_nullable_to_non_nullable
              as int,
      coupletType: null == coupletType
          ? _value.coupletType
          : coupletType // ignore: cast_nullable_to_non_nullable
              as String,
      coupletTypeName: freezed == coupletTypeName
          ? _value.coupletTypeName
          : coupletTypeName // ignore: cast_nullable_to_non_nullable
              as String?,
      verses: null == verses
          ? _value._verses
          : verses // ignore: cast_nullable_to_non_nullable
              as List<VerseModel>,
      poemPublicId: null == poemPublicId
          ? _value.poemPublicId
          : poemPublicId // ignore: cast_nullable_to_non_nullable
              as String,
      poemTitle: freezed == poemTitle
          ? _value.poemTitle
          : poemTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      poemExcerpt: freezed == poemExcerpt
          ? _value.poemExcerpt
          : poemExcerpt // ignore: cast_nullable_to_non_nullable
              as String?,
      poetryType: freezed == poetryType
          ? _value.poetryType
          : poetryType // ignore: cast_nullable_to_non_nullable
              as String?,
      totalCoupletsInPoem: freezed == totalCoupletsInPoem
          ? _value.totalCoupletsInPoem
          : totalCoupletsInPoem // ignore: cast_nullable_to_non_nullable
              as int?,
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
      likeCount: null == likeCount
          ? _value.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int,
      bookmarkCount: null == bookmarkCount
          ? _value.bookmarkCount
          : bookmarkCount // ignore: cast_nullable_to_non_nullable
              as int,
      isLikedByCurrentUser: freezed == isLikedByCurrentUser
          ? _value.isLikedByCurrentUser
          : isLikedByCurrentUser // ignore: cast_nullable_to_non_nullable
              as bool?,
      isBookmarkedByCurrentUser: freezed == isBookmarkedByCurrentUser
          ? _value.isBookmarkedByCurrentUser
          : isBookmarkedByCurrentUser // ignore: cast_nullable_to_non_nullable
              as bool?,
      bookmarkedAt: freezed == bookmarkedAt
          ? _value.bookmarkedAt
          : bookmarkedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BookmarkedCoupletResponseImpl implements _BookmarkedCoupletResponse {
  const _$BookmarkedCoupletResponseImpl(
      {required this.coupletPublicId,
      required this.coupletNumber,
      required this.coupletType,
      this.coupletTypeName,
      required final List<VerseModel> verses,
      required this.poemPublicId,
      this.poemTitle,
      this.poemExcerpt,
      this.poetryType,
      this.totalCoupletsInPoem,
      required this.poetPublicId,
      required this.poetName,
      this.poetProfileImageUrl,
      this.likeCount = 0,
      this.bookmarkCount = 0,
      this.isLikedByCurrentUser,
      this.isBookmarkedByCurrentUser,
      this.bookmarkedAt})
      : _verses = verses;

  factory _$BookmarkedCoupletResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$BookmarkedCoupletResponseImplFromJson(json);

  @override
  final String coupletPublicId;
  @override
  final int coupletNumber;
  @override
  final String coupletType;
  @override
  final String? coupletTypeName;
  final List<VerseModel> _verses;
  @override
  List<VerseModel> get verses {
    if (_verses is EqualUnmodifiableListView) return _verses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_verses);
  }

// Poem context
  @override
  final String poemPublicId;
  @override
  final String? poemTitle;
  @override
  final String? poemExcerpt;
  @override
  final String? poetryType;
  @override
  final int? totalCoupletsInPoem;
// Poet context
  @override
  final String poetPublicId;
  @override
  final String poetName;
  @override
  final String? poetProfileImageUrl;
// Engagement
  @override
  @JsonKey()
  final int likeCount;
  @override
  @JsonKey()
  final int bookmarkCount;
  @override
  final bool? isLikedByCurrentUser;
  @override
  final bool? isBookmarkedByCurrentUser;
  @override
  final DateTime? bookmarkedAt;

  @override
  String toString() {
    return 'BookmarkedCoupletResponse(coupletPublicId: $coupletPublicId, coupletNumber: $coupletNumber, coupletType: $coupletType, coupletTypeName: $coupletTypeName, verses: $verses, poemPublicId: $poemPublicId, poemTitle: $poemTitle, poemExcerpt: $poemExcerpt, poetryType: $poetryType, totalCoupletsInPoem: $totalCoupletsInPoem, poetPublicId: $poetPublicId, poetName: $poetName, poetProfileImageUrl: $poetProfileImageUrl, likeCount: $likeCount, bookmarkCount: $bookmarkCount, isLikedByCurrentUser: $isLikedByCurrentUser, isBookmarkedByCurrentUser: $isBookmarkedByCurrentUser, bookmarkedAt: $bookmarkedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookmarkedCoupletResponseImpl &&
            (identical(other.coupletPublicId, coupletPublicId) ||
                other.coupletPublicId == coupletPublicId) &&
            (identical(other.coupletNumber, coupletNumber) ||
                other.coupletNumber == coupletNumber) &&
            (identical(other.coupletType, coupletType) ||
                other.coupletType == coupletType) &&
            (identical(other.coupletTypeName, coupletTypeName) ||
                other.coupletTypeName == coupletTypeName) &&
            const DeepCollectionEquality().equals(other._verses, _verses) &&
            (identical(other.poemPublicId, poemPublicId) ||
                other.poemPublicId == poemPublicId) &&
            (identical(other.poemTitle, poemTitle) ||
                other.poemTitle == poemTitle) &&
            (identical(other.poemExcerpt, poemExcerpt) ||
                other.poemExcerpt == poemExcerpt) &&
            (identical(other.poetryType, poetryType) ||
                other.poetryType == poetryType) &&
            (identical(other.totalCoupletsInPoem, totalCoupletsInPoem) ||
                other.totalCoupletsInPoem == totalCoupletsInPoem) &&
            (identical(other.poetPublicId, poetPublicId) ||
                other.poetPublicId == poetPublicId) &&
            (identical(other.poetName, poetName) ||
                other.poetName == poetName) &&
            (identical(other.poetProfileImageUrl, poetProfileImageUrl) ||
                other.poetProfileImageUrl == poetProfileImageUrl) &&
            (identical(other.likeCount, likeCount) ||
                other.likeCount == likeCount) &&
            (identical(other.bookmarkCount, bookmarkCount) ||
                other.bookmarkCount == bookmarkCount) &&
            (identical(other.isLikedByCurrentUser, isLikedByCurrentUser) ||
                other.isLikedByCurrentUser == isLikedByCurrentUser) &&
            (identical(other.isBookmarkedByCurrentUser,
                    isBookmarkedByCurrentUser) ||
                other.isBookmarkedByCurrentUser == isBookmarkedByCurrentUser) &&
            (identical(other.bookmarkedAt, bookmarkedAt) ||
                other.bookmarkedAt == bookmarkedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      coupletPublicId,
      coupletNumber,
      coupletType,
      coupletTypeName,
      const DeepCollectionEquality().hash(_verses),
      poemPublicId,
      poemTitle,
      poemExcerpt,
      poetryType,
      totalCoupletsInPoem,
      poetPublicId,
      poetName,
      poetProfileImageUrl,
      likeCount,
      bookmarkCount,
      isLikedByCurrentUser,
      isBookmarkedByCurrentUser,
      bookmarkedAt);

  /// Create a copy of BookmarkedCoupletResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BookmarkedCoupletResponseImplCopyWith<_$BookmarkedCoupletResponseImpl>
      get copyWith => __$$BookmarkedCoupletResponseImplCopyWithImpl<
          _$BookmarkedCoupletResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BookmarkedCoupletResponseImplToJson(
      this,
    );
  }
}

abstract class _BookmarkedCoupletResponse implements BookmarkedCoupletResponse {
  const factory _BookmarkedCoupletResponse(
      {required final String coupletPublicId,
      required final int coupletNumber,
      required final String coupletType,
      final String? coupletTypeName,
      required final List<VerseModel> verses,
      required final String poemPublicId,
      final String? poemTitle,
      final String? poemExcerpt,
      final String? poetryType,
      final int? totalCoupletsInPoem,
      required final String poetPublicId,
      required final String poetName,
      final String? poetProfileImageUrl,
      final int likeCount,
      final int bookmarkCount,
      final bool? isLikedByCurrentUser,
      final bool? isBookmarkedByCurrentUser,
      final DateTime? bookmarkedAt}) = _$BookmarkedCoupletResponseImpl;

  factory _BookmarkedCoupletResponse.fromJson(Map<String, dynamic> json) =
      _$BookmarkedCoupletResponseImpl.fromJson;

  @override
  String get coupletPublicId;
  @override
  int get coupletNumber;
  @override
  String get coupletType;
  @override
  String? get coupletTypeName;
  @override
  List<VerseModel> get verses; // Poem context
  @override
  String get poemPublicId;
  @override
  String? get poemTitle;
  @override
  String? get poemExcerpt;
  @override
  String? get poetryType;
  @override
  int? get totalCoupletsInPoem; // Poet context
  @override
  String get poetPublicId;
  @override
  String get poetName;
  @override
  String? get poetProfileImageUrl; // Engagement
  @override
  int get likeCount;
  @override
  int get bookmarkCount;
  @override
  bool? get isLikedByCurrentUser;
  @override
  bool? get isBookmarkedByCurrentUser;
  @override
  DateTime? get bookmarkedAt;

  /// Create a copy of BookmarkedCoupletResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BookmarkedCoupletResponseImplCopyWith<_$BookmarkedCoupletResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}
