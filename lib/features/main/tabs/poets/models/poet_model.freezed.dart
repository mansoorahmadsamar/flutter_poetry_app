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
  int? get deathYear => throw _privateConstructorUsedError;
  @JsonKey(name: 'profileImageUrl')
  String? get profileImageUrl => throw _privateConstructorUsedError;
  String get gender =>
      throw _privateConstructorUsedError; // MALE, FEMALE, OTHER
  String get era =>
      throw _privateConstructorUsedError; // CLASSICAL, MODERN, CONTEMPORARY, EMERGING
  int get poemCount => throw _privateConstructorUsedError;
  int get viewCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'isFeatured')
  bool get isFeatured => throw _privateConstructorUsedError;
  @JsonKey(name: 'isTrending')
  bool get isTrending => throw _privateConstructorUsedError;
  @JsonKey(name: 'topTags')
  List<String>? get topTags => throw _privateConstructorUsedError;

  /// Serializes this PoetModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PoetModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
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
      int? deathYear,
      @JsonKey(name: 'profileImageUrl') String? profileImageUrl,
      String gender,
      String era,
      int poemCount,
      int viewCount,
      @JsonKey(name: 'isFeatured') bool isFeatured,
      @JsonKey(name: 'isTrending') bool isTrending,
      @JsonKey(name: 'topTags') List<String>? topTags});
}

/// @nodoc
class _$PoetModelCopyWithImpl<$Res, $Val extends PoetModel>
    implements $PoetModelCopyWith<$Res> {
  _$PoetModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PoetModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? publicId = null,
    Object? name = null,
    Object? shortBio = null,
    Object? birthYear = null,
    Object? deathYear = freezed,
    Object? profileImageUrl = freezed,
    Object? gender = null,
    Object? era = null,
    Object? poemCount = null,
    Object? viewCount = null,
    Object? isFeatured = null,
    Object? isTrending = null,
    Object? topTags = freezed,
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
      deathYear: freezed == deathYear
          ? _value.deathYear
          : deathYear // ignore: cast_nullable_to_non_nullable
              as int?,
      profileImageUrl: freezed == profileImageUrl
          ? _value.profileImageUrl
          : profileImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      gender: null == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String,
      era: null == era
          ? _value.era
          : era // ignore: cast_nullable_to_non_nullable
              as String,
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
      topTags: freezed == topTags
          ? _value.topTags
          : topTags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
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
      int? deathYear,
      @JsonKey(name: 'profileImageUrl') String? profileImageUrl,
      String gender,
      String era,
      int poemCount,
      int viewCount,
      @JsonKey(name: 'isFeatured') bool isFeatured,
      @JsonKey(name: 'isTrending') bool isTrending,
      @JsonKey(name: 'topTags') List<String>? topTags});
}

/// @nodoc
class __$$PoetModelImplCopyWithImpl<$Res>
    extends _$PoetModelCopyWithImpl<$Res, _$PoetModelImpl>
    implements _$$PoetModelImplCopyWith<$Res> {
  __$$PoetModelImplCopyWithImpl(
      _$PoetModelImpl _value, $Res Function(_$PoetModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of PoetModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? publicId = null,
    Object? name = null,
    Object? shortBio = null,
    Object? birthYear = null,
    Object? deathYear = freezed,
    Object? profileImageUrl = freezed,
    Object? gender = null,
    Object? era = null,
    Object? poemCount = null,
    Object? viewCount = null,
    Object? isFeatured = null,
    Object? isTrending = null,
    Object? topTags = freezed,
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
      deathYear: freezed == deathYear
          ? _value.deathYear
          : deathYear // ignore: cast_nullable_to_non_nullable
              as int?,
      profileImageUrl: freezed == profileImageUrl
          ? _value.profileImageUrl
          : profileImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      gender: null == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String,
      era: null == era
          ? _value.era
          : era // ignore: cast_nullable_to_non_nullable
              as String,
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
      topTags: freezed == topTags
          ? _value._topTags
          : topTags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
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
      this.deathYear,
      @JsonKey(name: 'profileImageUrl') this.profileImageUrl,
      required this.gender,
      required this.era,
      required this.poemCount,
      required this.viewCount,
      @JsonKey(name: 'isFeatured') required this.isFeatured,
      @JsonKey(name: 'isTrending') required this.isTrending,
      @JsonKey(name: 'topTags') final List<String>? topTags})
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
  final int? deathYear;
  @override
  @JsonKey(name: 'profileImageUrl')
  final String? profileImageUrl;
  @override
  final String gender;
// MALE, FEMALE, OTHER
  @override
  final String era;
// CLASSICAL, MODERN, CONTEMPORARY, EMERGING
  @override
  final int poemCount;
  @override
  final int viewCount;
  @override
  @JsonKey(name: 'isFeatured')
  final bool isFeatured;
  @override
  @JsonKey(name: 'isTrending')
  final bool isTrending;
  final List<String>? _topTags;
  @override
  @JsonKey(name: 'topTags')
  List<String>? get topTags {
    final value = _topTags;
    if (value == null) return null;
    if (_topTags is EqualUnmodifiableListView) return _topTags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'PoetModel(publicId: $publicId, name: $name, shortBio: $shortBio, birthYear: $birthYear, deathYear: $deathYear, profileImageUrl: $profileImageUrl, gender: $gender, era: $era, poemCount: $poemCount, viewCount: $viewCount, isFeatured: $isFeatured, isTrending: $isTrending, topTags: $topTags)';
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
            const DeepCollectionEquality().equals(other._topTags, _topTags));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
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
      const DeepCollectionEquality().hash(_topTags));

  /// Create a copy of PoetModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
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
      final int? deathYear,
      @JsonKey(name: 'profileImageUrl') final String? profileImageUrl,
      required final String gender,
      required final String era,
      required final int poemCount,
      required final int viewCount,
      @JsonKey(name: 'isFeatured') required final bool isFeatured,
      @JsonKey(name: 'isTrending') required final bool isTrending,
      @JsonKey(name: 'topTags') final List<String>? topTags}) = _$PoetModelImpl;

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
  int? get deathYear;
  @override
  @JsonKey(name: 'profileImageUrl')
  String? get profileImageUrl;
  @override
  String get gender; // MALE, FEMALE, OTHER
  @override
  String get era; // CLASSICAL, MODERN, CONTEMPORARY, EMERGING
  @override
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
  @JsonKey(name: 'topTags')
  List<String>? get topTags;

  /// Create a copy of PoetModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PoetModelImplCopyWith<_$PoetModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
