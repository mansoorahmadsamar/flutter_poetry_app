import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_poetry_app/features/search/models/global_search_state.dart';
import 'package:flutter_poetry_app/features/search/models/search_models.dart';
import 'package:flutter_poetry_app/features/search/providers/global_search_provider.dart';
import 'package:flutter_poetry_app/features/search/services/search_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_search_backend.dart';

// testWidgets for its fake clock: the 300 ms debounce elapses with pump().

/// Answers each autocomplete call with a [Completer] the test controls.
class _HeldAutocomplete implements SearchService {
  final calls = <({String query, Completer<AutocompleteResponse> reply})>[];

  @override
  Future<AutocompleteResponse> getAutocomplete({
    required String query,
    String lang = 'ur',
    CancelToken? cancelToken,
  }) {
    final reply = Completer<AutocompleteResponse>();
    calls.add((query: query, reply: reply));
    return reply.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

const _dili = AutocompleteResponse(
  poets: [AutocompletePoet(publicId: 'p1', name: 'دلی والے')],
  totalCount: 1,
);

void main() {
  group('GlobalSearchNotifier autocomplete (T-182)', () {
    testWidgets(
        'suggestions for the typed query land; Roman text is sent as typed',
        (tester) async {
      final service = _HeldAutocomplete();
      final notifier = GlobalSearchNotifier(
          service, MemorySearchHistory(), IdleDiscoverService(), 'ur');

      notifier.onQueryChanged('  Dil ');
      await tester.pump(const Duration(milliseconds: 300));
      expect(service.calls.single.query, 'Dil');
      expect(notifier.state.mode, SearchMode.autocompleting);

      service.calls.single.reply.complete(_dili);
      await tester.pump();
      expect(notifier.state.autocompleteResults, _dili);
      expect(notifier.state.isLoadingAutocomplete, isFalse);
      notifier.dispose();
    });

    testWidgets(
        'a failure for an older query does not clear the current suggestions',
        (tester) async {
      final service = _HeldAutocomplete();
      final notifier = GlobalSearchNotifier(
          service, MemorySearchHistory(), IdleDiscoverService(), 'ur');

      notifier.onQueryChanged('دل');
      await tester.pump(const Duration(milliseconds: 300));
      notifier.onQueryChanged('دلی');
      await tester.pump(const Duration(milliseconds: 300));
      expect(service.calls.map((c) => c.query), ['دل', 'دلی']);

      service.calls[1].reply.complete(_dili);
      await tester.pump();
      service.calls[0].reply.completeError(Exception('500'));
      await tester.pump();

      expect(notifier.state.currentQuery, 'دلی');
      expect(notifier.state.autocompleteResults, _dili);
      notifier.dispose();
    });

    testWidgets(
        'a failure for the current query ends loading with no suggestions',
        (tester) async {
      final service = _HeldAutocomplete();
      final notifier = GlobalSearchNotifier(
          service, MemorySearchHistory(), IdleDiscoverService(), 'ur');

      notifier.onQueryChanged('دل');
      await tester.pump(const Duration(milliseconds: 300));
      service.calls.single.reply.completeError(Exception('parse'));
      await tester.pump();

      expect(notifier.state.isLoadingAutocomplete, isFalse);
      expect(notifier.state.autocompleteResults, isNull);
      notifier.dispose();
    });
  });
}
