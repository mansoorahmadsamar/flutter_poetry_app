import 'package:flutter/material.dart';
import 'package:flutter_poetry_app/core/providers/language_provider.dart';
import 'package:flutter_poetry_app/core/routing/app_router.dart';
import 'package:flutter_poetry_app/features/discover/models/discover_bundle_model.dart';
import 'package:flutter_poetry_app/features/search/models/global_search_state.dart';
import 'package:flutter_poetry_app/features/search/models/search_models.dart';
import 'package:flutter_poetry_app/features/search/models/search_origin.dart';
import 'package:flutter_poetry_app/features/search/providers/global_search_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../helpers/search_test_harness.dart';

/// T-183: every search entry point on the search screen passes why the user
/// searched, so the backend can tell typed searches from UI shortcuts.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  const category = ContentCard(
    type: 'CATEGORY',
    publicId: 'cat-ghazal',
    primaryText: 'غزل',
  );

  GlobalSearchState idleState() => GlobalSearchState(
        recentSearches: const ['پرانی تلاش'],
        trendingSearches: TrendingSearchesResponse(
          searches: const [
            TrendingSearch(query: 'Rubai', normalizedQuery: 'rubai'),
          ],
          totalCount: 1,
          timeframe: 'daily',
          period: 'daily',
        ),
        discoverBundle: const DiscoverBundle(
          trendingSearches: TrendingSearches(),
          editorsPicks: ContentSection(),
          recommended: ContentSection(),
          featuredPoets: ContentSection(),
          categories: ContentSection(items: [category]),
          language: 'ur',
        ),
      );

  SearchOrigin? lastOrigin(FakeGlobalSearchNotifier n) => n.searches.last.origin;

  group('search screen entry points send their origin', () {
    testWidgets('keyboard submit is "typed"', (tester) async {
      final app = await pumpSearchScreen(tester, state: idleState());

      await tester.enterText(find.byType(TextField), 'dil');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      expect(app.notifier.searches.single.query, 'dil');
      expect(lastOrigin(app.notifier), SearchOrigin.typed);
    });

    testWidgets('a recent search is "history"', (tester) async {
      final app = await pumpSearchScreen(tester, state: idleState());

      await tester.tap(find.text('پرانی تلاش'));
      await tester.pumpAndSettle();

      expect(app.notifier.searches.single.query, 'پرانی تلاش');
      expect(lastOrigin(app.notifier), SearchOrigin.history);
    });

    testWidgets('a trending search is "trending"', (tester) async {
      final app = await pumpSearchScreen(tester, state: idleState());

      await tester.tap(find.text('Rubai'));
      await tester.pumpAndSettle();

      expect(app.notifier.searches.single.query, 'Rubai');
      expect(lastOrigin(app.notifier), SearchOrigin.trending);
    });

    testWidgets('a category chip is "browse" (English UI)', (tester) async {
      final app = await pumpSearchScreen(tester,
          state: idleState(), languageCode: 'en');

      await tester.tap(find.text('غزل'));
      await tester.pumpAndSettle();

      expect(app.notifier.searches.single.query, 'غزل');
      expect(lastOrigin(app.notifier), SearchOrigin.browse);
    });

    testWidgets('a suggestion that runs a text search is "suggestion"',
        (tester) async {
      final app = await pumpSearchScreen(
        tester,
        state: const GlobalSearchState(
          mode: SearchMode.autocompleting,
          currentQuery: 'غز',
          autocompleteResults: AutocompleteResponse(categories: [urduCategory]),
        ),
      );

      await tester.tap(
          find.byKey(ValueKey('suggestion-category-${urduCategory.publicId}')));
      await tester.pumpAndSettle();

      expect(app.notifier.searches.single.query, urduCategory.name);
      expect(lastOrigin(app.notifier), SearchOrigin.suggestion);
    });

    testWidgets('the "Search for …" row is "typed"', (tester) async {
      final app = await pumpSearchScreen(
        tester,
        state: const GlobalSearchState(
          mode: SearchMode.autocompleting,
          currentQuery: 'دل',
          autocompleteResults: AutocompleteResponse(),
        ),
      );

      await tester.tap(find.text('تلاش کریں: "دل"'));
      await tester.pumpAndSettle();

      expect(lastOrigin(app.notifier), SearchOrigin.typed);
    });

    testWidgets('a related search is "browse"', (tester) async {
      final app = await pumpSearchScreen(
        tester,
        state: resultsState(
          lastPage(realUrduSearchResponse()),
          related: const RelatedSearchesResponse(
            query: 'دل',
            timeWindow: '30d',
            relatedSearches: [
              TrendingSearch(query: 'دل نادان', normalizedQuery: 'دل نادان'),
            ],
          ),
        ),
      );

      await tester.tap(find.text('دل نادان'));
      await tester.pumpAndSettle();

      expect(app.notifier.searches.single.query, 'دل نادان');
      expect(lastOrigin(app.notifier), SearchOrigin.browse);
    });
  });

  group('/search route extra', () {
    test('SearchRouteExtra.of carries the query and origin', () {
      expect(SearchRouteExtra.of('Rubai', SearchOrigin.trending),
          {'query': 'Rubai', 'origin': 'trending'});
    });

    test('a query without (or with an unknown) origin is "browse"', () {
      expect(SearchRouteExtra.originOf(null), SearchOrigin.browse);
      expect(SearchRouteExtra.originOf({'query': 'x'}), SearchOrigin.browse);
      expect(SearchRouteExtra.originOf({'query': 'x', 'origin': 'nope'}),
          SearchOrigin.browse);
    });

    Future<FakeGlobalSearchNotifier> pumpRoute(
        WidgetTester tester, Object? extra) async {
      // The app's real `/search` route, opened the way Discover opens it.
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final searchRoute = container
          .read(appRoutesProvider)
          .whereType<GoRoute>()
          .firstWhere((r) => r.path == '/search');
      final router = GoRouter(
        initialLocation: '/search',
        initialExtra: extra,
        routes: [searchRoute],
      );
      addTearDown(router.dispose);
      final notifier = FakeGlobalSearchNotifier(const GlobalSearchState());
      await tester.pumpWidget(ProviderScope(
        overrides: [
          globalSearchProvider.overrideWith((ref) => notifier),
          selectedLanguageProvider.overrideWithValue('ur'),
        ],
        child: MaterialApp.router(routerConfig: router),
      ));
      await tester.pumpAndSettle();
      return notifier;
    }

    testWidgets('a Discover trending chip opens /search as "trending"',
        (tester) async {
      final notifier = await pumpRoute(
          tester, SearchRouteExtra.of('Rubai', SearchOrigin.trending));

      expect(notifier.searches.single.query, 'Rubai');
      expect(notifier.searches.single.origin, SearchOrigin.trending);
    });

    testWidgets('an old-style {query} extra searches as "browse"',
        (tester) async {
      final notifier = await pumpRoute(tester, {'query': 'غزل'});

      expect(notifier.searches.single.query, 'غزل');
      expect(notifier.searches.single.origin, SearchOrigin.browse);
    });

    testWidgets('/search without a query searches nothing', (tester) async {
      final notifier = await pumpRoute(tester, null);
      expect(notifier.searches, isEmpty);
    });
  });
}
