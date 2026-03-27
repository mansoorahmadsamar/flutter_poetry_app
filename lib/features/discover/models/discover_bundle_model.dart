import 'package:freezed_annotation/freezed_annotation.dart';
import '../../hashtags/models/hashtag_model.dart';

part 'discover_bundle_model.freezed.dart';
part 'discover_bundle_model.g.dart';

/// Complete discover bundle from /api/discover endpoint
@freezed
class DiscoverBundle with _$DiscoverBundle {
  const factory DiscoverBundle({
    required TrendingSearches trendingSearches,
    required ContentSection editorsPicks,
    required ContentSection recommended,
    required ContentSection featuredPoets,
    required ContentSection categories,
    @Default([]) List<HashtagDto> trendingHashtags,
    required String language,
    @Default(false) bool personalized,
    int? timestamp,
  }) = _DiscoverBundle;

  factory DiscoverBundle.fromJson(Map<String, dynamic> json) =>
      _$DiscoverBundleFromJson(json);
}

/// Trending searches with daily and weekly rankings
@freezed
class TrendingSearches with _$TrendingSearches {
  const factory TrendingSearches({
    @Default([]) List<TrendingQuery> daily,
    @Default([]) List<TrendingQuery> weekly,
  }) = _TrendingSearches;

  factory TrendingSearches.fromJson(Map<String, dynamic> json) =>
      _$TrendingSearchesFromJson(json);
}

/// Individual trending search query
@freezed
class TrendingQuery with _$TrendingQuery {
  const factory TrendingQuery({
    required String query,
    @Default(0) int searchCount,
    @Default(0) int rank,
  }) = _TrendingQuery;

  factory TrendingQuery.fromJson(Map<String, dynamic> json) =>
      _$TrendingQueryFromJson(json);
}

/// Content section with unified ContentCard items
@freezed
class ContentSection with _$ContentSection {
  const factory ContentSection({
    String? sectionTitle,
    String? sectionKey,
    @Default([]) List<ContentCard> items,
    @Default(0) int totalCount,
  }) = _ContentSection;

  factory ContentSection.fromJson(Map<String, dynamic> json) =>
      _$ContentSectionFromJson(json);
}

/// Unified content card format for all content types
@freezed
class ContentCard with _$ContentCard {
  const factory ContentCard({
    required String type, // POET, POEM, VERSE, COUPLET, CATEGORY, TAG
    required String publicId,
    required String primaryText,
    String? secondaryText,
    String? badge,
    String? badgeKey,
    ContentMetrics? metrics,
    @Default('ur') String language,
    @Default('rtl') String direction,
    double? score,
    String? imageUrl, // For poets with profile images
  }) = _ContentCard;

  factory ContentCard.fromJson(Map<String, dynamic> json) =>
      _$ContentCardFromJson(json);
}

/// Engagement metrics for content cards
@freezed
class ContentMetrics with _$ContentMetrics {
  const factory ContentMetrics({
    @Default(0) int likeCount,
    @Default(0) int shareCount,
    @Default(0) int bookmarkCount,
    @Default(0) int viewCount,
  }) = _ContentMetrics;

  factory ContentMetrics.fromJson(Map<String, dynamic> json) =>
      _$ContentMetricsFromJson(json);
}

/// Extension for content type helpers
extension ContentCardExtension on ContentCard {
  bool get isRtl => direction == 'rtl';

  bool get isPoet => type == 'POET';
  bool get isPoem => type == 'POEM';
  bool get isVerse => type == 'VERSE';
  bool get isCouplet => type == 'COUPLET';
  bool get isCategory => type == 'CATEGORY';
  bool get isTag => type == 'TAG';

  /// Get icon for content type
  String get typeIcon {
    switch (type) {
      case 'POET':
        return '👤';
      case 'POEM':
        return '📜';
      case 'VERSE':
      case 'COUPLET':
        return '✨';
      case 'CATEGORY':
        return '📁';
      case 'TAG':
        return '🏷️';
      default:
        return '📄';
    }
  }
}
