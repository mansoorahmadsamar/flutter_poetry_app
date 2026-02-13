// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'poet_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PoetModel _$PoetModelFromJson(Map<String, dynamic> json) {
  return _PoetModel.fromJson(json);
}

/// @nodoc
mixin _$PoetModel {
  String get publicId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'shortBio')
  String get shortBio => throw _privateConstructorUsedError;
  int get birthYear => throw _privateConstructorUsedError;
  int get deathYear => throw _privateConstructorUsedError;
  @JsonKey(name: 'profileImageUrl')
  String? get profileImageUrl => throw _privateConstructorUsedError;
  String? get gender =>
      throw _privateConstructorUsedError; // MALE, FEMALE, OTHER
  String? get era =>
      throw _privateConstructorUsedError; // CLASSICAL, MODERN, CONTEMPORARY, EMERGING
  int get poemCount => throw _privateConstructorUsedError;
  int get viewCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'isFeatured')
  bool get isFeatured => throw _privateConstructorUsedError;
  @JsonKey(name: 'isTrending')
  bool get isTrending => throw _privateConstructorUsedError;
  @JsonKey(name: 'birthPlace')
  String? get birthPlace => throw _privateConstructorUsedError;
  String? get country => throw _privateConstructorUsedError;
  @JsonKey(name: 'countryFlag')
  String? get countryFlag => throw _privateConstructorUsedError;
  @JsonKey(name: 'countryFlagUrl')
  String? get countryFlagUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'topTags')
  List<String> get topTags => throw _privateConstructorUsedError;
  @JsonKey(name: 'isActive')
  bool get isActive => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PoetModelCopyWith<PoetModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PoetModelCopyWith<$Res> {
  factory $PoetModelCopyWith(PoetModel value, $Res Function(PoetModel) then) =
      _$PoetModelCopyWithImpl<$Res, PoetModel>;
  @useResult
  $Res call(
      {String publicId,
      String name,
      @JsonKey(name: 'shortBio') String shortBio,
      int birthYear,
      int deathYear,
      @JsonKey(name: 'profileImageUrl') String? profileImageUrl,
      String? gender,
      String? era,
      int poemCount,
      int viewCount,
      @JsonKey(name: 'isFeatured') bool isFeatured,
      @JsonKey(name: 'isTrending') bool isTrending,
      @JsonKey(name: 'birthPlace') String? birthPlace,
      String? country,
      @JsonKey(name: 'countryFlag') String? countryFlag,
      @JsonKey(name: 'countryFlagUrl') String? countryFlagUrl,
      @JsonKey(name: 'topTags') List<String> topTags,
      @JsonKey(name: 'isActive') bool isActive});
}

/// @nodoc
class _$PoetModelCopyWithImpl<$Res, $Val extends PoetModel>
    implements $PoetModelCopyWith<$Res> {
  _$PoetModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? publicId = null,
    Object? name = null,
    Object? shortBio = null,
    Object? birthYear = null,
    Object? deathYear = null,
    Object? profileImageUrl = freezed,
    Object? gender = freezed,
    Object? era = freezed,
    Object? poemCount = null,
    Object? viewCount = null,
    Object? isFeatured = null,
    Object? isTrending = null,
    Object? birthPlace = freezed,
    Object? country = freezed,
    Object? countryFlag = freezed,
    Object? countryFlagUrl = freezed,
    Object? topTags = null,
    Object? isActive = null,
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
      shortBio: null == shortBio
          ? _value.shortBio
          : shortBio // ignore: cast_nullable_to_non_nullable
              as String,
      birthYear: null == birthYear
          ? _value.birthYear
          : birthYear // ignore: cast_nullable_to_non_nullable
              as int,
      deathYear: null == deathYear
          ? _value.deathYear
          : deathYear // ignore: cast_nullable_to_non_nullable
              as int,
      profileImageUrl: freezed == profileImageUrl
          ? _value.profileImageUrl
          : profileImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      gender: freezed == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String?,
      era: freezed == era
          ? _value.era
          : era // ignore: cast_nullable_to_non_nullable
              as String?,
      poemCount: null == poemCount
          ? _value.poemCount
          : poemCount // ignore: cast_nullable_to_non_nullable
              as int,
      viewCount: null == viewCount
          ? _value.viewCount
          : viewCount // ignore: cast_nullable_to_non_nullable
              as int,
      isFeatured: null == isFeatured
          ? _value.isFeatured
          : isFeatured // ignore: cast_nullable_to_non_nullable
              as bool,
      isTrending: null == isTrending
          ? _value.isTrending
          : isTrending // ignore: cast_nullable_to_non_nullable
              as bool,
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
      topTags: null == topTags
          ? _value.topTags
          : topTags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PoetModelImplCopyWith<$Res>
    implements $PoetModelCopyWith<$Res> {
  factory _$$PoetModelImplCopyWith(
          _$PoetModelImpl value, $Res Function(_$PoetModelImpl) then) =
      __$$PoetModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String publicId,
      String name,
      @JsonKey(name: 'shortBio') String shortBio,
      int birthYear,
      int deathYear,
      @JsonKey(name: 'profileImageUrl') String? profileImageUrl,
      String? gender,
      String? era,
      int poemCount,
      int viewCount,
      @JsonKey(name: 'isFeatured') bool isFeatured,
      @JsonKey(name: 'isTrending') bool isTrending,
      @JsonKey(name: 'birthPlace') String? birthPlace,
      String? country,
      @JsonKey(name: 'countryFlag') String? countryFlag,
      @JsonKey(name: 'countryFlagUrl') String? countryFlagUrl,
      @JsonKey(name: 'topTags') List<String> topTags,
      @JsonKey(name: 'isActive') bool isActive});
}

/// @nodoc
class __$$PoetModelImplCopyWithImpl<$Res>
    extends _$PoetModelCopyWithImpl<$Res, _$PoetModelImpl>
    implements _$$PoetModelImplCopyWith<$Res> {
  __$$PoetModelImplCopyWithImpl(
      _$PoetModelImpl _value, $Res Function(_$PoetModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? publicId = null,
    Object? name = null,
    Object? shortBio = null,
    Object? birthYear = null,
    Object? deathYear = null,
    Object? profileImageUrl = freezed,
    Object? gender = freezed,
    Object? era = freezed,
    Object? poemCount = null,
    Object? viewCount = null,
    Object? isFeatured = null,
    Object? isTrending = null,
    Object? birthPlace = freezed,
    Object? country = freezed,
    Object? countryFlag = freezed,
    Object? countryFlagUrl = freezed,
    Object? topTags = null,
    Object? isActive = null,
  }) {
    return _then(_$PoetModelImpl(
      publicId: null == publicId
          ? _value.publicId
          : publicId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      shortBio: null == shortBio
          ? _value.shortBio
          : shortBio // ignore: cast_nullable_to_non_nullable
              as String,
      birthYear: null == birthYear
          ? _value.birthYear
          : birthYear // ignore: cast_nullable_to_non_nullable
              as int,
      deathYear: null == deathYear
          ? _value.deathYear
          : deathYear // ignore: cast_nullable_to_non_nullable
              as int,
      profileImageUrl: freezed == profileImageUrl
          ? _value.profileImageUrl
          : profileImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      gender: freezed == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String?,
      era: freezed == era
          ? _value.era
          : era // ignore: cast_nullable_to_non_nullable
              as String?,
      poemCount: null == poemCount
          ? _value.poemCount
          : poemCount // ignore: cast_nullable_to_non_nullable
              as int,
      viewCount: null == viewCount
          ? _value.viewCount
          : viewCount // ignore: cast_nullable_to_non_nullable
              as int,
      isFeatured: null == isFeatured
          ? _value.isFeatured
          : isFeatured // ignore: cast_nullable_to_non_nullable
              as bool,
      isTrending: null == isTrending
          ? _value.isTrending
          : isTrending // ignore: cast_nullable_to_non_nullable
              as bool,
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
      topTags: null == topTags
          ? _value._topTags
          : topTags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PoetModelImpl implements _PoetModel {
  const _$PoetModelImpl(
      {required this.publicId,
      required this.name,
      @JsonKey(name: 'shortBio') required this.shortBio,
      required this.birthYear,
      this.deathYear = 0,
      @JsonKey(name: 'profileImageUrl') this.profileImageUrl,
      this.gender,
      this.era,
      this.poemCount = 0,
      this.viewCount = 0,
      @JsonKey(name: 'isFeatured') this.isFeatured = false,
      @JsonKey(name: 'isTrending') this.isTrending = false,
      @JsonKey(name: 'birthPlace') this.birthPlace,
      this.country,
      @JsonKey(name: 'countryFlag') this.countryFlag,
      @JsonKey(name: 'countryFlagUrl') this.countryFlagUrl,
      @JsonKey(name: 'topTags') final List<String> topTags = const [],
      @JsonKey(name: 'isActive') this.isActive = true})
      : _topTags = topTags;

  factory _$PoetModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PoetModelImplFromJson(json);

  @override
  final String publicId;
  @override
  final String name;
  @override
  @JsonKey(name: 'shortBio')
  final String shortBio;
  @override
  final int birthYear;
  @override
  @JsonKey()
  final int deathYear;
  @override
  @JsonKey(name: 'profileImageUrl')
  final String? profileImageUrl;
  @override
  final String? gender;
// MALE, FEMALE, OTHER
  @override
  final String? era;
// CLASSICAL, MODERN, CONTEMPORARY, EMERGING
  @override
  @JsonKey()
  final int poemCount;
  @override
  @JsonKey()
  final int viewCount;
  @override
  @JsonKey(name: 'isFeatured')
  final bool isFeatured;
  @override
  @JsonKey(name: 'isTrending')
  final bool isTrending;
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
  final List<String> _topTags;
  @override
  @JsonKey(name: 'topTags')
  List<String> get topTags {
    if (_topTags is EqualUnmodifiableListView) return _topTags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_topTags);
  }

  @override
  @JsonKey(name: 'isActive')
  final bool isActive;

  @override
  String toString() {
    return 'PoetModel(publicId: $publicId, name: $name, shortBio: $shortBio, birthYear: $birthYear, deathYear: $deathYear, profileImageUrl: $profileImageUrl, gender: $gender, era: $era, poemCount: $poemCount, viewCount: $viewCount, isFeatured: $isFeatured, isTrending: $isTrending, birthPlace: $birthPlace, country: $country, countryFlag: $countryFlag, countryFlagUrl: $countryFlagUrl, topTags: $topTags, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PoetModelImpl &&
            (identical(other.publicId, publicId) ||
                other.publicId == publicId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.shortBio, shortBio) ||
                other.shortBio == shortBio) &&
            (identical(other.birthYear, birthYear) ||
                other.birthYear == birthYear) &&
            (identical(other.deathYear, deathYear) ||
                other.deathYear == deathYear) &&
            (identical(other.profileImageUrl, profileImageUrl) ||
                other.profileImageUrl == profileImageUrl) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.era, era) || other.era == era) &&
            (identical(other.poemCount, poemCount) ||
                other.poemCount == poemCount) &&
            (identical(other.viewCount, viewCount) ||
                other.viewCount == viewCount) &&
            (identical(other.isFeatured, isFeatured) ||
                other.isFeatured == isFeatured) &&
            (identical(other.isTrending, isTrending) ||
                other.isTrending == isTrending) &&
            (identical(other.birthPlace, birthPlace) ||
                other.birthPlace == birthPlace) &&
            (identical(other.country, country) || other.country == country) &&
            (identical(other.countryFlag, countryFlag) ||
                other.countryFlag == countryFlag) &&
            (identical(other.countryFlagUrl, countryFlagUrl) ||
                other.countryFlagUrl == countryFlagUrl) &&
            const DeepCollectionEquality().equals(other._topTags, _topTags) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      publicId,
      name,
      shortBio,
      birthYear,
      deathYear,
      profileImageUrl,
      gender,
      era,
      poemCount,
      viewCount,
      isFeatured,
      isTrending,
      birthPlace,
      country,
      countryFlag,
      countryFlagUrl,
      const DeepCollectionEquality().hash(_topTags),
      isActive);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PoetModelImplCopyWith<_$PoetModelImpl> get copyWith =>
      __$$PoetModelImplCopyWithImpl<_$PoetModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PoetModelImplToJson(
      this,
    );
  }
}

abstract class _PoetModel implements PoetModel {
  const factory _PoetModel(
      {required final String publicId,
      required final String name,
      @JsonKey(name: 'shortBio') required final String shortBio,
      required final int birthYear,
      final int deathYear,
      @JsonKey(name: 'profileImageUrl') final String? profileImageUrl,
      final String? gender,
      final String? era,
      final int poemCount,
      final int viewCount,
      @JsonKey(name: 'isFeatured') final bool isFeatured,
      @JsonKey(name: 'isTrending') final bool isTrending,
      @JsonKey(name: 'birthPlace') final String? birthPlace,
      final String? country,
      @JsonKey(name: 'countryFlag') final String? countryFlag,
      @JsonKey(name: 'countryFlagUrl') final String? countryFlagUrl,
      @JsonKey(name: 'topTags') final List<String> topTags,
      @JsonKey(name: 'isActive') final bool isActive}) = _$PoetModelImpl;

  factory _PoetModel.fromJson(Map<String, dynamic> json) =
      _$PoetModelImpl.fromJson;

  @override
  String get publicId;
  @override
  String get name;
  @override
  @JsonKey(name: 'shortBio')
  String get shortBio;
  @override
  int get birthYear;
  @override
  int get deathYear;
  @override
  @JsonKey(name: 'profileImageUrl')
  String? get profileImageUrl;
  @override
  String? get gender;
  @override // MALE, FEMALE, OTHER
  String? get era;
  @override // CLASSICAL, MODERN, CONTEMPORARY, EMERGING
  int get poemCount;
  @override
  int get viewCount;
  @override
  @JsonKey(name: 'isFeatured')
  bool get isFeatured;
  @override
  @JsonKey(name: 'isTrending')
  bool get isTrending;
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
  @JsonKey(name: 'topTags')
  List<String> get topTags;
  @override
  @JsonKey(name: 'isActive')
  bool get isActive;
  @override
  @JsonKey(ignore: true)
  _$$PoetModelImplCopyWith<_$PoetModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
