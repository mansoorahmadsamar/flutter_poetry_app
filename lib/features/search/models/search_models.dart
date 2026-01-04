import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/models/poem_model.dart';

part 'search_models.freezed.dart';
part 'search_models.g.dart';

// ============================================================================
// AUTOCOMPLETE MODELS
// ============================================================================

/// Response from autocomplete API containing all suggestion types
@freezed
class AutocompleteResponse with _$AutocompleteResponse {
  const factory AutocompleteResponse({
    @Default([]) List<AutocompletePoet> poets,
    @Default([]) List<AutocompletePoem> poems,
    @Default([]) List<AutocompleteTag> tags,
    @Default([]) List<AutocompleteCategory> categories,
    @Default(0) int totalCount,
  }) = _AutocompleteResponse;

  factory AutocompleteResponse.fromJson(Map<String, dynamic> json) =>
      _$AutocompleteResponseFromJson(json);
}

/// Poet suggestion from autocomplete
@freezed
class AutocompletePoet with _$AutocompletePoet {
  const factory AutocompletePoet({
    required String publicId,
    required String name,
    String? profileImageUrl,
    String? era,
    @Default(0.0) double score,
  }) = _AutocompletePoet;

  factory AutocompletePoet.fromJson(Map<String, dynamic> json) =>
      _$AutocompletePoetFromJson(json);
}

/// Poem suggestion from autocomplete
@freezed
class AutocompletePoem with _$AutocompletePoem {
  const factory AutocompletePoem({
    required String publicId,
    required String title,
    required String poetName,
    required String poetPublicId,
    required String poetryType,
    @Default(0.0) double score,
  }) = _AutocompletePoem;

  factory AutocompletePoem.fromJson(Map<String, dynamic> json) =>
      _$AutocompletePoemFromJson(json);
}

/// Tag suggestion from autocomplete
@freezed
class AutocompleteTag with _$AutocompleteTag {
  const factory AutocompleteTag({
    required String publicId,
    required String name,
    required String slug,
    required String tagType,
    @Default(0.0) double score,
  }) = _AutocompleteTag;

  factory AutocompleteTag.fromJson(Map<String, dynamic> json) =>
      _$AutocompleteTagFromJson(json);
}

/// Category suggestion from autocomplete
@freezed
class AutocompleteCategory with _$AutocompleteCategory {
  const factory AutocompleteCategory({
    required String publicId,
    required String name,
    required String slug,
    @Default(0) int poemCount,
    @Default(0.0) double score,
  }) = _AutocompleteCategory;

  factory AutocompleteCategory.fromJson(Map<String, dynamic> json) =>
      _$AutocompleteCategoryFromJson(json);
}

// ============================================================================
// COUPLET SEARCH MODELS
// ============================================================================

/// Search result for a single couplet
@freezed
class CoupletSearchResult with _$CoupletSearchResult {
  const factory CoupletSearchResult({
    required String publicId,
    required int coupletNumber,
    required String coupletType,
    required List<VerseModel> verses,
    required PoemSummary poem,
    required PoetSummary poet,
    @Default(0) int likeCount,
    @Default(0) int shareCount,
    @Default(0) int bookmarkCount,
    @Default(0.0) double engagementScore,
    @Default(false) bool isLiked,
    @Default(false) bool isBookmarked,
  }) = _CoupletSearchResult;

  factory CoupletSearchResult.fromJson(Map<String, dynamic> json) =>
      _$CoupletSearchResultFromJson(json);
}

/// Summary information about a poem
@freezed
class PoemSummary with _$PoemSummary {
  const factory PoemSummary({
    required String publicId,
    required String title,
    required String poetName,
  }) = _PoemSummary;

  factory PoemSummary.fromJson(Map<String, dynamic> json) =>
      _$PoemSummaryFromJson(json);
}

/// Summary information about a poet
@freezed
class PoetSummary with _$PoetSummary {
  const factory PoetSummary({
    required String publicId,
    required String name,
    String? profileImageUrl,
  }) = _PoetSummary;

  factory PoetSummary.fromJson(Map<String, dynamic> json) =>
      _$PoetSummaryFromJson(json);
}

// ============================================================================
// RECOMMENDATION MODELS
// ============================================================================

/// Response from recommendations API
@freezed
class RecommendationResponse with _$RecommendationResponse {
  const factory RecommendationResponse({
    required String type, // PERSONALIZED, SIMILAR, TRENDING, HYBRID
    @Default([]) List<RecommendationItem> items,
    @Default(0) int totalCount,
    required String algorithm,
  }) = _RecommendationResponse;

  factory RecommendationResponse.fromJson(Map<String, dynamic> json) =>
      _$RecommendationResponseFromJson(json);
}

/// Individual recommendation item
@freezed
class RecommendationItem with _$RecommendationItem {
  const factory RecommendationItem({
    required String contentType, // POEM, COUPLET, POET
    required String publicId,
    required String title,
    String? poetName,
    @Default(0) int likeCount,
    @Default(0) int shareCount,
    @Default(0) int bookmarkCount,
    @Default(0.0) double score,
    String? reason,
  }) = _RecommendationItem;

  factory RecommendationItem.fromJson(Map<String, dynamic> json) =>
      _$RecommendationItemFromJson(json);
}

// ============================================================================
// TRENDING & RELATED SEARCHES MODELS
// ============================================================================

/// Single trending search query
@freezed
class TrendingSearch with _$TrendingSearch {
  const factory TrendingSearch({
    required String query,
    required String normalizedQuery,
    @Default(0) int count,
    @Default(0.0) double score,
  }) = _TrendingSearch;

  factory TrendingSearch.fromJson(Map<String, dynamic> json) =>
      _$TrendingSearchFromJson(json);
}

/// Response from related searches API
@freezed
class RelatedSearchesResponse with _$RelatedSearchesResponse {
  const factory RelatedSearchesResponse({
    required String query,
    @Default([]) List<TrendingSearch> relatedSearches,
    @Default(0) int totalCount,
    required String timeWindow,
  }) = _RelatedSearchesResponse;

  factory RelatedSearchesResponse.fromJson(Map<String, dynamic> json) =>
      _$RelatedSearchesResponseFromJson(json);
}

/// Response from trending searches API
@freezed
class TrendingSearchesResponse with _$TrendingSearchesResponse {
  const factory TrendingSearchesResponse({
    @Default([]) List<TrendingSearch> searches,
    @Default(0) int totalCount,
    required String timeframe,
    required String period,
  }) = _TrendingSearchesResponse;

  factory TrendingSearchesResponse.fromJson(Map<String, dynamic> json) =>
      _$TrendingSearchesResponseFromJson(json);
}
