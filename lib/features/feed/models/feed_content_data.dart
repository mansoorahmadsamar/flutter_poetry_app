import 'package:freezed_annotation/freezed_annotation.dart';

part 'feed_content_data.freezed.dart';
part 'feed_content_data.g.dart';

/// Sealed class for type-safe feed content data.
/// Each feed item type has its own typed model with compile-time safety.
sealed class FeedContentData {
  factory FeedContentData.fromJson(String type, Map<String, dynamic> json) {
    return switch (type) {
      'COUPLET' => CoupletContentData.fromJson(json),
      'POEM' => PoemContentData.fromJson(json),
      'POET_SPOTLIGHT' => PoetSpotlightContentData.fromJson(json),
      'POET_IMAGE' => PoetImageContentData.fromJson(json),
      _ => UnknownContentData(rawData: json),
    };
  }
}

@freezed
class CoupletContentData with _$CoupletContentData implements FeedContentData {
  const factory CoupletContentData({
    String? versesTextArabic,
    String? versesTextRoman,
    String? poetPublicId,
    String? poetProfileImageUrl,
    int? poetBirthYear,
    int? poetDeathYear,
    String? poetName,
    String? poemPublicId,
    @Default(0) int likeCount,
    @Default(0) int shareCount,
    @Default(0) int bookmarkCount,
    @Default([]) List<String> tagSlugs,
    // Reactions system (Section 19)
    Map<String, dynamic>? reactions,
  }) = _CoupletContentData;

  factory CoupletContentData.fromJson(Map<String, dynamic> json) =>
      _$CoupletContentDataFromJson(json);
}

@freezed
class PoemContentData with _$PoemContentData implements FeedContentData {
  const factory PoemContentData({
    String? title,
    String? excerpt,
    String? poetPublicId,
    String? poetProfileImageUrl,
    int? poetBirthYear,
    int? poetDeathYear,
    String? poetName,
    String? poetryType,
    @Default(0) int likeCount,
    @Default(0) int viewCount,
    String? thumbnailUrl,
    // Reactions system (Section 19)
    Map<String, dynamic>? reactions,
  }) = _PoemContentData;

  factory PoemContentData.fromJson(Map<String, dynamic> json) =>
      _$PoemContentDataFromJson(json);
}

@freezed
class FeaturedCouplet with _$FeaturedCouplet {
  const factory FeaturedCouplet({
    String? coupletPublicId,
    @Default([]) List<String> verses,
    @Default(0) int likeCount,
    @Default('ARABIC') String script,
  }) = _FeaturedCouplet;

  factory FeaturedCouplet.fromJson(Map<String, dynamic> json) =>
      _$FeaturedCoupletFromJson(json);
}

@freezed
class PoetSpotlightContentData with _$PoetSpotlightContentData
    implements FeedContentData {
  const factory PoetSpotlightContentData({
    String? poetName,
    String? bio,
    required String poetPublicId,
    String? profileImageUrl,
    int? birthYear,
    int? deathYear,
    @Default(0) int poemCount,
    @Default(0) int followerCount,
    @Default(0) int viewCount,
    FeaturedCouplet? featuredCouplet,
  }) = _PoetSpotlightContentData;

  factory PoetSpotlightContentData.fromJson(Map<String, dynamic> json) =>
      _$PoetSpotlightContentDataFromJson(json);
}

@freezed
class PoetImageContentData with _$PoetImageContentData
    implements FeedContentData {
  const factory PoetImageContentData({
    String? imageUrl,
    String? thumbnailUrl,
    String? contentText,
    @Default(0) int likeCount,
    @Default(0) int shareCount,
    @Default(0) int bookmarkCount,
    String? poetPublicId,
    String? poetName,
    String? poetProfileImageUrl,
    int? poetBirthYear,
    int? poetDeathYear,
    // Reactions system (Section 19)
    Map<String, dynamic>? reactions,
  }) = _PoetImageContentData;

  factory PoetImageContentData.fromJson(Map<String, dynamic> json) =>
      _$PoetImageContentDataFromJson(json);
}

/// Fallback for unknown/future feed item types.
/// Renders as SizedBox.shrink() in the UI — never crashes the app.
class UnknownContentData implements FeedContentData {
  final Map<String, dynamic> rawData;
  UnknownContentData({required this.rawData});
}
