// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reaction_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ReactionType _$ReactionTypeFromJson(Map<String, dynamic> json) {
  return _ReactionType.fromJson(json);
}

/// @nodoc
mixin _$ReactionType {
  String get key => throw _privateConstructorUsedError;
  String get emoji => throw _privateConstructorUsedError;
  String get urduLabel => throw _privateConstructorUsedError;
  String get englishLabel => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ReactionTypeCopyWith<ReactionType> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReactionTypeCopyWith<$Res> {
  factory $ReactionTypeCopyWith(
          ReactionType value, $Res Function(ReactionType) then) =
      _$ReactionTypeCopyWithImpl<$Res, ReactionType>;
  @useResult
  $Res call({String key, String emoji, String urduLabel, String englishLabel});
}

/// @nodoc
class _$ReactionTypeCopyWithImpl<$Res, $Val extends ReactionType>
    implements $ReactionTypeCopyWith<$Res> {
  _$ReactionTypeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? key = null,
    Object? emoji = null,
    Object? urduLabel = null,
    Object? englishLabel = null,
  }) {
    return _then(_value.copyWith(
      key: null == key
          ? _value.key
          : key // ignore: cast_nullable_to_non_nullable
              as String,
      emoji: null == emoji
          ? _value.emoji
          : emoji // ignore: cast_nullable_to_non_nullable
              as String,
      urduLabel: null == urduLabel
          ? _value.urduLabel
          : urduLabel // ignore: cast_nullable_to_non_nullable
              as String,
      englishLabel: null == englishLabel
          ? _value.englishLabel
          : englishLabel // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReactionTypeImplCopyWith<$Res>
    implements $ReactionTypeCopyWith<$Res> {
  factory _$$ReactionTypeImplCopyWith(
          _$ReactionTypeImpl value, $Res Function(_$ReactionTypeImpl) then) =
      __$$ReactionTypeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String key, String emoji, String urduLabel, String englishLabel});
}

/// @nodoc
class __$$ReactionTypeImplCopyWithImpl<$Res>
    extends _$ReactionTypeCopyWithImpl<$Res, _$ReactionTypeImpl>
    implements _$$ReactionTypeImplCopyWith<$Res> {
  __$$ReactionTypeImplCopyWithImpl(
      _$ReactionTypeImpl _value, $Res Function(_$ReactionTypeImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? key = null,
    Object? emoji = null,
    Object? urduLabel = null,
    Object? englishLabel = null,
  }) {
    return _then(_$ReactionTypeImpl(
      key: null == key
          ? _value.key
          : key // ignore: cast_nullable_to_non_nullable
              as String,
      emoji: null == emoji
          ? _value.emoji
          : emoji // ignore: cast_nullable_to_non_nullable
              as String,
      urduLabel: null == urduLabel
          ? _value.urduLabel
          : urduLabel // ignore: cast_nullable_to_non_nullable
              as String,
      englishLabel: null == englishLabel
          ? _value.englishLabel
          : englishLabel // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReactionTypeImpl implements _ReactionType {
  const _$ReactionTypeImpl(
      {required this.key,
      required this.emoji,
      required this.urduLabel,
      required this.englishLabel});

  factory _$ReactionTypeImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReactionTypeImplFromJson(json);

  @override
  final String key;
  @override
  final String emoji;
  @override
  final String urduLabel;
  @override
  final String englishLabel;

  @override
  String toString() {
    return 'ReactionType(key: $key, emoji: $emoji, urduLabel: $urduLabel, englishLabel: $englishLabel)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReactionTypeImpl &&
            (identical(other.key, key) || other.key == key) &&
            (identical(other.emoji, emoji) || other.emoji == emoji) &&
            (identical(other.urduLabel, urduLabel) ||
                other.urduLabel == urduLabel) &&
            (identical(other.englishLabel, englishLabel) ||
                other.englishLabel == englishLabel));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, key, emoji, urduLabel, englishLabel);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ReactionTypeImplCopyWith<_$ReactionTypeImpl> get copyWith =>
      __$$ReactionTypeImplCopyWithImpl<_$ReactionTypeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReactionTypeImplToJson(
      this,
    );
  }
}

abstract class _ReactionType implements ReactionType {
  const factory _ReactionType(
      {required final String key,
      required final String emoji,
      required final String urduLabel,
      required final String englishLabel}) = _$ReactionTypeImpl;

  factory _ReactionType.fromJson(Map<String, dynamic> json) =
      _$ReactionTypeImpl.fromJson;

  @override
  String get key;
  @override
  String get emoji;
  @override
  String get urduLabel;
  @override
  String get englishLabel;
  @override
  @JsonKey(ignore: true)
  _$$ReactionTypeImplCopyWith<_$ReactionTypeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ReactionSummary _$ReactionSummaryFromJson(Map<String, dynamic> json) {
  return _ReactionSummary.fromJson(json);
}

/// @nodoc
mixin _$ReactionSummary {
  int get total => throw _privateConstructorUsedError;
  Map<String, int>? get byType => throw _privateConstructorUsedError;
  String? get userReaction => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ReactionSummaryCopyWith<ReactionSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReactionSummaryCopyWith<$Res> {
  factory $ReactionSummaryCopyWith(
          ReactionSummary value, $Res Function(ReactionSummary) then) =
      _$ReactionSummaryCopyWithImpl<$Res, ReactionSummary>;
  @useResult
  $Res call({int total, Map<String, int>? byType, String? userReaction});
}

/// @nodoc
class _$ReactionSummaryCopyWithImpl<$Res, $Val extends ReactionSummary>
    implements $ReactionSummaryCopyWith<$Res> {
  _$ReactionSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? total = null,
    Object? byType = freezed,
    Object? userReaction = freezed,
  }) {
    return _then(_value.copyWith(
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      byType: freezed == byType
          ? _value.byType
          : byType // ignore: cast_nullable_to_non_nullable
              as Map<String, int>?,
      userReaction: freezed == userReaction
          ? _value.userReaction
          : userReaction // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReactionSummaryImplCopyWith<$Res>
    implements $ReactionSummaryCopyWith<$Res> {
  factory _$$ReactionSummaryImplCopyWith(_$ReactionSummaryImpl value,
          $Res Function(_$ReactionSummaryImpl) then) =
      __$$ReactionSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int total, Map<String, int>? byType, String? userReaction});
}

/// @nodoc
class __$$ReactionSummaryImplCopyWithImpl<$Res>
    extends _$ReactionSummaryCopyWithImpl<$Res, _$ReactionSummaryImpl>
    implements _$$ReactionSummaryImplCopyWith<$Res> {
  __$$ReactionSummaryImplCopyWithImpl(
      _$ReactionSummaryImpl _value, $Res Function(_$ReactionSummaryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? total = null,
    Object? byType = freezed,
    Object? userReaction = freezed,
  }) {
    return _then(_$ReactionSummaryImpl(
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      byType: freezed == byType
          ? _value._byType
          : byType // ignore: cast_nullable_to_non_nullable
              as Map<String, int>?,
      userReaction: freezed == userReaction
          ? _value.userReaction
          : userReaction // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReactionSummaryImpl extends _ReactionSummary {
  const _$ReactionSummaryImpl(
      {this.total = 0, final Map<String, int>? byType, this.userReaction})
      : _byType = byType,
        super._();

  factory _$ReactionSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReactionSummaryImplFromJson(json);

  @override
  @JsonKey()
  final int total;
  final Map<String, int>? _byType;
  @override
  Map<String, int>? get byType {
    final value = _byType;
    if (value == null) return null;
    if (_byType is EqualUnmodifiableMapView) return _byType;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final String? userReaction;

  @override
  String toString() {
    return 'ReactionSummary(total: $total, byType: $byType, userReaction: $userReaction)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReactionSummaryImpl &&
            (identical(other.total, total) || other.total == total) &&
            const DeepCollectionEquality().equals(other._byType, _byType) &&
            (identical(other.userReaction, userReaction) ||
                other.userReaction == userReaction));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, total,
      const DeepCollectionEquality().hash(_byType), userReaction);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ReactionSummaryImplCopyWith<_$ReactionSummaryImpl> get copyWith =>
      __$$ReactionSummaryImplCopyWithImpl<_$ReactionSummaryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReactionSummaryImplToJson(
      this,
    );
  }
}

abstract class _ReactionSummary extends ReactionSummary {
  const factory _ReactionSummary(
      {final int total,
      final Map<String, int>? byType,
      final String? userReaction}) = _$ReactionSummaryImpl;
  const _ReactionSummary._() : super._();

  factory _ReactionSummary.fromJson(Map<String, dynamic> json) =
      _$ReactionSummaryImpl.fromJson;

  @override
  int get total;
  @override
  Map<String, int>? get byType;
  @override
  String? get userReaction;
  @override
  @JsonKey(ignore: true)
  _$$ReactionSummaryImplCopyWith<_$ReactionSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ReactionResponse _$ReactionResponseFromJson(Map<String, dynamic> json) {
  return _ReactionResponse.fromJson(json);
}

/// @nodoc
mixin _$ReactionResponse {
  String? get userReaction => throw _privateConstructorUsedError;
  int get totalReactionCount => throw _privateConstructorUsedError;
  Map<String, int>? get reactionCounts => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ReactionResponseCopyWith<ReactionResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReactionResponseCopyWith<$Res> {
  factory $ReactionResponseCopyWith(
          ReactionResponse value, $Res Function(ReactionResponse) then) =
      _$ReactionResponseCopyWithImpl<$Res, ReactionResponse>;
  @useResult
  $Res call(
      {String? userReaction,
      int totalReactionCount,
      Map<String, int>? reactionCounts,
      String? message});
}

/// @nodoc
class _$ReactionResponseCopyWithImpl<$Res, $Val extends ReactionResponse>
    implements $ReactionResponseCopyWith<$Res> {
  _$ReactionResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userReaction = freezed,
    Object? totalReactionCount = null,
    Object? reactionCounts = freezed,
    Object? message = freezed,
  }) {
    return _then(_value.copyWith(
      userReaction: freezed == userReaction
          ? _value.userReaction
          : userReaction // ignore: cast_nullable_to_non_nullable
              as String?,
      totalReactionCount: null == totalReactionCount
          ? _value.totalReactionCount
          : totalReactionCount // ignore: cast_nullable_to_non_nullable
              as int,
      reactionCounts: freezed == reactionCounts
          ? _value.reactionCounts
          : reactionCounts // ignore: cast_nullable_to_non_nullable
              as Map<String, int>?,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReactionResponseImplCopyWith<$Res>
    implements $ReactionResponseCopyWith<$Res> {
  factory _$$ReactionResponseImplCopyWith(_$ReactionResponseImpl value,
          $Res Function(_$ReactionResponseImpl) then) =
      __$$ReactionResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? userReaction,
      int totalReactionCount,
      Map<String, int>? reactionCounts,
      String? message});
}

/// @nodoc
class __$$ReactionResponseImplCopyWithImpl<$Res>
    extends _$ReactionResponseCopyWithImpl<$Res, _$ReactionResponseImpl>
    implements _$$ReactionResponseImplCopyWith<$Res> {
  __$$ReactionResponseImplCopyWithImpl(_$ReactionResponseImpl _value,
      $Res Function(_$ReactionResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userReaction = freezed,
    Object? totalReactionCount = null,
    Object? reactionCounts = freezed,
    Object? message = freezed,
  }) {
    return _then(_$ReactionResponseImpl(
      userReaction: freezed == userReaction
          ? _value.userReaction
          : userReaction // ignore: cast_nullable_to_non_nullable
              as String?,
      totalReactionCount: null == totalReactionCount
          ? _value.totalReactionCount
          : totalReactionCount // ignore: cast_nullable_to_non_nullable
              as int,
      reactionCounts: freezed == reactionCounts
          ? _value._reactionCounts
          : reactionCounts // ignore: cast_nullable_to_non_nullable
              as Map<String, int>?,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReactionResponseImpl implements _ReactionResponse {
  const _$ReactionResponseImpl(
      {this.userReaction,
      this.totalReactionCount = 0,
      final Map<String, int>? reactionCounts,
      this.message})
      : _reactionCounts = reactionCounts;

  factory _$ReactionResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReactionResponseImplFromJson(json);

  @override
  final String? userReaction;
  @override
  @JsonKey()
  final int totalReactionCount;
  final Map<String, int>? _reactionCounts;
  @override
  Map<String, int>? get reactionCounts {
    final value = _reactionCounts;
    if (value == null) return null;
    if (_reactionCounts is EqualUnmodifiableMapView) return _reactionCounts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final String? message;

  @override
  String toString() {
    return 'ReactionResponse(userReaction: $userReaction, totalReactionCount: $totalReactionCount, reactionCounts: $reactionCounts, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReactionResponseImpl &&
            (identical(other.userReaction, userReaction) ||
                other.userReaction == userReaction) &&
            (identical(other.totalReactionCount, totalReactionCount) ||
                other.totalReactionCount == totalReactionCount) &&
            const DeepCollectionEquality()
                .equals(other._reactionCounts, _reactionCounts) &&
            (identical(other.message, message) || other.message == message));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, userReaction, totalReactionCount,
      const DeepCollectionEquality().hash(_reactionCounts), message);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ReactionResponseImplCopyWith<_$ReactionResponseImpl> get copyWith =>
      __$$ReactionResponseImplCopyWithImpl<_$ReactionResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReactionResponseImplToJson(
      this,
    );
  }
}

abstract class _ReactionResponse implements ReactionResponse {
  const factory _ReactionResponse(
      {final String? userReaction,
      final int totalReactionCount,
      final Map<String, int>? reactionCounts,
      final String? message}) = _$ReactionResponseImpl;

  factory _ReactionResponse.fromJson(Map<String, dynamic> json) =
      _$ReactionResponseImpl.fromJson;

  @override
  String? get userReaction;
  @override
  int get totalReactionCount;
  @override
  Map<String, int>? get reactionCounts;
  @override
  String? get message;
  @override
  @JsonKey(ignore: true)
  _$$ReactionResponseImplCopyWith<_$ReactionResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
