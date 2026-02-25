// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'poets_discovery_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PoetSection {
  List<PoetModel> get poets => throw _privateConstructorUsedError;
  int get totalCount => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $PoetSectionCopyWith<PoetSection> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PoetSectionCopyWith<$Res> {
  factory $PoetSectionCopyWith(
          PoetSection value, $Res Function(PoetSection) then) =
      _$PoetSectionCopyWithImpl<$Res, PoetSection>;
  @useResult
  $Res call({List<PoetModel> poets, int totalCount});
}

/// @nodoc
class _$PoetSectionCopyWithImpl<$Res, $Val extends PoetSection>
    implements $PoetSectionCopyWith<$Res> {
  _$PoetSectionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? poets = null,
    Object? totalCount = null,
  }) {
    return _then(_value.copyWith(
      poets: null == poets
          ? _value.poets
          : poets // ignore: cast_nullable_to_non_nullable
              as List<PoetModel>,
      totalCount: null == totalCount
          ? _value.totalCount
          : totalCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PoetSectionImplCopyWith<$Res>
    implements $PoetSectionCopyWith<$Res> {
  factory _$$PoetSectionImplCopyWith(
          _$PoetSectionImpl value, $Res Function(_$PoetSectionImpl) then) =
      __$$PoetSectionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<PoetModel> poets, int totalCount});
}

/// @nodoc
class __$$PoetSectionImplCopyWithImpl<$Res>
    extends _$PoetSectionCopyWithImpl<$Res, _$PoetSectionImpl>
    implements _$$PoetSectionImplCopyWith<$Res> {
  __$$PoetSectionImplCopyWithImpl(
      _$PoetSectionImpl _value, $Res Function(_$PoetSectionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? poets = null,
    Object? totalCount = null,
  }) {
    return _then(_$PoetSectionImpl(
      poets: null == poets
          ? _value._poets
          : poets // ignore: cast_nullable_to_non_nullable
              as List<PoetModel>,
      totalCount: null == totalCount
          ? _value.totalCount
          : totalCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$PoetSectionImpl implements _PoetSection {
  const _$PoetSectionImpl(
      {final List<PoetModel> poets = const [], this.totalCount = 0})
      : _poets = poets;

  final List<PoetModel> _poets;
  @override
  @JsonKey()
  List<PoetModel> get poets {
    if (_poets is EqualUnmodifiableListView) return _poets;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_poets);
  }

  @override
  @JsonKey()
  final int totalCount;

  @override
  String toString() {
    return 'PoetSection(poets: $poets, totalCount: $totalCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PoetSectionImpl &&
            const DeepCollectionEquality().equals(other._poets, _poets) &&
            (identical(other.totalCount, totalCount) ||
                other.totalCount == totalCount));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_poets), totalCount);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PoetSectionImplCopyWith<_$PoetSectionImpl> get copyWith =>
      __$$PoetSectionImplCopyWithImpl<_$PoetSectionImpl>(this, _$identity);
}

abstract class _PoetSection implements PoetSection {
  const factory _PoetSection(
      {final List<PoetModel> poets, final int totalCount}) = _$PoetSectionImpl;

  @override
  List<PoetModel> get poets;
  @override
  int get totalCount;
  @override
  @JsonKey(ignore: true)
  _$$PoetSectionImplCopyWith<_$PoetSectionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$PoetsDiscoveryState {
  PoetsDiscoveryStatus get status => throw _privateConstructorUsedError;
  PoetSection get trending => throw _privateConstructorUsedError;
  PoetSection get featured => throw _privateConstructorUsedError;
  PoetSection get topRead => throw _privateConstructorUsedError;
  PoetSection get classical => throw _privateConstructorUsedError;
  PoetSection get modern => throw _privateConstructorUsedError;
  PoetSection get women => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $PoetsDiscoveryStateCopyWith<PoetsDiscoveryState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PoetsDiscoveryStateCopyWith<$Res> {
  factory $PoetsDiscoveryStateCopyWith(
          PoetsDiscoveryState value, $Res Function(PoetsDiscoveryState) then) =
      _$PoetsDiscoveryStateCopyWithImpl<$Res, PoetsDiscoveryState>;
  @useResult
  $Res call(
      {PoetsDiscoveryStatus status,
      PoetSection trending,
      PoetSection featured,
      PoetSection topRead,
      PoetSection classical,
      PoetSection modern,
      PoetSection women,
      String? errorMessage});

  $PoetSectionCopyWith<$Res> get trending;
  $PoetSectionCopyWith<$Res> get featured;
  $PoetSectionCopyWith<$Res> get topRead;
  $PoetSectionCopyWith<$Res> get classical;
  $PoetSectionCopyWith<$Res> get modern;
  $PoetSectionCopyWith<$Res> get women;
}

/// @nodoc
class _$PoetsDiscoveryStateCopyWithImpl<$Res, $Val extends PoetsDiscoveryState>
    implements $PoetsDiscoveryStateCopyWith<$Res> {
  _$PoetsDiscoveryStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? trending = null,
    Object? featured = null,
    Object? topRead = null,
    Object? classical = null,
    Object? modern = null,
    Object? women = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_value.copyWith(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as PoetsDiscoveryStatus,
      trending: null == trending
          ? _value.trending
          : trending // ignore: cast_nullable_to_non_nullable
              as PoetSection,
      featured: null == featured
          ? _value.featured
          : featured // ignore: cast_nullable_to_non_nullable
              as PoetSection,
      topRead: null == topRead
          ? _value.topRead
          : topRead // ignore: cast_nullable_to_non_nullable
              as PoetSection,
      classical: null == classical
          ? _value.classical
          : classical // ignore: cast_nullable_to_non_nullable
              as PoetSection,
      modern: null == modern
          ? _value.modern
          : modern // ignore: cast_nullable_to_non_nullable
              as PoetSection,
      women: null == women
          ? _value.women
          : women // ignore: cast_nullable_to_non_nullable
              as PoetSection,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $PoetSectionCopyWith<$Res> get trending {
    return $PoetSectionCopyWith<$Res>(_value.trending, (value) {
      return _then(_value.copyWith(trending: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $PoetSectionCopyWith<$Res> get featured {
    return $PoetSectionCopyWith<$Res>(_value.featured, (value) {
      return _then(_value.copyWith(featured: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $PoetSectionCopyWith<$Res> get topRead {
    return $PoetSectionCopyWith<$Res>(_value.topRead, (value) {
      return _then(_value.copyWith(topRead: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $PoetSectionCopyWith<$Res> get classical {
    return $PoetSectionCopyWith<$Res>(_value.classical, (value) {
      return _then(_value.copyWith(classical: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $PoetSectionCopyWith<$Res> get modern {
    return $PoetSectionCopyWith<$Res>(_value.modern, (value) {
      return _then(_value.copyWith(modern: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $PoetSectionCopyWith<$Res> get women {
    return $PoetSectionCopyWith<$Res>(_value.women, (value) {
      return _then(_value.copyWith(women: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PoetsDiscoveryStateImplCopyWith<$Res>
    implements $PoetsDiscoveryStateCopyWith<$Res> {
  factory _$$PoetsDiscoveryStateImplCopyWith(_$PoetsDiscoveryStateImpl value,
          $Res Function(_$PoetsDiscoveryStateImpl) then) =
      __$$PoetsDiscoveryStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {PoetsDiscoveryStatus status,
      PoetSection trending,
      PoetSection featured,
      PoetSection topRead,
      PoetSection classical,
      PoetSection modern,
      PoetSection women,
      String? errorMessage});

  @override
  $PoetSectionCopyWith<$Res> get trending;
  @override
  $PoetSectionCopyWith<$Res> get featured;
  @override
  $PoetSectionCopyWith<$Res> get topRead;
  @override
  $PoetSectionCopyWith<$Res> get classical;
  @override
  $PoetSectionCopyWith<$Res> get modern;
  @override
  $PoetSectionCopyWith<$Res> get women;
}

/// @nodoc
class __$$PoetsDiscoveryStateImplCopyWithImpl<$Res>
    extends _$PoetsDiscoveryStateCopyWithImpl<$Res, _$PoetsDiscoveryStateImpl>
    implements _$$PoetsDiscoveryStateImplCopyWith<$Res> {
  __$$PoetsDiscoveryStateImplCopyWithImpl(_$PoetsDiscoveryStateImpl _value,
      $Res Function(_$PoetsDiscoveryStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? trending = null,
    Object? featured = null,
    Object? topRead = null,
    Object? classical = null,
    Object? modern = null,
    Object? women = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_$PoetsDiscoveryStateImpl(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as PoetsDiscoveryStatus,
      trending: null == trending
          ? _value.trending
          : trending // ignore: cast_nullable_to_non_nullable
              as PoetSection,
      featured: null == featured
          ? _value.featured
          : featured // ignore: cast_nullable_to_non_nullable
              as PoetSection,
      topRead: null == topRead
          ? _value.topRead
          : topRead // ignore: cast_nullable_to_non_nullable
              as PoetSection,
      classical: null == classical
          ? _value.classical
          : classical // ignore: cast_nullable_to_non_nullable
              as PoetSection,
      modern: null == modern
          ? _value.modern
          : modern // ignore: cast_nullable_to_non_nullable
              as PoetSection,
      women: null == women
          ? _value.women
          : women // ignore: cast_nullable_to_non_nullable
              as PoetSection,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$PoetsDiscoveryStateImpl implements _PoetsDiscoveryState {
  const _$PoetsDiscoveryStateImpl(
      {this.status = PoetsDiscoveryStatus.initial,
      this.trending = const PoetSection(),
      this.featured = const PoetSection(),
      this.topRead = const PoetSection(),
      this.classical = const PoetSection(),
      this.modern = const PoetSection(),
      this.women = const PoetSection(),
      this.errorMessage});

  @override
  @JsonKey()
  final PoetsDiscoveryStatus status;
  @override
  @JsonKey()
  final PoetSection trending;
  @override
  @JsonKey()
  final PoetSection featured;
  @override
  @JsonKey()
  final PoetSection topRead;
  @override
  @JsonKey()
  final PoetSection classical;
  @override
  @JsonKey()
  final PoetSection modern;
  @override
  @JsonKey()
  final PoetSection women;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'PoetsDiscoveryState(status: $status, trending: $trending, featured: $featured, topRead: $topRead, classical: $classical, modern: $modern, women: $women, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PoetsDiscoveryStateImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.trending, trending) ||
                other.trending == trending) &&
            (identical(other.featured, featured) ||
                other.featured == featured) &&
            (identical(other.topRead, topRead) || other.topRead == topRead) &&
            (identical(other.classical, classical) ||
                other.classical == classical) &&
            (identical(other.modern, modern) || other.modern == modern) &&
            (identical(other.women, women) || other.women == women) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(runtimeType, status, trending, featured,
      topRead, classical, modern, women, errorMessage);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PoetsDiscoveryStateImplCopyWith<_$PoetsDiscoveryStateImpl> get copyWith =>
      __$$PoetsDiscoveryStateImplCopyWithImpl<_$PoetsDiscoveryStateImpl>(
          this, _$identity);
}

abstract class _PoetsDiscoveryState implements PoetsDiscoveryState {
  const factory _PoetsDiscoveryState(
      {final PoetsDiscoveryStatus status,
      final PoetSection trending,
      final PoetSection featured,
      final PoetSection topRead,
      final PoetSection classical,
      final PoetSection modern,
      final PoetSection women,
      final String? errorMessage}) = _$PoetsDiscoveryStateImpl;

  @override
  PoetsDiscoveryStatus get status;
  @override
  PoetSection get trending;
  @override
  PoetSection get featured;
  @override
  PoetSection get topRead;
  @override
  PoetSection get classical;
  @override
  PoetSection get modern;
  @override
  PoetSection get women;
  @override
  String? get errorMessage;
  @override
  @JsonKey(ignore: true)
  _$$PoetsDiscoveryStateImplCopyWith<_$PoetsDiscoveryStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
