import 'package:freezed_annotation/freezed_annotation.dart';
import 'feed_content_data.dart';
import 'social_context.dart';

part 'feed_item.freezed.dart';

@Freezed(toJson: false)
class FeedItem with _$FeedItem {
  const factory FeedItem({
    required String type,
    required String publicId,
    @Default('') String reason,
    @Default('') String sourceId,
    String? lang,
    required FeedContentData contentData,
    SocialContext? socialContext,
    // RESERVED — not currently sent by backend. Always null for now.
    String? displayMode,
    String? primaryAction,
    bool? autoExpandFirstVerse,
    int? previewDurationMs,
  }) = _FeedItem;

  factory FeedItem.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    final rawContentData =
        Map<String, dynamic>.from(json['contentData'] as Map? ?? {});

    return FeedItem(
      type: type,
      publicId: json['publicId'] as String,
      reason: json['reason'] as String? ?? '',
      sourceId: json['sourceId'] as String? ?? '',
      lang: json['lang'] as String?,
      contentData: FeedContentData.fromJson(type, rawContentData),
      socialContext: json['socialContext'] != null
          ? SocialContext.fromJson(
              json['socialContext'] as Map<String, dynamic>)
          : null,
      // RESERVED fields — parsed defensively but always null for now
      displayMode: json['displayMode'] as String?,
      primaryAction: json['primaryAction'] as String?,
      autoExpandFirstVerse: json['autoExpandFirstVerse'] as bool?,
      previewDurationMs: json['previewDurationMs'] as int?,
    );
  }
}
