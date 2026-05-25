import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../features/discover/models/discover_bundle_model.dart';
import '../../features/hashtags/models/hashtag_model.dart';
import '../../features/main/tabs/poets/models/poem_model.dart';
import '../../features/main/tabs/poets/models/poet_model.dart';
import 'dio_client.dart';

/// Service wrapping the anonymous `/api/guest/**` API surface.
///
/// All endpoints are GET-only, never carry an Authorization header (the
/// AuthInterceptor strips it on this path prefix), are hard-paginated to
/// `page ∈ [0,4]` × `size ∈ [1,20]` server-side, and are rate-limited
/// 60/min per IP. See [FLUTTER_API_DOCUMENTATION.md §21] for the contract.
///
/// Existing domain models ([PoemModel], [PoetModel], [DiscoverBundle]) are
/// reused — their engagement fields (`isLikedByCurrentUser`,
/// `isBookmarkedByCurrentUser`, etc.) are already nullable and stay null
/// for guest responses.
class GuestService {
  final DioClient _dioClient;
  final _logger = Logger();

  GuestService(this._dioClient);

  /// Clamps caller-supplied pagination to the server-enforced bounds so we
  /// never produce out-of-range requests. The backend silently clamps too,
  /// but doing it client-side keeps logs honest.
  int _clampPage(int page) => page.clamp(0, 4).toInt();
  int _clampSize(int size) => size.clamp(1, 20).toInt();

  // ──────────────────────────────────────────────────────────────────────────
  // Discover bundle
  // ──────────────────────────────────────────────────────────────────────────

  /// Single-call bundle for the guest landing screen. The guest endpoint
  /// returns `featuredPoems / featuredPoets / trendingPoets / trendingCouplets`,
  /// which we adapt into the existing [DiscoverBundle] shape so the same
  /// Discover screen can render either authed or guest data unchanged.
  Future<DiscoverBundle> getDiscoverBundle({required String lang}) async {
    final response = await _get('/api/guest/discover', {'lang': lang});
    final data = response.data?['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Guest discover bundle missing data field');
    }

    final featuredPoems = _asMapList(data['featuredPoems']);
    final featuredPoets = _asMapList(data['featuredPoets']);
    final trendingPoets = _asMapList(data['trendingPoets']);
    final trendingCouplets = _asMapList(data['trendingCouplets']);
    final language = data['language']?.toString() ?? lang;

    return DiscoverBundle(
      trendingSearches: const TrendingSearches(),
      editorsPicks: ContentSection(
        sectionKey: 'featuredPoems',
        sectionTitle: 'Featured Poems',
        totalCount: featuredPoems.length,
        items: featuredPoems.map(_poemSummaryToCard).toList(),
      ),
      recommended: ContentSection(
        sectionKey: 'trendingCouplets',
        sectionTitle: 'Trending Couplets',
        totalCount: trendingCouplets.length,
        items: trendingCouplets.map(_coupletToCard).toList(),
      ),
      featuredPoets: ContentSection(
        sectionKey: 'featuredPoets',
        sectionTitle: 'Featured Poets',
        totalCount: featuredPoets.length,
        items: [
          ...featuredPoets,
          ...trendingPoets,
        ].map(_poetSummaryToCard).toList(),
      ),
      categories: const ContentSection(
        sectionKey: 'categories',
        items: [],
      ),
      trendingHashtags: const <HashtagDto>[],
      language: language,
      personalized: false,
      timestamp: data['timestamp'] is int
          ? data['timestamp'] as int
          : DateTime.now().millisecondsSinceEpoch,
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Poems
  // ──────────────────────────────────────────────────────────────────────────

  /// Paginated list of public poems (newest-first). Returns a parsed
  /// envelope `{items, totalElements, totalPages, page}` — caller can wrap
  /// this in whatever pagination shape its provider expects.
  Future<GuestPage<PoemModel>> getPoems({
    int page = 0,
    int size = 20,
    String lang = 'ur',
    String? poetryType,
  }) async {
    final response = await _get(
      '/api/guest/poems',
      {
        'page': _clampPage(page),
        'size': _clampSize(size),
        'lang': lang,
        if (poetryType != null) 'poetryType': poetryType,
      },
    );
    return _pageFromEnvelope(response, PoemModel.fromJson);
  }

  Future<PoemModel> getPoemById(String publicId, {String lang = 'ur'}) async {
    final response = await _get('/api/guest/poems/$publicId', {'lang': lang});
    final data = response.data?['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Guest poem detail missing data field');
    }
    return PoemModel.fromJson(data);
  }

  Future<GuestPage<PoemModel>> searchPoems({
    required String q,
    int page = 0,
    int size = 20,
    String lang = 'ur',
  }) async {
    final response = await _get(
      '/api/guest/poems/search',
      {
        'q': q,
        'page': _clampPage(page),
        'size': _clampSize(size),
        'lang': lang,
      },
    );
    return _pageFromEnvelope(response, PoemModel.fromJson);
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Poets
  // ──────────────────────────────────────────────────────────────────────────

  Future<GuestPage<PoetModel>> getPoets({
    int page = 0,
    int size = 20,
    String lang = 'ur',
  }) async {
    final response = await _get(
      '/api/guest/poets',
      {
        'page': _clampPage(page),
        'size': _clampSize(size),
        'lang': lang,
      },
    );
    return _pageFromEnvelope(response, PoetModel.fromJson);
  }

  Future<PoetModel> getPoetById(String publicId, {String lang = 'ur'}) async {
    final response = await _get('/api/guest/poets/$publicId', {'lang': lang});
    final data = response.data?['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Guest poet detail missing data field');
    }
    return PoetModel.fromJson(data);
  }

  Future<GuestPage<PoetModel>> searchPoets({
    required String q,
    int page = 0,
    int size = 20,
    String lang = 'ur',
  }) async {
    final response = await _get(
      '/api/guest/poets/search',
      {
        'q': q,
        'page': _clampPage(page),
        'size': _clampSize(size),
        'lang': lang,
      },
    );
    return _pageFromEnvelope(response, PoetModel.fromJson);
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Couplets (trending only — guest API has no couplet search)
  // ──────────────────────────────────────────────────────────────────────────

  /// Trending couplets within a `days`-day window. Returns the raw maps —
  /// callers that already have a `CoupletModel` parser can plug it in.
  /// The guest DTO has no `userReaction` / engagement-state fields.
  Future<List<Map<String, dynamic>>> getTrendingCouplets({
    int days = 7,
    int page = 0,
    int size = 10,
  }) async {
    final response = await _get(
      '/api/guest/couplets/trending',
      {
        'days': days.clamp(1, 30),
        'page': _clampPage(page),
        'size': _clampSize(size),
      },
    );
    return _asMapList(response.data?['data']);
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Internals
  // ──────────────────────────────────────────────────────────────────────────

  Future<Response> _get(String path, Map<String, dynamic> query) async {
    try {
      return await _dioClient.get(path, queryParameters: query);
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        final retryAfter = int.tryParse(
              e.response?.headers.value('retry-after') ?? '',
            ) ??
            60;
        _logger.w('Guest endpoint rate-limited (retry in ${retryAfter}s)');
        throw GuestRateLimitException(retryAfter: retryAfter);
      }
      rethrow;
    }
  }

  /// Parses the standard `{success, message, data: {content: [...], ...}}`
  /// pagination envelope into a [GuestPage].
  GuestPage<T> _pageFromEnvelope<T>(
    Response response,
    T Function(Map<String, dynamic>) parse,
  ) {
    final data = response.data?['data'] as Map<String, dynamic>?;
    if (data == null) {
      return GuestPage<T>(items: const [], page: 0, totalPages: 0, totalElements: 0);
    }
    final content = _asMapList(data['content']);
    return GuestPage<T>(
      items: content.map(parse).toList(),
      page: (data['pageable'] is Map<String, dynamic>
              ? (data['pageable'] as Map<String, dynamic>)['pageNumber'] as int?
              : data['number'] as int?) ??
          0,
      totalPages: data['totalPages'] as int? ?? 0,
      totalElements: data['totalElements'] as int? ?? 0,
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Card adapters — convert guest DTOs into the unified ContentCard format
  // that the Discover screen already consumes.
  // ──────────────────────────────────────────────────────────────────────────

  ContentCard _poemSummaryToCard(Map<String, dynamic> j) {
    final image = j['poetProfileImageUrl']?.toString();
    return ContentCard(
      type: 'POEM',
      publicId: j['publicId']?.toString() ?? '',
      primaryText: (j['title']?.toString().isNotEmpty ?? false)
          ? j['title'].toString()
          : (j['excerpt']?.toString() ?? ''),
      secondaryText: j['poetName']?.toString(),
      badgeKey: j['poetryType']?.toString(),
      badge: j['poetryTypeName']?.toString(),
      language: j['language']?.toString() ?? 'ur',
      direction: j['direction']?.toString() ?? 'rtl',
      imageUrl: (image == null || image.isEmpty || image == '-') ? null : image,
      metrics: ContentMetrics(
        likeCount: _asInt(j['likeCount']),
        shareCount: _asInt(j['shareCount']),
        viewCount: _asInt(j['viewCount']),
      ),
    );
  }

  ContentCard _poetSummaryToCard(Map<String, dynamic> j) {
    final image = j['profileImageUrl']?.toString();
    return ContentCard(
      type: 'POET',
      publicId: j['publicId']?.toString() ?? '',
      primaryText: j['name']?.toString() ?? '',
      secondaryText: j['shortBio']?.toString(),
      badge: j['era']?.toString(),
      badgeKey: j['era']?.toString(),
      language: j['language']?.toString() ?? 'ur',
      direction: j['direction']?.toString() ?? 'rtl',
      imageUrl: (image == null || image.isEmpty || image == '-') ? null : image,
      metrics: ContentMetrics(viewCount: _asInt(j['poemCount'])),
    );
  }

  ContentCard _coupletToCard(Map<String, dynamic> j) {
    final image = j['poetProfileImageUrl']?.toString();
    final verses = _asMapList(j['verses']);
    final excerpt = verses
        .map((v) => v['verseText']?.toString())
        .where((s) => s != null && s.isNotEmpty)
        .take(2)
        .join('\n');
    return ContentCard(
      type: 'COUPLET',
      publicId: j['publicId']?.toString() ?? '',
      primaryText: excerpt,
      secondaryText: j['poetName']?.toString(),
      badge: j['coupletTypeName']?.toString(),
      badgeKey: j['coupletType']?.toString(),
      language: 'ur',
      direction: 'rtl',
      imageUrl: (image == null || image.isEmpty || image == '-') ? null : image,
      metrics: ContentMetrics(
        likeCount: _asInt(j['likeCount']),
        shareCount: _asInt(j['shareCount']),
      ),
    );
  }

  List<Map<String, dynamic>> _asMapList(dynamic value) {
    if (value is! List) return const [];
    return value.whereType<Map<String, dynamic>>().toList();
  }

  int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

/// Anonymous endpoints rate-limit at 60/min per IP. Thrown when the backend
/// returns HTTP 429 so callers can show a friendly snackbar instead of a
/// generic network error.
class GuestRateLimitException implements Exception {
  final int retryAfter;
  const GuestRateLimitException({required this.retryAfter});

  @override
  String toString() =>
      'GuestRateLimitException(retryAfter: ${retryAfter}s)';
}

/// Minimal page envelope returned by [GuestService] paginated endpoints.
/// Trivial shape — callers map this into whatever provider state they use.
class GuestPage<T> {
  final List<T> items;
  final int page;
  final int totalPages;
  final int totalElements;

  const GuestPage({
    required this.items,
    required this.page,
    required this.totalPages,
    required this.totalElements,
  });

  bool get isLast => totalPages == 0 || page >= totalPages - 1;
  int get nextPage => math.min(page + 1, 4); // server clamps to [0,4]
}

final guestServiceProvider = Provider<GuestService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return GuestService(dioClient);
});
