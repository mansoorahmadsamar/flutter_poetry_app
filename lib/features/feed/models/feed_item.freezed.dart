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
  SocialContext? get socialContext =>
      throw _privateConstructorUsedError; // RESERVED — not currently sent by backend. Always null for now.
  String? get displayMode => throw _privateConstructorUsedError;
  String? get primaryAction => throw _privateConstructorUsedError;
  bool? get autoExpandFirstVerse => throw _privateConstructorUsedError;
  int? get previewDurationMs => throw _privateConstructorUsedError;

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
      FeedContentData contentData,
      SocialContext? socialContext,
      String? displayMode,
      String? primaryAction,
      bool? autoExpandFirstVerse,
      int? previewDurationMs});

  $SocialContextCopyWith<$Res>? get socialContext;
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
    Object? socialContext = freezed,
    Object? displayMode = freezed,
    Object? primaryAction = freezed,
    Object? autoExpandFirstVerse = freezed,
    Object? previewDurationMs = freezed,
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
      socialContext: freezed == socialContext
          ? _value.socialContext
          : socialContext // ignore: cast_nullable_to_non_nullable
              as SocialContext?,
      displayMode: freezed == displayMode
          ? _value.displayMode
          : displayMode // ignore: cast_nullable_to_non_nullable
              as String?,
      primaryAction: freezed == primaryAction
          ? _value.primaryAction
          : primaryAction // ignore: cast_nullable_to_non_nullable
              as String?,
      autoExpandFirstVerse: freezed == autoExpandFirstVerse
          ? _value.autoExpandFirstVerse
          : autoExpandFirstVerse // ignore: cast_nullable_to_non_nullable
              as bool?,
      previewDurationMs: freezed == previewDurationMs
          ? _value.previewDurationMs
          : previewDurationMs // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $SocialContextCopyWith<$Res>? get socialContext {
    if (_value.socialContext == null) {
      return null;
    }

    return $SocialContextCopyWith<$Res>(_value.socialContext!, (value) {
      return _then(_value.copyWith(socialContext: value) as $Val);
    });
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
      FeedContentData contentData,
      SocialContext? socialContext,
      String? displayMode,
      String? primaryAction,
      bool? autoExpandFirstVerse,
      int? previewDurationMs});

  @override
  $SocialContextCopyWith<$Res>? get socialContext;
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
    Object? socialContext = freezed,
    Object? displayMode = freezed,
    Object? primaryAction = freezed,
    Object? autoExpandFirstVerse = freezed,
    Object? previewDurationMs = freezed,
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
      socialContext: freezed == socialContext
          ? _value.socialContext
          : socialContext // ignore: cast_nullable_to_non_nullable
              as SocialContext?,
      displayMode: freezed == displayMode
          ? _value.displayMode
          : displayMode // ignore: cast_nullable_to_non_nullable
              as String?,
      primaryAction: freezed == primaryAction
          ? _value.primaryAction
          : primaryAction // ignore: cast_nullable_to_non_nullable
              as String?,
      autoExpandFirstVerse: freezed == autoExpandFirstVerse
          ? _value.autoExpandFirstVerse
          : autoExpandFirstVerse // ignore: cast_nullable_to_non_nullable
              as bool?,
      previewDurationMs: freezed == previewDurationMs
          ? _value.previewDurationMs
          : previewDurationMs // ignore: cast_nullable_to_non_nullable
              as int?,
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
      required this.contentData,
      this.socialContext,
      this.displayMode,
      this.primaryAction,
      this.autoExpandFirstVerse,
      this.previewDurationMs});

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
  final SocialContext? socialContext;
// RESERVED — not currently sent by backend. Always null for now.
  @override
  final String? displayMode;
  @override
  final String? primaryAction;
  @override
  final bool? autoExpandFirstVerse;
  @override
  final int? previewDurationMs;

  @override
  String toString() {
    return 'FeedItem(type: $type, publicId: $publicId, reason: $reason, sourceId: $sourceId, lang: $lang, contentData: $contentData, socialContext: $socialContext, displayMode: $displayMode, primaryAction: $primaryAction, autoExpandFirstVerse: $autoExpandFirstVerse, previewDurationMs: $previewDurationMs)';
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
                other.contentData == contentData) &&
            (identical(other.socialContext, socialContext) ||
                other.socialContext == socialContext) &&
            (identical(other.displayMode, displayMode) ||
                other.displayMode == displayMode) &&
            (identical(other.primaryAction, primaryAction) ||
                other.primaryAction == primaryAction) &&
            (identical(other.autoExpandFirstVerse, autoExpandFirstVerse) ||
                other.autoExpandFirstVerse == autoExpandFirstVerse) &&
            (identical(other.previewDurationMs, previewDurationMs) ||
                other.previewDurationMs == previewDurationMs));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      type,
      publicId,
      reason,
      sourceId,
      lang,
      contentData,
      socialContext,
      displayMode,
      primaryAction,
      autoExpandFirstVerse,
      previewDurationMs);

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
      required final FeedContentData contentData,
      final SocialContext? socialContext,
      final String? displayMode,
      final String? primaryAction,
      final bool? autoExpandFirstVerse,
      final int? previewDurationMs}) = _$FeedItemImpl;

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
  SocialContext? get socialContext;
  @override // RESERVED — not currently sent by backend. Always null for now.
  String? get displayMode;
  @override
  String? get primaryAction;
  @override
  bool? get autoExpandFirstVerse;
  @override
  int? get previewDurationMs;
  @override
  @JsonKey(ignore: true)
  _$$FeedItemImplCopyWith<_$FeedItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
