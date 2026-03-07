// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'feed_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$FeedResponse {
  List<FeedItem> get items => throw _privateConstructorUsedError;
  String? get nextCursor => throw _privateConstructorUsedError;
  bool get hasMore => throw _privateConstructorUsedError;
  bool get isPersonalized => throw _privateConstructorUsedError;
  String get sessionId => throw _privateConstructorUsedError;
  int get itemCount => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $FeedResponseCopyWith<FeedResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FeedResponseCopyWith<$Res> {
  factory $FeedResponseCopyWith(
          FeedResponse value, $Res Function(FeedResponse) then) =
      _$FeedResponseCopyWithImpl<$Res, FeedResponse>;
  @useResult
  $Res call(
      {List<FeedItem> items,
      String? nextCursor,
      bool hasMore,
      bool isPersonalized,
      String sessionId,
      int itemCount});
}

/// @nodoc
class _$FeedResponseCopyWithImpl<$Res, $Val extends FeedResponse>
    implements $FeedResponseCopyWith<$Res> {
  _$FeedResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? nextCursor = freezed,
    Object? hasMore = null,
    Object? isPersonalized = null,
    Object? sessionId = null,
    Object? itemCount = null,
  }) {
    return _then(_value.copyWith(
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<FeedItem>,
      nextCursor: freezed == nextCursor
          ? _value.nextCursor
          : nextCursor // ignore: cast_nullable_to_non_nullable
              as String?,
      hasMore: null == hasMore
          ? _value.hasMore
          : hasMore // ignore: cast_nullable_to_non_nullable
              as bool,
      isPersonalized: null == isPersonalized
          ? _value.isPersonalized
          : isPersonalized // ignore: cast_nullable_to_non_nullable
              as bool,
      sessionId: null == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String,
      itemCount: null == itemCount
          ? _value.itemCount
          : itemCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FeedResponseImplCopyWith<$Res>
    implements $FeedResponseCopyWith<$Res> {
  factory _$$FeedResponseImplCopyWith(
          _$FeedResponseImpl value, $Res Function(_$FeedResponseImpl) then) =
      __$$FeedResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<FeedItem> items,
      String? nextCursor,
      bool hasMore,
      bool isPersonalized,
      String sessionId,
      int itemCount});
}

/// @nodoc
class __$$FeedResponseImplCopyWithImpl<$Res>
    extends _$FeedResponseCopyWithImpl<$Res, _$FeedResponseImpl>
    implements _$$FeedResponseImplCopyWith<$Res> {
  __$$FeedResponseImplCopyWithImpl(
      _$FeedResponseImpl _value, $Res Function(_$FeedResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? nextCursor = freezed,
    Object? hasMore = null,
    Object? isPersonalized = null,
    Object? sessionId = null,
    Object? itemCount = null,
  }) {
    return _then(_$FeedResponseImpl(
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<FeedItem>,
      nextCursor: freezed == nextCursor
          ? _value.nextCursor
          : nextCursor // ignore: cast_nullable_to_non_nullable
              as String?,
      hasMore: null == hasMore
          ? _value.hasMore
          : hasMore // ignore: cast_nullable_to_non_nullable
              as bool,
      isPersonalized: null == isPersonalized
          ? _value.isPersonalized
          : isPersonalized // ignore: cast_nullable_to_non_nullable
              as bool,
      sessionId: null == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String,
      itemCount: null == itemCount
          ? _value.itemCount
          : itemCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$FeedResponseImpl with DiagnosticableTreeMixin implements _FeedResponse {
  const _$FeedResponseImpl(
      {required final List<FeedItem> items,
      this.nextCursor,
      this.hasMore = false,
      this.isPersonalized = false,
      this.sessionId = '',
      this.itemCount = 0})
      : _items = items;

  final List<FeedItem> _items;
  @override
  List<FeedItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final String? nextCursor;
  @override
  @JsonKey()
  final bool hasMore;
  @override
  @JsonKey()
  final bool isPersonalized;
  @override
  @JsonKey()
  final String sessionId;
  @override
  @JsonKey()
  final int itemCount;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'FeedResponse(items: $items, nextCursor: $nextCursor, hasMore: $hasMore, isPersonalized: $isPersonalized, sessionId: $sessionId, itemCount: $itemCount)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'FeedResponse'))
      ..add(DiagnosticsProperty('items', items))
      ..add(DiagnosticsProperty('nextCursor', nextCursor))
      ..add(DiagnosticsProperty('hasMore', hasMore))
      ..add(DiagnosticsProperty('isPersonalized', isPersonalized))
      ..add(DiagnosticsProperty('sessionId', sessionId))
      ..add(DiagnosticsProperty('itemCount', itemCount));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeedResponseImpl &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.nextCursor, nextCursor) ||
                other.nextCursor == nextCursor) &&
            (identical(other.hasMore, hasMore) || other.hasMore == hasMore) &&
            (identical(other.isPersonalized, isPersonalized) ||
                other.isPersonalized == isPersonalized) &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.itemCount, itemCount) ||
                other.itemCount == itemCount));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_items),
      nextCursor,
      hasMore,
      isPersonalized,
      sessionId,
      itemCount);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FeedResponseImplCopyWith<_$FeedResponseImpl> get copyWith =>
      __$$FeedResponseImplCopyWithImpl<_$FeedResponseImpl>(this, _$identity);
}

abstract class _FeedResponse implements FeedResponse {
  const factory _FeedResponse(
      {required final List<FeedItem> items,
      final String? nextCursor,
      final bool hasMore,
      final bool isPersonalized,
      final String sessionId,
      final int itemCount}) = _$FeedResponseImpl;

  @override
  List<FeedItem> get items;
  @override
  String? get nextCursor;
  @override
  bool get hasMore;
  @override
  bool get isPersonalized;
  @override
  String get sessionId;
  @override
  int get itemCount;
  @override
  @JsonKey(ignore: true)
  _$$FeedResponseImplCopyWith<_$FeedResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
