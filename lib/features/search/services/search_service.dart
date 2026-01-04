import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:flutter_poetry_app/core/network/dto/api_response.dart';
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
  final Logger _logger = Logger();
  static const String _baseEndpoint = '/api/search';

  SearchService(this._dio);

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
        final paginatedResponse = PaginatedResponse<CoupletSearchResult>.fromJson(
          apiResponse.data!,
          (json) => CoupletSearchResult.fromJson(json as Map<String, dynamic>? ?? {}),
        );

        _logger.i('✅ Couplet search: "${query}" - ${paginatedResponse.totalElements} results');
        return paginatedResponse;
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
  // AUTOCOMPLETE
  // ============================================================================

  /// Get autocomplete suggestions (poets, poems, tags, categories)
  ///
  /// Endpoint: GET /api/search/autocomplete
  ///
  /// Parameters:
  /// - [query]: Search query (minimum 2 characters)
  /// - [lang]: Language code (default: 'ur')
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
  }) async {
    // Early return for short queries
    if (query.trim().length < 2) {
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
