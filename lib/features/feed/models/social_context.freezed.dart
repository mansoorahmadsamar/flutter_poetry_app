// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'social_context.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SocialContext {
  List<String>? get reactedByNames => throw _privateConstructorUsedError;
  int? get totalReactions => throw _privateConstructorUsedError;
  String? get trendingLabel => throw _privateConstructorUsedError;
  String? get velocityLabel => throw _privateConstructorUsedError;
  String? get activityLabel => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $SocialContextCopyWith<SocialContext> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SocialContextCopyWith<$Res> {
  factory $SocialContextCopyWith(
          SocialContext value, $Res Function(SocialContext) then) =
      _$SocialContextCopyWithImpl<$Res, SocialContext>;
  @useResult
  $Res call(
      {List<String>? reactedByNames,
      int? totalReactions,
      String? trendingLabel,
      String? velocityLabel,
      String? activityLabel});
}

/// @nodoc
class _$SocialContextCopyWithImpl<$Res, $Val extends SocialContext>
    implements $SocialContextCopyWith<$Res> {
  _$SocialContextCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? reactedByNames = freezed,
    Object? totalReactions = freezed,
    Object? trendingLabel = freezed,
    Object? velocityLabel = freezed,
    Object? activityLabel = freezed,
  }) {
    return _then(_value.copyWith(
      reactedByNames: freezed == reactedByNames
          ? _value.reactedByNames
          : reactedByNames // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      totalReactions: freezed == totalReactions
          ? _value.totalReactions
          : totalReactions // ignore: cast_nullable_to_non_nullable
              as int?,
      trendingLabel: freezed == trendingLabel
          ? _value.trendingLabel
          : trendingLabel // ignore: cast_nullable_to_non_nullable
              as String?,
      velocityLabel: freezed == velocityLabel
          ? _value.velocityLabel
          : velocityLabel // ignore: cast_nullable_to_non_nullable
              as String?,
      activityLabel: freezed == activityLabel
          ? _value.activityLabel
          : activityLabel // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SocialContextImplCopyWith<$Res>
    implements $SocialContextCopyWith<$Res> {
  factory _$$SocialContextImplCopyWith(
          _$SocialContextImpl value, $Res Function(_$SocialContextImpl) then) =
      __$$SocialContextImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<String>? reactedByNames,
      int? totalReactions,
      String? trendingLabel,
      String? velocityLabel,
      String? activityLabel});
}

/// @nodoc
class __$$SocialContextImplCopyWithImpl<$Res>
    extends _$SocialContextCopyWithImpl<$Res, _$SocialContextImpl>
    implements _$$SocialContextImplCopyWith<$Res> {
  __$$SocialContextImplCopyWithImpl(
      _$SocialContextImpl _value, $Res Function(_$SocialContextImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? reactedByNames = freezed,
    Object? totalReactions = freezed,
    Object? trendingLabel = freezed,
    Object? velocityLabel = freezed,
    Object? activityLabel = freezed,
  }) {
    return _then(_$SocialContextImpl(
      reactedByNames: freezed == reactedByNames
          ? _value._reactedByNames
          : reactedByNames // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      totalReactions: freezed == totalReactions
          ? _value.totalReactions
          : totalReactions // ignore: cast_nullable_to_non_nullable
              as int?,
      trendingLabel: freezed == trendingLabel
          ? _value.trendingLabel
          : trendingLabel // ignore: cast_nullable_to_non_nullable
              as String?,
      velocityLabel: freezed == velocityLabel
          ? _value.velocityLabel
          : velocityLabel // ignore: cast_nullable_to_non_nullable
              as String?,
      activityLabel: freezed == activityLabel
          ? _value.activityLabel
          : activityLabel // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$SocialContextImpl implements _SocialContext {
  const _$SocialContextImpl(
      {final List<String>? reactedByNames,
      this.totalReactions,
      this.trendingLabel,
      this.velocityLabel,
      this.activityLabel})
      : _reactedByNames = reactedByNames;

  final List<String>? _reactedByNames;
  @override
  List<String>? get reactedByNames {
    final value = _reactedByNames;
    if (value == null) return null;
    if (_reactedByNames is EqualUnmodifiableListView) return _reactedByNames;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final int? totalReactions;
  @override
  final String? trendingLabel;
  @override
  final String? velocityLabel;
  @override
  final String? activityLabel;

  @override
  String toString() {
    return 'SocialContext(reactedByNames: $reactedByNames, totalReactions: $totalReactions, trendingLabel: $trendingLabel, velocityLabel: $velocityLabel, activityLabel: $activityLabel)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SocialContextImpl &&
            const DeepCollectionEquality()
                .equals(other._reactedByNames, _reactedByNames) &&
            (identical(other.totalReactions, totalReactions) ||
                other.totalReactions == totalReactions) &&
            (identical(other.trendingLabel, trendingLabel) ||
                other.trendingLabel == trendingLabel) &&
            (identical(other.velocityLabel, velocityLabel) ||
                other.velocityLabel == velocityLabel) &&
            (identical(other.activityLabel, activityLabel) ||
                other.activityLabel == activityLabel));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_reactedByNames),
      totalReactions,
      trendingLabel,
      velocityLabel,
      activityLabel);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SocialContextImplCopyWith<_$SocialContextImpl> get copyWith =>
      __$$SocialContextImplCopyWithImpl<_$SocialContextImpl>(this, _$identity);
}

abstract class _SocialContext implements SocialContext {
  const factory _SocialContext(
      {final List<String>? reactedByNames,
      final int? totalReactions,
      final String? trendingLabel,
      final String? velocityLabel,
      final String? activityLabel}) = _$SocialContextImpl;

  @override
  List<String>? get reactedByNames;
  @override
  int? get totalReactions;
  @override
  String? get trendingLabel;
  @override
  String? get velocityLabel;
  @override
  String? get activityLabel;
  @override
  @JsonKey(ignore: true)
  _$$SocialContextImplCopyWith<_$SocialContextImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
