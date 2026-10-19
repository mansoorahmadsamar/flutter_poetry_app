import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_poetry_app/features/search/models/global_search_state.dart';
import 'package:flutter_poetry_app/features/search/providers/global_search_provider.dart';

import '../../../helpers/fake_dio_adapter.dart';
import '../helpers/fake_search_backend.dart';

/// T-074: every tab tap used to re-run the search — one more `/api/search`
/// (a `search_queries` row that inflates trending) and one more
/// `/api/search/related` per tap.
void main() {
  late FakeSearchBackend backend;
  late GlobalSearchNotifier notifier;

  setUp(() {
    backend = FakeSearchBackend();
    notifier = backend.createNotifier();
  });

  tearDown(() {
    notifier.dispose();
    backend.dispose();
  });

  group('GlobalSearchNotifier.setActiveSegment', () {
    test('regression: switching tabs for the same query makes no request',
        () async {
      await notifier.executeSearch(query: 'jigar');
      expect(backend.searches, hasLength(1));
      expect(backend.relatedRequests, hasLength(1));
      final loaded = notifier.state.unifiedResults;

      for (final segment in [
        DiscoverSegment.poets,
        DiscoverSegment.poems,
        DiscoverSegment.verses,
        DiscoverSegment.categories,
        DiscoverSegment.all,
        DiscoverSegment.poems,
      ]) {
        notifier.setActiveSegment(segment);
        await pumpEventQueue();
        expect(notifier.state.activeSegment, segment);
        expect(notifier.state.mode, SearchMode.results);
        expect(notifier.state.unifiedResults, same(loaded));
      }

      expect(backend.searches, hasLength(1), reason: 'no re-search per tab');
      expect(backend.relatedRequests, hasLength(1));
    });

    test('pages loaded in a tab survive switching away and back', () async {
      await notifier.executeSearch(query: 'jigar');
      final firstPagePoems = notifier.state.unifiedResults!.poems.length;

      notifier.setActiveSegment(DiscoverSegment.poems);
      await notifier.loadMore();
      expect(backend.searches, hasLength(2));
      expect(
          notifier.state.unifiedResults!.poems, hasLength(firstPagePoems * 2));

      notifier.setActiveSegment(DiscoverSegment.poets);
      notifier.setActiveSegment(DiscoverSegment.poems);
      await pumpEventQueue();

      expect(backend.searches, hasLength(2));
      expect(
          notifier.state.unifiedResults!.poems, hasLength(firstPagePoems * 2));

      // The next page continues where the last one stopped.
      await notifier.loadMore();
      expect(backend.searches, hasLength(3));
      expect(backend.searches.last.queryParameters['page'], 2);
      expect(backend.searches.last.queryParameters['type'], 'poems_only');
    });

    test('a tab with nothing loaded for the current query fetches it once',
        () async {
      backend.onSearch = (_) => const FakeReply.offline();
      await notifier.executeSearch(query: 'jigar');
      expect(notifier.state.mode, SearchMode.error);
      expect(notifier.state.unifiedResults, isNull);

      backend.onSearch = null;
      notifier.setActiveSegment(DiscoverSegment.poems);
      await pumpEventQueue();

      expect(backend.searches, hasLength(2));
      expect(notifier.state.mode, SearchMode.results);
      expect(notifier.state.activeSegment, DiscoverSegment.poems);
      expect(notifier.state.unifiedResults!.poems, isNotEmpty);

      notifier.setActiveSegment(DiscoverSegment.poets);
      await pumpEventQueue();
      expect(backend.searches, hasLength(2));
    });

    test('a new query is still searched', () async {
      await notifier.executeSearch(query: 'jigar');
      await notifier.executeSearch(query: 'dil');
      expect(backend.searches.map((r) => r.queryParameters['q']),
          ['jigar', 'dil']);
    });
  });

  group('GlobalSearchNotifier.loadMore paging', () {
    test(
        'regression: the next page uses the first page\'s size, so no '
        'results are skipped', () async {
      await notifier.executeSearch(query: 'jigar');
      notifier.setActiveSegment(DiscoverSegment.poems);
      await notifier.loadMore();

      final first = backend.searches.first.queryParameters;
      final next = backend.searches.last.queryParameters;
      expect(next['page'], 1);
      // page 1 at a different size than page 0 starts at the wrong offset
      // (backend: PageRequest.of(page, size)).
      expect(next['size'], first['size']);
    });

    test('a page that arrives after a new search is dropped', () async {
      await notifier.executeSearch(query: 'jigar');
      notifier.setActiveSegment(DiscoverSegment.poems);

      final held = Completer<FakeReply>();
      backend.onSearch = (_) => held.future;
      final staleLoad = notifier.loadMore();
      await pumpEventQueue();

      backend.onSearch = null;
      await notifier.executeSearch(query: 'dil');
      final fresh = notifier.state.unifiedResults;

      held.complete(backend.fixtureReply(backend.searches[1]));
      await staleLoad;

      expect(notifier.state.currentQuery, 'dil');
      expect(notifier.state.unifiedResults, same(fresh));
      expect(notifier.state.isLoadingMore, isFalse);
    });

    test('a search that finishes after a newer one is dropped', () async {
      final held = Completer<FakeReply>();
      backend.onSearch = (_) => held.future;
      final staleSearch = notifier.executeSearch(query: 'jigar');
      await pumpEventQueue();

      backend.onSearch = null;
      await notifier.executeSearch(query: 'dil');
      final fresh = notifier.state.unifiedResults;

      held.complete(backend.fixtureReply(backend.searches.first));
      await staleSearch;

      expect(notifier.state.currentQuery, 'dil');
      expect(notifier.state.unifiedResults, same(fresh));
      expect(notifier.state.mode, SearchMode.results);
    });
  });

  group('مصرعے tab (verse hits)', () {
    test('pages verse hits with type=verses_only and appends them', () async {
      await notifier.executeSearch(query: 'jigar');
      final firstPage = notifier.state.unifiedResults!.verses.length;
      expect(firstPage, greaterThan(0));

      notifier.setActiveSegment(DiscoverSegment.misras);
      await notifier.loadMore();

      final request = backend.searches.last.queryParameters;
      expect(request['type'], 'verses_only');
      expect(request['page'], 1);
      expect(notifier.state.unifiedResults!.verses, hasLength(firstPage * 2));
      expect(backend.searches, hasLength(2));
    });
  });
}
