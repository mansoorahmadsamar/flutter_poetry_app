import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/providers/poet_providers.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/providers/poet_search_pagination_provider.dart';
import 'package:flutter_poetry_app/features/search/widgets/search_results_grid.dart';

import '../../../helpers/fake_poet_search_service.dart';

Future<FakePoetSearchService> _pumpSearchedGrid(
  WidgetTester tester, {
  required int total,
}) async {
  late FakePoetSearchService service;
  final container = ProviderContainer(overrides: [
    selectedLanguageProvider.overrideWithValue('en'),
    poetServiceProvider.overrideWith(
        (ref) => service = FakePoetSearchService(ref, total: total)),
  ]);
  addTearDown(container.dispose);

  // The grid is a sliver inside the screen's CustomScrollView, as in
  // PoetsSearchScreen.
  await tester.pumpWidget(UncontrolledProviderScope(
    container: container,
    child: const MaterialApp(
      home: Scaffold(
        body: CustomScrollView(slivers: [SearchResultsGrid()]),
      ),
    ),
  ));
  await tester.runAsync(() =>
      container.read(poetSearchPaginationProvider.notifier).search('ghalib'));
  await tester.pump();
  return service;
}

Future<void> _scrollToEnd(WidgetTester tester) async {
  await tester.fling(
      find.byType(CustomScrollView), const Offset(0, -5000), 3000);
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('SearchResultsGrid pagination', () {
    testWidgets('regression: scrolling to the end loads page 2',
        (tester) async {
      final service = await _pumpSearchedGrid(tester, total: 25);
      expect(service.requestedPages, [0]);
      expect(find.text('Found 25 poets'), findsOneWidget);

      await _scrollToEnd(tester);

      // The fling may carry on past the new end and fetch page 3 as well;
      // what matters is that page 2 was requested, in order, once.
      expect(service.requestedPages.take(2), [0, 1]);
      expect(service.requestedPages.toSet(),
          hasLength(service.requestedPages.length));
    });

    testWidgets('keeps paging to the last page, once per page, then stops',
        (tester) async {
      final service = await _pumpSearchedGrid(tester, total: 25);

      for (var i = 0; i < 5; i++) {
        await _scrollToEnd(tester);
      }

      expect(service.requestedPages, [0, 1, 2]);
      expect(find.text('No more results'), findsOneWidget);
    });

    testWidgets('a single page never requests more', (tester) async {
      final service = await _pumpSearchedGrid(tester, total: 6);
      await _scrollToEnd(tester);
      expect(service.requestedPages, [0]);
      expect(find.text('No more results'), findsOneWidget);
    });
  });
}
