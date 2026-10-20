import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_poetry_app/core/providers/language_provider.dart';
import 'package:flutter_poetry_app/features/search/providers/global_search_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../helpers/fake_dio_adapter.dart';
import '../helpers/fake_search_backend.dart';
import '../helpers/search_test_harness.dart';

/// T-182 (client half): typing on the search screen shows the poets, poems,
/// tags and categories the backend suggests — through the real notifier,
/// service and screen, with `/api/search/autocomplete` answered from a
/// fixture in the backend's AutocompleteSuggestions shape.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  Future<({GoRouter router, FakeSearchBackend backend})> pumpLive(
    WidgetTester tester, {
    String lang = 'ur',
    bool signedIn = true,
    FutureOr<FakeReply> Function(dynamic)? autocomplete,
  }) async {
    tester.view.physicalSize = const Size(900, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final backend = FakeSearchBackend(signedIn: signedIn);
    backend.adapter.on(
      'GET',
      '/api/search/autocomplete',
      (o) => autocomplete?.call(o) ??
          FakeReply(200, searchFixture('autocomplete_dil_main.json')),
    );
    final notifier = backend.createNotifier(lang: lang);
    addTearDown(() {
      backend.dispose();
    });
    final router = buildSearchTestRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(ProviderScope(
      overrides: [
        globalSearchProvider.overrideWith((ref) => notifier),
        selectedLanguageProvider.overrideWithValue(lang),
      ],
      child: MaterialApp.router(routerConfig: router),
    ));
    await tester.pump();
    return (router: router, backend: backend);
  }

  /// Types [text], lets the 300 ms debounce fire and the (real) request
  /// finish, then settles the entrance animations.
  Future<void> type(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextField), text);
    await tester.pump(const Duration(milliseconds: 350));
    for (var i = 0; i < 50; i++) {
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump(const Duration(milliseconds: 20));
      if (find.byType(CircularProgressIndicator).evaluate().isEmpty &&
          find.textContaining('داغ').evaluate().isNotEmpty) {
        break;
      }
    }
    await tester.pumpAndSettle();
  }

  Finder byKey(String key) => find.byKey(ValueKey(key));

  testWidgets('regression: Urdu, signed in: every suggestion type renders',
      (tester) async {
    final app = await pumpLive(tester);
    await type(tester, 'دل');

    expect(app.backend.adapter.requestsTo('/api/search/autocomplete').single
        .queryParameters['q'], 'دل');
    // Group headers.
    for (final title in ['شعراء', 'کلام', 'ٹیگز', 'زمرے']) {
      expect(find.text(title), findsOneWidget, reason: title);
    }
    expect(find.text('داغ دہلوی'), findsOneWidget);
    expect(find.text('دلاور فگار'), findsOneWidget);
    expect(find.text('دل ناداں تجھے ہوا کیا ہے'), findsOneWidget);
    expect(find.text('مرزا غالب'), findsOneWidget, reason: 'poem subtitle');
    expect(find.text('دل کی بات'), findsOneWidget);
    expect(find.text('دل'), findsWidgets);
    expect(find.text('دل کی شاعری'), findsOneWidget);
    expect(find.text('42'), findsOneWidget, reason: 'category poem count');
    // Nothing shows the placeholder, and the untitled poem has no row.
    expect(find.text('-'), findsNothing);
    expect(byKey('suggestion-poem-poem-no-title'), findsNothing);
    expect(
        Directionality.of(tester.element(find.text('داغ دہلوی'))),
        TextDirection.rtl);
  });

  testWidgets('tapping a live poem suggestion opens the poem', (tester) async {
    final app = await pumpLive(tester);
    await type(tester, 'دل');

    await tester.tap(byKey('suggestion-poem-poem-dil-e-nadan'));
    await tester.pumpAndSettle();
    expect(currentPath(app.router), '/main/poems/poem-dil-e-nadan');
  });

  testWidgets('regression: a guest sees live suggestions too', (tester) async {
    final app = await pumpLive(tester, signedIn: false);
    await type(tester, 'دل');

    expect(app.backend.adapter.requestsTo('/api/search/autocomplete'),
        hasLength(1));
    expect(find.text('داغ دہلوی'), findsOneWidget);
  });

  testWidgets('English UI: suggestions render with English group titles',
      (tester) async {
    await pumpLive(tester, lang: 'en');
    await type(tester, 'دل');

    for (final title in ['Poets', 'Poems', 'Tags', 'Categories']) {
      expect(find.text(title), findsOneWidget, reason: title);
    }
    expect(find.text('Search for "دل"'), findsOneWidget);
    expect(
        Directionality.of(tester.element(find.text('Search for "دل"'))),
        TextDirection.ltr);
  });

  testWidgets('a server error leaves the "Search for" row, no spinner',
      (tester) async {
    await pumpLive(tester,
        autocomplete: (_) => const FakeReply(500, {'success': false}));
    await type(tester, 'دل');

    expect(find.text('تلاش کریں: "دل"'), findsOneWidget);
    expect(find.text('شعراء'), findsNothing);
  });
}
