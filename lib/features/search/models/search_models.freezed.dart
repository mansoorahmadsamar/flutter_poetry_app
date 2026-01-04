// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AutocompleteResponse _$AutocompleteResponseFromJson(Map<String, dynamic> json) {
  return _AutocompleteResponse.fromJson(json);
}

/// @nodoc
mixin _$AutocompleteResponse {
  List<AutocompletePoet> get poets => throw _privateConstructorUsedError;
  List<AutocompletePoem> get poems => throw _privateConstructorUsedError;
  List<AutocompleteTag> get tags => throw _privateConstructorUsedError;
  List<AutocompleteCategory> get categories =>
      throw _privateConstructorUsedError;
  int get totalCount => throw _privateConstructorUsedError;

  /// Serializes this AutocompleteResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AutocompleteResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AutocompleteResponseCopyWith<AutocompleteResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AutocompleteResponseCopyWith<$Res> {
  factory $AutocompleteResponseCopyWith(AutocompleteResponse value,
          $Res Function(AutocompleteResponse) then) =
      _$AutocompleteResponseCopyWithImpl<$Res, AutocompleteResponse>;
  @useResult
  $Res call(
      {List<AutocompletePoet> poets,
      List<AutocompletePoem> poems,
      List<AutocompleteTag> tags,
      List<AutocompleteCategory> categories,
      int totalCount});
}

/// @nodoc
class _$AutocompleteResponseCopyWithImpl<$Res,
        $Val extends AutocompleteResponse>
    implements $AutocompleteResponseCopyWith<$Res> {
  _$AutocompleteResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AutocompleteResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? poets = null,
    Object? poems = null,
    Object? tags = null,
    Object? categories = null,
    Object? totalCount = null,
  }) {
    return _then(_value.copyWith(
      poets: null == poets
          ? _value.poets
          : poets // ignore: cast_nullable_to_non_nullable
              as List<AutocompletePoet>,
      poems: null == poems
          ? _value.poems
          : poems // ignore: cast_nullable_to_non_nullable
              as List<AutocompletePoem>,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<AutocompleteTag>,
      categories: null == categories
          ? _value.categories
          : categories // ignore: cast_nullable_to_non_nullable
              as List<AutocompleteCategory>,
      totalCount: null == totalCount
          ? _value.totalCount
          : totalCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AutocompleteResponseImplCopyWith<$Res>
    implements $AutocompleteResponseCopyWith<$Res> {
  factory _$$AutocompleteResponseImplCopyWith(_$AutocompleteResponseImpl value,
          $Res Function(_$AutocompleteResponseImpl) then) =
      __$$AutocompleteResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<AutocompletePoet> poets,
      List<AutocompletePoem> poems,
      List<AutocompleteTag> tags,
      List<AutocompleteCategory> categories,
      int totalCount});
}

/// @nodoc
class __$$AutocompleteResponseImplCopyWithImpl<$Res>
    extends _$AutocompleteResponseCopyWithImpl<$Res, _$AutocompleteResponseImpl>
    implements _$$AutocompleteResponseImplCopyWith<$Res> {
  __$$AutocompleteResponseImplCopyWithImpl(_$AutocompleteResponseImpl _value,
      $Res Function(_$AutocompleteResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of AutocompleteResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? poets = null,
    Object? poems = null,
    Object? tags = null,
    Object? categories = null,
    Object? totalCount = null,
  }) {
    return _then(_$AutocompleteResponseImpl(
      poets: null == poets
          ? _value._poets
          : poets // ignore: cast_nullable_to_non_nullable
              as List<AutocompletePoet>,
      poems: null == poems
          ? _value._poems
          : poems // ignore: cast_nullable_to_non_nullable
              as List<AutocompletePoem>,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<AutocompleteTag>,
      categories: null == categories
          ? _value._categories
          : categories // ignore: cast_nullable_to_non_nullable
              as List<AutocompleteCategory>,
      totalCount: null == totalCount
          ? _value.totalCount
          : totalCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AutocompleteResponseImpl implements _AutocompleteResponse {
  const _$AutocompleteResponseImpl(
      {final List<AutocompletePoet> poets = const [],
      final List<AutocompletePoem> poems = const [],
      final List<AutocompleteTag> tags = const [],
      final List<AutocompleteCategory> categories = const [],
      this.totalCount = 0})
      : _poets = poets,
        _poems = poems,
        _tags = tags,
        _categories = categories;

  factory _$AutocompleteResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$AutocompleteResponseImplFromJson(json);

  final List<AutocompletePoet> _poets;
  @override
  @JsonKey()
  List<AutocompletePoet> get poets {
    if (_poets is EqualUnmodifiableListView) return _poets;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_poets);
  }

  final List<AutocompletePoem> _poems;
  @override
  @JsonKey()
  List<AutocompletePoem> get poems {
    if (_poems is EqualUnmodifiableListView) return _poems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_poems);
  }

  final List<AutocompleteTag> _tags;
  @override
  @JsonKey()
  List<AutocompleteTag> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  final List<AutocompleteCategory> _categories;
  @override
  @JsonKey()
  List<AutocompleteCategory> get categories {
    if (_categories is EqualUnmodifiableListView) return _categories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_categories);
  }

  @override
  @JsonKey()
  final int totalCount;

  @override
  String toString() {
    return 'AutocompleteResponse(poets: $poets, poems: $poems, tags: $tags, categories: $categories, totalCount: $totalCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AutocompleteResponseImpl &&
            const DeepCollectionEquality().equals(other._poets, _poets) &&
            const DeepCollectionEquality().equals(other._poems, _poems) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            const DeepCollectionEquality()
                .equals(other._categories, _categories) &&
            (identical(other.totalCount, totalCount) ||
                other.totalCount == totalCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_poets),
      const DeepCollectionEquality().hash(_poems),
      const DeepCollectionEquality().hash(_tags),
      const DeepCollectionEquality().hash(_categories),
      totalCount);

  /// Create a copy of AutocompleteResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AutocompleteResponseImplCopyWith<_$AutocompleteResponseImpl>
      get copyWith =>
          __$$AutocompleteResponseImplCopyWithImpl<_$AutocompleteResponseImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AutocompleteResponseImplToJson(
      this,
    );
  }
}

abstract class _AutocompleteResponse implements AutocompleteResponse {
  const factory _AutocompleteResponse(
      {final List<AutocompletePoet> poets,
      final List<AutocompletePoem> poems,
      final List<AutocompleteTag> tags,
      final List<AutocompleteCategory> categories,
      final int totalCount}) = _$AutocompleteResponseImpl;

  factory _AutocompleteResponse.fromJson(Map<String, dynamic> json) =
      _$AutocompleteResponseImpl.fromJson;

  @override
  List<AutocompletePoet> get poets;
  @override
  List<AutocompletePoem> get poems;
  @override
  List<AutocompleteTag> get tags;
  @override
  List<AutocompleteCategory> get categories;
  @override
  int get totalCount;

  /// Create a copy of AutocompleteResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AutocompleteResponseImplCopyWith<_$AutocompleteResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}

AutocompletePoet _$AutocompletePoetFromJson(Map<String, dynamic> json) {
  return _AutocompletePoet.fromJson(json);
}

/// @nodoc
mixin _$AutocompletePoet {
  String get publicId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get profileImageUrl => throw _privateConstructorUsedError;
  String? get era => throw _privateConstructorUsedError;
  double get score => throw _privateConstructorUsedError;

  /// Serializes this AutocompletePoet to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AutocompletePoet
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AutocompletePoetCopyWith<AutocompletePoet> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AutocompletePoetCopyWith<$Res> {
  factory $AutocompletePoetCopyWith(
          AutocompletePoet value, $Res Function(AutocompletePoet) then) =
      _$AutocompletePoetCopyWithImpl<$Res, AutocompletePoet>;
  @useResult
  $Res call(
      {String publicId,
      String name,
      String? profileImageUrl,
      String? era,
      double score});
}

/// @nodoc
class _$AutocompletePoetCopyWithImpl<$Res, $Val extends AutocompletePoet>
    implements $AutocompletePoetCopyWith<$Res> {
  _$AutocompletePoetCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AutocompletePoet
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? publicId = null,
    Object? name = null,
    Object? profileImageUrl = freezed,
    Object? era = freezed,
    Object? score = null,
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
      profileImageUrl: freezed == profileImageUrl
          ? _value.profileImageUrl
          : profileImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      era: freezed == era
          ? _value.era
          : era // ignore: cast_nullable_to_non_nullable
              as String?,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AutocompletePoetImplCopyWith<$Res>
    implements $AutocompletePoetCopyWith<$Res> {
  factory _$$AutocompletePoetImplCopyWith(_$AutocompletePoetImpl value,
          $Res Function(_$AutocompletePoetImpl) then) =
      __$$AutocompletePoetImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String publicId,
      String name,
      String? profileImageUrl,
      String? era,
      double score});
}

/// @nodoc
class __$$AutocompletePoetImplCopyWithImpl<$Res>
    extends _$AutocompletePoetCopyWithImpl<$Res, _$AutocompletePoetImpl>
    implements _$$AutocompletePoetImplCopyWith<$Res> {
  __$$AutocompletePoetImplCopyWithImpl(_$AutocompletePoetImpl _value,
      $Res Function(_$AutocompletePoetImpl) _then)
      : super(_value, _then);

  /// Create a copy of AutocompletePoet
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? publicId = null,
    Object? name = null,
    Object? profileImageUrl = freezed,
    Object? era = freezed,
    Object? score = null,
  }) {
    return _then(_$AutocompletePoetImpl(
      publicId: null == publicId
          ? _value.publicId
          : publicId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      profileImageUrl: freezed == profileImageUrl
          ? _value.profileImageUrl
          : profileImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      era: freezed == era
          ? _value.era
          : era // ignore: cast_nullable_to_non_nullable
              as String?,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AutocompletePoetImpl implements _AutocompletePoet {
  const _$AutocompletePoetImpl(
      {required this.publicId,
      required this.name,
      this.profileImageUrl,
      this.era,
      this.score = 0.0});

  factory _$AutocompletePoetImpl.fromJson(Map<String, dynamic> json) =>
      _$$AutocompletePoetImplFromJson(json);

  @override
  final String publicId;
  @override
  final String name;
  @override
  final String? profileImageUrl;
  @override
  final String? era;
  @override
  @JsonKey()
  final double score;

  @override
  String toString() {
    return 'AutocompletePoet(publicId: $publicId, name: $name, profileImageUrl: $profileImageUrl, era: $era, score: $score)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AutocompletePoetImpl &&
            (identical(other.publicId, publicId) ||
                other.publicId == publicId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.profileImageUrl, profileImageUrl) ||
                other.profileImageUrl == profileImageUrl) &&
            (identical(other.era, era) || other.era == era) &&
            (identical(other.score, score) || other.score == score));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, publicId, name, profileImageUrl, era, score);

  /// Create a copy of AutocompletePoet
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AutocompletePoetImplCopyWith<_$AutocompletePoetImpl> get copyWith =>
      __$$AutocompletePoetImplCopyWithImpl<_$AutocompletePoetImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AutocompletePoetImplToJson(
      this,
    );
  }
}

abstract class _AutocompletePoet implements AutocompletePoet {
  const factory _AutocompletePoet(
      {required final String publicId,
      required final String name,
      final String? profileImageUrl,
      final String? era,
      final double score}) = _$AutocompletePoetImpl;

  factory _AutocompletePoet.fromJson(Map<String, dynamic> json) =
      _$AutocompletePoetImpl.fromJson;

  @override
  String get publicId;
  @override
  String get name;
  @override
  String? get profileImageUrl;
  @override
  String? get era;
  @override
  double get score;

  /// Create a copy of AutocompletePoet
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AutocompletePoetImplCopyWith<_$AutocompletePoetImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AutocompletePoem _$AutocompletePoemFromJson(Map<String, dynamic> json) {
  return _AutocompletePoem.fromJson(json);
}

/// @nodoc
mixin _$AutocompletePoem {
  String get publicId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get poetName => throw _privateConstructorUsedError;
  String get poetPublicId => throw _privateConstructorUsedError;
  String get poetryType => throw _privateConstructorUsedError;
  double get score => throw _privateConstructorUsedError;

  /// Serializes this AutocompletePoem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AutocompletePoem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AutocompletePoemCopyWith<AutocompletePoem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AutocompletePoemCopyWith<$Res> {
  factory $AutocompletePoemCopyWith(
          AutocompletePoem value, $Res Function(AutocompletePoem) then) =
      _$AutocompletePoemCopyWithImpl<$Res, AutocompletePoem>;
  @useResult
  $Res call(
      {String publicId,
      String title,
      String poetName,
      String poetPublicId,
      String poetryType,
      double score});
}

/// @nodoc
class _$AutocompletePoemCopyWithImpl<$Res, $Val extends AutocompletePoem>
    implements $AutocompletePoemCopyWith<$Res> {
  _$AutocompletePoemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AutocompletePoem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? publicId = null,
    Object? title = null,
    Object? poetName = null,
    Object? poetPublicId = null,
    Object? poetryType = null,
    Object? score = null,
  }) {
    return _then(_value.copyWith(
      publicId: null == publicId
          ? _value.publicId
          : publicId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      poetName: null == poetName
          ? _value.poetName
          : poetName // ignore: cast_nullable_to_non_nullable
              as String,
      poetPublicId: null == poetPublicId
          ? _value.poetPublicId
          : poetPublicId // ignore: cast_nullable_to_non_nullable
              as String,
      poetryType: null == poetryType
          ? _value.poetryType
          : poetryType // ignore: cast_nullable_to_non_nullable
              as String,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AutocompletePoemImplCopyWith<$Res>
    implements $AutocompletePoemCopyWith<$Res> {
  factory _$$AutocompletePoemImplCopyWith(_$AutocompletePoemImpl value,
          $Res Function(_$AutocompletePoemImpl) then) =
      __$$AutocompletePoemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String publicId,
      String title,
      String poetName,
      String poetPublicId,
      String poetryType,
      double score});
}

/// @nodoc
class __$$AutocompletePoemImplCopyWithImpl<$Res>
    extends _$AutocompletePoemCopyWithImpl<$Res, _$AutocompletePoemImpl>
    implements _$$AutocompletePoemImplCopyWith<$Res> {
  __$$AutocompletePoemImplCopyWithImpl(_$AutocompletePoemImpl _value,
      $Res Function(_$AutocompletePoemImpl) _then)
      : super(_value, _then);

  /// Create a copy of AutocompletePoem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? publicId = null,
    Object? title = null,
    Object? poetName = null,
    Object? poetPublicId = null,
    Object? poetryType = null,
    Object? score = null,
  }) {
    return _then(_$AutocompletePoemImpl(
      publicId: null == publicId
          ? _value.publicId
          : publicId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      poetName: null == poetName
          ? _value.poetName
          : poetName // ignore: cast_nullable_to_non_nullable
              as String,
      poetPublicId: null == poetPublicId
          ? _value.poetPublicId
          : poetPublicId // ignore: cast_nullable_to_non_nullable
              as String,
      poetryType: null == poetryType
          ? _value.poetryType
          : poetryType // ignore: cast_nullable_to_non_nullable
              as String,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AutocompletePoemImpl implements _AutocompletePoem {
  const _$AutocompletePoemImpl(
      {required this.publicId,
      required this.title,
      required this.poetName,
      required this.poetPublicId,
      required this.poetryType,
      this.score = 0.0});

  factory _$AutocompletePoemImpl.fromJson(Map<String, dynamic> json) =>
      _$$AutocompletePoemImplFromJson(json);

  @override
  final String publicId;
  @override
  final String title;
  @override
  final String poetName;
  @override
  final String poetPublicId;
  @override
  final String poetryType;
  @override
  @JsonKey()
  final double score;

  @override
  String toString() {
    return 'AutocompletePoem(publicId: $publicId, title: $title, poetName: $poetName, poetPublicId: $poetPublicId, poetryType: $poetryType, score: $score)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AutocompletePoemImpl &&
            (identical(other.publicId, publicId) ||
                other.publicId == publicId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.poetName, poetName) ||
                other.poetName == poetName) &&
            (identical(other.poetPublicId, poetPublicId) ||
                other.poetPublicId == poetPublicId) &&
            (identical(other.poetryType, poetryType) ||
                other.poetryType == poetryType) &&
            (identical(other.score, score) || other.score == score));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, publicId, title, poetName, poetPublicId, poetryType, score);

  /// Create a copy of AutocompletePoem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AutocompletePoemImplCopyWith<_$AutocompletePoemImpl> get copyWith =>
      __$$AutocompletePoemImplCopyWithImpl<_$AutocompletePoemImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AutocompletePoemImplToJson(
      this,
    );
  }
}

abstract class _AutocompletePoem implements AutocompletePoem {
  const factory _AutocompletePoem(
      {required final String publicId,
      required final String title,
      required final String poetName,
      required final String poetPublicId,
      required final String poetryType,
      final double score}) = _$AutocompletePoemImpl;

  factory _AutocompletePoem.fromJson(Map<String, dynamic> json) =
      _$AutocompletePoemImpl.fromJson;

  @override
  String get publicId;
  @override
  String get title;
  @override
  String get poetName;
  @override
  String get poetPublicId;
  @override
  String get poetryType;
  @override
  double get score;

  /// Create a copy of AutocompletePoem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AutocompletePoemImplCopyWith<_$AutocompletePoemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AutocompleteTag _$AutocompleteTagFromJson(Map<String, dynamic> json) {
  return _AutocompleteTag.fromJson(json);
}

/// @nodoc
mixin _$AutocompleteTag {
  String get publicId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get slug => throw _privateConstructorUsedError;
  String get tagType => throw _privateConstructorUsedError;
  double get score => throw _privateConstructorUsedError;

  /// Serializes this AutocompleteTag to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AutocompleteTag
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AutocompleteTagCopyWith<AutocompleteTag> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AutocompleteTagCopyWith<$Res> {
  factory $AutocompleteTagCopyWith(
          AutocompleteTag value, $Res Function(AutocompleteTag) then) =
      _$AutocompleteTagCopyWithImpl<$Res, AutocompleteTag>;
  @useResult
  $Res call(
      {String publicId,
      String name,
      String slug,
      String tagType,
      double score});
}

/// @nodoc
class _$AutocompleteTagCopyWithImpl<$Res, $Val extends AutocompleteTag>
    implements $AutocompleteTagCopyWith<$Res> {
  _$AutocompleteTagCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AutocompleteTag
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? publicId = null,
    Object? name = null,
    Object? slug = null,
    Object? tagType = null,
    Object? score = null,
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
      tagType: null == tagType
          ? _value.tagType
          : tagType // ignore: cast_nullable_to_non_nullable
              as String,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AutocompleteTagImplCopyWith<$Res>
    implements $AutocompleteTagCopyWith<$Res> {
  factory _$$AutocompleteTagImplCopyWith(_$AutocompleteTagImpl value,
          $Res Function(_$AutocompleteTagImpl) then) =
      __$$AutocompleteTagImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String publicId,
      String name,
      String slug,
      String tagType,
      double score});
}

/// @nodoc
class __$$AutocompleteTagImplCopyWithImpl<$Res>
    extends _$AutocompleteTagCopyWithImpl<$Res, _$AutocompleteTagImpl>
    implements _$$AutocompleteTagImplCopyWith<$Res> {
  __$$AutocompleteTagImplCopyWithImpl(
      _$AutocompleteTagImpl _value, $Res Function(_$AutocompleteTagImpl) _then)
      : super(_value, _then);

  /// Create a copy of AutocompleteTag
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? publicId = null,
    Object? name = null,
    Object? slug = null,
    Object? tagType = null,
    Object? score = null,
  }) {
    return _then(_$AutocompleteTagImpl(
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
      tagType: null == tagType
          ? _value.tagType
          : tagType // ignore: cast_nullable_to_non_nullable
              as String,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AutocompleteTagImpl implements _AutocompleteTag {
  const _$AutocompleteTagImpl(
      {required this.publicId,
      required this.name,
      required this.slug,
      required this.tagType,
      this.score = 0.0});

  factory _$AutocompleteTagImpl.fromJson(Map<String, dynamic> json) =>
      _$$AutocompleteTagImplFromJson(json);

  @override
  final String publicId;
  @override
  final String name;
  @override
  final String slug;
  @override
  final String tagType;
  @override
  @JsonKey()
  final double score;

  @override
  String toString() {
    return 'AutocompleteTag(publicId: $publicId, name: $name, slug: $slug, tagType: $tagType, score: $score)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AutocompleteTagImpl &&
            (identical(other.publicId, publicId) ||
                other.publicId == publicId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.slug, slug) || other.slug == slug) &&
            (identical(other.tagType, tagType) || other.tagType == tagType) &&
            (identical(other.score, score) || other.score == score));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, publicId, name, slug, tagType, score);

  /// Create a copy of AutocompleteTag
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AutocompleteTagImplCopyWith<_$AutocompleteTagImpl> get copyWith =>
      __$$AutocompleteTagImplCopyWithImpl<_$AutocompleteTagImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AutocompleteTagImplToJson(
      this,
    );
  }
}

abstract class _AutocompleteTag implements AutocompleteTag {
  const factory _AutocompleteTag(
      {required final String publicId,
      required final String name,
      required final String slug,
      required final String tagType,
      final double score}) = _$AutocompleteTagImpl;

  factory _AutocompleteTag.fromJson(Map<String, dynamic> json) =
      _$AutocompleteTagImpl.fromJson;

  @override
  String get publicId;
  @override
  String get name;
  @override
  String get slug;
  @override
  String get tagType;
  @override
  double get score;

  /// Create a copy of AutocompleteTag
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AutocompleteTagImplCopyWith<_$AutocompleteTagImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AutocompleteCategory _$AutocompleteCategoryFromJson(Map<String, dynamic> json) {
  return _AutocompleteCategory.fromJson(json);
}

/// @nodoc
mixin _$AutocompleteCategory {
  String get publicId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get slug => throw _privateConstructorUsedError;
  int get poemCount => throw _privateConstructorUsedError;
  double get score => throw _privateConstructorUsedError;

  /// Serializes this AutocompleteCategory to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AutocompleteCategory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AutocompleteCategoryCopyWith<AutocompleteCategory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AutocompleteCategoryCopyWith<$Res> {
  factory $AutocompleteCategoryCopyWith(AutocompleteCategory value,
          $Res Function(AutocompleteCategory) then) =
      _$AutocompleteCategoryCopyWithImpl<$Res, AutocompleteCategory>;
  @useResult
  $Res call(
      {String publicId, String name, String slug, int poemCount, double score});
}

/// @nodoc
class _$AutocompleteCategoryCopyWithImpl<$Res,
        $Val extends AutocompleteCategory>
    implements $AutocompleteCategoryCopyWith<$Res> {
  _$AutocompleteCategoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AutocompleteCategory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? publicId = null,
    Object? name = null,
    Object? slug = null,
    Object? poemCount = null,
    Object? score = null,
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
      poemCount: null == poemCount
          ? _value.poemCount
          : poemCount // ignore: cast_nullable_to_non_nullable
              as int,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AutocompleteCategoryImplCopyWith<$Res>
    implements $AutocompleteCategoryCopyWith<$Res> {
  factory _$$AutocompleteCategoryImplCopyWith(_$AutocompleteCategoryImpl value,
          $Res Function(_$AutocompleteCategoryImpl) then) =
      __$$AutocompleteCategoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String publicId, String name, String slug, int poemCount, double score});
}

/// @nodoc
class __$$AutocompleteCategoryImplCopyWithImpl<$Res>
    extends _$AutocompleteCategoryCopyWithImpl<$Res, _$AutocompleteCategoryImpl>
    implements _$$AutocompleteCategoryImplCopyWith<$Res> {
  __$$AutocompleteCategoryImplCopyWithImpl(_$AutocompleteCategoryImpl _value,
      $Res Function(_$AutocompleteCategoryImpl) _then)
      : super(_value, _then);

  /// Create a copy of AutocompleteCategory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? publicId = null,
    Object? name = null,
    Object? slug = null,
    Object? poemCount = null,
    Object? score = null,
  }) {
    return _then(_$AutocompleteCategoryImpl(
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
      poemCount: null == poemCount
          ? _value.poemCount
          : poemCount // ignore: cast_nullable_to_non_nullable
              as int,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AutocompleteCategoryImpl implements _AutocompleteCategory {
  const _$AutocompleteCategoryImpl(
      {required this.publicId,
      required this.name,
      required this.slug,
      this.poemCount = 0,
      this.score = 0.0});

  factory _$AutocompleteCategoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$AutocompleteCategoryImplFromJson(json);

  @override
  final String publicId;
  @override
  final String name;
  @override
  final String slug;
  @override
  @JsonKey()
  final int poemCount;
  @override
  @JsonKey()
  final double score;

  @override
  String toString() {
    return 'AutocompleteCategory(publicId: $publicId, name: $name, slug: $slug, poemCount: $poemCount, score: $score)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AutocompleteCategoryImpl &&
            (identical(other.publicId, publicId) ||
                other.publicId == publicId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.slug, slug) || other.slug == slug) &&
            (identical(other.poemCount, poemCount) ||
                other.poemCount == poemCount) &&
            (identical(other.score, score) || other.score == score));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, publicId, name, slug, poemCount, score);

  /// Create a copy of AutocompleteCategory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AutocompleteCategoryImplCopyWith<_$AutocompleteCategoryImpl>
      get copyWith =>
          __$$AutocompleteCategoryImplCopyWithImpl<_$AutocompleteCategoryImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AutocompleteCategoryImplToJson(
      this,
    );
  }
}

abstract class _AutocompleteCategory implements AutocompleteCategory {
  const factory _AutocompleteCategory(
      {required final String publicId,
      required final String name,
      required final String slug,
      final int poemCount,
      final double score}) = _$AutocompleteCategoryImpl;

  factory _AutocompleteCategory.fromJson(Map<String, dynamic> json) =
      _$AutocompleteCategoryImpl.fromJson;

  @override
  String get publicId;
  @override
  String get name;
  @override
  String get slug;
  @override
  int get poemCount;
  @override
  double get score;

  /// Create a copy of AutocompleteCategory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AutocompleteCategoryImplCopyWith<_$AutocompleteCategoryImpl>
      get copyWith => throw _privateConstructorUsedError;
}

CoupletSearchResult _$CoupletSearchResultFromJson(Map<String, dynamic> json) {
  return _CoupletSearchResult.fromJson(json);
}

/// @nodoc
mixin _$CoupletSearchResult {
  String get publicId => throw _privateConstructorUsedError;
  int get coupletNumber => throw _privateConstructorUsedError;
  String get coupletType => throw _privateConstructorUsedError;
  List<VerseModel> get verses => throw _privateConstructorUsedError;
  PoemSummary get poem => throw _privateConstructorUsedError;
  PoetSummary get poet => throw _privateConstructorUsedError;
  int get likeCount => throw _privateConstructorUsedError;
  int get shareCount => throw _privateConstructorUsedError;
  int get bookmarkCount => throw _privateConstructorUsedError;
  double get engagementScore => throw _privateConstructorUsedError;
  bool get isLiked => throw _privateConstructorUsedError;
  bool get isBookmarked => throw _privateConstructorUsedError;

  /// Serializes this CoupletSearchResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CoupletSearchResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CoupletSearchResultCopyWith<CoupletSearchResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CoupletSearchResultCopyWith<$Res> {
  factory $CoupletSearchResultCopyWith(
          CoupletSearchResult value, $Res Function(CoupletSearchResult) then) =
      _$CoupletSearchResultCopyWithImpl<$Res, CoupletSearchResult>;
  @useResult
  $Res call(
      {String publicId,
      int coupletNumber,
      String coupletType,
      List<VerseModel> verses,
      PoemSummary poem,
      PoetSummary poet,
      int likeCount,
      int shareCount,
      int bookmarkCount,
      double engagementScore,
      bool isLiked,
      bool isBookmarked});

  $PoemSummaryCopyWith<$Res> get poem;
  $PoetSummaryCopyWith<$Res> get poet;
}

/// @nodoc
class _$CoupletSearchResultCopyWithImpl<$Res, $Val extends CoupletSearchResult>
    implements $CoupletSearchResultCopyWith<$Res> {
  _$CoupletSearchResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CoupletSearchResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? publicId = null,
    Object? coupletNumber = null,
    Object? coupletType = null,
    Object? verses = null,
    Object? poem = null,
    Object? poet = null,
    Object? likeCount = null,
    Object? shareCount = null,
    Object? bookmarkCount = null,
    Object? engagementScore = null,
    Object? isLiked = null,
    Object? isBookmarked = null,
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
      verses: null == verses
          ? _value.verses
          : verses // ignore: cast_nullable_to_non_nullable
              as List<VerseModel>,
      poem: null == poem
          ? _value.poem
          : poem // ignore: cast_nullable_to_non_nullable
              as PoemSummary,
      poet: null == poet
          ? _value.poet
          : poet // ignore: cast_nullable_to_non_nullable
              as PoetSummary,
      likeCount: null == likeCount
          ? _value.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int,
      shareCount: null == shareCount
          ? _value.shareCount
          : shareCount // ignore: cast_nullable_to_non_nullable
              as int,
      bookmarkCount: null == bookmarkCount
          ? _value.bookmarkCount
          : bookmarkCount // ignore: cast_nullable_to_non_nullable
              as int,
      engagementScore: null == engagementScore
          ? _value.engagementScore
          : engagementScore // ignore: cast_nullable_to_non_nullable
              as double,
      isLiked: null == isLiked
          ? _value.isLiked
          : isLiked // ignore: cast_nullable_to_non_nullable
              as bool,
      isBookmarked: null == isBookmarked
          ? _value.isBookmarked
          : isBookmarked // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  /// Create a copy of CoupletSearchResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PoemSummaryCopyWith<$Res> get poem {
    return $PoemSummaryCopyWith<$Res>(_value.poem, (value) {
      return _then(_value.copyWith(poem: value) as $Val);
    });
  }

  /// Create a copy of CoupletSearchResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PoetSummaryCopyWith<$Res> get poet {
    return $PoetSummaryCopyWith<$Res>(_value.poet, (value) {
      return _then(_value.copyWith(poet: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CoupletSearchResultImplCopyWith<$Res>
    implements $CoupletSearchResultCopyWith<$Res> {
  factory _$$CoupletSearchResultImplCopyWith(_$CoupletSearchResultImpl value,
          $Res Function(_$CoupletSearchResultImpl) then) =
      __$$CoupletSearchResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String publicId,
      int coupletNumber,
      String coupletType,
      List<VerseModel> verses,
      PoemSummary poem,
      PoetSummary poet,
      int likeCount,
      int shareCount,
      int bookmarkCount,
      double engagementScore,
      bool isLiked,
      bool isBookmarked});

  @override
  $PoemSummaryCopyWith<$Res> get poem;
  @override
  $PoetSummaryCopyWith<$Res> get poet;
}

/// @nodoc
class __$$CoupletSearchResultImplCopyWithImpl<$Res>
    extends _$CoupletSearchResultCopyWithImpl<$Res, _$CoupletSearchResultImpl>
    implements _$$CoupletSearchResultImplCopyWith<$Res> {
  __$$CoupletSearchResultImplCopyWithImpl(_$CoupletSearchResultImpl _value,
      $Res Function(_$CoupletSearchResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of CoupletSearchResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? publicId = null,
    Object? coupletNumber = null,
    Object? coupletType = null,
    Object? verses = null,
    Object? poem = null,
    Object? poet = null,
    Object? likeCount = null,
    Object? shareCount = null,
    Object? bookmarkCount = null,
    Object? engagementScore = null,
    Object? isLiked = null,
    Object? isBookmarked = null,
  }) {
    return _then(_$CoupletSearchResultImpl(
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
      verses: null == verses
          ? _value._verses
          : verses // ignore: cast_nullable_to_non_nullable
              as List<VerseModel>,
      poem: null == poem
          ? _value.poem
          : poem // ignore: cast_nullable_to_non_nullable
              as PoemSummary,
      poet: null == poet
          ? _value.poet
          : poet // ignore: cast_nullable_to_non_nullable
              as PoetSummary,
      likeCount: null == likeCount
          ? _value.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int,
      shareCount: null == shareCount
          ? _value.shareCount
          : shareCount // ignore: cast_nullable_to_non_nullable
              as int,
      bookmarkCount: null == bookmarkCount
          ? _value.bookmarkCount
          : bookmarkCount // ignore: cast_nullable_to_non_nullable
              as int,
      engagementScore: null == engagementScore
          ? _value.engagementScore
          : engagementScore // ignore: cast_nullable_to_non_nullable
              as double,
      isLiked: null == isLiked
          ? _value.isLiked
          : isLiked // ignore: cast_nullable_to_non_nullable
              as bool,
      isBookmarked: null == isBookmarked
          ? _value.isBookmarked
          : isBookmarked // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CoupletSearchResultImpl implements _CoupletSearchResult {
  const _$CoupletSearchResultImpl(
      {required this.publicId,
      required this.coupletNumber,
      required this.coupletType,
      required final List<VerseModel> verses,
      required this.poem,
      required this.poet,
      this.likeCount = 0,
      this.shareCount = 0,
      this.bookmarkCount = 0,
      this.engagementScore = 0.0,
      this.isLiked = false,
      this.isBookmarked = false})
      : _verses = verses;

  factory _$CoupletSearchResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$CoupletSearchResultImplFromJson(json);

  @override
  final String publicId;
  @override
  final int coupletNumber;
  @override
  final String coupletType;
  final List<VerseModel> _verses;
  @override
  List<VerseModel> get verses {
    if (_verses is EqualUnmodifiableListView) return _verses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_verses);
  }

  @override
  final PoemSummary poem;
  @override
  final PoetSummary poet;
  @override
  @JsonKey()
  final int likeCount;
  @override
  @JsonKey()
  final int shareCount;
  @override
  @JsonKey()
  final int bookmarkCount;
  @override
  @JsonKey()
  final double engagementScore;
  @override
  @JsonKey()
  final bool isLiked;
  @override
  @JsonKey()
  final bool isBookmarked;

  @override
  String toString() {
    return 'CoupletSearchResult(publicId: $publicId, coupletNumber: $coupletNumber, coupletType: $coupletType, verses: $verses, poem: $poem, poet: $poet, likeCount: $likeCount, shareCount: $shareCount, bookmarkCount: $bookmarkCount, engagementScore: $engagementScore, isLiked: $isLiked, isBookmarked: $isBookmarked)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CoupletSearchResultImpl &&
            (identical(other.publicId, publicId) ||
                other.publicId == publicId) &&
            (identical(other.coupletNumber, coupletNumber) ||
                other.coupletNumber == coupletNumber) &&
            (identical(other.coupletType, coupletType) ||
                other.coupletType == coupletType) &&
            const DeepCollectionEquality().equals(other._verses, _verses) &&
            (identical(other.poem, poem) || other.poem == poem) &&
            (identical(other.poet, poet) || other.poet == poet) &&
            (identical(other.likeCount, likeCount) ||
                other.likeCount == likeCount) &&
            (identical(other.shareCount, shareCount) ||
                other.shareCount == shareCount) &&
            (identical(other.bookmarkCount, bookmarkCount) ||
                other.bookmarkCount == bookmarkCount) &&
            (identical(other.engagementScore, engagementScore) ||
                other.engagementScore == engagementScore) &&
            (identical(other.isLiked, isLiked) || other.isLiked == isLiked) &&
            (identical(other.isBookmarked, isBookmarked) ||
                other.isBookmarked == isBookmarked));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      publicId,
      coupletNumber,
      coupletType,
      const DeepCollectionEquality().hash(_verses),
      poem,
      poet,
      likeCount,
      shareCount,
      bookmarkCount,
      engagementScore,
      isLiked,
      isBookmarked);

  /// Create a copy of CoupletSearchResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CoupletSearchResultImplCopyWith<_$CoupletSearchResultImpl> get copyWith =>
      __$$CoupletSearchResultImplCopyWithImpl<_$CoupletSearchResultImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CoupletSearchResultImplToJson(
      this,
    );
  }
}

abstract class _CoupletSearchResult implements CoupletSearchResult {
  const factory _CoupletSearchResult(
      {required final String publicId,
      required final int coupletNumber,
      required final String coupletType,
      required final List<VerseModel> verses,
      required final PoemSummary poem,
      required final PoetSummary poet,
      final int likeCount,
      final int shareCount,
      final int bookmarkCount,
      final double engagementScore,
      final bool isLiked,
      final bool isBookmarked}) = _$CoupletSearchResultImpl;

  factory _CoupletSearchResult.fromJson(Map<String, dynamic> json) =
      _$CoupletSearchResultImpl.fromJson;

  @override
  String get publicId;
  @override
  int get coupletNumber;
  @override
  String get coupletType;
  @override
  List<VerseModel> get verses;
  @override
  PoemSummary get poem;
  @override
  PoetSummary get poet;
  @override
  int get likeCount;
  @override
  int get shareCount;
  @override
  int get bookmarkCount;
  @override
  double get engagementScore;
  @override
  bool get isLiked;
  @override
  bool get isBookmarked;

  /// Create a copy of CoupletSearchResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CoupletSearchResultImplCopyWith<_$CoupletSearchResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PoemSummary _$PoemSummaryFromJson(Map<String, dynamic> json) {
  return _PoemSummary.fromJson(json);
}

/// @nodoc
mixin _$PoemSummary {
  String get publicId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get poetName => throw _privateConstructorUsedError;

  /// Serializes this PoemSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PoemSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PoemSummaryCopyWith<PoemSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PoemSummaryCopyWith<$Res> {
  factory $PoemSummaryCopyWith(
          PoemSummary value, $Res Function(PoemSummary) then) =
      _$PoemSummaryCopyWithImpl<$Res, PoemSummary>;
  @useResult
  $Res call({String publicId, String title, String poetName});
}

/// @nodoc
class _$PoemSummaryCopyWithImpl<$Res, $Val extends PoemSummary>
    implements $PoemSummaryCopyWith<$Res> {
  _$PoemSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PoemSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? publicId = null,
    Object? title = null,
    Object? poetName = null,
  }) {
    return _then(_value.copyWith(
      publicId: null == publicId
          ? _value.publicId
          : publicId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      poetName: null == poetName
          ? _value.poetName
          : poetName // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PoemSummaryImplCopyWith<$Res>
    implements $PoemSummaryCopyWith<$Res> {
  factory _$$PoemSummaryImplCopyWith(
          _$PoemSummaryImpl value, $Res Function(_$PoemSummaryImpl) then) =
      __$$PoemSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String publicId, String title, String poetName});
}

/// @nodoc
class __$$PoemSummaryImplCopyWithImpl<$Res>
    extends _$PoemSummaryCopyWithImpl<$Res, _$PoemSummaryImpl>
    implements _$$PoemSummaryImplCopyWith<$Res> {
  __$$PoemSummaryImplCopyWithImpl(
      _$PoemSummaryImpl _value, $Res Function(_$PoemSummaryImpl) _then)
      : super(_value, _then);

  /// Create a copy of PoemSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? publicId = null,
    Object? title = null,
    Object? poetName = null,
  }) {
    return _then(_$PoemSummaryImpl(
      publicId: null == publicId
          ? _value.publicId
          : publicId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      poetName: null == poetName
          ? _value.poetName
          : poetName // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PoemSummaryImpl implements _PoemSummary {
  const _$PoemSummaryImpl(
      {required this.publicId, required this.title, required this.poetName});

  factory _$PoemSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$PoemSummaryImplFromJson(json);

  @override
  final String publicId;
  @override
  final String title;
  @override
  final String poetName;

  @override
  String toString() {
    return 'PoemSummary(publicId: $publicId, title: $title, poetName: $poetName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PoemSummaryImpl &&
            (identical(other.publicId, publicId) ||
                other.publicId == publicId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.poetName, poetName) ||
                other.poetName == poetName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, publicId, title, poetName);

  /// Create a copy of PoemSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PoemSummaryImplCopyWith<_$PoemSummaryImpl> get copyWith =>
      __$$PoemSummaryImplCopyWithImpl<_$PoemSummaryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PoemSummaryImplToJson(
      this,
    );
  }
}

abstract class _PoemSummary implements PoemSummary {
  const factory _PoemSummary(
      {required final String publicId,
      required final String title,
      required final String poetName}) = _$PoemSummaryImpl;

  factory _PoemSummary.fromJson(Map<String, dynamic> json) =
      _$PoemSummaryImpl.fromJson;

  @override
  String get publicId;
  @override
  String get title;
  @override
  String get poetName;

  /// Create a copy of PoemSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PoemSummaryImplCopyWith<_$PoemSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PoetSummary _$PoetSummaryFromJson(Map<String, dynamic> json) {
  return _PoetSummary.fromJson(json);
}

/// @nodoc
mixin _$PoetSummary {
  String get publicId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get profileImageUrl => throw _privateConstructorUsedError;

  /// Serializes this PoetSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PoetSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PoetSummaryCopyWith<PoetSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PoetSummaryCopyWith<$Res> {
  factory $PoetSummaryCopyWith(
          PoetSummary value, $Res Function(PoetSummary) then) =
      _$PoetSummaryCopyWithImpl<$Res, PoetSummary>;
  @useResult
  $Res call({String publicId, String name, String? profileImageUrl});
}

/// @nodoc
class _$PoetSummaryCopyWithImpl<$Res, $Val extends PoetSummary>
    implements $PoetSummaryCopyWith<$Res> {
  _$PoetSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PoetSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? publicId = null,
    Object? name = null,
    Object? profileImageUrl = freezed,
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
      profileImageUrl: freezed == profileImageUrl
          ? _value.profileImageUrl
          : profileImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PoetSummaryImplCopyWith<$Res>
    implements $PoetSummaryCopyWith<$Res> {
  factory _$$PoetSummaryImplCopyWith(
          _$PoetSummaryImpl value, $Res Function(_$PoetSummaryImpl) then) =
      __$$PoetSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String publicId, String name, String? profileImageUrl});
}

/// @nodoc
class __$$PoetSummaryImplCopyWithImpl<$Res>
    extends _$PoetSummaryCopyWithImpl<$Res, _$PoetSummaryImpl>
    implements _$$PoetSummaryImplCopyWith<$Res> {
  __$$PoetSummaryImplCopyWithImpl(
      _$PoetSummaryImpl _value, $Res Function(_$PoetSummaryImpl) _then)
      : super(_value, _then);

  /// Create a copy of PoetSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? publicId = null,
    Object? name = null,
    Object? profileImageUrl = freezed,
  }) {
    return _then(_$PoetSummaryImpl(
      publicId: null == publicId
          ? _value.publicId
          : publicId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      profileImageUrl: freezed == profileImageUrl
          ? _value.profileImageUrl
          : profileImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PoetSummaryImpl implements _PoetSummary {
  const _$PoetSummaryImpl(
      {required this.publicId, required this.name, this.profileImageUrl});

  factory _$PoetSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$PoetSummaryImplFromJson(json);

  @override
  final String publicId;
  @override
  final String name;
  @override
  final String? profileImageUrl;

  @override
  String toString() {
    return 'PoetSummary(publicId: $publicId, name: $name, profileImageUrl: $profileImageUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PoetSummaryImpl &&
            (identical(other.publicId, publicId) ||
                other.publicId == publicId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.profileImageUrl, profileImageUrl) ||
                other.profileImageUrl == profileImageUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, publicId, name, profileImageUrl);

  /// Create a copy of PoetSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PoetSummaryImplCopyWith<_$PoetSummaryImpl> get copyWith =>
      __$$PoetSummaryImplCopyWithImpl<_$PoetSummaryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PoetSummaryImplToJson(
      this,
    );
  }
}

abstract class _PoetSummary implements PoetSummary {
  const factory _PoetSummary(
      {required final String publicId,
      required final String name,
      final String? profileImageUrl}) = _$PoetSummaryImpl;

  factory _PoetSummary.fromJson(Map<String, dynamic> json) =
      _$PoetSummaryImpl.fromJson;

  @override
  String get publicId;
  @override
  String get name;
  @override
  String? get profileImageUrl;

  /// Create a copy of PoetSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PoetSummaryImplCopyWith<_$PoetSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RecommendationResponse _$RecommendationResponseFromJson(
    Map<String, dynamic> json) {
  return _RecommendationResponse.fromJson(json);
}

/// @nodoc
mixin _$RecommendationResponse {
  String get type =>
      throw _privateConstructorUsedError; // PERSONALIZED, SIMILAR, TRENDING, HYBRID
  List<RecommendationItem> get items => throw _privateConstructorUsedError;
  int get totalCount => throw _privateConstructorUsedError;
  String get algorithm => throw _privateConstructorUsedError;

  /// Serializes this RecommendationResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RecommendationResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecommendationResponseCopyWith<RecommendationResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecommendationResponseCopyWith<$Res> {
  factory $RecommendationResponseCopyWith(RecommendationResponse value,
          $Res Function(RecommendationResponse) then) =
      _$RecommendationResponseCopyWithImpl<$Res, RecommendationResponse>;
  @useResult
  $Res call(
      {String type,
      List<RecommendationItem> items,
      int totalCount,
      String algorithm});
}

/// @nodoc
class _$RecommendationResponseCopyWithImpl<$Res,
        $Val extends RecommendationResponse>
    implements $RecommendationResponseCopyWith<$Res> {
  _$RecommendationResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RecommendationResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? items = null,
    Object? totalCount = null,
    Object? algorithm = null,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<RecommendationItem>,
      totalCount: null == totalCount
          ? _value.totalCount
          : totalCount // ignore: cast_nullable_to_non_nullable
              as int,
      algorithm: null == algorithm
          ? _value.algorithm
          : algorithm // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RecommendationResponseImplCopyWith<$Res>
    implements $RecommendationResponseCopyWith<$Res> {
  factory _$$RecommendationResponseImplCopyWith(
          _$RecommendationResponseImpl value,
          $Res Function(_$RecommendationResponseImpl) then) =
      __$$RecommendationResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String type,
      List<RecommendationItem> items,
      int totalCount,
      String algorithm});
}

/// @nodoc
class __$$RecommendationResponseImplCopyWithImpl<$Res>
    extends _$RecommendationResponseCopyWithImpl<$Res,
        _$RecommendationResponseImpl>
    implements _$$RecommendationResponseImplCopyWith<$Res> {
  __$$RecommendationResponseImplCopyWithImpl(
      _$RecommendationResponseImpl _value,
      $Res Function(_$RecommendationResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of RecommendationResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? items = null,
    Object? totalCount = null,
    Object? algorithm = null,
  }) {
    return _then(_$RecommendationResponseImpl(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<RecommendationItem>,
      totalCount: null == totalCount
          ? _value.totalCount
          : totalCount // ignore: cast_nullable_to_non_nullable
              as int,
      algorithm: null == algorithm
          ? _value.algorithm
          : algorithm // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RecommendationResponseImpl implements _RecommendationResponse {
  const _$RecommendationResponseImpl(
      {required this.type,
      final List<RecommendationItem> items = const [],
      this.totalCount = 0,
      required this.algorithm})
      : _items = items;

  factory _$RecommendationResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecommendationResponseImplFromJson(json);

  @override
  final String type;
// PERSONALIZED, SIMILAR, TRENDING, HYBRID
  final List<RecommendationItem> _items;
// PERSONALIZED, SIMILAR, TRENDING, HYBRID
  @override
  @JsonKey()
  List<RecommendationItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  @JsonKey()
  final int totalCount;
  @override
  final String algorithm;

  @override
  String toString() {
    return 'RecommendationResponse(type: $type, items: $items, totalCount: $totalCount, algorithm: $algorithm)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecommendationResponseImpl &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.totalCount, totalCount) ||
                other.totalCount == totalCount) &&
            (identical(other.algorithm, algorithm) ||
                other.algorithm == algorithm));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, type,
      const DeepCollectionEquality().hash(_items), totalCount, algorithm);

  /// Create a copy of RecommendationResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecommendationResponseImplCopyWith<_$RecommendationResponseImpl>
      get copyWith => __$$RecommendationResponseImplCopyWithImpl<
          _$RecommendationResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RecommendationResponseImplToJson(
      this,
    );
  }
}

abstract class _RecommendationResponse implements RecommendationResponse {
  const factory _RecommendationResponse(
      {required final String type,
      final List<RecommendationItem> items,
      final int totalCount,
      required final String algorithm}) = _$RecommendationResponseImpl;

  factory _RecommendationResponse.fromJson(Map<String, dynamic> json) =
      _$RecommendationResponseImpl.fromJson;

  @override
  String get type; // PERSONALIZED, SIMILAR, TRENDING, HYBRID
  @override
  List<RecommendationItem> get items;
  @override
  int get totalCount;
  @override
  String get algorithm;

  /// Create a copy of RecommendationResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecommendationResponseImplCopyWith<_$RecommendationResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}

RecommendationItem _$RecommendationItemFromJson(Map<String, dynamic> json) {
  return _RecommendationItem.fromJson(json);
}

/// @nodoc
mixin _$RecommendationItem {
  String get contentType =>
      throw _privateConstructorUsedError; // POEM, COUPLET, POET
  String get publicId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get poetName => throw _privateConstructorUsedError;
  int get likeCount => throw _privateConstructorUsedError;
  int get shareCount => throw _privateConstructorUsedError;
  int get bookmarkCount => throw _privateConstructorUsedError;
  double get score => throw _privateConstructorUsedError;
  String? get reason => throw _privateConstructorUsedError;

  /// Serializes this RecommendationItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RecommendationItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecommendationItemCopyWith<RecommendationItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecommendationItemCopyWith<$Res> {
  factory $RecommendationItemCopyWith(
          RecommendationItem value, $Res Function(RecommendationItem) then) =
      _$RecommendationItemCopyWithImpl<$Res, RecommendationItem>;
  @useResult
  $Res call(
      {String contentType,
      String publicId,
      String title,
      String? poetName,
      int likeCount,
      int shareCount,
      int bookmarkCount,
      double score,
      String? reason});
}

/// @nodoc
class _$RecommendationItemCopyWithImpl<$Res, $Val extends RecommendationItem>
    implements $RecommendationItemCopyWith<$Res> {
  _$RecommendationItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RecommendationItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? contentType = null,
    Object? publicId = null,
    Object? title = null,
    Object? poetName = freezed,
    Object? likeCount = null,
    Object? shareCount = null,
    Object? bookmarkCount = null,
    Object? score = null,
    Object? reason = freezed,
  }) {
    return _then(_value.copyWith(
      contentType: null == contentType
          ? _value.contentType
          : contentType // ignore: cast_nullable_to_non_nullable
              as String,
      publicId: null == publicId
          ? _value.publicId
          : publicId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      poetName: freezed == poetName
          ? _value.poetName
          : poetName // ignore: cast_nullable_to_non_nullable
              as String?,
      likeCount: null == likeCount
          ? _value.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int,
      shareCount: null == shareCount
          ? _value.shareCount
          : shareCount // ignore: cast_nullable_to_non_nullable
              as int,
      bookmarkCount: null == bookmarkCount
          ? _value.bookmarkCount
          : bookmarkCount // ignore: cast_nullable_to_non_nullable
              as int,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as double,
      reason: freezed == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RecommendationItemImplCopyWith<$Res>
    implements $RecommendationItemCopyWith<$Res> {
  factory _$$RecommendationItemImplCopyWith(_$RecommendationItemImpl value,
          $Res Function(_$RecommendationItemImpl) then) =
      __$$RecommendationItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String contentType,
      String publicId,
      String title,
      String? poetName,
      int likeCount,
      int shareCount,
      int bookmarkCount,
      double score,
      String? reason});
}

/// @nodoc
class __$$RecommendationItemImplCopyWithImpl<$Res>
    extends _$RecommendationItemCopyWithImpl<$Res, _$RecommendationItemImpl>
    implements _$$RecommendationItemImplCopyWith<$Res> {
  __$$RecommendationItemImplCopyWithImpl(_$RecommendationItemImpl _value,
      $Res Function(_$RecommendationItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of RecommendationItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? contentType = null,
    Object? publicId = null,
    Object? title = null,
    Object? poetName = freezed,
    Object? likeCount = null,
    Object? shareCount = null,
    Object? bookmarkCount = null,
    Object? score = null,
    Object? reason = freezed,
  }) {
    return _then(_$RecommendationItemImpl(
      contentType: null == contentType
          ? _value.contentType
          : contentType // ignore: cast_nullable_to_non_nullable
              as String,
      publicId: null == publicId
          ? _value.publicId
          : publicId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      poetName: freezed == poetName
          ? _value.poetName
          : poetName // ignore: cast_nullable_to_non_nullable
              as String?,
      likeCount: null == likeCount
          ? _value.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int,
      shareCount: null == shareCount
          ? _value.shareCount
          : shareCount // ignore: cast_nullable_to_non_nullable
              as int,
      bookmarkCount: null == bookmarkCount
          ? _value.bookmarkCount
          : bookmarkCount // ignore: cast_nullable_to_non_nullable
              as int,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as double,
      reason: freezed == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RecommendationItemImpl implements _RecommendationItem {
  const _$RecommendationItemImpl(
      {required this.contentType,
      required this.publicId,
      required this.title,
      this.poetName,
      this.likeCount = 0,
      this.shareCount = 0,
      this.bookmarkCount = 0,
      this.score = 0.0,
      this.reason});

  factory _$RecommendationItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecommendationItemImplFromJson(json);

  @override
  final String contentType;
// POEM, COUPLET, POET
  @override
  final String publicId;
  @override
  final String title;
  @override
  final String? poetName;
  @override
  @JsonKey()
  final int likeCount;
  @override
  @JsonKey()
  final int shareCount;
  @override
  @JsonKey()
  final int bookmarkCount;
  @override
  @JsonKey()
  final double score;
  @override
  final String? reason;

  @override
  String toString() {
    return 'RecommendationItem(contentType: $contentType, publicId: $publicId, title: $title, poetName: $poetName, likeCount: $likeCount, shareCount: $shareCount, bookmarkCount: $bookmarkCount, score: $score, reason: $reason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecommendationItemImpl &&
            (identical(other.contentType, contentType) ||
                other.contentType == contentType) &&
            (identical(other.publicId, publicId) ||
                other.publicId == publicId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.poetName, poetName) ||
                other.poetName == poetName) &&
            (identical(other.likeCount, likeCount) ||
                other.likeCount == likeCount) &&
            (identical(other.shareCount, shareCount) ||
                other.shareCount == shareCount) &&
            (identical(other.bookmarkCount, bookmarkCount) ||
                other.bookmarkCount == bookmarkCount) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.reason, reason) || other.reason == reason));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, contentType, publicId, title,
      poetName, likeCount, shareCount, bookmarkCount, score, reason);

  /// Create a copy of RecommendationItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecommendationItemImplCopyWith<_$RecommendationItemImpl> get copyWith =>
      __$$RecommendationItemImplCopyWithImpl<_$RecommendationItemImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RecommendationItemImplToJson(
      this,
    );
  }
}

abstract class _RecommendationItem implements RecommendationItem {
  const factory _RecommendationItem(
      {required final String contentType,
      required final String publicId,
      required final String title,
      final String? poetName,
      final int likeCount,
      final int shareCount,
      final int bookmarkCount,
      final double score,
      final String? reason}) = _$RecommendationItemImpl;

  factory _RecommendationItem.fromJson(Map<String, dynamic> json) =
      _$RecommendationItemImpl.fromJson;

  @override
  String get contentType; // POEM, COUPLET, POET
  @override
  String get publicId;
  @override
  String get title;
  @override
  String? get poetName;
  @override
  int get likeCount;
  @override
  int get shareCount;
  @override
  int get bookmarkCount;
  @override
  double get score;
  @override
  String? get reason;

  /// Create a copy of RecommendationItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecommendationItemImplCopyWith<_$RecommendationItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TrendingSearch _$TrendingSearchFromJson(Map<String, dynamic> json) {
  return _TrendingSearch.fromJson(json);
}

/// @nodoc
mixin _$TrendingSearch {
  String get query => throw _privateConstructorUsedError;
  String get normalizedQuery => throw _privateConstructorUsedError;
  int get count => throw _privateConstructorUsedError;
  double get score => throw _privateConstructorUsedError;

  /// Serializes this TrendingSearch to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TrendingSearch
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TrendingSearchCopyWith<TrendingSearch> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrendingSearchCopyWith<$Res> {
  factory $TrendingSearchCopyWith(
          TrendingSearch value, $Res Function(TrendingSearch) then) =
      _$TrendingSearchCopyWithImpl<$Res, TrendingSearch>;
  @useResult
  $Res call({String query, String normalizedQuery, int count, double score});
}

/// @nodoc
class _$TrendingSearchCopyWithImpl<$Res, $Val extends TrendingSearch>
    implements $TrendingSearchCopyWith<$Res> {
  _$TrendingSearchCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TrendingSearch
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? query = null,
    Object? normalizedQuery = null,
    Object? count = null,
    Object? score = null,
  }) {
    return _then(_value.copyWith(
      query: null == query
          ? _value.query
          : query // ignore: cast_nullable_to_non_nullable
              as String,
      normalizedQuery: null == normalizedQuery
          ? _value.normalizedQuery
          : normalizedQuery // ignore: cast_nullable_to_non_nullable
              as String,
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TrendingSearchImplCopyWith<$Res>
    implements $TrendingSearchCopyWith<$Res> {
  factory _$$TrendingSearchImplCopyWith(_$TrendingSearchImpl value,
          $Res Function(_$TrendingSearchImpl) then) =
      __$$TrendingSearchImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String query, String normalizedQuery, int count, double score});
}

/// @nodoc
class __$$TrendingSearchImplCopyWithImpl<$Res>
    extends _$TrendingSearchCopyWithImpl<$Res, _$TrendingSearchImpl>
    implements _$$TrendingSearchImplCopyWith<$Res> {
  __$$TrendingSearchImplCopyWithImpl(
      _$TrendingSearchImpl _value, $Res Function(_$TrendingSearchImpl) _then)
      : super(_value, _then);

  /// Create a copy of TrendingSearch
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? query = null,
    Object? normalizedQuery = null,
    Object? count = null,
    Object? score = null,
  }) {
    return _then(_$TrendingSearchImpl(
      query: null == query
          ? _value.query
          : query // ignore: cast_nullable_to_non_nullable
              as String,
      normalizedQuery: null == normalizedQuery
          ? _value.normalizedQuery
          : normalizedQuery // ignore: cast_nullable_to_non_nullable
              as String,
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TrendingSearchImpl implements _TrendingSearch {
  const _$TrendingSearchImpl(
      {required this.query,
      required this.normalizedQuery,
      this.count = 0,
      this.score = 0.0});

  factory _$TrendingSearchImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrendingSearchImplFromJson(json);

  @override
  final String query;
  @override
  final String normalizedQuery;
  @override
  @JsonKey()
  final int count;
  @override
  @JsonKey()
  final double score;

  @override
  String toString() {
    return 'TrendingSearch(query: $query, normalizedQuery: $normalizedQuery, count: $count, score: $score)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrendingSearchImpl &&
            (identical(other.query, query) || other.query == query) &&
            (identical(other.normalizedQuery, normalizedQuery) ||
                other.normalizedQuery == normalizedQuery) &&
            (identical(other.count, count) || other.count == count) &&
            (identical(other.score, score) || other.score == score));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, query, normalizedQuery, count, score);

  /// Create a copy of TrendingSearch
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrendingSearchImplCopyWith<_$TrendingSearchImpl> get copyWith =>
      __$$TrendingSearchImplCopyWithImpl<_$TrendingSearchImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TrendingSearchImplToJson(
      this,
    );
  }
}

abstract class _TrendingSearch implements TrendingSearch {
  const factory _TrendingSearch(
      {required final String query,
      required final String normalizedQuery,
      final int count,
      final double score}) = _$TrendingSearchImpl;

  factory _TrendingSearch.fromJson(Map<String, dynamic> json) =
      _$TrendingSearchImpl.fromJson;

  @override
  String get query;
  @override
  String get normalizedQuery;
  @override
  int get count;
  @override
  double get score;

  /// Create a copy of TrendingSearch
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrendingSearchImplCopyWith<_$TrendingSearchImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RelatedSearchesResponse _$RelatedSearchesResponseFromJson(
    Map<String, dynamic> json) {
  return _RelatedSearchesResponse.fromJson(json);
}

/// @nodoc
mixin _$RelatedSearchesResponse {
  String get query => throw _privateConstructorUsedError;
  List<TrendingSearch> get relatedSearches =>
      throw _privateConstructorUsedError;
  int get totalCount => throw _privateConstructorUsedError;
  String get timeWindow => throw _privateConstructorUsedError;

  /// Serializes this RelatedSearchesResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RelatedSearchesResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RelatedSearchesResponseCopyWith<RelatedSearchesResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RelatedSearchesResponseCopyWith<$Res> {
  factory $RelatedSearchesResponseCopyWith(RelatedSearchesResponse value,
          $Res Function(RelatedSearchesResponse) then) =
      _$RelatedSearchesResponseCopyWithImpl<$Res, RelatedSearchesResponse>;
  @useResult
  $Res call(
      {String query,
      List<TrendingSearch> relatedSearches,
      int totalCount,
      String timeWindow});
}

/// @nodoc
class _$RelatedSearchesResponseCopyWithImpl<$Res,
        $Val extends RelatedSearchesResponse>
    implements $RelatedSearchesResponseCopyWith<$Res> {
  _$RelatedSearchesResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RelatedSearchesResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? query = null,
    Object? relatedSearches = null,
    Object? totalCount = null,
    Object? timeWindow = null,
  }) {
    return _then(_value.copyWith(
      query: null == query
          ? _value.query
          : query // ignore: cast_nullable_to_non_nullable
              as String,
      relatedSearches: null == relatedSearches
          ? _value.relatedSearches
          : relatedSearches // ignore: cast_nullable_to_non_nullable
              as List<TrendingSearch>,
      totalCount: null == totalCount
          ? _value.totalCount
          : totalCount // ignore: cast_nullable_to_non_nullable
              as int,
      timeWindow: null == timeWindow
          ? _value.timeWindow
          : timeWindow // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RelatedSearchesResponseImplCopyWith<$Res>
    implements $RelatedSearchesResponseCopyWith<$Res> {
  factory _$$RelatedSearchesResponseImplCopyWith(
          _$RelatedSearchesResponseImpl value,
          $Res Function(_$RelatedSearchesResponseImpl) then) =
      __$$RelatedSearchesResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String query,
      List<TrendingSearch> relatedSearches,
      int totalCount,
      String timeWindow});
}

/// @nodoc
class __$$RelatedSearchesResponseImplCopyWithImpl<$Res>
    extends _$RelatedSearchesResponseCopyWithImpl<$Res,
        _$RelatedSearchesResponseImpl>
    implements _$$RelatedSearchesResponseImplCopyWith<$Res> {
  __$$RelatedSearchesResponseImplCopyWithImpl(
      _$RelatedSearchesResponseImpl _value,
      $Res Function(_$RelatedSearchesResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of RelatedSearchesResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? query = null,
    Object? relatedSearches = null,
    Object? totalCount = null,
    Object? timeWindow = null,
  }) {
    return _then(_$RelatedSearchesResponseImpl(
      query: null == query
          ? _value.query
          : query // ignore: cast_nullable_to_non_nullable
              as String,
      relatedSearches: null == relatedSearches
          ? _value._relatedSearches
          : relatedSearches // ignore: cast_nullable_to_non_nullable
              as List<TrendingSearch>,
      totalCount: null == totalCount
          ? _value.totalCount
          : totalCount // ignore: cast_nullable_to_non_nullable
              as int,
      timeWindow: null == timeWindow
          ? _value.timeWindow
          : timeWindow // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RelatedSearchesResponseImpl implements _RelatedSearchesResponse {
  const _$RelatedSearchesResponseImpl(
      {required this.query,
      final List<TrendingSearch> relatedSearches = const [],
      this.totalCount = 0,
      required this.timeWindow})
      : _relatedSearches = relatedSearches;

  factory _$RelatedSearchesResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$RelatedSearchesResponseImplFromJson(json);

  @override
  final String query;
  final List<TrendingSearch> _relatedSearches;
  @override
  @JsonKey()
  List<TrendingSearch> get relatedSearches {
    if (_relatedSearches is EqualUnmodifiableListView) return _relatedSearches;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_relatedSearches);
  }

  @override
  @JsonKey()
  final int totalCount;
  @override
  final String timeWindow;

  @override
  String toString() {
    return 'RelatedSearchesResponse(query: $query, relatedSearches: $relatedSearches, totalCount: $totalCount, timeWindow: $timeWindow)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RelatedSearchesResponseImpl &&
            (identical(other.query, query) || other.query == query) &&
            const DeepCollectionEquality()
                .equals(other._relatedSearches, _relatedSearches) &&
            (identical(other.totalCount, totalCount) ||
                other.totalCount == totalCount) &&
            (identical(other.timeWindow, timeWindow) ||
                other.timeWindow == timeWindow));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      query,
      const DeepCollectionEquality().hash(_relatedSearches),
      totalCount,
      timeWindow);

  /// Create a copy of RelatedSearchesResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RelatedSearchesResponseImplCopyWith<_$RelatedSearchesResponseImpl>
      get copyWith => __$$RelatedSearchesResponseImplCopyWithImpl<
          _$RelatedSearchesResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RelatedSearchesResponseImplToJson(
      this,
    );
  }
}

abstract class _RelatedSearchesResponse implements RelatedSearchesResponse {
  const factory _RelatedSearchesResponse(
      {required final String query,
      final List<TrendingSearch> relatedSearches,
      final int totalCount,
      required final String timeWindow}) = _$RelatedSearchesResponseImpl;

  factory _RelatedSearchesResponse.fromJson(Map<String, dynamic> json) =
      _$RelatedSearchesResponseImpl.fromJson;

  @override
  String get query;
  @override
  List<TrendingSearch> get relatedSearches;
  @override
  int get totalCount;
  @override
  String get timeWindow;

  /// Create a copy of RelatedSearchesResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RelatedSearchesResponseImplCopyWith<_$RelatedSearchesResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}

TrendingSearchesResponse _$TrendingSearchesResponseFromJson(
    Map<String, dynamic> json) {
  return _TrendingSearchesResponse.fromJson(json);
}

/// @nodoc
mixin _$TrendingSearchesResponse {
  List<TrendingSearch> get searches => throw _privateConstructorUsedError;
  int get totalCount => throw _privateConstructorUsedError;
  String get timeframe => throw _privateConstructorUsedError;
  String get period => throw _privateConstructorUsedError;

  /// Serializes this TrendingSearchesResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TrendingSearchesResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TrendingSearchesResponseCopyWith<TrendingSearchesResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrendingSearchesResponseCopyWith<$Res> {
  factory $TrendingSearchesResponseCopyWith(TrendingSearchesResponse value,
          $Res Function(TrendingSearchesResponse) then) =
      _$TrendingSearchesResponseCopyWithImpl<$Res, TrendingSearchesResponse>;
  @useResult
  $Res call(
      {List<TrendingSearch> searches,
      int totalCount,
      String timeframe,
      String period});
}

/// @nodoc
class _$TrendingSearchesResponseCopyWithImpl<$Res,
        $Val extends TrendingSearchesResponse>
    implements $TrendingSearchesResponseCopyWith<$Res> {
  _$TrendingSearchesResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TrendingSearchesResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? searches = null,
    Object? totalCount = null,
    Object? timeframe = null,
    Object? period = null,
  }) {
    return _then(_value.copyWith(
      searches: null == searches
          ? _value.searches
          : searches // ignore: cast_nullable_to_non_nullable
              as List<TrendingSearch>,
      totalCount: null == totalCount
          ? _value.totalCount
          : totalCount // ignore: cast_nullable_to_non_nullable
              as int,
      timeframe: null == timeframe
          ? _value.timeframe
          : timeframe // ignore: cast_nullable_to_non_nullable
              as String,
      period: null == period
          ? _value.period
          : period // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TrendingSearchesResponseImplCopyWith<$Res>
    implements $TrendingSearchesResponseCopyWith<$Res> {
  factory _$$TrendingSearchesResponseImplCopyWith(
          _$TrendingSearchesResponseImpl value,
          $Res Function(_$TrendingSearchesResponseImpl) then) =
      __$$TrendingSearchesResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<TrendingSearch> searches,
      int totalCount,
      String timeframe,
      String period});
}

/// @nodoc
class __$$TrendingSearchesResponseImplCopyWithImpl<$Res>
    extends _$TrendingSearchesResponseCopyWithImpl<$Res,
        _$TrendingSearchesResponseImpl>
    implements _$$TrendingSearchesResponseImplCopyWith<$Res> {
  __$$TrendingSearchesResponseImplCopyWithImpl(
      _$TrendingSearchesResponseImpl _value,
      $Res Function(_$TrendingSearchesResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of TrendingSearchesResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? searches = null,
    Object? totalCount = null,
    Object? timeframe = null,
    Object? period = null,
  }) {
    return _then(_$TrendingSearchesResponseImpl(
      searches: null == searches
          ? _value._searches
          : searches // ignore: cast_nullable_to_non_nullable
              as List<TrendingSearch>,
      totalCount: null == totalCount
          ? _value.totalCount
          : totalCount // ignore: cast_nullable_to_non_nullable
              as int,
      timeframe: null == timeframe
          ? _value.timeframe
          : timeframe // ignore: cast_nullable_to_non_nullable
              as String,
      period: null == period
          ? _value.period
          : period // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TrendingSearchesResponseImpl implements _TrendingSearchesResponse {
  const _$TrendingSearchesResponseImpl(
      {final List<TrendingSearch> searches = const [],
      this.totalCount = 0,
      required this.timeframe,
      required this.period})
      : _searches = searches;

  factory _$TrendingSearchesResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrendingSearchesResponseImplFromJson(json);

  final List<TrendingSearch> _searches;
  @override
  @JsonKey()
  List<TrendingSearch> get searches {
    if (_searches is EqualUnmodifiableListView) return _searches;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_searches);
  }

  @override
  @JsonKey()
  final int totalCount;
  @override
  final String timeframe;
  @override
  final String period;

  @override
  String toString() {
    return 'TrendingSearchesResponse(searches: $searches, totalCount: $totalCount, timeframe: $timeframe, period: $period)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrendingSearchesResponseImpl &&
            const DeepCollectionEquality().equals(other._searches, _searches) &&
            (identical(other.totalCount, totalCount) ||
                other.totalCount == totalCount) &&
            (identical(other.timeframe, timeframe) ||
                other.timeframe == timeframe) &&
            (identical(other.period, period) || other.period == period));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_searches),
      totalCount,
      timeframe,
      period);

  /// Create a copy of TrendingSearchesResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrendingSearchesResponseImplCopyWith<_$TrendingSearchesResponseImpl>
      get copyWith => __$$TrendingSearchesResponseImplCopyWithImpl<
          _$TrendingSearchesResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TrendingSearchesResponseImplToJson(
      this,
    );
  }
}

abstract class _TrendingSearchesResponse implements TrendingSearchesResponse {
  const factory _TrendingSearchesResponse(
      {final List<TrendingSearch> searches,
      final int totalCount,
      required final String timeframe,
      required final String period}) = _$TrendingSearchesResponseImpl;

  factory _TrendingSearchesResponse.fromJson(Map<String, dynamic> json) =
      _$TrendingSearchesResponseImpl.fromJson;

  @override
  List<TrendingSearch> get searches;
  @override
  int get totalCount;
  @override
  String get timeframe;
  @override
  String get period;

  /// Create a copy of TrendingSearchesResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrendingSearchesResponseImplCopyWith<_$TrendingSearchesResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}
