import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../discover/models/discover_bundle_model.dart';
import 'feed_content_data.dart';
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

  /// Builds a guest feed from the anonymous `/api/guest/discover` bundle.
  /// The bundle returns flat `ContentCard`s (POEM / POET / COUPLET); we
  /// interleave them — couplets first (the strongest hook on the feed),
  /// then poems, then poet spotlights — and wrap each as a [FeedItem] so
  /// the existing feed widgets render it unchanged.
  ///
  /// Guest discover is non-paginated and cached server-side for 15 min, so
  /// `hasMore = false` and `nextCursor = null`. `sessionId = 'guest'` is a
  /// sentinel the event tracker uses to skip writes.
  factory FeedResponse.fromGuestBundle(DiscoverBundle bundle) {
    final items = <FeedItem>[];

    // Couplets — strongest engagement format, lead with them.
    for (final card in bundle.recommended.items) {
      items.add(_coupletItemFromCard(card));
    }
    // Then featured poems.
    for (final card in bundle.editorsPicks.items) {
      items.add(_poemItemFromCard(card));
    }
    // Then featured / trending poet spotlights.
    for (final card in bundle.featuredPoets.items) {
      items.add(_poetSpotlightItemFromCard(card));
    }

    return FeedResponse(
      items: items,
      nextCursor: null,
      hasMore: false,
      isPersonalized: false,
      sessionId: 'guest',
      itemCount: items.length,
    );
  }
}

FeedItem _poemItemFromCard(ContentCard card) {
  return FeedItem(
    type: 'POEM',
    publicId: card.publicId,
    reason: 'GUEST_FEATURED',
    sourceId: 'guest-discover',
    lang: card.language,
    contentData: PoemContentData(
      title: card.primaryText,
      excerpt: card.primaryText,
      poetName: card.secondaryText,
      poetProfileImageUrl: card.imageUrl,
      poetryType: card.badgeKey,
      likeCount: card.metrics?.likeCount ?? 0,
      viewCount: card.metrics?.viewCount ?? 0,
    ),
  );
}

FeedItem _coupletItemFromCard(ContentCard card) {
  return FeedItem(
    type: 'COUPLET',
    publicId: card.publicId,
    reason: 'GUEST_TRENDING',
    sourceId: 'guest-discover',
    lang: card.language,
    contentData: CoupletContentData(
      versesTextArabic: card.primaryText,
      poetName: card.secondaryText,
      poetProfileImageUrl: card.imageUrl,
      likeCount: card.metrics?.likeCount ?? 0,
      shareCount: card.metrics?.shareCount ?? 0,
    ),
  );
}

FeedItem _poetSpotlightItemFromCard(ContentCard card) {
  return FeedItem(
    type: 'POET_SPOTLIGHT',
    publicId: card.publicId,
    reason: 'GUEST_FEATURED_POET',
    sourceId: 'guest-discover',
    lang: card.language,
    contentData: PoetSpotlightContentData(
      poetPublicId: card.publicId,
      poetName: card.primaryText,
      bio: card.secondaryText,
      profileImageUrl: card.imageUrl,
      poemCount: card.metrics?.viewCount ?? 0,
    ),
  );
}
