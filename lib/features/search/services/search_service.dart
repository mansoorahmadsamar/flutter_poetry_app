import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:flutter_poetry_app/core/auth/auth_provider.dart';
import 'package:flutter_poetry_app/core/network/dto/api_response.dart';
import 'package:flutter_poetry_app/core/network/guest_service.dart';
import 'package:flutter_poetry_app/features/search/models/search_models.dart';

/// Service for all global search operations
/// Implements 5 backend API endpoints:
/// 1. Couplet search
/// 2. Autocomplete suggestions
/// 3. Recommendations
/// 4. Related searches
/// 5. Trending searches
class SearchService {
  final Dio _dio;
  final Ref _ref;
  final Logger _logger = Logger();
  static const String _baseEndpoint = '/api/search';

  SearchService(this._dio, this._ref);

  bool get _isGuest => _ref.read(authProvider).isGuest;
  GuestService get _guest => _ref.read(guestServiceProvider);

  // ============================================================================
  // COUPLET SEARCH
  // ============================================================================

  /// Search for couplets with filters and sorting
  ///
  /// Endpoint: GET /api/search/couplets
  ///
  /// Parameters:
  /// - [query]: Search query (required)
  /// - [poetId]: Filter by poet publicId (optional)
  /// - [sortBy]: Sort option (relevance, likes, shares, bookmarks, trending)
  /// - [lang]: Language code (ur, en, hi) - defaults to 'ur'
  /// - [page]: Page number for pagination (default: 0)
  /// - [size]: Page size (default: 20)
  ///
  /// Returns: Paginated list of couplet search results
  Future<PaginatedResponse<CoupletSearchResult>> searchCouplets({
    required String query,
    String? poetId,
    String sortBy = 'relevance',
    String lang = 'ur',
    int page = 0,
    int size = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'q': query,
        'sort': sortBy,
        'lang': lang,
        'page': page,
        'size': size,
      };

      if (poetId != null && poetId.isNotEmpty) {
        queryParams['poet'] = poetId;
      }

      _logger.i('🔍 Searching couplets: "$query" (sort: $sortBy, lang: $lang)');

      final response = await _dio.get(
        '$_baseEndpoint/couplets',
        queryParameters: queryParams,
      );

      _logger.d('📦 Raw API response: ${response.data}');

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        try {
          _logger.d('📋 Parsing paginated response...');
          final paginatedResponse = PaginatedResponse<CoupletSearchResult>.fromJson(
            apiResponse.data!,
            (json) => CoupletSearchResult.fromJson(json as Map<String, dynamic>? ?? {}),
          );

          _logger.i('✅ Couplet search: "${query}" - ${paginatedResponse.totalElements} results');
          return paginatedResponse;
        } catch (parseError, stackTrace) {
          _logger.e('❌ Error parsing couplet response: $parseError');
          _logger.e('Stack: $stackTrace');
          _logger.e('Data keys: ${apiResponse.data!.keys.toList()}');
          rethrow;
        }
      } else {
        throw Exception(apiResponse.message ?? 'Search failed');
      }
    } on DioException catch (e) {
      _logger.e('❌ Error searching couplets: ${e.message}');
      rethrow;
    } catch (e) {
      _logger.e('❌ Unexpected error searching couplets: $e');
      throw Exception('Failed to search couplets: ${e.toString()}');
    }
  }

  // ============================================================================
  // UNIFIED SEARCH (All Content Types)
  // ============================================================================

  /// Unified search across all content types
  ///
  /// Endpoint: GET /api/search
  ///
  /// This is the MAIN search endpoint that should be used when users hit enter
  /// to search. It returns poets, poems, verses, couplets, tags, and categories
  /// with per-type pagination metadata.
  ///
  /// Parameters:
  /// - [query]: Search query (required)
  /// - [type]: Content type filter ('all', 'poems_only', 'verses_only', etc.)
  /// - [lang]: Language code (ur, en, hi) - defaults to 'ur'
  /// - [page]: Page number (0-based) - defaults to 0
  /// - [size]: Page size - defaults to 10
  ///
  /// Returns: Unified search results with all content types and pagination flags
  Future<UnifiedSearchResponse> searchUnified({
    required String query,
    String type = 'all',
    String lang = 'ur',
    int page = 0,
    int size = 10,
  }) async {
    if (_isGuest) {
      // Guests don't get couplet / verse / tag / category search — those
      // surfaces aren't in the guest API. We fan out to the available
      // /api/guest/poems/search + /api/guest/poets/search and synthesize a
      // UnifiedSearchResponse so the existing search UI renders unchanged.
      // The poem/poet sections work; couplets/verses/tags/categories are
      // empty and the screen surfaces "Sign in to search couplets" inline.
      final poems = type == 'poets_only'
          ? null
          : await _guest.searchPoems(q: query, page: page, size: size, lang: lang);
      final poets = type == 'poems_only'
          ? null
          : await _guest.searchPoets(q: query, page: page, size: size, lang: lang);

      return UnifiedSearchResponse(
        totalResults: (poems?.items.length ?? 0) + (poets?.items.length ?? 0),
        poemCount: poems?.items.length ?? 0,
        poetCount: poets?.items.length ?? 0,
        poems: poems?.items ?? const [],
        poets: poets?.items ?? const [],
        totalPoems: poems?.totalElements ?? 0,
        totalPoets: poets?.totalElements ?? 0,
        hasMorePoems: poems != null && !poems.isLast,
        hasMorePoets: poets != null && !poets.isLast,
        currentPage: page,
        pageSize: size,
      );
    }
    try {
      _logger.i('🔍 Unified search: "$query" (type: $type, lang: $lang, page: $page, size: $size)');

      final response = await _dio.get(
        _baseEndpoint,
        queryParameters: {
          'q': query,
          'type': type,
          'lang': lang,
          'page': page,
          'size': size,
        },
      );

      _logger.d('📦 Raw unified search response: ${response.data}');

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        try {
          final unifiedResponse = UnifiedSearchResponse.fromJson(apiResponse.data!);
          _logger.i('✅ Unified search: "$query" - ${unifiedResponse.totalResults} total results');
          _logger.i('   Poets: ${unifiedResponse.poetCount}, Poems: ${unifiedResponse.poemCount}, Couplets: ${unifiedResponse.coupletCount}');
          return unifiedResponse;
        } catch (parseError, stackTrace) {
          _logger.e('❌ Error parsing unified search response: $parseError');
          _logger.e('Stack: $stackTrace');
          _logger.e('Data keys: ${apiResponse.data!.keys.toList()}');
          rethrow;
        }
      } else {
        throw Exception(apiResponse.message ?? 'Unified search failed');
      }
    } on DioException catch (e) {
      _logger.e('❌ Error in unified search: ${e.message}');
      rethrow;
    } catch (e) {
      _logger.e('❌ Unexpected error in unified search: $e');
      throw Exception('Failed to perform unified search: ${e.toString()}');
    }
  }

  /// Load more items for a specific content type (pagination).
  ///
  /// Use after initial `searchUnified(type: 'all')` to fetch page N+1
  /// of a single type (e.g. poems_only, verses_only).
  ///
  /// Parameters:
  /// - [query]: Same search query
  /// - [type]: Single-type filter ('poems_only', 'verses_only', 'poets_only', 'couplets_only', etc.)
  /// - [page]: Next page number (1-based after initial page 0)
  /// - [lang]: Language code
  /// - [size]: Page size
  Future<UnifiedSearchResponse> loadMore({
    required String query,
    required String type,
    required int page,
    String lang = 'ur',
    int size = 10,
  }) async {
    return searchUnified(
      query: query,
      type: type,
      lang: lang,
      page: page,
      size: size,
    );
  }

  // ============================================================================
  // AUTOCOMPLETE
  // ============================================================================

  /// Get autocomplete suggestions (poets, poems, tags, categories)
  ///
  /// Endpoint: GET /api/search/autocomplete
  ///
  /// Parameters:
  /// - [query]: Search query (minimum 2 characters)
  /// - [lang]: Language code (default: 'ur')
  /// - [cancelToken]: Optional CancelToken to cancel the request
  ///
  /// Returns: Grouped suggestions by type
  /// - Poets: max 3
  /// - Poems: max 5
  /// - Tags: max 3
  /// - Categories: max 3
  ///
  /// Target latency: <200ms
  Future<AutocompleteResponse> getAutocomplete({
    required String query,
    String lang = 'ur',
    CancelToken? cancelToken,
  }) async {
    // No guest autocomplete endpoint — return empty so guests don't hit the
    // authed route (401) while typing. Guest search still works via
    // searchUnified -> /api/guest/poems|poets/search.
    if (_isGuest || query.trim().length < 2) {
      return const AutocompleteResponse(
        poets: [],
        poems: [],
        tags: [],
        categories: [],
        totalCount: 0,
      );
    }

    try {
      _logger.d('🔤 Fetching autocomplete for: "$query"');

      final response = await _dio.get(
        '$_baseEndpoint/autocomplete',
        queryParameters: {
          'q': query.trim(),
          'lang': lang,
        },
        cancelToken: cancelToken,
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        final autocompleteResponse = AutocompleteResponse.fromJson(apiResponse.data!);
        _logger.i('✅ Autocomplete: "$query" - ${autocompleteResponse.totalCount} suggestions');
        return autocompleteResponse;
      } else {
        throw Exception(apiResponse.message ?? 'Autocomplete failed');
      }
    } on DioException catch (e) {
      _logger.e('❌ Error fetching autocomplete: ${e.message}');
      rethrow;
    } catch (e) {
      _logger.e('❌ Unexpected error in autocomplete: $e');
      // Return empty response on error (graceful degradation)
      return const AutocompleteResponse(
        poets: [],
        poems: [],
        tags: [],
        categories: [],
        totalCount: 0,
      );
    }
  }

  // ============================================================================
  // RECOMMENDATIONS
  // ============================================================================

  /// Get content recommendations
  ///
  /// Endpoint: GET /api/search/recommendations
  ///
  /// Recommendation Types:
  /// - **personalized**: Based on user's bookmarks/likes
  /// - **similar**: More Like This algorithm (requires contentId)
  /// - **trending**: Popular content by timeframe
  /// - **hybrid**: Combined (40% personalized + 60% trending)
  ///
  /// Parameters:
  /// - [type]: Recommendation type (required)
  /// - [contentId]: Content ID for "similar" type (optional)
  /// - [contentType]: POEM, COUPLET, POET (default: COUPLET)
  /// - [timeframe]: For trending (day, week, month) - default: week
  /// - [limit]: Number of recommendations (default: 10)
  /// - [userId]: User ID for personalized (optional, uses auth header)
  Future<RecommendationResponse> getRecommendations({
    required String type,
    String? contentId,
    String contentType = 'COUPLET',
    String timeframe = 'week',
    int limit = 10,
    String? userId,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'type': type,
        'limit': limit,
      };

      if (type == 'similar') {
        if (contentId == null || contentId.isEmpty) {
          throw ArgumentError('contentId is required for "similar" type');
        }
        queryParams['contentType'] = contentType;
        queryParams['contentId'] = contentId;
      } else if (type == 'trending') {
        queryParams['timeframe'] = timeframe;
      }

      final headers = <String, String>{};
      if (userId != null && userId.isNotEmpty) {
        headers['X-User-Id'] = userId;
      }

      _logger.i('💡 Fetching recommendations (type: $type)');

      final response = await _dio.get(
        '$_baseEndpoint/recommendations',
        queryParameters: queryParams,
        options: Options(headers: headers),
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        final recommendationResponse = RecommendationResponse.fromJson(apiResponse.data!);
        _logger.i('✅ Recommendations ($type): ${recommendationResponse.totalCount} items');
        return recommendationResponse;
      } else {
        throw Exception(apiResponse.message ?? 'Recommendations failed');
      }
    } on DioException catch (e) {
      _logger.e('❌ Error fetching recommendations: ${e.message}');
      rethrow;
    } catch (e) {
      _logger.e('❌ Unexpected error in recommendations: $e');
      throw Exception('Failed to get recommendations: ${e.toString()}');
    }
  }

  // ============================================================================
  // RELATED SEARCHES
  // ============================================================================

  /// Get related searches (people also searched)
  ///
  /// Endpoint: GET /api/search/related
  ///
  /// Uses session co-occurrence analysis (30-day window)
  ///
  /// Parameters:
  /// - [query]: Original search query
  /// - [limit]: Number of related searches (default: 5)
  Future<RelatedSearchesResponse> getRelatedSearches({
    required String query,
    int limit = 5,
  }) async {
    // Related searches use session/auth analysis — no guest endpoint. Return
    // empty for guests instead of hitting the authed route (401).
    if (_isGuest) {
      return RelatedSearchesResponse(
        query: query,
        relatedSearches: const [],
        totalCount: 0,
        timeWindow: '30d',
      );
    }

    try {
      _logger.d('🔗 Fetching related searches for: "$query"');

      final response = await _dio.get(
        '$_baseEndpoint/related',
        queryParameters: {
          'q': query,
          'limit': limit,
        },
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        final relatedResponse = RelatedSearchesResponse.fromJson(apiResponse.data!);
        _logger.i('✅ Related searches for "$query": ${relatedResponse.totalCount} found');
        return relatedResponse;
      } else {
        throw Exception(apiResponse.message ?? 'Related searches failed');
      }
    } on DioException catch (e) {
      _logger.e('❌ Error fetching related searches: ${e.message}');
      rethrow;
    } catch (e) {
      _logger.e('❌ Unexpected error in related searches: $e');
      // Return empty response on error (graceful degradation)
      return RelatedSearchesResponse(
        query: query,
        relatedSearches: const [],
        totalCount: 0,
        timeWindow: '30d',
      );
    }
  }

  // ============================================================================
  // TRENDING SEARCHES
  // ============================================================================

  /// Get trending search queries
  ///
  /// Endpoint: GET /api/search/trending
  ///
  /// Parameters:
  /// - [timeframe]: Time period (day, week, month) - default: week
  /// - [limit]: Number of trending searches (default: 10)
  ///
  /// Returns: Most popular search queries by timeframe
  Future<TrendingSearchesResponse> getTrendingSearches({
    String timeframe = 'week',
    int limit = 10,
  }) async {
    try {
      _logger.d('📈 Fetching trending searches ($timeframe)');

      final response = await _dio.get(
        '$_baseEndpoint/trending',
        queryParameters: {
          'timeframe': timeframe,
          'limit': limit,
        },
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        final trendingResponse = TrendingSearchesResponse.fromJson(apiResponse.data!);
        _logger.i('✅ Trending searches ($timeframe): ${trendingResponse.totalCount} found');
        return trendingResponse;
      } else {
        throw Exception(apiResponse.message ?? 'Trending searches failed');
      }
    } on DioException catch (e) {
      _logger.e('❌ Error fetching trending searches: ${e.message}');
      rethrow;
    } catch (e) {
      _logger.e('❌ Unexpected error in trending searches: $e');
      // Return empty response on error (graceful degradation)
      return TrendingSearchesResponse(
        searches: const [],
        totalCount: 0,
        timeframe: timeframe,
        period: timeframe,
      );
    }
  }
}
