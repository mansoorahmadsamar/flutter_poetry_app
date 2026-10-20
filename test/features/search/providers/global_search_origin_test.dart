import 'package:flutter_poetry_app/features/search/models/global_search_state.dart';
import 'package:flutter_poetry_app/features/search/models/search_origin.dart';
import 'package:flutter_poetry_app/features/search/providers/global_search_provider.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_dio_adapter.dart';
import '../helpers/fake_search_backend.dart';

/// T-183: every `/api/search` request carries `origin`; further pages and
/// re-runs carry the origin of the search they belong to.
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

  List<Object?> origins() =>
      [for (final r in backend.searches) r.queryParameters['origin']];

  test('each origin is sent as the `origin` query parameter', () async {
    for (final origin in SearchOrigin.values) {
      await notifier.executeSearch(query: 'jigar ${origin.name}', origin: origin);
    }
    expect(origins(), ['typed', 'suggestion', 'history', 'trending', 'browse']);
    // The other parameters are unchanged.
    expect(backend.searches.first.queryParameters,
        containsPair('type', 'all'));
  });

  test('a new query without an origin is "typed"', () async {
    await notifier.executeSearch(query: 'jigar');
    expect(origins(), ['typed']);
  });

  test('load-more pages carry the origin of their search; tab switches send '
      'nothing', () async {
    await notifier.executeSearch(query: 'jigar', origin: SearchOrigin.trending);
    notifier.setActiveSegment(DiscoverSegment.poems);
    await pumpEventQueue();
    expect(backend.searches, hasLength(1), reason: 'tab switch: no request');

    await notifier.loadMore();
    expect(backend.searches, hasLength(2));
    expect(backend.searches.last.queryParameters['type'], 'poems_only');
    expect(origins(), ['trending', 'trending']);
  });

  test('a retry after a failure keeps the original origin', () async {
    backend.onSearch = (_) => const FakeReply(503, {'success': false});
    await notifier.executeSearch(query: 'jigar', origin: SearchOrigin.history);
    expect(notifier.state.mode, SearchMode.error);

    backend.onSearch = null;
    await notifier.executeSearch(); // the error screen's retry button
    expect(notifier.state.mode, SearchMode.results);
    expect(origins(), ['history', 'history']);
  });

  test('a tab switch that has to re-search keeps the original origin',
      () async {
    backend.onSearch = (_) => const FakeReply(503, {'success': false});
    await notifier.executeSearch(query: 'jigar', origin: SearchOrigin.browse);

    backend.onSearch = null;
    notifier.setActiveSegment(DiscoverSegment.poets);
    await pumpEventQueue();
    expect(origins(), ['browse', 'browse']);
  });

  test('a new search after paging starts with its own origin', () async {
    await notifier.executeSearch(query: 'jigar', origin: SearchOrigin.trending);
    await notifier.executeSearch(query: 'dil', origin: SearchOrigin.typed);
    notifier.setActiveSegment(DiscoverSegment.poems);
    await notifier.loadMore();
    expect(origins(), ['trending', 'typed', 'typed']);
  });
}
