import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_poetry_app/features/discover/models/discover_bundle_model.dart';
import 'package:flutter_poetry_app/features/discover/services/discover_service.dart';
import 'package:flutter_poetry_app/features/search/models/global_search_state.dart';
import 'package:flutter_poetry_app/features/search/models/search_models.dart';
import 'package:flutter_poetry_app/features/search/providers/global_search_provider.dart';
import 'package:flutter_poetry_app/features/search/services/search_history_service.dart';
import 'package:flutter_poetry_app/features/search/services/search_service.dart';

import '../helpers/search_test_harness.dart';

void main() {
  group('GlobalSearchNotifier.executeSearch', () {
    late _RecordingSearchService service;
    late GlobalSearchNotifier notifier;

    setUp(() {
      service = _RecordingSearchService(realUrduSearchResponse());
      notifier = GlobalSearchNotifier(
        service,
        _MemoryHistoryService(),
        _IdleDiscoverService(),
        'ur',
      );
    });

    tearDown(() => notifier.dispose());

    test('segment: switches tab in the same update, with one request',
        () async {
      notifier.setActiveSegment(DiscoverSegment.categories); // idle: no search
      expect(service.queries, isEmpty);

      await notifier.executeSearch(query: 'غزل', segment: DiscoverSegment.all);

      expect(notifier.state.activeSegment, DiscoverSegment.all);
      expect(notifier.state.currentQuery, 'غزل');
      expect(notifier.state.mode, SearchMode.results);
      expect(notifier.state.unifiedResults, isNotNull);
      // Only the new query was searched — the old one was not re-run.
      expect(service.queries, ['غزل']);
    });

    test('without segment: keeps the active tab', () async {
      notifier.setActiveSegment(DiscoverSegment.poems);

      await notifier.executeSearch(query: 'دل');

      expect(notifier.state.activeSegment, DiscoverSegment.poems);
      expect(service.queries, ['دل']);
    });

    test('normalises the query sent to the API (diacritics)', () async {
      await notifier.executeSearch(query: 'دِل');

      expect(service.queries, ['دل']);
      expect(notifier.state.currentQuery, 'دِل'); // shown as typed
    });
  });
}

class _RecordingSearchService implements SearchService {
  _RecordingSearchService(this.response);

  final UnifiedSearchResponse response;
  final queries = <String>[];

  @override
  Future<UnifiedSearchResponse> searchUnified({
    required String query,
    String type = 'all',
    String lang = 'ur',
    int page = 0,
    int size = 10,
  }) async {
    queries.add(query);
    return response;
  }

  @override
  Future<RelatedSearchesResponse> getRelatedSearches({
    required String query,
    int limit = 5,
  }) async =>
      RelatedSearchesResponse(query: query, timeWindow: '30d');

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

class _MemoryHistoryService implements SearchHistoryService {
  final _history = <String>[];

  @override
  Future<List<String>> getHistory() async => List.of(_history);

  @override
  Future<void> addSearch(String query) async => _history.insert(0, query);

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

class _IdleDiscoverService implements DiscoverService {
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
