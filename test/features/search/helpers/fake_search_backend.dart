import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_poetry_app/features/discover/models/discover_bundle_model.dart';
import 'package:flutter_poetry_app/features/discover/services/discover_service.dart';
import 'package:flutter_poetry_app/features/search/providers/global_search_provider.dart';
import 'package:flutter_poetry_app/features/search/services/search_history_service.dart';
import 'package:flutter_poetry_app/features/search/services/search_service.dart';

import '../../../helpers/fake_auth_notifier.dart';
import '../../../helpers/fake_dio_adapter.dart';
import 'search_test_harness.dart';

/// The `/api/search` backend behind a real [SearchService] and
/// [GlobalSearchNotifier], answering from fixtures through a
/// [FakeDioAdapter] so tests can count the requests the app makes (each one
/// is a `search_queries` row on the real backend).
///
/// `type=all` answers with [allPage]. A single-type page (`poems_only`,
/// `couplets_only`, …) repeats that type's items from [allPage] with the page
/// number appended to their ids, and reports more pages until [lastPage].
class FakeSearchBackend {
  FakeSearchBackend({
    Map<String, dynamic>? allPage,
    this.lastPage = 2,
    this.signedIn = true,
  }) : allPage = allPage ??
            searchFixture('unified_search_jigar.json')['data']
                as Map<String, dynamic> {
    dio = Dio(BaseOptions(baseUrl: 'http://fake.test'))
      ..httpClientAdapter = adapter;
    adapter.on('GET', '/api/search', (options) => searchReply(options));
    adapter.on(
      'GET',
      '/api/search/related',
      (options) => FakeReply(200, {
        'success': true,
        'message': 'ok',
        'data': {
          'query': options.queryParameters['q'],
          'relatedSearches': const [],
          'totalCount': 0,
          'timeWindow': '30d',
        },
      }),
    );
  }

  final adapter = FakeDioAdapter();
  late final Dio dio;
  final Map<String, dynamic> allPage;
  final int lastPage;
  final bool signedIn;

  /// When set, answers `/api/search` instead of the fixture (e.g. to hold a
  /// response open with a [Completer] or to fail it).
  FutureOr<FakeReply> Function(RequestOptions options)? onSearch;

  /// Every `/api/search` request, in order.
  List<RequestOptions> get searches => adapter.requestsTo('/api/search');

  /// Every `/api/search/related` request, in order.
  List<RequestOptions> get relatedRequests =>
      adapter.requestsTo('/api/search/related');

  FutureOr<FakeReply> searchReply(RequestOptions options) {
    final custom = onSearch;
    if (custom != null) return custom(options);
    return fixtureReply(options);
  }

  /// The fixture answer for [options] (`type` + `page`).
  FakeReply fixtureReply(RequestOptions options) {
    final params = options.queryParameters;
    final type = params['type'] as String? ?? 'all';
    if (type == 'all') {
      return FakeReply(
          200, {'success': true, 'message': 'ok', 'data': allPage});
    }
    final page = params['page'] as int? ?? 0;
    final key = switch (type) {
      'poets_only' => 'poets',
      'poems_only' => 'poems',
      'verses_only' => 'verses',
      'couplets_only' => 'couplets',
      'categories_only' => 'categories',
      _ => 'tags',
    };
    final hasMoreKey = 'hasMore${key[0].toUpperCase()}${key.substring(1)}';
    final items = [
      for (final item in (allPage[key] as List? ?? const []))
        _withPageSuffix(item as Map<String, dynamic>, key, page),
    ];
    return FakeReply(200, {
      'success': true,
      'message': 'ok',
      'data': {
        key: items,
        hasMoreKey: page < lastPage,
        'currentPage': page,
        'pageSize': params['size'],
      },
    });
  }

  static Map<String, dynamic> _withPageSuffix(
    Map<String, dynamic> item,
    String key,
    int page,
  ) {
    final copy = Map<String, dynamic>.from(item);
    if (key == 'verses') {
      final verse = Map<String, dynamic>.from(copy['verse'] as Map);
      verse['publicId'] = '${verse['publicId']}-p$page';
      copy['verse'] = verse;
    } else {
      copy['publicId'] = '${copy['publicId']}-p$page';
    }
    return copy;
  }

  /// A real [GlobalSearchNotifier] over a real [SearchService] using this
  /// backend. Disposed with the test's [ProviderContainer].
  GlobalSearchNotifier createNotifier({String lang = 'ur'}) {
    final container = ProviderContainer(overrides: [
      authOverride(
          signedIn ? FakeAuthNotifier.signedIn() : FakeAuthNotifier.guest()),
    ]);
    final service = _ServiceHolder.create(container, dio);
    final notifier = GlobalSearchNotifier(
      service,
      MemorySearchHistory(),
      IdleDiscoverService(),
      lang,
    );
    _containers.add(container);
    return notifier;
  }

  final _containers = <ProviderContainer>[];

  void dispose() {
    for (final c in _containers) {
      c.dispose();
    }
  }
}

/// [SearchService] needs a [Ref] (it reads `authProvider.isGuest`); a
/// throwaway provider hands one over.
abstract final class _ServiceHolder {
  static SearchService create(ProviderContainer container, Dio dio) {
    final provider = Provider<SearchService>((ref) => SearchService(dio, ref));
    return container.read(provider);
  }
}

/// Search history kept in memory (no SharedPreferences).
class MemorySearchHistory implements SearchHistoryService {
  final _history = <String>[];

  @override
  Future<List<String>> getHistory() async => List.of(_history);

  @override
  Future<void> addSearch(String query) async => _history.insert(0, query);

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

/// A discover service whose bundle never arrives, so nothing else is fetched.
class IdleDiscoverService implements DiscoverService {
  @override
  Future<DiscoverBundle> getDiscoverBundle({
    required String lang,
    bool forceRefresh = false,
  }) =>
      Completer<DiscoverBundle>().future;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}
