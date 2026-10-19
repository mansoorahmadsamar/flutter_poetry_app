import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_poetry_app/core/network/guest_service.dart';
import 'package:flutter_poetry_app/features/search/services/search_service.dart';

import '../../../helpers/fake_auth_notifier.dart';
import '../../../helpers/fixture_dio_client.dart';

/// T-114: a guest single-type search (`couplets_only`, `verses_only`,
/// `categories_only`, …) fanned out to both guest poem and poet search,
/// although guests can search neither couplets, verses nor categories —
/// two wasted requests against the 60/min guest rate limit.
void main() {
  late FixtureDioClient guestClient;
  late ProviderContainer container;
  late SearchService service;

  setUp(() {
    // An empty Spring page for every guest search.
    guestClient = FixtureDioClient({
      'success': true,
      'message': 'ok',
      'data': {
        'content': const [],
        'totalPages': 0,
        'totalElements': 0,
        'number': 0,
      },
    });
    container = ProviderContainer(overrides: [
      authOverride(FakeAuthNotifier.guest()),
      guestServiceProvider.overrideWithValue(GuestService(guestClient)),
    ]);
    final provider = Provider<SearchService>(
      // Any authenticated call would fail loudly: no adapter route exists.
      (ref) =>
          SearchService(Dio(BaseOptions(baseUrl: 'http://unused.test')), ref),
    );
    service = container.read(provider);
  });

  tearDown(() => container.dispose());

  Future<List<String>> pathsFor(String type) async {
    await service.searchUnified(query: 'jigar', type: type);
    return guestClient.requestedPaths;
  }

  test('"all" searches guest poems and poets', () async {
    expect(
        await pathsFor('all'),
        unorderedEquals([
          '/api/guest/poems/search',
          '/api/guest/poets/search',
        ]));
  });

  test('poems_only searches only poems', () async {
    expect(await pathsFor('poems_only'), ['/api/guest/poems/search']);
  });

  test('poets_only searches only poets', () async {
    expect(await pathsFor('poets_only'), ['/api/guest/poets/search']);
  });

  for (final type in [
    'couplets_only',
    'verses_only',
    'categories_only',
    'tags_only',
  ]) {
    test('regression: $type makes no request and returns nothing', () async {
      final response = await service.searchUnified(query: 'jigar', type: type);

      expect(guestClient.requestedPaths, isEmpty);
      expect(response.totalResults, 0);
      expect(response.poems, isEmpty);
      expect(response.poets, isEmpty);
      expect(response.hasMorePoems, isFalse);
      expect(response.hasMorePoets, isFalse);
    });
  }
}
