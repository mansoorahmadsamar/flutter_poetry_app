import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_poetry_app/features/search/models/global_search_state.dart';
import 'package:flutter_poetry_app/features/search/models/search_models.dart';
import 'package:flutter_poetry_app/features/search/widgets/app_search_couplet_card.dart';

import '../helpers/search_test_harness.dart';

/// Regression for "data comes in search results, but when I click it doesn't
/// go anywhere": every result type, in "All" and in each tab, either opens
/// the right screen with the right id or is rendered as not tappable.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  final couplets = coupletVariants();

  /// Real Urdu results + couplet variants + synthetic categories/tags.
  UnifiedSearchResponse fullResults() {
    final real = realUrduSearchResponse();
    return real.copyWith(
      couplets: [couplets.withPoem, couplets.legacyNested, couplets.withoutPoem],
      coupletCount: 3,
      categories: const [urduCategory],
      categoryCount: 1,
      tags: const [urduTag, romanTag, placeholderSlugTag],
      tagCount: 3,
      totalResults: real.totalResults + 4,
    );
  }

  Finder byKey(String key) => find.byKey(ValueKey(key));

  Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
    expect(finder, findsOneWidget);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  group('"All" preview results', () {
    testWidgets('poet avatar opens /main/poets/:publicId', (tester) async {
      final results = fullResults();
      final poet = results.poets.first;
      final app = await pumpSearchScreen(tester, state: resultsState(results));

      await tapAndSettle(tester, byKey('search-poet-${poet.publicId}'));

      expect(currentPath(app.router), '/main/poets/${poet.publicId}');
      expect(find.text('poet:${poet.publicId}'), findsOneWidget);
    });

    testWidgets('regression: poem card opens /main/poems/:publicId',
        (tester) async {
      final results = fullResults();
      final poem = results.poems.first;
      final app = await pumpSearchScreen(tester, state: resultsState(results));

      await tapAndSettle(tester, byKey('search-poem-${poem.publicId}'));

      expect(currentPath(app.router), '/main/poems/${poem.publicId}');
      expect(find.text('poem:${poem.publicId}'), findsOneWidget);
    });

    testWidgets(
        'regression: couplet card opens its parent poem, not the couplet id',
        (tester) async {
      final couplet = couplets.withPoem;
      final app =
          await pumpSearchScreen(tester, state: resultsState(fullResults()));

      await tapAndSettle(tester, byKey('search-couplet-${couplet.publicId}'));

      expect(currentPath(app.router), '/main/poems/${couplet.poemPublicId}');
      expect(currentPath(app.router), isNot(contains(couplet.publicId)));
      expect(find.text('poem:${couplet.poemPublicId}'), findsOneWidget);
    });

    testWidgets('couplet with only the legacy nested poem opens that poem',
        (tester) async {
      final couplet = couplets.legacyNested;
      final app =
          await pumpSearchScreen(tester, state: resultsState(fullResults()));

      await tapAndSettle(tester, byKey('search-couplet-${couplet.publicId}'));

      expect(currentPath(app.router), '/main/poems/${couplet.poem!.publicId}');
    });

    testWidgets(
        'couplet without a poem id has no chevron and does not navigate',
        (tester) async {
      final couplet = couplets.withoutPoem;
      final app =
          await pumpSearchScreen(tester, state: resultsState(fullResults()));
      final card = byKey('search-couplet-${couplet.publicId}');

      expect(
        find.descendant(
          of: card,
          matching: find.byKey(AppSearchCoupletCard.chevronKey),
        ),
        findsNothing,
      );
      // ...while openable couplets show one.
      expect(
        find.descendant(
          of: byKey('search-couplet-${couplets.withPoem.publicId}'),
          matching: find.byKey(AppSearchCoupletCard.chevronKey),
        ),
        findsOneWidget,
      );

      await tapAndSettle(tester, card);
      expect(currentPath(app.router), '/search');
    });

    testWidgets('regression: category chip searches for the category name',
        (tester) async {
      final app =
          await pumpSearchScreen(tester, state: resultsState(fullResults()));

      await tapAndSettle(tester, byKey('search-category-${urduCategory.publicId}'));

      expect(app.notifier.searches, [
        (query: urduCategory.name, segment: DiscoverSegment.all),
      ]);
      expect(currentPath(app.router), '/search');
    });

    testWidgets('regression: Urdu tag chip opens /hashtags/:slug',
        (tester) async {
      final app =
          await pumpSearchScreen(tester, state: resultsState(fullResults()));

      await tapAndSettle(tester, byKey('search-tag-${urduTag.publicId}'));

      expect(currentPath(app.router), '/hashtags/${urduTag.slug}');
      // The destination receives the decoded Urdu slug.
      expect(find.text('hashtag:${urduTag.slug}'), findsOneWidget);
    });

    testWidgets('Roman tag chip opens /hashtags/:slug', (tester) async {
      final app =
          await pumpSearchScreen(tester, state: resultsState(fullResults()));

      await tapAndSettle(tester, byKey('search-tag-${romanTag.publicId}'));

      expect(currentPath(app.router), '/hashtags/ishq');
    });

    testWidgets('a tag whose slug is "-" is not tappable', (tester) async {
      final app =
          await pumpSearchScreen(tester, state: resultsState(fullResults()));
      final chip = byKey('search-tag-${placeholderSlugTag.publicId}');

      expect(
        find.descendant(of: chip, matching: find.byType(InkWell)),
        findsNothing,
      );
      await tapAndSettle(tester, chip);
      expect(currentPath(app.router), '/search');
    });

    testWidgets('related search chip runs that search', (tester) async {
      final related = RelatedSearchesResponse(
        query: 'دل',
        relatedSearches: const [
          TrendingSearch(query: 'دل نادان', normalizedQuery: 'دل نادان'),
        ],
        timeWindow: '30d',
      );
      final app = await pumpSearchScreen(
        tester,
        state: resultsState(fullResults(), related: related),
      );

      await tapAndSettle(tester, find.text('دل نادان'));

      expect(app.notifier.searches.single.query, 'دل نادان');
    });

    testWidgets('Urdu renders RTL, English renders LTR, both navigate',
        (tester) async {
      for (final (lang, dir) in [
        ('ur', TextDirection.rtl),
        ('en', TextDirection.ltr),
      ]) {
        final results = fullResults();
        final poem = results.poems.first;
        final app = await pumpSearchScreen(
          tester,
          state: resultsState(results),
          languageCode: lang,
        );
        final card = byKey('search-poem-${poem.publicId}');
        expect(Directionality.of(tester.element(card)), dir, reason: lang);

        await tapAndSettle(tester, card);
        expect(currentPath(app.router), '/main/poems/${poem.publicId}',
            reason: lang);
      }
    });
  });

  group('filtered tabs', () {
    testWidgets('شعراء tab: poet card opens /main/poets/:publicId',
        (tester) async {
      final results = fullResults();
      final poet = results.poets.last;
      final app = await pumpSearchScreen(
        tester,
        state: resultsState(lastPage(results), segment: DiscoverSegment.poets),
      );

      await tapAndSettle(tester, byKey('search-poet-${poet.publicId}'));

      expect(currentPath(app.router), '/main/poets/${poet.publicId}');
    });

    testWidgets('غزلیں tab: poem card opens /main/poems/:publicId',
        (tester) async {
      final results = fullResults();
      final poem = results.poems.last;
      final app = await pumpSearchScreen(
        tester,
        state: resultsState(lastPage(results), segment: DiscoverSegment.poems),
      );

      await tapAndSettle(tester, byKey('search-poem-${poem.publicId}'));

      expect(currentPath(app.router), '/main/poems/${poem.publicId}');
    });

    testWidgets('regression: اشعار tab: couplet opens its parent poem',
        (tester) async {
      final couplet = couplets.withPoem;
      final app = await pumpSearchScreen(
        tester,
        state: resultsState(lastPage(fullResults()), segment: DiscoverSegment.verses),
      );

      await tapAndSettle(tester, byKey('search-couplet-${couplet.publicId}'));

      expect(currentPath(app.router), '/main/poems/${couplet.poemPublicId}');
    });

    testWidgets('اشعار tab: couplet without a poem id is inert',
        (tester) async {
      final couplet = couplets.withoutPoem;
      final app = await pumpSearchScreen(
        tester,
        state: resultsState(lastPage(fullResults()), segment: DiscoverSegment.verses),
      );
      final card = byKey('search-couplet-${couplet.publicId}');

      expect(
        find.descendant(
          of: card,
          matching: find.byKey(AppSearchCoupletCard.chevronKey),
        ),
        findsNothing,
      );
      await tapAndSettle(tester, card);
      expect(currentPath(app.router), '/search');
    });

    testWidgets('regression: زمرے tab: category item searches for its name',
        (tester) async {
      final app = await pumpSearchScreen(
        tester,
        state: resultsState(lastPage(fullResults()), segment: DiscoverSegment.categories),
      );

      await tapAndSettle(tester, byKey('search-category-${urduCategory.publicId}'));

      expect(app.notifier.searches, [
        (query: urduCategory.name, segment: DiscoverSegment.all),
      ]);
    });
  });

  group('guest mode', () {
    /// Shaped exactly like SearchService.searchUnified's guest branch:
    /// only /api/guest/poems/search + /api/guest/poets/search results.
    UnifiedSearchResponse guestResults() {
      final real = realUrduSearchResponse();
      return UnifiedSearchResponse(
        totalResults: real.poems.length + real.poets.length,
        poemCount: real.poems.length,
        poetCount: real.poets.length,
        poems: real.poems,
        poets: real.poets,
        totalPoems: real.totalPoems,
        totalPoets: real.totalPoets,
        hasMorePoems: true,
        hasMorePoets: true,
      );
    }

    testWidgets('only poem and poet results show, and both navigate',
        (tester) async {
      final results = guestResults();
      final poem = results.poems.first;
      final poet = results.poets.first;
      final app = await pumpSearchScreen(tester, state: resultsState(results));

      expect(find.byType(AppSearchCoupletCard), findsNothing);
      expect(find.text('زمرے'), findsOneWidget); // the tab label only
      expect(find.text('ٹیگز'), findsNothing);

      await tapAndSettle(tester, byKey('search-poem-${poem.publicId}'));
      expect(currentPath(app.router), '/main/poems/${poem.publicId}');

      app.router.pop();
      await tester.pumpAndSettle();
      expect(currentPath(app.router), '/search');

      await tapAndSettle(tester, byKey('search-poet-${poet.publicId}'));
      expect(currentPath(app.router), '/main/poets/${poet.publicId}');
    });
  });
}
