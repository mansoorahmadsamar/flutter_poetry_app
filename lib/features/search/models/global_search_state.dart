import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_poetry_app/core/network/dto/api_response.dart';
import 'package:flutter_poetry_app/features/search/models/search_models.dart';

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

/// Main state for global search screen
@freezed
class GlobalSearchState with _$GlobalSearchState {
  const factory GlobalSearchState({
    @Default(SearchMode.idle) SearchMode mode,
    @Default('') String currentQuery,
    String? selectedFilter, // Poet filter (publicId)
    @Default('relevance') String sortBy, // relevance, likes, shares, bookmarks, trending

    // Autocomplete data
    AutocompleteResponse? autocompleteResults,
    @Default(false) bool isLoadingAutocomplete,

    // Search results data
    UnifiedSearchResponse? unifiedResults,  // New unified search results
    PaginatedResponse<CoupletSearchResult>? coupletResults,  // Legacy - will be deprecated
    @Default(false) bool isLoadingResults,

    // Discovery data
    @Default([]) List<String> recentSearches,
    TrendingSearchesResponse? trendingSearches,
    RecommendationResponse? recommendations,
    RelatedSearchesResponse? relatedSearches,

    // Error state
    String? errorMessage,
  }) = _GlobalSearchState;
}
