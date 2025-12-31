// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'poet_profile_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PoetProfileModel _$PoetProfileModelFromJson(Map<String, dynamic> json) {
  return _PoetProfileModel.fromJson(json);
}

/// @nodoc
mixin _$PoetProfileModel {
  String get publicId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get biography => throw _privateConstructorUsedError;
  @JsonKey(name: 'shortBio')
  String get shortBio => throw _privateConstructorUsedError;
  String? get gender => throw _privateConstructorUsedError;
  String? get era => throw _privateConstructorUsedError;
  int get birthYear => throw _privateConstructorUsedError;
  int? get deathYear => throw _privateConstructorUsedError;
  @JsonKey(name: 'birthDate')
  String? get birthDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'deathDate')
  String? get deathDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'birthPlace')
  String? get birthPlace => throw _privateConstructorUsedError;
  String? get country => throw _privateConstructorUsedError;
  @JsonKey(name: 'countryFlag')
  String? get countryFlag => throw _privateConstructorUsedError;
  @JsonKey(name: 'countryFlagUrl')
  String? get countryFlagUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'primaryLanguageCode')
  String? get primaryLanguageCode => throw _privateConstructorUsedError;
  @JsonKey(name: 'primaryLanguageName')
  String? get primaryLanguageName => throw _privateConstructorUsedError;
  @JsonKey(name: 'isFeatured')
  bool get isFeatured => throw _privateConstructorUsedError;
  @JsonKey(name: 'isTrending')
  bool get isTrending => throw _privateConstructorUsedError;
  @JsonKey(name: 'isVerified')
  bool get isVerified => throw _privateConstructorUsedError;
  @JsonKey(name: 'viewCount')
  int get viewCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'followerCount')
  int get followerCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'poemCount')
  int get poemCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'profileImageUrl')
  String? get profileImageUrl => throw _privateConstructorUsedError;
  List<PoetImageModel>? get gallery => throw _privateConstructorUsedError;
  List<PoetBookModel>? get books => throw _privateConstructorUsedError;
  List<PoetVideoModel>? get videos => throw _privateConstructorUsedError;
  List<String>? get facts => throw _privateConstructorUsedError;
  List<PoetTagModel>? get tags => throw _privateConstructorUsedError;
  @JsonKey(name: 'createdAt')
  String? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updatedAt')
  String? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this PoetProfileModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PoetProfileModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PoetProfileModelCopyWith<PoetProfileModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PoetProfileModelCopyWith<$Res> {
  factory $PoetProfileModelCopyWith(
          PoetProfileModel value, $Res Function(PoetProfileModel) then) =
      _$PoetProfileModelCopyWithImpl<$Res, PoetProfileModel>;
  @useResult
  $Res call(
      {String publicId,
      String name,
      String? biography,
      @JsonKey(name: 'shortBio') String shortBio,
      String? gender,
      String? era,
      int birthYear,
      int? deathYear,
      @JsonKey(name: 'birthDate') String? birthDate,
      @JsonKey(name: 'deathDate') String? deathDate,
      @JsonKey(name: 'birthPlace') String? birthPlace,
      String? country,
      @JsonKey(name: 'countryFlag') String? countryFlag,
      @JsonKey(name: 'countryFlagUrl') String? countryFlagUrl,
      @JsonKey(name: 'primaryLanguageCode') String? primaryLanguageCode,
      @JsonKey(name: 'primaryLanguageName') String? primaryLanguageName,
      @JsonKey(name: 'isFeatured') bool isFeatured,
      @JsonKey(name: 'isTrending') bool isTrending,
      @JsonKey(name: 'isVerified') bool isVerified,
      @JsonKey(name: 'viewCount') int viewCount,
      @JsonKey(name: 'followerCount') int followerCount,
      @JsonKey(name: 'poemCount') int poemCount,
      @JsonKey(name: 'profileImageUrl') String? profileImageUrl,
      List<PoetImageModel>? gallery,
      List<PoetBookModel>? books,
      List<PoetVideoModel>? videos,
      List<String>? facts,
      List<PoetTagModel>? tags,
      @JsonKey(name: 'createdAt') String? createdAt,
      @JsonKey(name: 'updatedAt') String? updatedAt});
}

/// @nodoc
class _$PoetProfileModelCopyWithImpl<$Res, $Val extends PoetProfileModel>
    implements $PoetProfileModelCopyWith<$Res> {
  _$PoetProfileModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PoetProfileModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? publicId = null,
    Object? name = null,
    Object? biography = freezed,
    Object? shortBio = null,
    Object? gender = freezed,
    Object? era = freezed,
    Object? birthYear = null,
    Object? deathYear = freezed,
    Object? birthDate = freezed,
    Object? deathDate = freezed,
    Object? birthPlace = freezed,
    Object? country = freezed,
    Object? countryFlag = freezed,
    Object? countryFlagUrl = freezed,
    Object? primaryLanguageCode = freezed,
    Object? primaryLanguageName = freezed,
    Object? isFeatured = null,
    Object? isTrending = null,
    Object? isVerified = null,
    Object? viewCount = null,
    Object? followerCount = null,
    Object? poemCount = null,
    Object? profileImageUrl = freezed,
    Object? gallery = freezed,
    Object? books = freezed,
    Object? videos = freezed,
    Object? facts = freezed,
    Object? tags = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
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
      biography: freezed == biography
          ? _value.biography
          : biography // ignore: cast_nullable_to_non_nullable
              as String?,
      shortBio: null == shortBio
          ? _value.shortBio
          : shortBio // ignore: cast_nullable_to_non_nullable
              as String,
      gender: freezed == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String?,
      era: freezed == era
          ? _value.era
          : era // ignore: cast_nullable_to_non_nullable
              as String?,
      birthYear: null == birthYear
          ? _value.birthYear
          : birthYear // ignore: cast_nullable_to_non_nullable
              as int,
      deathYear: freezed == deathYear
          ? _value.deathYear
          : deathYear // ignore: cast_nullable_to_non_nullable
              as int?,
      birthDate: freezed == birthDate
          ? _value.birthDate
          : birthDate // ignore: cast_nullable_to_non_nullable
              as String?,
      deathDate: freezed == deathDate
          ? _value.deathDate
          : deathDate // ignore: cast_nullable_to_non_nullable
              as String?,
      birthPlace: freezed == birthPlace
          ? _value.birthPlace
          : birthPlace // ignore: cast_nullable_to_non_nullable
              as String?,
      country: freezed == country
          ? _value.country
          : country // ignore: cast_nullable_to_non_nullable
              as String?,
      countryFlag: freezed == countryFlag
          ? _value.countryFlag
          : countryFlag // ignore: cast_nullable_to_non_nullable
              as String?,
      countryFlagUrl: freezed == countryFlagUrl
          ? _value.countryFlagUrl
          : countryFlagUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      primaryLanguageCode: freezed == primaryLanguageCode
          ? _value.primaryLanguageCode
          : primaryLanguageCode // ignore: cast_nullable_to_non_nullable
              as String?,
      primaryLanguageName: freezed == primaryLanguageName
          ? _value.primaryLanguageName
          : primaryLanguageName // ignore: cast_nullable_to_non_nullable
              as String?,
      isFeatured: null == isFeatured
          ? _value.isFeatured
          : isFeatured // ignore: cast_nullable_to_non_nullable
              as bool,
      isTrending: null == isTrending
          ? _value.isTrending
          : isTrending // ignore: cast_nullable_to_non_nullable
              as bool,
      isVerified: null == isVerified
          ? _value.isVerified
          : isVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      viewCount: null == viewCount
          ? _value.viewCount
          : viewCount // ignore: cast_nullable_to_non_nullable
              as int,
      followerCount: null == followerCount
          ? _value.followerCount
          : followerCount // ignore: cast_nullable_to_non_nullable
              as int,
      poemCount: null == poemCount
          ? _value.poemCount
          : poemCount // ignore: cast_nullable_to_non_nullable
              as int,
      profileImageUrl: freezed == profileImageUrl
          ? _value.profileImageUrl
          : profileImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      gallery: freezed == gallery
          ? _value.gallery
          : gallery // ignore: cast_nullable_to_non_nullable
              as List<PoetImageModel>?,
      books: freezed == books
          ? _value.books
          : books // ignore: cast_nullable_to_non_nullable
              as List<PoetBookModel>?,
      videos: freezed == videos
          ? _value.videos
          : videos // ignore: cast_nullable_to_non_nullable
              as List<PoetVideoModel>?,
      facts: freezed == facts
          ? _value.facts
          : facts // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      tags: freezed == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<PoetTagModel>?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PoetProfileModelImplCopyWith<$Res>
    implements $PoetProfileModelCopyWith<$Res> {
  factory _$$PoetProfileModelImplCopyWith(_$PoetProfileModelImpl value,
          $Res Function(_$PoetProfileModelImpl) then) =
      __$$PoetProfileModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String publicId,
      String name,
      String? biography,
      @JsonKey(name: 'shortBio') String shortBio,
      String? gender,
      String? era,
      int birthYear,
      int? deathYear,
      @JsonKey(name: 'birthDate') String? birthDate,
      @JsonKey(name: 'deathDate') String? deathDate,
      @JsonKey(name: 'birthPlace') String? birthPlace,
      String? country,
      @JsonKey(name: 'countryFlag') String? countryFlag,
      @JsonKey(name: 'countryFlagUrl') String? countryFlagUrl,
      @JsonKey(name: 'primaryLanguageCode') String? primaryLanguageCode,
      @JsonKey(name: 'primaryLanguageName') String? primaryLanguageName,
      @JsonKey(name: 'isFeatured') bool isFeatured,
      @JsonKey(name: 'isTrending') bool isTrending,
      @JsonKey(name: 'isVerified') bool isVerified,
      @JsonKey(name: 'viewCount') int viewCount,
      @JsonKey(name: 'followerCount') int followerCount,
      @JsonKey(name: 'poemCount') int poemCount,
      @JsonKey(name: 'profileImageUrl') String? profileImageUrl,
      List<PoetImageModel>? gallery,
      List<PoetBookModel>? books,
      List<PoetVideoModel>? videos,
      List<String>? facts,
      List<PoetTagModel>? tags,
      @JsonKey(name: 'createdAt') String? createdAt,
      @JsonKey(name: 'updatedAt') String? updatedAt});
}

/// @nodoc
class __$$PoetProfileModelImplCopyWithImpl<$Res>
    extends _$PoetProfileModelCopyWithImpl<$Res, _$PoetProfileModelImpl>
    implements _$$PoetProfileModelImplCopyWith<$Res> {
  __$$PoetProfileModelImplCopyWithImpl(_$PoetProfileModelImpl _value,
      $Res Function(_$PoetProfileModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of PoetProfileModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? publicId = null,
    Object? name = null,
    Object? biography = freezed,
    Object? shortBio = null,
    Object? gender = freezed,
    Object? era = freezed,
    Object? birthYear = null,
    Object? deathYear = freezed,
    Object? birthDate = freezed,
    Object? deathDate = freezed,
    Object? birthPlace = freezed,
    Object? country = freezed,
    Object? countryFlag = freezed,
    Object? countryFlagUrl = freezed,
    Object? primaryLanguageCode = freezed,
    Object? primaryLanguageName = freezed,
    Object? isFeatured = null,
    Object? isTrending = null,
    Object? isVerified = null,
    Object? viewCount = null,
    Object? followerCount = null,
    Object? poemCount = null,
    Object? profileImageUrl = freezed,
    Object? gallery = freezed,
    Object? books = freezed,
    Object? videos = freezed,
    Object? facts = freezed,
    Object? tags = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$PoetProfileModelImpl(
      publicId: null == publicId
          ? _value.publicId
          : publicId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      biography: freezed == biography
          ? _value.biography
          : biography // ignore: cast_nullable_to_non_nullable
              as String?,
      shortBio: null == shortBio
          ? _value.shortBio
          : shortBio // ignore: cast_nullable_to_non_nullable
              as String,
      gender: freezed == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String?,
      era: freezed == era
          ? _value.era
          : era // ignore: cast_nullable_to_non_nullable
              as String?,
      birthYear: null == birthYear
          ? _value.birthYear
          : birthYear // ignore: cast_nullable_to_non_nullable
              as int,
      deathYear: freezed == deathYear
          ? _value.deathYear
          : deathYear // ignore: cast_nullable_to_non_nullable
              as int?,
      birthDate: freezed == birthDate
          ? _value.birthDate
          : birthDate // ignore: cast_nullable_to_non_nullable
              as String?,
      deathDate: freezed == deathDate
          ? _value.deathDate
          : deathDate // ignore: cast_nullable_to_non_nullable
              as String?,
      birthPlace: freezed == birthPlace
          ? _value.birthPlace
          : birthPlace // ignore: cast_nullable_to_non_nullable
              as String?,
      country: freezed == country
          ? _value.country
          : country // ignore: cast_nullable_to_non_nullable
              as String?,
      countryFlag: freezed == countryFlag
          ? _value.countryFlag
          : countryFlag // ignore: cast_nullable_to_non_nullable
              as String?,
      countryFlagUrl: freezed == countryFlagUrl
          ? _value.countryFlagUrl
          : countryFlagUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      primaryLanguageCode: freezed == primaryLanguageCode
          ? _value.primaryLanguageCode
          : primaryLanguageCode // ignore: cast_nullable_to_non_nullable
              as String?,
      primaryLanguageName: freezed == primaryLanguageName
          ? _value.primaryLanguageName
          : primaryLanguageName // ignore: cast_nullable_to_non_nullable
              as String?,
      isFeatured: null == isFeatured
          ? _value.isFeatured
          : isFeatured // ignore: cast_nullable_to_non_nullable
              as bool,
      isTrending: null == isTrending
          ? _value.isTrending
          : isTrending // ignore: cast_nullable_to_non_nullable
              as bool,
      isVerified: null == isVerified
          ? _value.isVerified
          : isVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      viewCount: null == viewCount
          ? _value.viewCount
          : viewCount // ignore: cast_nullable_to_non_nullable
              as int,
      followerCount: null == followerCount
          ? _value.followerCount
          : followerCount // ignore: cast_nullable_to_non_nullable
              as int,
      poemCount: null == poemCount
          ? _value.poemCount
          : poemCount // ignore: cast_nullable_to_non_nullable
              as int,
      profileImageUrl: freezed == profileImageUrl
          ? _value.profileImageUrl
          : profileImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      gallery: freezed == gallery
          ? _value._gallery
          : gallery // ignore: cast_nullable_to_non_nullable
              as List<PoetImageModel>?,
      books: freezed == books
          ? _value._books
          : books // ignore: cast_nullable_to_non_nullable
              as List<PoetBookModel>?,
      videos: freezed == videos
          ? _value._videos
          : videos // ignore: cast_nullable_to_non_nullable
              as List<PoetVideoModel>?,
      facts: freezed == facts
          ? _value._facts
          : facts // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      tags: freezed == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<PoetTagModel>?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PoetProfileModelImpl implements _PoetProfileModel {
  const _$PoetProfileModelImpl(
      {required this.publicId,
      required this.name,
      this.biography,
      @JsonKey(name: 'shortBio') required this.shortBio,
      this.gender,
      this.era,
      required this.birthYear,
      this.deathYear,
      @JsonKey(name: 'birthDate') this.birthDate,
      @JsonKey(name: 'deathDate') this.deathDate,
      @JsonKey(name: 'birthPlace') this.birthPlace,
      this.country,
      @JsonKey(name: 'countryFlag') this.countryFlag,
      @JsonKey(name: 'countryFlagUrl') this.countryFlagUrl,
      @JsonKey(name: 'primaryLanguageCode') this.primaryLanguageCode,
      @JsonKey(name: 'primaryLanguageName') this.primaryLanguageName,
      @JsonKey(name: 'isFeatured') required this.isFeatured,
      @JsonKey(name: 'isTrending') required this.isTrending,
      @JsonKey(name: 'isVerified') required this.isVerified,
      @JsonKey(name: 'viewCount') required this.viewCount,
      @JsonKey(name: 'followerCount') required this.followerCount,
      @JsonKey(name: 'poemCount') required this.poemCount,
      @JsonKey(name: 'profileImageUrl') this.profileImageUrl,
      final List<PoetImageModel>? gallery,
      final List<PoetBookModel>? books,
      final List<PoetVideoModel>? videos,
      final List<String>? facts,
      final List<PoetTagModel>? tags,
      @JsonKey(name: 'createdAt') this.createdAt,
      @JsonKey(name: 'updatedAt') this.updatedAt})
      : _gallery = gallery,
        _books = books,
        _videos = videos,
        _facts = facts,
        _tags = tags;

  factory _$PoetProfileModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PoetProfileModelImplFromJson(json);

  @override
  final String publicId;
  @override
  final String name;
  @override
  final String? biography;
  @override
  @JsonKey(name: 'shortBio')
  final String shortBio;
  @override
  final String? gender;
  @override
  final String? era;
  @override
  final int birthYear;
  @override
  final int? deathYear;
  @override
  @JsonKey(name: 'birthDate')
  final String? birthDate;
  @override
  @JsonKey(name: 'deathDate')
  final String? deathDate;
  @override
  @JsonKey(name: 'birthPlace')
  final String? birthPlace;
  @override
  final String? country;
  @override
  @JsonKey(name: 'countryFlag')
  final String? countryFlag;
  @override
  @JsonKey(name: 'countryFlagUrl')
  final String? countryFlagUrl;
  @override
  @JsonKey(name: 'primaryLanguageCode')
  final String? primaryLanguageCode;
  @override
  @JsonKey(name: 'primaryLanguageName')
  final String? primaryLanguageName;
  @override
  @JsonKey(name: 'isFeatured')
  final bool isFeatured;
  @override
  @JsonKey(name: 'isTrending')
  final bool isTrending;
  @override
  @JsonKey(name: 'isVerified')
  final bool isVerified;
  @override
  @JsonKey(name: 'viewCount')
  final int viewCount;
  @override
  @JsonKey(name: 'followerCount')
  final int followerCount;
  @override
  @JsonKey(name: 'poemCount')
  final int poemCount;
  @override
  @JsonKey(name: 'profileImageUrl')
  final String? profileImageUrl;
  final List<PoetImageModel>? _gallery;
  @override
  List<PoetImageModel>? get gallery {
    final value = _gallery;
    if (value == null) return null;
    if (_gallery is EqualUnmodifiableListView) return _gallery;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<PoetBookModel>? _books;
  @override
  List<PoetBookModel>? get books {
    final value = _books;
    if (value == null) return null;
    if (_books is EqualUnmodifiableListView) return _books;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<PoetVideoModel>? _videos;
  @override
  List<PoetVideoModel>? get videos {
    final value = _videos;
    if (value == null) return null;
    if (_videos is EqualUnmodifiableListView) return _videos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _facts;
  @override
  List<String>? get facts {
    final value = _facts;
    if (value == null) return null;
    if (_facts is EqualUnmodifiableListView) return _facts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<PoetTagModel>? _tags;
  @override
  List<PoetTagModel>? get tags {
    final value = _tags;
    if (value == null) return null;
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'createdAt')
  final String? createdAt;
  @override
  @JsonKey(name: 'updatedAt')
  final String? updatedAt;

  @override
  String toString() {
    return 'PoetProfileModel(publicId: $publicId, name: $name, biography: $biography, shortBio: $shortBio, gender: $gender, era: $era, birthYear: $birthYear, deathYear: $deathYear, birthDate: $birthDate, deathDate: $deathDate, birthPlace: $birthPlace, country: $country, countryFlag: $countryFlag, countryFlagUrl: $countryFlagUrl, primaryLanguageCode: $primaryLanguageCode, primaryLanguageName: $primaryLanguageName, isFeatured: $isFeatured, isTrending: $isTrending, isVerified: $isVerified, viewCount: $viewCount, followerCount: $followerCount, poemCount: $poemCount, profileImageUrl: $profileImageUrl, gallery: $gallery, books: $books, videos: $videos, facts: $facts, tags: $tags, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PoetProfileModelImpl &&
            (identical(other.publicId, publicId) ||
                other.publicId == publicId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.biography, biography) ||
                other.biography == biography) &&
            (identical(other.shortBio, shortBio) ||
                other.shortBio == shortBio) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.era, era) || other.era == era) &&
            (identical(other.birthYear, birthYear) ||
                other.birthYear == birthYear) &&
            (identical(other.deathYear, deathYear) ||
                other.deathYear == deathYear) &&
            (identical(other.birthDate, birthDate) ||
                other.birthDate == birthDate) &&
            (identical(other.deathDate, deathDate) ||
                other.deathDate == deathDate) &&
            (identical(other.birthPlace, birthPlace) ||
                other.birthPlace == birthPlace) &&
            (identical(other.country, country) || other.country == country) &&
            (identical(other.countryFlag, countryFlag) ||
                other.countryFlag == countryFlag) &&
            (identical(other.countryFlagUrl, countryFlagUrl) ||
                other.countryFlagUrl == countryFlagUrl) &&
            (identical(other.primaryLanguageCode, primaryLanguageCode) ||
                other.primaryLanguageCode == primaryLanguageCode) &&
            (identical(other.primaryLanguageName, primaryLanguageName) ||
                other.primaryLanguageName == primaryLanguageName) &&
            (identical(other.isFeatured, isFeatured) ||
                other.isFeatured == isFeatured) &&
            (identical(other.isTrending, isTrending) ||
                other.isTrending == isTrending) &&
            (identical(other.isVerified, isVerified) ||
                other.isVerified == isVerified) &&
            (identical(other.viewCount, viewCount) ||
                other.viewCount == viewCount) &&
            (identical(other.followerCount, followerCount) ||
                other.followerCount == followerCount) &&
            (identical(other.poemCount, poemCount) ||
                other.poemCount == poemCount) &&
            (identical(other.profileImageUrl, profileImageUrl) ||
                other.profileImageUrl == profileImageUrl) &&
            const DeepCollectionEquality().equals(other._gallery, _gallery) &&
            const DeepCollectionEquality().equals(other._books, _books) &&
            const DeepCollectionEquality().equals(other._videos, _videos) &&
            const DeepCollectionEquality().equals(other._facts, _facts) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
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
        name,
        biography,
        shortBio,
        gender,
        era,
        birthYear,
        deathYear,
        birthDate,
        deathDate,
        birthPlace,
        country,
        countryFlag,
        countryFlagUrl,
        primaryLanguageCode,
        primaryLanguageName,
        isFeatured,
        isTrending,
        isVerified,
        viewCount,
        followerCount,
        poemCount,
        profileImageUrl,
        const DeepCollectionEquality().hash(_gallery),
        const DeepCollectionEquality().hash(_books),
        const DeepCollectionEquality().hash(_videos),
        const DeepCollectionEquality().hash(_facts),
        const DeepCollectionEquality().hash(_tags),
        createdAt,
        updatedAt
      ]);

  /// Create a copy of PoetProfileModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PoetProfileModelImplCopyWith<_$PoetProfileModelImpl> get copyWith =>
      __$$PoetProfileModelImplCopyWithImpl<_$PoetProfileModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PoetProfileModelImplToJson(
      this,
    );
  }
}

abstract class _PoetProfileModel implements PoetProfileModel {
  const factory _PoetProfileModel(
      {required final String publicId,
      required final String name,
      final String? biography,
      @JsonKey(name: 'shortBio') required final String shortBio,
      final String? gender,
      final String? era,
      required final int birthYear,
      final int? deathYear,
      @JsonKey(name: 'birthDate') final String? birthDate,
      @JsonKey(name: 'deathDate') final String? deathDate,
      @JsonKey(name: 'birthPlace') final String? birthPlace,
      final String? country,
      @JsonKey(name: 'countryFlag') final String? countryFlag,
      @JsonKey(name: 'countryFlagUrl') final String? countryFlagUrl,
      @JsonKey(name: 'primaryLanguageCode') final String? primaryLanguageCode,
      @JsonKey(name: 'primaryLanguageName') final String? primaryLanguageName,
      @JsonKey(name: 'isFeatured') required final bool isFeatured,
      @JsonKey(name: 'isTrending') required final bool isTrending,
      @JsonKey(name: 'isVerified') required final bool isVerified,
      @JsonKey(name: 'viewCount') required final int viewCount,
      @JsonKey(name: 'followerCount') required final int followerCount,
      @JsonKey(name: 'poemCount') required final int poemCount,
      @JsonKey(name: 'profileImageUrl') final String? profileImageUrl,
      final List<PoetImageModel>? gallery,
      final List<PoetBookModel>? books,
      final List<PoetVideoModel>? videos,
      final List<String>? facts,
      final List<PoetTagModel>? tags,
      @JsonKey(name: 'createdAt') final String? createdAt,
      @JsonKey(name: 'updatedAt')
      final String? updatedAt}) = _$PoetProfileModelImpl;

  factory _PoetProfileModel.fromJson(Map<String, dynamic> json) =
      _$PoetProfileModelImpl.fromJson;

  @override
  String get publicId;
  @override
  String get name;
  @override
  String? get biography;
  @override
  @JsonKey(name: 'shortBio')
  String get shortBio;
  @override
  String? get gender;
  @override
  String? get era;
  @override
  int get birthYear;
  @override
  int? get deathYear;
  @override
  @JsonKey(name: 'birthDate')
  String? get birthDate;
  @override
  @JsonKey(name: 'deathDate')
  String? get deathDate;
  @override
  @JsonKey(name: 'birthPlace')
  String? get birthPlace;
  @override
  String? get country;
  @override
  @JsonKey(name: 'countryFlag')
  String? get countryFlag;
  @override
  @JsonKey(name: 'countryFlagUrl')
  String? get countryFlagUrl;
  @override
  @JsonKey(name: 'primaryLanguageCode')
  String? get primaryLanguageCode;
  @override
  @JsonKey(name: 'primaryLanguageName')
  String? get primaryLanguageName;
  @override
  @JsonKey(name: 'isFeatured')
  bool get isFeatured;
  @override
  @JsonKey(name: 'isTrending')
  bool get isTrending;
  @override
  @JsonKey(name: 'isVerified')
  bool get isVerified;
  @override
  @JsonKey(name: 'viewCount')
  int get viewCount;
  @override
  @JsonKey(name: 'followerCount')
  int get followerCount;
  @override
  @JsonKey(name: 'poemCount')
  int get poemCount;
  @override
  @JsonKey(name: 'profileImageUrl')
  String? get profileImageUrl;
  @override
  List<PoetImageModel>? get gallery;
  @override
  List<PoetBookModel>? get books;
  @override
  List<PoetVideoModel>? get videos;
  @override
  List<String>? get facts;
  @override
  List<PoetTagModel>? get tags;
  @override
  @JsonKey(name: 'createdAt')
  String? get createdAt;
  @override
  @JsonKey(name: 'updatedAt')
  String? get updatedAt;

  /// Create a copy of PoetProfileModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PoetProfileModelImplCopyWith<_$PoetProfileModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
