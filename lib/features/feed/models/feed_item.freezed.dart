// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'feed_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$FeedItem {
  String get type => throw _privateConstructorUsedError;
  String get publicId => throw _privateConstructorUsedError;
  String get reason => throw _privateConstructorUsedError;
  String get sourceId => throw _privateConstructorUsedError;
  String? get lang => throw _privateConstructorUsedError;
  FeedContentData get contentData => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $FeedItemCopyWith<FeedItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FeedItemCopyWith<$Res> {
  factory $FeedItemCopyWith(FeedItem value, $Res Function(FeedItem) then) =
      _$FeedItemCopyWithImpl<$Res, FeedItem>;
  @useResult
  $Res call(
      {String type,
      String publicId,
      String reason,
      String sourceId,
      String? lang,
      FeedContentData contentData});
}

/// @nodoc
class _$FeedItemCopyWithImpl<$Res, $Val extends FeedItem>
    implements $FeedItemCopyWith<$Res> {
  _$FeedItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? publicId = null,
    Object? reason = null,
    Object? sourceId = null,
    Object? lang = freezed,
    Object? contentData = null,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      publicId: null == publicId
          ? _value.publicId
          : publicId // ignore: cast_nullable_to_non_nullable
              as String,
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
      sourceId: null == sourceId
          ? _value.sourceId
          : sourceId // ignore: cast_nullable_to_non_nullable
              as String,
      lang: freezed == lang
          ? _value.lang
          : lang // ignore: cast_nullable_to_non_nullable
              as String?,
      contentData: null == contentData
          ? _value.contentData
          : contentData // ignore: cast_nullable_to_non_nullable
              as FeedContentData,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FeedItemImplCopyWith<$Res>
    implements $FeedItemCopyWith<$Res> {
  factory _$$FeedItemImplCopyWith(
          _$FeedItemImpl value, $Res Function(_$FeedItemImpl) then) =
      __$$FeedItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String type,
      String publicId,
      String reason,
      String sourceId,
      String? lang,
      FeedContentData contentData});
}

/// @nodoc
class __$$FeedItemImplCopyWithImpl<$Res>
    extends _$FeedItemCopyWithImpl<$Res, _$FeedItemImpl>
    implements _$$FeedItemImplCopyWith<$Res> {
  __$$FeedItemImplCopyWithImpl(
      _$FeedItemImpl _value, $Res Function(_$FeedItemImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? publicId = null,
    Object? reason = null,
    Object? sourceId = null,
    Object? lang = freezed,
    Object? contentData = null,
  }) {
    return _then(_$FeedItemImpl(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      publicId: null == publicId
          ? _value.publicId
          : publicId // ignore: cast_nullable_to_non_nullable
              as String,
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
      sourceId: null == sourceId
          ? _value.sourceId
          : sourceId // ignore: cast_nullable_to_non_nullable
              as String,
      lang: freezed == lang
          ? _value.lang
          : lang // ignore: cast_nullable_to_non_nullable
              as String?,
      contentData: null == contentData
          ? _value.contentData
          : contentData // ignore: cast_nullable_to_non_nullable
              as FeedContentData,
    ));
  }
}

/// @nodoc

class _$FeedItemImpl implements _FeedItem {
  const _$FeedItemImpl(
      {required this.type,
      required this.publicId,
      this.reason = '',
      this.sourceId = '',
      this.lang,
      required this.contentData});

  @override
  final String type;
  @override
  final String publicId;
  @override
  @JsonKey()
  final String reason;
  @override
  @JsonKey()
  final String sourceId;
  @override
  final String? lang;
  @override
  final FeedContentData contentData;

  @override
  String toString() {
    return 'FeedItem(type: $type, publicId: $publicId, reason: $reason, sourceId: $sourceId, lang: $lang, contentData: $contentData)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeedItemImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.publicId, publicId) ||
                other.publicId == publicId) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.sourceId, sourceId) ||
                other.sourceId == sourceId) &&
            (identical(other.lang, lang) || other.lang == lang) &&
            (identical(other.contentData, contentData) ||
                other.contentData == contentData));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, type, publicId, reason, sourceId, lang, contentData);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FeedItemImplCopyWith<_$FeedItemImpl> get copyWith =>
      __$$FeedItemImplCopyWithImpl<_$FeedItemImpl>(this, _$identity);
}

abstract class _FeedItem implements FeedItem {
  const factory _FeedItem(
      {required final String type,
      required final String publicId,
      final String reason,
      final String sourceId,
      final String? lang,
      required final FeedContentData contentData}) = _$FeedItemImpl;

  @override
  String get type;
  @override
  String get publicId;
  @override
  String get reason;
  @override
  String get sourceId;
  @override
  String? get lang;
  @override
  FeedContentData get contentData;
  @override
  @JsonKey(ignore: true)
  _$$FeedItemImplCopyWith<_$FeedItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
