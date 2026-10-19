import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_poetry_app/features/search/models/global_search_state.dart';
import 'package:flutter_poetry_app/features/search/models/search_models.dart';
import 'package:flutter_poetry_app/features/search/widgets/app_search_verse_card.dart';

import '../helpers/search_test_harness.dart';

/// T-073: `/api/search` returns `verses[]` (single matching lines) which the
/// app parsed but never showed, so a Roman query like `jigar` showed fewer
/// results than it had.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  final jigar = realRomanJigarResponse();
  final first = jigar.verses.first; // poem id present, poet fields "-"

  /// The backend after T-073: poet id/name on the verse too.
  final withPoet = jigar.verses[1].copyWith(
    poetPublicId: 'poet-jigar',
    poetName: 'جگر مراد آبادی',
  );

  /// A verse whose poem id came back as the `"-"` placeholder.
  final noPoem = VerseSearchResult.fromJson({
    'verse': {
      'publicId': 'verse-without-poem',
      'verseText': 'جگر کا خون',
      'romanizedText': 'jigar ka khoon',
    },
    'poemPublicId': '-',
    'poemTitle': '-',
    'poetPublicId': '-',
    'poetName': '-',
  });

  UnifiedSearchResponse results({List<VerseSearchResult>? verses}) {
    final list = verses ?? [first, withPoet, ...jigar.verses.skip(2)];
    return lastPage(jigar.copyWith(verses: list, verseCount: list.length));
  }

  Finder verseCard(VerseSearchResult v) =>
      find.byKey(ValueKey('search-verse-${v.resultKey}'));

  /// The text of the bold (highlighted) spans in [richText].
  String highlighted(WidgetTester tester, Finder richText) {
    final span = tester.widget<RichText>(richText).text as TextSpan;
    return [
      for (final child in span.children!.cast<TextSpan>())
        if (child.style?.fontWeight == FontWeight.w700) child.text,
    ].join('|');
  }

  Finder richTextIn(Finder card, String text) => find.descendant(
        of: card,
        matching: find.byWidgetPredicate(
          (w) => w is RichText && w.text.toPlainText() == text,
        ),
      );

  Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
    expect(finder, findsOneWidget);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  group('"All" preview: verse hits', () {
    testWidgets('regression: Roman "jigar" shows its verse hits',
        (tester) async {
      await pumpSearchScreen(
        tester,
        state: resultsState(results(), query: 'jigar'),
      );

      expect(find.text('مصرعے'), findsOneWidget);
      // Preview shows the first three lines.
      for (final v in results().verses.take(3)) {
        expect(verseCard(v), findsOneWidget);
      }
      expect(verseCard(results().verses[3]), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Roman query highlights the Roman line', (tester) async {
      await pumpSearchScreen(
        tester,
        state: resultsState(results(), query: 'jigar'),
      );

      final roman = find.descendant(
        of: verseCard(first),
        matching: find.byKey(AppSearchVerseCard.romanKey),
      );
      expect(roman, findsOneWidget);
      final romanText = richTextIn(verseCard(first), first.romanizedText!);
      expect(highlighted(tester, romanText), 'jigar|jigar');
      expect(
        tester.widget<RichText>(romanText).textDirection,
        TextDirection.ltr,
      );
    });

    testWidgets('Urdu query highlights the Urdu line, right-to-left',
        (tester) async {
      await pumpSearchScreen(
        tester,
        state: resultsState(results(), query: 'جگر'),
      );

      final urdu = richTextIn(verseCard(first), first.verse.text);
      expect(urdu, findsOneWidget);
      expect(highlighted(tester, urdu), 'جگر|جگر');
      expect(tester.widget<RichText>(urdu).textDirection, TextDirection.rtl);
    });

    testWidgets('English UI: LTR screen, the Urdu line stays RTL',
        (tester) async {
      await pumpSearchScreen(
        tester,
        state: resultsState(results(), query: 'jigar'),
        languageCode: 'en',
      );

      expect(find.text('Lines'), findsOneWidget);
      expect(
        Directionality.of(tester.element(verseCard(first))),
        TextDirection.ltr,
      );
      final urdu = richTextIn(verseCard(first), first.verse.text);
      expect(tester.widget<RichText>(urdu).textDirection, TextDirection.rtl);
    });

    testWidgets('shows poet name and poem title when the API sends them',
        (tester) async {
      await pumpSearchScreen(
        tester,
        state: resultsState(results(), query: 'jigar'),
      );

      expect(richTextIn(verseCard(withPoet), 'جگر مراد آبادی'), findsOneWidget);
      expect(
          richTextIn(verseCard(withPoet), withPoet.poemTitle!), findsOneWidget);
      // "-" poet fields render nothing, never a lone dash.
      expect(richTextIn(verseCard(first), '-'), findsNothing);
      expect(find.descendant(of: verseCard(first), matching: find.text('-')),
          findsNothing);
    });

    testWidgets('regression: tapping a verse opens its poem, not the verse',
        (tester) async {
      final app = await pumpSearchScreen(
        tester,
        state: resultsState(results(), query: 'jigar'),
      );

      await tapAndSettle(tester, verseCard(first));

      expect(currentPath(app.router), '/main/poems/${first.poemPublicId}');
      expect(currentPath(app.router), isNot(contains(first.verse.publicId!)));
      expect(find.text('poem:${first.poemPublicId}'), findsOneWidget);
    });

    testWidgets('verse with a "-" poem id has no chevron and does not navigate',
        (tester) async {
      final app = await pumpSearchScreen(
        tester,
        state: resultsState(results(verses: [noPoem, first]), query: 'jigar'),
      );

      expect(noPoem.poemIdToOpen, isNull);
      expect(
        find.descendant(
          of: verseCard(noPoem),
          matching: find.byKey(AppSearchVerseCard.chevronKey),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: verseCard(first),
          matching: find.byKey(AppSearchVerseCard.chevronKey),
        ),
        findsOneWidget,
      );

      await tapAndSettle(tester, verseCard(noPoem));
      expect(currentPath(app.router), '/search');
    });

    testWidgets('"see all" opens the مصرعے tab', (tester) async {
      final app = await pumpSearchScreen(
        tester,
        state: resultsState(results(), query: 'jigar'),
      );

      final seeAll = find.descendant(
        of: find
            .ancestor(
              of: find.text('مصرعے'),
              matching: find.byType(Row),
            )
            .first,
        matching: find.text('سب دیکھیں'),
      );
      await tapAndSettle(tester, seeAll);

      expect(app.notifier.segmentSwitches, [DiscoverSegment.misras]);
      expect(app.notifier.searches, isEmpty, reason: 'no new search');
      expect(verseCard(results().verses[4]), findsOneWidget);
    });
  });

  group('مصرعے tab', () {
    testWidgets('lists every loaded verse with the total in the tab label',
        (tester) async {
      await pumpSearchScreen(
        tester,
        state: resultsState(results(),
            query: 'jigar', segment: DiscoverSegment.misras),
      );

      for (final v in results().verses) {
        expect(verseCard(v), findsOneWidget);
      }
      expect(find.text('مصرعے (${jigar.totalVerses})'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tapping a verse opens its poem', (tester) async {
      final app = await pumpSearchScreen(
        tester,
        state: resultsState(results(),
            query: 'jigar', segment: DiscoverSegment.misras),
      );

      await tapAndSettle(tester, verseCard(withPoet));

      expect(currentPath(app.router), '/main/poems/${withPoet.poemPublicId}');
    });

    testWidgets('English UI labels the tab "Lines"', (tester) async {
      await pumpSearchScreen(
        tester,
        state: resultsState(results(),
            query: 'jigar', segment: DiscoverSegment.misras),
        languageCode: 'en',
      );

      expect(find.text('Lines (${jigar.totalVerses})'), findsOneWidget);
      expect(find.textContaining('lines for "jigar"'), findsOneWidget);
    });
  });
}
