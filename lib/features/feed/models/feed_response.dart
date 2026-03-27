import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'feed_item.dart';

part 'feed_response.freezed.dart';

@Freezed(toJson: false)
class FeedResponse with _$FeedResponse {
  const factory FeedResponse({
    required List<FeedItem> items,
    String? nextCursor,
    @Default(false) bool hasMore,
    @Default(false) bool isPersonalized,
    @Default('') String sessionId,
    @Default(0) int itemCount,
    int? newCount,
  }) = _FeedResponse;

  factory FeedResponse.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    final items = <FeedItem>[];
    for (final raw in rawItems) {
      try {
        items.add(FeedItem.fromJson(raw as Map<String, dynamic>));
      } catch (e, stack) {
        // Skip malformed items — never let one bad item crash the feed.
        debugPrint('FeedResponse: Failed to parse item: $e');
        debugPrint('FeedResponse: Raw item: $raw');
        debugPrint('FeedResponse: Stack: $stack');
      }
    }

    return FeedResponse(
      items: items,
      nextCursor: json['nextCursor'] as String?,
      hasMore: json['hasMore'] as bool? ?? false,
      isPersonalized: json['isPersonalized'] as bool? ?? false,
      sessionId: json['sessionId'] as String? ?? '',
      itemCount: json['itemCount'] as int? ?? 0,
      newCount: json['newCount'] as int?,
    );
  }
}
