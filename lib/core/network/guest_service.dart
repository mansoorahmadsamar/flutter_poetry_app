import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../features/discover/models/discover_bundle_model.dart';
import '../../features/hashtags/models/hashtag_model.dart';
import '../../features/main/tabs/poets/models/poem_model.dart';
import '../../features/main/tabs/poets/models/poet_model.dart';
import '../utils/api_placeholder.dart';
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

  /// The highest page any `/api/guest/**` list serves. The backend clamps
  /// `page` to `0..maxPage` (`GuestController.guestPageable`), so asking for
  /// a later page returns this one again — it is always the last page.
  static const int maxPage = 4;

  /// The largest page size the backend allows (`size` is clamped to 1..20).
  static const int maxPageSize = 20;

  /// Clamps caller-supplied pagination to the server-enforced bounds so we
  /// never produce out-of-range requests. The backend silently clamps too,
  /// but doing it client-side keeps logs honest.
  int _clampPage(int page) => page.clamp(0, maxPage).toInt();
  int _clampSize(int size) => size.clamp(1, maxPageSize).toInt();

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

  /// HTTP statuses a backend answers for a guest path it doesn't have yet:
  /// 404 (`/featured` and `/trending` hit `/poets/{publicId}` → "Poet not
  /// found"; unmapped paths), and 401/405 from an older security chain.
  static const _missingEndpointStatuses = {401, 404, 405};

  /// Filters ([GuestPoetFilter.kind]) this backend turned out not to have;
  /// they go straight to [getPoets] for the rest of this service's life, so
  /// each costs one wasted request at most (guest calls share a 60/min
  /// limit).
  final Set<String> _unsupportedPoetFilters = {};

  /// Poets for a guest filter (`docs/contracts/guest-poets.md`): featured,
  /// trending, era or gender — same query parameters and envelope as
  /// [getPoets].
  ///
  /// The filter endpoints ship after this app version, so when the backend
  /// does not have one (see [_missingEndpointStatuses]) this falls back to
  /// the unfiltered [getPoets] list instead of failing. Any other error
  /// (5xx, offline, 429) is thrown as before.
  Future<GuestPage<PoetModel>> getFilteredPoets(
    GuestPoetFilter filter, {
    int page = 0,
    int size = 20,
    String lang = 'ur',
  }) async {
    if (!_unsupportedPoetFilters.contains(filter.kind)) {
      try {
        final response = await _get(filter.path, {
          'page': _clampPage(page),
          'size': _clampSize(size),
          'lang': lang,
        });
        return _pageFromEnvelope(response, PoetModel.fromJson);
      } on DioException catch (e) {
        if (!_missingEndpointStatuses.contains(e.response?.statusCode)) {
          rethrow;
        }
        _unsupportedPoetFilters.add(filter.kind);
        _logger.w('Guest poet filter "${filter.kind}" not on this backend '
            '(${e.response?.statusCode}); using /api/guest/poets');
      }
    }
    return getPoets(page: page, size: size, lang: lang);
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
      serverLast: data['last'] == true,
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
    final title = presentOrNull(j['title']?.toString());
    final excerpt = presentOrNull(j['excerpt']?.toString());
    return ContentCard(
      type: 'POEM',
      publicId: j['publicId']?.toString() ?? '',
      primaryText: title ?? excerpt ?? '',
      excerpt: excerpt,
      secondaryText: j['poetName']?.toString(),
      poetPublicId: presentOrNull(j['poetPublicId']?.toString()),
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
      poetPublicId: presentOrNull(j['poetPublicId']?.toString()),
      poemPublicId: presentOrNull(j['poemPublicId']?.toString()),
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

/// A guest poet filter and its endpoint (`docs/contracts/guest-poets.md`).
class GuestPoetFilter {
  const GuestPoetFilter._(this.kind, this.path);

  /// `GET /api/guest/poets/featured`.
  static const featured =
      GuestPoetFilter._('featured', '/api/guest/poets/featured');

  /// `GET /api/guest/poets/trending`.
  static const trending =
      GuestPoetFilter._('trending', '/api/guest/poets/trending');

  /// `GET /api/guest/poets/era/{era}` — `CLASSICAL`, `MODERN`,
  /// `CONTEMPORARY`, `EMERGING`.
  GuestPoetFilter.era(String era)
      : this._('era', '/api/guest/poets/era/${Uri.encodeComponent(era)}');

  /// `GET /api/guest/poets/gender/{gender}` — `MALE`, `FEMALE`, `OTHER`.
  GuestPoetFilter.gender(String gender)
      : this._('gender',
            '/api/guest/poets/gender/${Uri.encodeComponent(gender)}');

  /// One endpoint family (all eras share `era`): a backend that lacks one
  /// value lacks them all.
  final String kind;
  final String path;
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

  /// The envelope's own `last` flag, when it sent one.
  final bool serverLast;

  const GuestPage({
    required this.items,
    required this.page,
    required this.totalPages,
    required this.totalElements,
    this.serverLast = false,
  });

  /// No further page can be fetched: the server said so, this is its last
  /// page, or this is [GuestService.maxPage] — `totalPages` counts every
  /// match, but a request past the clamp returns this page again.
  bool get isLast =>
      serverLast ||
      totalPages == 0 ||
      page >= totalPages - 1 ||
      page >= GuestService.maxPage;

  int get nextPage => math.min(page + 1, GuestService.maxPage);
}

final guestServiceProvider = Provider<GuestService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return GuestService(dioClient);
});
