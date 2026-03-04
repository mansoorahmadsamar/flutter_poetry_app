import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_poetry_app/core/network/dto/api_response.dart';
import 'package:flutter_poetry_app/features/search/models/search_models.dart';
import 'package:flutter_poetry_app/features/discover/models/discover_bundle_model.dart';

part 'global_search_state.freezed.dart';

/// Search mode enum
enum SearchMode {
  idle, // Empty search, show discovery content
  typing, // User is typing (debouncing)
  autocompleting, // Showing autocomplete suggestions
  searching, // Executing search
  results, // Showing results
  error, // Error state
}

/// Discover segment enum
enum DiscoverSegment {
  all, // All content types
  poets, // Poets only
  poems, // Poems only
  verses, // Verses/couplets only
  categories, // Categories only
}

/// Couplet sort options
enum CoupletSortOption {
  relevance, // Best match (default)
  trending, // Highest engagement
  likes, // Most liked
  shares, // Most shared
  bookmarks, // Most bookmarked
  recent, // Most recent
}

/// Main state for global search screen
@freezed
class GlobalSearchState with _$GlobalSearchState {
  const factory GlobalSearchState({
    @Default(SearchMode.idle) SearchMode mode,
    @Default('') String currentQuery,
    String? selectedFilter, // Poet filter (publicId)
    @Default('relevance') String sortBy, // relevance, likes, shares, bookmarks, trending
    @Default(DiscoverSegment.all) DiscoverSegment activeSegment,
    @Default(CoupletSortOption.relevance) CoupletSortOption coupletSort,

    // Autocomplete data
    AutocompleteResponse? autocompleteResults,
    @Default(false) bool isLoadingAutocomplete,

    // Search results data
    UnifiedSearchResponse? unifiedResults,
    PaginatedResponse<CoupletSearchResult>? coupletResults,  // Legacy - will be deprecated
    @Default(false) bool isLoadingResults,
    @Default(false) bool isLoadingMore, // Loading next page for a segment

    // Per-segment pagination tracking (next page to fetch)
    @Default({}) Map<DiscoverSegment, int> nextPage,

    // Discovery data
    @Default([]) List<String> recentSearches,
    TrendingSearchesResponse? trendingSearches,
    RecommendationResponse? recommendations,
    RelatedSearchesResponse? relatedSearches,
    DiscoverBundle? discoverBundle, // New: unified discover bundle

    // Error state
    String? errorMessage,
  }) = _GlobalSearchState;
}
