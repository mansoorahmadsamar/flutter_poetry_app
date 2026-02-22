import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/models/poem_model.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/models/poet_model.dart';

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
    String? description,
    String? iconUrl,
    @Default(0) int poemCount,
    @Default(0) int displayOrder,
    @Default(true) bool isActive,
    String? parentCategoryPublicId,
    String? parentCategoryName,
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
    String? coupletType,  // Made nullable - unified search doesn't return this
    String? coupletTypeName,  // Made nullable - API doesn't always include this
    required List<VerseModel> verses,
    PoemSummary? poem,  // Made nullable - API doesn't always include this
    PoetSummary? poet,  // Made nullable - API doesn't always include this
    @Default(0) int likeCount,
    @Default(0) int shareCount,
    @Default(0) int bookmarkCount,
    @Default(0.0) double engagementScore,
    bool? isLiked,  // Made nullable - API returns null when not authenticated
    bool? isBookmarked,  // Made nullable - API returns null when not authenticated
    DateTime? createdAt,  // Added from API response
  }) = _CoupletSearchResult;

  factory CoupletSearchResult.fromJson(Map<String, dynamic> json) =>
      _$CoupletSearchResultFromJson(json);
}

/// Verse search result from unified search API
/// This has a different structure than CoupletSearchResult
@freezed
class VerseSearchResult with _$VerseSearchResult {
  const factory VerseSearchResult({
    required VerseModel verse,
    required String poemPublicId,
    required String poemTitle,
    required String poetryType,
    String? poetryTypeName,
    required String poetPublicId,
    required String poetName,
    String? poetProfileImageUrl,
  }) = _VerseSearchResult;

  factory VerseSearchResult.fromJson(Map<String, dynamic> json) =>
      _$VerseSearchResultFromJson(json);
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
    String? message,  // Changed from 'algorithm' to match API response
    @Default(false) bool isPersonalized,  // Added from API response
    @Default(0) int count,  // Added from API response
  }) = _RecommendationResponse;

  factory RecommendationResponse.fromJson(Map<String, dynamic> json) =>
      _$RecommendationResponseFromJson(json);
}

/// JSON converter to handle "NaN" string from API
class NaNDoubleConverter implements JsonConverter<double, Object?> {
  const NaNDoubleConverter();

  @override
  double fromJson(Object? json) {
    if (json == null) return 0.0;
    if (json is num) return json.toDouble();
    if (json is String) {
      if (json == 'NaN' || json.isEmpty) return 0.0;
      return double.tryParse(json) ?? 0.0;
    }
    return 0.0;
  }

  @override
  Object? toJson(double object) => object;
}

/// Individual recommendation item
@freezed
class RecommendationItem with _$RecommendationItem {
  const factory RecommendationItem({
    required String contentType, // POEM, COUPLET, POET
    required String publicId,
    required String title,
    String? poetName,
    String? poetPublicId,  // Added from API response
    String? poetryType,  // Added from API response
    String? categoryName,  // Added from API response
    @Default(0) int likeCount,
    @Default(0) int shareCount,
    @Default(0) int bookmarkCount,
    @Default(0) int viewCount,  // Added from API response
    @NaNDoubleConverter() @Default(0.0) double score,  // Handle "NaN" from API
    String? reason,
  }) = _RecommendationItem;

  factory RecommendationItem.fromJson(Map<String, dynamic> json) =>
      _$RecommendationItemFromJson(json);
}

// ============================================================================
// UNIFIED SEARCH MODELS
// ============================================================================

/// Unified search response from /api/search endpoint
/// Returns all content types (poets, poems, verses, couplets, tags, categories)
/// with pagination metadata for per-type infinite scroll.
@freezed
class UnifiedSearchResponse with _$UnifiedSearchResponse {
  const factory UnifiedSearchResponse({
    // Current page item counts
    @Default(0) int totalResults,
    @Default(0) int poetCount,
    @Default(0) int poemCount,
    @Default(0) int verseCount,
    @Default(0) int coupletCount,
    @Default(0) int tagCount,
    @Default(0) int categoryCount,

    // Item arrays
    @Default([]) List<PoetModel> poets,
    @Default([]) List<PoemModel> poems,
    @Default([]) List<VerseSearchResult> verses,
    @Default([]) List<CoupletSearchResult> couplets,
    @Default([]) List<AutocompleteTag> tags,
    @Default([]) List<AutocompleteCategory> categories,

    // Total counts in DB — for tab labels like "Poems (847)"
    @Default(0) int totalPoems,
    @Default(0) int totalVerses,
    @Default(0) int totalPoets,
    @Default(0) int totalCouplets,
    @Default(0) int totalTags,
    @Default(0) int totalCategories,

    // Per-type "has more" flags — show/hide "Load More"
    @Default(false) bool hasMorePoems,
    @Default(false) bool hasMoreVerses,
    @Default(false) bool hasMorePoets,
    @Default(false) bool hasMoreCouplets,
    @Default(false) bool hasMoreTags,
    @Default(false) bool hasMoreCategories,

    // Pagination echo
    @Default(0) int currentPage,
    @Default(10) int pageSize,
  }) = _UnifiedSearchResponse;

  factory UnifiedSearchResponse.fromJson(Map<String, dynamic> json) =>
      _$UnifiedSearchResponseFromJson(json);
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
