import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_poetry_app/core/network/guest_service.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/providers/poet_providers.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/providers/poets_pagination_provider.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/services/poet_service.dart';

import '../../../../../helpers/fake_auth_notifier.dart';
import '../../../../../helpers/fake_dio_adapter.dart';
import '../../../../../helpers/fake_guest_api.dart';

/// T-122 at the list level: a guest scrolling the poets grid.
void main() {
  late FakeDioAdapter adapter;

  ProviderContainer guestContainer() {
    final container = ProviderContainer(overrides: [
      authOverride(FakeAuthNotifier.guest()),
      selectedLanguageProvider.overrideWithValue('ur'),
      guestServiceProvider
          .overrideWithValue(GuestService(AdapterDioClient(adapter))),
      // Signed-in calls would fail loudly: this Dio has no routes.
      poetServiceProvider.overrideWith((ref) => PoetService(Dio(), ref)),
    ]);
    addTearDown(container.dispose);
    return container;
  }

  Future<PoetsPaginationNotifier> loaded(ProviderContainer c) async {
    final notifier = c.read(poetsPaginationProvider.notifier);
    await pumpEventQueue();
    return notifier;
  }

  List<int> requestedPages() => [
        for (final r in adapter.requestsTo('/api/guest/poets'))
          r.queryParameters['page'] as int,
      ];

  setUp(() => adapter = FakeDioAdapter());

  test('regression: stops at the server\'s last page (4), no duplicates',
      () async {
    adapter.on('GET', '/api/guest/poets', clampedGuestPoetsRoute(total: 120));
    final c = guestContainer();
    final notifier = await loaded(c);

    for (var i = 0; i < 8; i++) {
      await notifier.loadMore();
    }

    final state = c.read(poetsPaginationProvider);
    expect(requestedPages(), [0, 1, 2, 3, 4]);
    expect(state.hasMore, isFalse);
    final ids = state.poets.map((p) => p.publicId).toList();
    expect(ids, hasLength(50));
    expect(ids.toSet(), hasLength(50));
  });

  test('a poet repeated on the next page is listed once', () async {
    adapter.on('GET', '/api/guest/poets', (options) {
      final page = options.queryParameters['page'] as int;
      final ids = page == 0 ? ['a', 'b'] : ['b', 'c'];
      return FakeReply(
        200,
        guestPoetPage(ids, page: page, totalElements: 4, size: 2),
      );
    });
    final c = guestContainer();
    final notifier = await loaded(c);
    await notifier.loadMore();

    expect(c.read(poetsPaginationProvider).poets.map((p) => p.publicId),
        ['a', 'b', 'c']);
  });

  test('a page that adds nothing new ends paging', () async {
    adapter.on('GET', '/api/guest/poets', (options) {
      final page = options.queryParameters['page'] as int;
      return FakeReply(
        200,
        guestPoetPage(['a', 'b'], page: page, totalElements: 6, size: 2),
      );
    });
    final c = guestContainer();
    final notifier = await loaded(c);
    await notifier.loadMore();
    await notifier.loadMore();

    expect(requestedPages(), [0, 1]);
    expect(c.read(poetsPaginationProvider).hasMore, isFalse);
  });
}
