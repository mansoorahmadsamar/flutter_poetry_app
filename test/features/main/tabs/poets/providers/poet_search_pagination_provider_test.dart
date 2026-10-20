import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/providers/poet_providers.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/providers/poet_search_pagination_provider.dart';

import '../../../../../helpers/fake_poet_search_service.dart';

(ProviderContainer, FakePoetSearchService Function()) _container(
  FakePoetSearchService Function(Ref ref) build,
) {
  FakePoetSearchService? service;
  final container = ProviderContainer(overrides: [
    selectedLanguageProvider.overrideWithValue('ur'),
    poetServiceProvider.overrideWith((ref) => service = build(ref)),
  ]);
  return (container, () => service!);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('PoetSearchPaginationNotifier.loadMore', () {
    test('appends the next page and stops at the last page', () async {
      final (container, service) =
          _container((ref) => FakePoetSearchService(ref, total: 25));
      addTearDown(container.dispose);
      final notifier = container.read(poetSearchPaginationProvider.notifier);

      await notifier.search('ghalib');
      await notifier.loadMore();
      await notifier.loadMore();
      await notifier.loadMore(); // past the last page: no request

      final state = container.read(poetSearchPaginationProvider);
      expect(service().requestedPages, [0, 1, 2]);
      expect(state.results, hasLength(25));
      expect(state.hasMore, isFalse);
      expect(state.currentPage, 2);
    });

    test('concurrent calls request the next page only once', () async {
      final (container, service) =
          _container((ref) => FakePoetSearchService(ref, total: 25));
      addTearDown(container.dispose);
      final notifier = container.read(poetSearchPaginationProvider.notifier);

      await notifier.search('ghalib');
      await Future.wait([notifier.loadMore(), notifier.loadMore()]);

      expect(service().requestedPages, [0, 1]);
      expect(container.read(poetSearchPaginationProvider).results,
          hasLength(20));
    });

    test('a poet repeated on the next page is shown once', () async {
      final (container, _) = _container((ref) => FakePoetSearchService(
            ref,
            total: 20,
            pages: {
              1: [fakePoet(9), for (var i = 10; i < 19; i++) fakePoet(i)],
            },
          ));
      addTearDown(container.dispose);
      final notifier = container.read(poetSearchPaginationProvider.notifier);

      await notifier.search('ghalib');
      await notifier.loadMore();

      final ids = container
          .read(poetSearchPaginationProvider)
          .results
          .map((p) => p.publicId)
          .toList();
      expect(ids.toSet(), hasLength(ids.length));
      expect(ids, hasLength(19));
    });

    test('a page with nothing new ends pagination instead of looping',
        () async {
      // Guest search clamps to page 4, so a later page can repeat page 4.
      final (container, service) = _container((ref) => FakePoetSearchService(
            ref,
            total: 100,
            pages: {
              1: [for (var i = 0; i < 10; i++) fakePoet(i)],
            },
          ));
      addTearDown(container.dispose);
      final notifier = container.read(poetSearchPaginationProvider.notifier);

      await notifier.search('ghalib');
      await notifier.loadMore();
      await notifier.loadMore();

      expect(service().requestedPages, [0, 1]);
      expect(container.read(poetSearchPaginationProvider).hasMore, isFalse);
    });

    test('a page still loading when a new search starts is discarded',
        () async {
      final (container, service) =
          _container((ref) => FakePoetSearchService(ref, total: 25));
      addTearDown(container.dispose);
      final notifier = container.read(poetSearchPaginationProvider.notifier);

      await notifier.search('ghalib');
      final gate = service().laterPagesGate = Completer<void>();
      final stalePage = notifier.loadMore(); // 'ghalib' page 2, held
      await notifier.search('faiz');
      gate.complete(); // the stale page arrives after the new search
      await stalePage;

      var state = container.read(poetSearchPaginationProvider);
      expect(state.currentQuery, 'faiz');
      expect(state.results, hasLength(10));
      expect(state.isLoadingMore, isFalse);
      expect(state.currentPage, 0);

      // Paging still works for the new search.
      await notifier.loadMore();
      state = container.read(poetSearchPaginationProvider);
      expect(state.results, hasLength(20));
      expect(service().requestedPages, [0, 1, 0, 1]);
    });
  });
}
