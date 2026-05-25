import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:flutter_poetry_app/core/auth/auth_provider.dart';
import 'package:flutter_poetry_app/core/network/dto/api_response.dart';
import 'package:flutter_poetry_app/core/network/guest_service.dart';
import '../models/poet_model.dart';
import '../models/poet_profile_model.dart';
import '../models/poet_image_model.dart';
import '../models/poet_book_model.dart';
import '../models/poet_video_model.dart';
import '../models/poem_model.dart';

class PoetService {
  final Dio _dio;
  final Ref _ref;
  final Logger _logger = Logger();

  static const String _baseEndpoint = '/api/poets';

  PoetService(this._dio, this._ref);

  bool get _isGuest => _ref.read(authProvider).isGuest;
  GuestService get _guest => _ref.read(guestServiceProvider);

  /// Adapt a [GuestPage] to the [PaginatedResponse] shape the rest of the
  /// app expects. Guest endpoints don't carry a `pageable` sub-object so we
  /// synthesize the minimal pagination metadata.
  PaginatedResponse<T> _adaptGuestPage<T>(GuestPage<T> page, int requestedSize) {
    return PaginatedResponse<T>(
      content: page.items,
      pageable: null,
      totalElements: page.totalElements,
      totalPages: page.totalPages,
      last: page.isLast,
      first: page.page == 0,
      numberOfElements: page.items.length,
      size: requestedSize,
      number: page.page,
      empty: page.items.isEmpty,
    );
  }

  /// Build a [PoetProfileModel] from a [PoetModel] when serving a guest. The
  /// guest endpoint returns only the poet summary fields — gallery, books,
  /// videos, facts, tags stay empty; biography reuses shortBio so the screen
  /// always has something to render.
  PoetProfileModel _adaptGuestPoet(PoetModel poet) {
    return PoetProfileModel(
      publicId: poet.publicId,
      name: poet.name,
      biography: poet.shortBio,
      shortBio: poet.shortBio,
      gender: poet.gender,
      era: poet.era,
      birthYear: poet.birthYear,
      deathYear: poet.deathYear,
      birthPlace: poet.birthPlace,
      country: poet.country,
      countryFlag: poet.countryFlag,
      countryFlagUrl: poet.countryFlagUrl,
      isFeatured: poet.isFeatured,
      isTrending: poet.isTrending,
      isVerified: poet.isVerified,
      viewCount: poet.viewCount,
      followerCount: poet.followerCount,
      poemCount: poet.poemCount,
      profileImageUrl: poet.profileImageUrl,
      gallery: const [],
      books: const [],
      videos: const [],
      facts: const [],
      tags: const [],
    );
  }

  /// Return an empty paginated response. Used for guest-mode requests on
  /// surfaces that have no anonymous endpoint (e.g. `getPoemsByPoet`,
  /// follower listings). Lets the UI render an empty section + an inline
  /// "Sign in to see all poems by this poet" CTA in the consumer.
  PaginatedResponse<T> _emptyPage<T>(int size) => PaginatedResponse<T>(
        content: const [],
        pageable: null,
        totalElements: 0,
        totalPages: 0,
        last: true,
        first: true,
        numberOfElements: 0,
        size: size,
        number: 0,
        empty: true,
      );

  /// Get all poets with pagination
  /// sortBy options: viewCount, poemCount, followerCount, birthYear, deathYear, createdAt, updatedAt
  /// sortDir options: asc, desc
  Future<PaginatedResponse<PoetModel>> getAllPoets({
    int page = 0,
    int size = 10,
    String lang = 'ur',
    String sortBy = 'viewCount',
    String sortDir = 'desc',
  }) async {
    if (_isGuest) {
      final guestPage =
          await _guest.getPoets(page: page, size: size, lang: lang);
      return _adaptGuestPage(guestPage, size);
    }
    try {
      final response = await _dio.get(
        _baseEndpoint,
        queryParameters: {
          'page': page,
          'size': size,
          'lang': lang,
          'sortBy': sortBy,
          'sortDir': sortDir,
        },
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        _logger.i('✅ Poets fetched successfully - Page: $page');
        return PaginatedResponse<PoetModel>.fromJson(
          apiResponse.data!,
          (json) => PoetModel.fromJson(json as Map<String, dynamic>? ?? {}),
        );
      } else {
        throw Exception(apiResponse.message);
      }
    } on DioException catch (e) {
      _logger.e('❌ Error fetching poets: ${e.message}');
      rethrow;
    }
  }

  /// Get featured poets
  Future<PaginatedResponse<PoetModel>> getFeaturedPoets({
    int page = 0,
    int size = 10,
    String lang = 'ur',
  }) async {
    if (_isGuest) {
      // Guest API has a single "featured" surface — same list backs both
      // featured and trending sections.
      final guestPage =
          await _guest.getPoets(page: page, size: size, lang: lang);
      return _adaptGuestPage(guestPage, size);
    }
    try {
      final response = await _dio.get(
        '$_baseEndpoint/featured',
        queryParameters: {
          'page': page,
          'size': size,
          'lang': lang,
        },
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        _logger.i('✅ Featured poets fetched successfully');
        return PaginatedResponse<PoetModel>.fromJson(
          apiResponse.data!,
          (json) => PoetModel.fromJson(json as Map<String, dynamic>? ?? {}),
        );
      } else {
        throw Exception(apiResponse.message ?? 'Failed to fetch featured poets');
      }
    } on DioException catch (e) {
      _logger.e('❌ Error fetching featured poets: ${e.message}');
      rethrow;
    }
  }

  /// Get trending poets
  Future<PaginatedResponse<PoetModel>> getTrendingPoets({
    int page = 0,
    int size = 10,
    String lang = 'ur',
  }) async {
    if (_isGuest) {
      final guestPage =
          await _guest.getPoets(page: page, size: size, lang: lang);
      return _adaptGuestPage(guestPage, size);
    }
    try {
      final response = await _dio.get(
        '$_baseEndpoint/trending',
        queryParameters: {
          'page': page,
          'size': size,
          'lang': lang,
        },
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        _logger.i('✅ Trending poets fetched successfully');
        return PaginatedResponse<PoetModel>.fromJson(
          apiResponse.data!,
          (json) => PoetModel.fromJson(json as Map<String, dynamic>? ?? {}),
        );
      } else {
        throw Exception(apiResponse.message ?? 'Failed to fetch trending poets');
      }
    } on DioException catch (e) {
      _logger.e('❌ Error fetching trending poets: ${e.message}');
      rethrow;
    }
  }

  /// Get poets by gender
  Future<PaginatedResponse<PoetModel>> getPoetsByGender({
    required String gender,
    int page = 0,
    int size = 10,
    String lang = 'ur',
  }) async {
    if (_isGuest) {
      // Guest API has no gender filter — fall back to the flat directory.
      final guestPage =
          await _guest.getPoets(page: page, size: size, lang: lang);
      return _adaptGuestPage(guestPage, size);
    }
    try {
      final response = await _dio.get(
        '$_baseEndpoint/gender/$gender',
        queryParameters: {
          'page': page,
          'size': size,
          'lang': lang,
        },
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        _logger.i('✅ Poets by gender fetched successfully - Gender: $gender');
        return PaginatedResponse<PoetModel>.fromJson(
          apiResponse.data!,
          (json) => PoetModel.fromJson(json as Map<String, dynamic>? ?? {}),
        );
      } else {
        throw Exception(apiResponse.message ?? 'Failed to fetch poets by gender');
      }
    } on DioException catch (e) {
      _logger.e('❌ Error fetching poets by gender: ${e.message}');
      rethrow;
    }
  }

  /// Get poets by era
  Future<PaginatedResponse<PoetModel>> getPoetsByEra({
    required String era,
    int page = 0,
    int size = 10,
    String lang = 'ur',
  }) async {
    if (_isGuest) {
      // Guest API has no era filter — fall back to the flat directory.
      final guestPage =
          await _guest.getPoets(page: page, size: size, lang: lang);
      return _adaptGuestPage(guestPage, size);
    }
    try {
      final response = await _dio.get(
        '$_baseEndpoint/era/$era',
        queryParameters: {
          'page': page,
          'size': size,
          'lang': lang,
        },
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        _logger.i('✅ Poets by era fetched successfully - Era: $era');
        return PaginatedResponse<PoetModel>.fromJson(
          apiResponse.data!,
          (json) => PoetModel.fromJson(json as Map<String, dynamic>? ?? {}),
        );
      } else {
        throw Exception(apiResponse.message ?? 'Failed to fetch poets by era');
      }
    } on DioException catch (e) {
      _logger.e('❌ Error fetching poets by era: ${e.message}');
      rethrow;
    }
  }

  /// Get poets by tag
  Future<PaginatedResponse<PoetModel>> getPoetsByTag({
    required String tagSlug,
    int page = 0,
    int size = 10,
    String lang = 'ur',
  }) async {
    if (_isGuest) {
      // Guest API has no tag filter — fall back to the flat directory.
      final guestPage =
          await _guest.getPoets(page: page, size: size, lang: lang);
      return _adaptGuestPage(guestPage, size);
    }
    try {
      final response = await _dio.get(
        '$_baseEndpoint/tags/$tagSlug',
        queryParameters: {
          'page': page,
          'size': size,
          'lang': lang,
        },
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        _logger.i('✅ Poets by tag fetched successfully - Tag: $tagSlug');
        return PaginatedResponse<PoetModel>.fromJson(
          apiResponse.data!,
          (json) => PoetModel.fromJson(json as Map<String, dynamic>? ?? {}),
        );
      } else {
        throw Exception(apiResponse.message ?? 'Failed to fetch poets by tag');
      }
    } on DioException catch (e) {
      _logger.e('❌ Error fetching poets by tag: ${e.message}');
      rethrow;
    }
  }

  /// Search poets
  Future<PaginatedResponse<PoetModel>> searchPoets({
    required String query,
    String lang = 'ur',
    int page = 0,
    int size = 10,
  }) async {
    if (_isGuest) {
      final guestPage = await _guest.searchPoets(
        q: query,
        page: page,
        size: size,
        lang: lang,
      );
      return _adaptGuestPage(guestPage, size);
    }
    try {
      final response = await _dio.get(
        '$_baseEndpoint/search',
        queryParameters: {
          'query': query,
          'lang': lang,
          'page': page,
          'size': size,
        },
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        _logger.i('✅ Poet search completed - Query: $query');
        return PaginatedResponse<PoetModel>.fromJson(
          apiResponse.data!,
          (json) => PoetModel.fromJson(json as Map<String, dynamic>? ?? {}),
        );
      } else {
        throw Exception(apiResponse.message ?? 'Failed to search poets');
      }
    } on DioException catch (e) {
      _logger.e('❌ Error searching poets: ${e.message}');
      rethrow;
    }
  }

  /// Get poets by poem count (top poets)
  Future<PaginatedResponse<PoetModel>> getTopPoetsByPoemCount({
    int page = 0,
    int size = 10,
    String lang = 'ur',
  }) async {
    if (_isGuest) {
      final guestPage =
          await _guest.getPoets(page: page, size: size, lang: lang);
      return _adaptGuestPage(guestPage, size);
    }
    try {
      final response = await _dio.get(
        '$_baseEndpoint/top/by-poems',
        queryParameters: {
          'page': page,
          'size': size,
          'lang': lang,
        },
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        _logger.i('✅ Top poets by poem count fetched successfully');
        return PaginatedResponse<PoetModel>.fromJson(
          apiResponse.data!,
          (json) => PoetModel.fromJson(json as Map<String, dynamic>? ?? {}),
        );
      } else {
        throw Exception(apiResponse.message ?? 'Failed to fetch top poets');
      }
    } on DioException catch (e) {
      _logger.e('❌ Error fetching top poets by poem count: ${e.message}');
      rethrow;
    }
  }

  /// Get poets by views (most popular)
  Future<PaginatedResponse<PoetModel>> getTopPoetsByViews({
    int page = 0,
    int size = 10,
    String lang = 'ur',
  }) async {
    if (_isGuest) {
      final guestPage =
          await _guest.getPoets(page: page, size: size, lang: lang);
      return _adaptGuestPage(guestPage, size);
    }
    try {
      final response = await _dio.get(
        '$_baseEndpoint/top/by-views',
        queryParameters: {
          'page': page,
          'size': size,
          'lang': lang,
        },
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        _logger.i('✅ Top poets by views fetched successfully');
        return PaginatedResponse<PoetModel>.fromJson(
          apiResponse.data!,
          (json) => PoetModel.fromJson(json as Map<String, dynamic>? ?? {}),
        );
      } else {
        throw Exception(apiResponse.message ?? 'Failed to fetch top poets');
      }
    } on DioException catch (e) {
      _logger.e('❌ Error fetching top poets by views: ${e.message}');
      rethrow;
    }
  }

  /// Get complete poet profile
  Future<PoetProfileModel> getPoetProfile({
    required String publicId,
    String lang = 'ur',
  }) async {
    if (_isGuest) {
      // Guest API returns a slim poet summary, not the fat profile shape —
      // adapt it. Gallery/books/videos/facts/tags are empty for guests; the
      // poet detail screen renders an inline "Sign in to see all poems"
      // CTA for the missing poem list.
      final guestPoet = await _guest.getPoetById(publicId, lang: lang);
      return _adaptGuestPoet(guestPoet);
    }
    try {
      final response = await _dio.get(
        '$_baseEndpoint/$publicId/profile',
        queryParameters: {
          'lang': lang,
        },
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        _logger.i('✅ Poet profile fetched successfully - ID: $publicId');
        return PoetProfileModel.fromJson(apiResponse.data!);
      } else {
        throw Exception(apiResponse.message ?? 'Failed to fetch poet profile');
      }
    } on DioException catch (e) {
      _logger.e('❌ Error fetching poet profile: ${e.message}');
      rethrow;
    }
  }

  /// Get poet gallery images
  Future<List<PoetImageModel>> getPoetGallery({
    required String publicId,
    String lang = 'ur',
  }) async {
    try {
      final response = await _dio.get(
        '$_baseEndpoint/$publicId/gallery',
        queryParameters: {
          'lang': lang,
        },
      );

      final apiResponse = ApiResponse<dynamic>.fromJson(
        response.data,
        (json) => json,
      );

      if (apiResponse.success && apiResponse.data != null) {
        final List<dynamic> data = apiResponse.data as List<dynamic>;
        _logger.i('✅ Poet gallery fetched successfully - ID: $publicId');
        return data
            .map((item) => PoetImageModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(apiResponse.message);
      }
    } on DioException catch (e) {
      _logger.e('❌ Error fetching poet gallery: ${e.message}');
      rethrow;
    }
  }

  /// Get poet books
  Future<List<PoetBookModel>> getPoetBooks({
    required String publicId,
    String lang = 'ur',
  }) async {
    try {
      final response = await _dio.get(
        '$_baseEndpoint/$publicId/books',
        queryParameters: {
          'lang': lang,
        },
      );

      final apiResponse = ApiResponse<dynamic>.fromJson(
        response.data,
        (json) => json,
      );

      if (apiResponse.success && apiResponse.data != null) {
        final List<dynamic> data = apiResponse.data as List<dynamic>;
        _logger.i('✅ Poet books fetched successfully - ID: $publicId');
        return data
            .map((item) => PoetBookModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(apiResponse.message);
      }
    } on DioException catch (e) {
      _logger.e('❌ Error fetching poet books: ${e.message}');
      rethrow;
    }
  }

  /// Get poet videos
  /// videoType options: MUSHAIRA, INTERVIEW, DOCUMENTARY, RECITATION, BIOGRAPHY, OTHER
  Future<List<PoetVideoModel>> getPoetVideos({
    required String publicId,
    String? videoType,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (videoType != null) {
        queryParams['type'] = videoType;
      }

      final response = await _dio.get(
        '$_baseEndpoint/$publicId/videos',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final apiResponse = ApiResponse<dynamic>.fromJson(
        response.data,
        (json) => json,
      );

      if (apiResponse.success && apiResponse.data != null) {
        final List<dynamic> data = apiResponse.data as List<dynamic>;
        _logger.i('✅ Poet videos fetched successfully - ID: $publicId, Type: $videoType');
        return data
            .map((item) => PoetVideoModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(apiResponse.message);
      }
    } on DioException catch (e) {
      _logger.e('❌ Error fetching poet videos: ${e.message}');
      rethrow;
    }
  }

  /// Get poet facts
  Future<List<String>> getPoetFacts({
    required String publicId,
    String lang = 'ur',
  }) async {
    try {
      final response = await _dio.get(
        '$_baseEndpoint/$publicId/facts',
        queryParameters: {
          'lang': lang,
        },
      );

      final apiResponse = ApiResponse<dynamic>.fromJson(
        response.data,
        (json) => json,
      );

      if (apiResponse.success && apiResponse.data != null) {
        final List<dynamic> data = apiResponse.data as List<dynamic>;
        _logger.i('✅ Poet facts fetched successfully - ID: $publicId');
        return data.map((item) => item.toString()).toList();
      } else {
        throw Exception(apiResponse.message);
      }
    } on DioException catch (e) {
      _logger.e('❌ Error fetching poet facts: ${e.message}');
      rethrow;
    }
  }

  // ============= FOLLOW SYSTEM =============

  /// Follow a poet: POST /api/poets/{publicId}/follow
  Future<({bool following, int followerCount})> followPoet({
    required String publicId,
  }) async {
    try {
      final response = await _dio.post('$_baseEndpoint/$publicId/follow');

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        _logger.i('✅ Followed poet: $publicId');
        return (
          following: apiResponse.data!['following'] as bool? ?? true,
          followerCount: apiResponse.data!['followerCount'] as int? ?? 0,
        );
      } else {
        throw Exception(apiResponse.message ?? 'Failed to follow poet');
      }
    } on DioException catch (e) {
      _logger.e('❌ Error following poet: ${e.message}');
      rethrow;
    }
  }

  /// Unfollow a poet: DELETE /api/poets/{publicId}/follow
  Future<({bool following, int followerCount})> unfollowPoet({
    required String publicId,
  }) async {
    try {
      final response = await _dio.delete('$_baseEndpoint/$publicId/follow');

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        _logger.i('✅ Unfollowed poet: $publicId');
        return (
          following: apiResponse.data!['following'] as bool? ?? false,
          followerCount: apiResponse.data!['followerCount'] as int? ?? 0,
        );
      } else {
        throw Exception(apiResponse.message ?? 'Failed to unfollow poet');
      }
    } on DioException catch (e) {
      _logger.e('❌ Error unfollowing poet: ${e.message}');
      rethrow;
    }
  }

  /// Check follow status: GET /api/poets/{publicId}/is-following
  Future<({bool isFollowing, String? followedAt})> isFollowingPoet({
    required String publicId,
  }) async {
    try {
      final response = await _dio.get('$_baseEndpoint/$publicId/is-following');

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        return (
          isFollowing: apiResponse.data!['isFollowing'] as bool? ?? false,
          followedAt: apiResponse.data!['followedAt'] as String?,
        );
      } else {
        throw Exception(apiResponse.message ?? 'Failed to check follow status');
      }
    } on DioException catch (e) {
      _logger.e('❌ Error checking follow status: ${e.message}');
      rethrow;
    }
  }

  /// Get list of poets the user is following: GET /api/users/me/following
  Future<PaginatedResponse<PoetModel>> getFollowingPoets({
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/api/users/me/following',
        queryParameters: {
          'page': page,
          'size': size,
        },
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        _logger.i('✅ Following list fetched - Page: $page');
        return PaginatedResponse<PoetModel>.fromJson(
          apiResponse.data!,
          (json) => PoetModel.fromJson(json as Map<String, dynamic>? ?? {}),
        );
      } else {
        throw Exception(apiResponse.message ?? 'Failed to fetch following list');
      }
    } on DioException catch (e) {
      _logger.e('❌ Error fetching following list: ${e.message}');
      rethrow;
    }
  }

  /// Get poems by poet with optional poetry type filtering
  Future<PaginatedResponse<PoemModel>> getPoemsByPoet({
    required String poetPublicId,
    String? poetryType,
    int page = 0,
    int size = 20,
    String lang = 'ur',
  }) async {
    if (_isGuest) {
      // Guest API has no `/poems/poet/{id}` endpoint. The poet detail
      // screen renders an inline "Sign in to see all poems by [poet]"
      // CTA when this comes back empty, so guests still get a clear
      // sign-in prompt without breaking the screen.
      return _emptyPage<PoemModel>(size);
    }
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'size': size,
        'lang': lang,
      };
      if (poetryType != null) {
        queryParams['poetryType'] = poetryType;
      }

      final response = await _dio.get(
        '/api/poems/poet/$poetPublicId',
        queryParameters: queryParams,
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        _logger.i('✅ Poems fetched - Poet: $poetPublicId, Type: $poetryType, Page: $page');
        return PaginatedResponse<PoemModel>.fromJson(
          apiResponse.data!,
          (json) => PoemModel.fromJson(json as Map<String, dynamic>),
        );
      } else {
        throw Exception(apiResponse.message ?? 'Failed to fetch poems');
      }
    } on DioException catch (e) {
      _logger.e('❌ Error fetching poems: ${e.message}');
      rethrow;
    }
  }

  /// Get single poem detail
  Future<PoemModel> getPoemById(String publicId, {String lang = 'ur'}) async {
    if (_isGuest) {
      return _guest.getPoemById(publicId, lang: lang);
    }
    try {
      final response = await _dio.get(
        '/api/poems/$publicId',
        queryParameters: {'lang': lang},
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        _logger.i('✅ Poem detail fetched: $publicId');
        return PoemModel.fromJson(apiResponse.data!);
      } else {
        throw Exception(apiResponse.message ?? 'Failed to fetch poem');
      }
    } on DioException catch (e) {
      _logger.e('❌ Error fetching poem detail: ${e.message}');
      rethrow;
    }
  }
}
