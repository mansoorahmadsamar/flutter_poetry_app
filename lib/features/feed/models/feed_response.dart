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
  }) = _FeedResponse;

  factory FeedResponse.fromJson(Map<String, dynamic> json) {
    return FeedResponse(
      items: (json['items'] as List<dynamic>?)
              ?.map((i) => FeedItem.fromJson(i as Map<String, dynamic>))
              .toList() ??
          [],
      nextCursor: json['nextCursor'] as String?,
      hasMore: json['hasMore'] as bool? ?? false,
      isPersonalized: json['isPersonalized'] as bool? ?? false,
      sessionId: json['sessionId'] as String? ?? '',
      itemCount: json['itemCount'] as int? ?? 0,
    );
  }
}
