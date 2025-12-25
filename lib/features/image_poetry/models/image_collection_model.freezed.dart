// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'image_collection_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SaveImageRequest _$SaveImageRequestFromJson(Map<String, dynamic> json) {
  return _SaveImageRequest.fromJson(json);
}

/// @nodoc
mixin _$SaveImageRequest {
  String get collectionName => throw _privateConstructorUsedError;
  bool get isFavorite => throw _privateConstructorUsedError;

  /// Serializes this SaveImageRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SaveImageRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SaveImageRequestCopyWith<SaveImageRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SaveImageRequestCopyWith<$Res> {
  factory $SaveImageRequestCopyWith(
          SaveImageRequest value, $Res Function(SaveImageRequest) then) =
      _$SaveImageRequestCopyWithImpl<$Res, SaveImageRequest>;
  @useResult
  $Res call({String collectionName, bool isFavorite});
}

/// @nodoc
class _$SaveImageRequestCopyWithImpl<$Res, $Val extends SaveImageRequest>
    implements $SaveImageRequestCopyWith<$Res> {
  _$SaveImageRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SaveImageRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? collectionName = null,
    Object? isFavorite = null,
  }) {
    return _then(_value.copyWith(
      collectionName: null == collectionName
          ? _value.collectionName
          : collectionName // ignore: cast_nullable_to_non_nullable
              as String,
      isFavorite: null == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SaveImageRequestImplCopyWith<$Res>
    implements $SaveImageRequestCopyWith<$Res> {
  factory _$$SaveImageRequestImplCopyWith(_$SaveImageRequestImpl value,
          $Res Function(_$SaveImageRequestImpl) then) =
      __$$SaveImageRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String collectionName, bool isFavorite});
}

/// @nodoc
class __$$SaveImageRequestImplCopyWithImpl<$Res>
    extends _$SaveImageRequestCopyWithImpl<$Res, _$SaveImageRequestImpl>
    implements _$$SaveImageRequestImplCopyWith<$Res> {
  __$$SaveImageRequestImplCopyWithImpl(_$SaveImageRequestImpl _value,
      $Res Function(_$SaveImageRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of SaveImageRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? collectionName = null,
    Object? isFavorite = null,
  }) {
    return _then(_$SaveImageRequestImpl(
      collectionName: null == collectionName
          ? _value.collectionName
          : collectionName // ignore: cast_nullable_to_non_nullable
              as String,
      isFavorite: null == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SaveImageRequestImpl implements _SaveImageRequest {
  const _$SaveImageRequestImpl(
      {this.collectionName = 'My Images', this.isFavorite = false});

  factory _$SaveImageRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$SaveImageRequestImplFromJson(json);

  @override
  @JsonKey()
  final String collectionName;
  @override
  @JsonKey()
  final bool isFavorite;

  @override
  String toString() {
    return 'SaveImageRequest(collectionName: $collectionName, isFavorite: $isFavorite)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SaveImageRequestImpl &&
            (identical(other.collectionName, collectionName) ||
                other.collectionName == collectionName) &&
            (identical(other.isFavorite, isFavorite) ||
                other.isFavorite == isFavorite));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, collectionName, isFavorite);

  /// Create a copy of SaveImageRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SaveImageRequestImplCopyWith<_$SaveImageRequestImpl> get copyWith =>
      __$$SaveImageRequestImplCopyWithImpl<_$SaveImageRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SaveImageRequestImplToJson(
      this,
    );
  }
}

abstract class _SaveImageRequest implements SaveImageRequest {
  const factory _SaveImageRequest(
      {final String collectionName,
      final bool isFavorite}) = _$SaveImageRequestImpl;

  factory _SaveImageRequest.fromJson(Map<String, dynamic> json) =
      _$SaveImageRequestImpl.fromJson;

  @override
  String get collectionName;
  @override
  bool get isFavorite;

  /// Create a copy of SaveImageRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SaveImageRequestImplCopyWith<_$SaveImageRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CollectionStatsModel _$CollectionStatsModelFromJson(Map<String, dynamic> json) {
  return _CollectionStatsModel.fromJson(json);
}

/// @nodoc
mixin _$CollectionStatsModel {
  int get totalImages => throw _privateConstructorUsedError;
  int get favoriteCount => throw _privateConstructorUsedError;
  int get collectionCount => throw _privateConstructorUsedError;
  List<String> get collectionNames => throw _privateConstructorUsedError;

  /// Serializes this CollectionStatsModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CollectionStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CollectionStatsModelCopyWith<CollectionStatsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CollectionStatsModelCopyWith<$Res> {
  factory $CollectionStatsModelCopyWith(CollectionStatsModel value,
          $Res Function(CollectionStatsModel) then) =
      _$CollectionStatsModelCopyWithImpl<$Res, CollectionStatsModel>;
  @useResult
  $Res call(
      {int totalImages,
      int favoriteCount,
      int collectionCount,
      List<String> collectionNames});
}

/// @nodoc
class _$CollectionStatsModelCopyWithImpl<$Res,
        $Val extends CollectionStatsModel>
    implements $CollectionStatsModelCopyWith<$Res> {
  _$CollectionStatsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CollectionStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalImages = null,
    Object? favoriteCount = null,
    Object? collectionCount = null,
    Object? collectionNames = null,
  }) {
    return _then(_value.copyWith(
      totalImages: null == totalImages
          ? _value.totalImages
          : totalImages // ignore: cast_nullable_to_non_nullable
              as int,
      favoriteCount: null == favoriteCount
          ? _value.favoriteCount
          : favoriteCount // ignore: cast_nullable_to_non_nullable
              as int,
      collectionCount: null == collectionCount
          ? _value.collectionCount
          : collectionCount // ignore: cast_nullable_to_non_nullable
              as int,
      collectionNames: null == collectionNames
          ? _value.collectionNames
          : collectionNames // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CollectionStatsModelImplCopyWith<$Res>
    implements $CollectionStatsModelCopyWith<$Res> {
  factory _$$CollectionStatsModelImplCopyWith(_$CollectionStatsModelImpl value,
          $Res Function(_$CollectionStatsModelImpl) then) =
      __$$CollectionStatsModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int totalImages,
      int favoriteCount,
      int collectionCount,
      List<String> collectionNames});
}

/// @nodoc
class __$$CollectionStatsModelImplCopyWithImpl<$Res>
    extends _$CollectionStatsModelCopyWithImpl<$Res, _$CollectionStatsModelImpl>
    implements _$$CollectionStatsModelImplCopyWith<$Res> {
  __$$CollectionStatsModelImplCopyWithImpl(_$CollectionStatsModelImpl _value,
      $Res Function(_$CollectionStatsModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of CollectionStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalImages = null,
    Object? favoriteCount = null,
    Object? collectionCount = null,
    Object? collectionNames = null,
  }) {
    return _then(_$CollectionStatsModelImpl(
      totalImages: null == totalImages
          ? _value.totalImages
          : totalImages // ignore: cast_nullable_to_non_nullable
              as int,
      favoriteCount: null == favoriteCount
          ? _value.favoriteCount
          : favoriteCount // ignore: cast_nullable_to_non_nullable
              as int,
      collectionCount: null == collectionCount
          ? _value.collectionCount
          : collectionCount // ignore: cast_nullable_to_non_nullable
              as int,
      collectionNames: null == collectionNames
          ? _value._collectionNames
          : collectionNames // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CollectionStatsModelImpl implements _CollectionStatsModel {
  const _$CollectionStatsModelImpl(
      {this.totalImages = 0,
      this.favoriteCount = 0,
      this.collectionCount = 0,
      final List<String> collectionNames = const []})
      : _collectionNames = collectionNames;

  factory _$CollectionStatsModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CollectionStatsModelImplFromJson(json);

  @override
  @JsonKey()
  final int totalImages;
  @override
  @JsonKey()
  final int favoriteCount;
  @override
  @JsonKey()
  final int collectionCount;
  final List<String> _collectionNames;
  @override
  @JsonKey()
  List<String> get collectionNames {
    if (_collectionNames is EqualUnmodifiableListView) return _collectionNames;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_collectionNames);
  }

  @override
  String toString() {
    return 'CollectionStatsModel(totalImages: $totalImages, favoriteCount: $favoriteCount, collectionCount: $collectionCount, collectionNames: $collectionNames)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CollectionStatsModelImpl &&
            (identical(other.totalImages, totalImages) ||
                other.totalImages == totalImages) &&
            (identical(other.favoriteCount, favoriteCount) ||
                other.favoriteCount == favoriteCount) &&
            (identical(other.collectionCount, collectionCount) ||
                other.collectionCount == collectionCount) &&
            const DeepCollectionEquality()
                .equals(other._collectionNames, _collectionNames));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, totalImages, favoriteCount,
      collectionCount, const DeepCollectionEquality().hash(_collectionNames));

  /// Create a copy of CollectionStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CollectionStatsModelImplCopyWith<_$CollectionStatsModelImpl>
      get copyWith =>
          __$$CollectionStatsModelImplCopyWithImpl<_$CollectionStatsModelImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CollectionStatsModelImplToJson(
      this,
    );
  }
}

abstract class _CollectionStatsModel implements CollectionStatsModel {
  const factory _CollectionStatsModel(
      {final int totalImages,
      final int favoriteCount,
      final int collectionCount,
      final List<String> collectionNames}) = _$CollectionStatsModelImpl;

  factory _CollectionStatsModel.fromJson(Map<String, dynamic> json) =
      _$CollectionStatsModelImpl.fromJson;

  @override
  int get totalImages;
  @override
  int get favoriteCount;
  @override
  int get collectionCount;
  @override
  List<String> get collectionNames;

  /// Create a copy of CollectionStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CollectionStatsModelImplCopyWith<_$CollectionStatsModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
