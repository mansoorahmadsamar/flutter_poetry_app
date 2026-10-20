import 'package:flutter/material.dart';
import 'package:flutter_poetry_app/core/design_system/app_typography.dart';
import 'package:flutter_poetry_app/features/hashtags/models/couplet_theme.dart';
import 'package:flutter_poetry_app/features/hashtags/widgets/couplet_theme_chips.dart';
import 'package:flutter_poetry_app/features/search/models/global_search_state.dart';
import 'package:flutter_poetry_app/features/search/models/search_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../helpers/fixtures.dart';
import '../helpers/search_test_harness.dart';

/// Couplet and verse search results: theme chips (open the theme's hashtag
/// page) and opening the parent poem at the couplet (`?couplet=`).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  final ranked = parseCoupletThemes(
      loadJsonFixture('themes/couplet_themes.json')['ranked']);
  final couplets = coupletVariants();
  final jigar = realRomanJigarResponse();

  /// Production couplet with a poem id (number 4) and themes.
  final themedCouplet = couplets.withPoem.copyWith(themes: ranked);

  /// Production verse (couplet 1 of its poem) with themes.
  final themedVerse = jigar.verses.first.copyWith(themes: ranked);

  UnifiedSearchResponse results({bool themed = true}) => lastPage(
        realUrduSearchResponse().copyWith(
          couplets: [themed ? themedCouplet : couplets.withPoem],
          coupletCount: 1,
          verses: [themed ? themedVerse : jigar.verses.first],
          verseCount: 1,
        ),
      );

  Finder coupletCard(CoupletSearchResult c) =>
      find.byKey(ValueKey('search-couplet-${c.publicId}'));
  Finder verseCard(VerseSearchResult v) =>
      find.byKey(ValueKey('search-verse-${v.resultKey}'));
  Finder chipIn(Finder card, String slug) => find.descendant(
      of: card, matching: find.byKey(CoupletThemeChips.chipKey(slug)));

  /// Taps [card] near its top corner — on the card, never on a theme chip.
  Future<void> tapCard(WidgetTester tester, Finder card) async {
    await tester.tapAt(tester.getTopLeft(card) + const Offset(40, 24));
    await tester.pumpAndSettle();
  }

  group('theme chips on search results', () {
    testWidgets('Urdu: couplet and verse cards show Urdu chips (Nastaliq, RTL)',
        (tester) async {
      await pumpSearchScreen(tester, state: resultsState(results()));

      for (final card in [coupletCard(themedCouplet), verseCard(themedVerse)]) {
        expect(chipIn(card, 'hijr'), findsOneWidget);
        final text = tester.widget<Text>(find.descendant(
            of: chipIn(card, 'hijr'), matching: find.byType(Text)));
        expect(text.data, '#ہجر');
        expect(text.style?.fontFamily, AppTypography.urduFontFamily);
        expect(Directionality.of(tester.element(chipIn(card, 'hijr'))),
            TextDirection.rtl);
      }
    });

    testWidgets('English: English chips, LTR', (tester) async {
      await pumpSearchScreen(tester,
          state: resultsState(results()), languageCode: 'en');

      final chip = chipIn(coupletCard(themedCouplet), 'hijr');
      expect(find.descendant(of: chip, matching: find.text('#Separation')),
          findsOneWidget);
      expect(Directionality.of(tester.element(chip)), TextDirection.ltr);
    });

    for (final lang in ['ur', 'en']) {
      testWidgets('$lang: a couplet chip opens /hashtags/:slug, not the poem',
          (tester) async {
        final app = await pumpSearchScreen(tester,
            state: resultsState(results()), languageCode: lang);

        await tester.tap(chipIn(coupletCard(themedCouplet), 'yaad'));
        await tester.pumpAndSettle();

        expect(currentPath(app.router), '/hashtags/yaad');
        expect(find.text('hashtag:yaad'), findsOneWidget);
      });
    }

    testWidgets('a verse chip in the مصرعے tab opens its hashtag page',
        (tester) async {
      final app = await pumpSearchScreen(tester,
          state: resultsState(results(), segment: DiscoverSegment.misras));

      await tester.tap(chipIn(verseCard(themedVerse), 'intezar'));
      await tester.pumpAndSettle();

      expect(currentPath(app.router), '/hashtags/intezar');
    });

    testWidgets('production results (no themes): no chips', (tester) async {
      await pumpSearchScreen(tester,
          state: resultsState(results(themed: false)));

      expect(find.byType(CoupletThemeChips), findsNWidgets(2));
      expect(find.byKey(CoupletThemeChips.chipKey('hijr')), findsNothing);
    });
  });

  group('search results open the poem at the couplet', () {
    testWidgets('a couplet result opens /main/poems/:poemId?couplet=<n>',
        (tester) async {
      final app =
          await pumpSearchScreen(tester, state: resultsState(results()));

      await tapCard(tester, coupletCard(themedCouplet));

      expect(
          currentPath(app.router), '/main/poems/${themedCouplet.poemPublicId}');
      expect(app.router.state.uri.queryParameters, {'couplet': '4'});
    });

    testWidgets('a verse result opens its poem at its couplet (English UI)',
        (tester) async {
      final app = await pumpSearchScreen(tester,
          state: resultsState(results(), segment: DiscoverSegment.misras),
          languageCode: 'en');

      await tapCard(tester, verseCard(themedVerse));

      expect(
          currentPath(app.router), '/main/poems/${themedVerse.poemPublicId}');
      expect(app.router.state.uri.queryParameters,
          {'couplet': '${themedVerse.verse.coupletNumber}'});
    });

    testWidgets(
        'a couplet with an unknown number (0) opens the plain poem link',
        (tester) async {
      final unknown = couplets.withPoem.copyWith(coupletNumber: 0);
      final app = await pumpSearchScreen(tester,
          state: resultsState(lastPage(realUrduSearchResponse()
              .copyWith(couplets: [unknown], coupletCount: 1))));

      await tapCard(tester, coupletCard(unknown));

      expect(currentPath(app.router), '/main/poems/${unknown.poemPublicId}');
      expect(app.router.state.uri.queryParameters, isEmpty);
    });
  });
}
