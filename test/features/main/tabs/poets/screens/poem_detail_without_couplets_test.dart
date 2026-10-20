import 'package:flutter/material.dart';
import 'package:flutter_poetry_app/core/design_system/app_typography.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/models/poem_model.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/widgets/poem_reading_card.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../helpers/fixtures.dart';
import '../../../../../helpers/poem_detail_harness.dart';

/// T-207: a poem whose response has no couplets (nazms and other non-ghazal
/// types, or a guest poem whose couplet load failed) showed an endless
/// spinner: the screen passed `null` for an empty couplet list and
/// `PoemReadingCard` read `null` as "still loading". The poem is loaded; its
/// text must show, and a poem with no text at all gets an empty state.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  const poemId = 'nazm-1';

  // Real lines from fixtures (never retyped by hand): Urdu misras and their
  // production Roman transliterations.
  final urVerses =
      (((loadJsonFixture('hashtags/couplets_page_main.json')['data']
              as Map)['content'] as List)
          .first as Map)['verses'] as List;
  final ur1 = (urVerses[0] as Map)['verseText'] as String;
  final ur2 = (urVerses[1] as Map)['verseText'] as String;
  final roman = (loadJsonFixture('search/couplet_result_variants.json')[
      'withoutNewFields'] as Map)['verses'] as List;
  final en1 = (roman[0] as Map)['romanizedText'] as String;
  final en2 = (roman[1] as Map)['romanizedText'] as String;

  PoemContentModel content(String lang, String fullText,
          {List<VerseModel> verses = const []}) =>
      PoemContentModel(
        publicId: 'content-$lang',
        languageCode: lang,
        languageName: lang,
        languageNativeName: lang,
        script: lang == 'ur' ? 'ARABIC' : 'ROMAN',
        scriptDirection: lang == 'ur' ? 'rtl' : 'ltr',
        title: lang == 'ur' ? ur1 : en1,
        fullText: fullText,
        verses: verses,
      );

  /// A nazm with no couplets; [contents] / [excerpt] carry its text.
  PoemModel nazm(
          {List<PoemContentModel> contents = const [], String? excerpt}) =>
      PoemModel(
        publicId: poemId,
        poetPublicId: 'poet-faiz',
        poetName: 'فیض احمد فیض',
        poetryType: 'NAZM',
        title: ur1,
        excerpt: excerpt,
        contents: contents,
      );

  final bilingual = nazm(contents: [
    content('ur', '$ur1\n$ur2\n\n$ur2\n$ur1'),
    content('en', '$en1\n$en2'),
  ]);

  /// [text] inside the reading card (the app bar also shows the title).
  Finder inCard(String text) => find.descendant(
      of: find.byType(PoemReadingCard), matching: find.text(text));

  Finder spinner() => find.descendant(
      of: find.byType(PoemReadingCard),
      matching: find.byType(CircularProgressIndicator));

  Future<void> pump(WidgetTester tester, PoemModel poem, String lang) =>
      pumpPoemDetail(tester, '/main/poems/$poemId',
          poem: poem, lang: lang, settle: false);

  group('regression T-207: poem with no couplets', () {
    testWidgets('Urdu: the text shows (Nastaliq, RTL), no endless spinner',
        (tester) async {
      await pump(tester, bilingual, 'ur');

      expect(spinner(), findsNothing);
      expect(inCard(ur1), findsNWidgets(2));
      expect(inCard(ur2), findsNWidgets(2));
      final line = tester.widget<Text>(inCard(ur2).first);
      expect(line.textDirection, TextDirection.rtl);
      expect(line.style?.fontFamily, AppTypography.urduFontFamily);
      expect(find.byKey(PoemReadingCard.emptyTextKey), findsNothing);
      // Nothing animates forever any more.
      await tester.pumpAndSettle();
    });

    testWidgets('English: the English text shows, LTR, no spinner',
        (tester) async {
      await pump(tester, bilingual, 'en');

      expect(spinner(), findsNothing);
      expect(inCard(en1), findsOneWidget);
      expect(inCard(en2), findsOneWidget);
      expect(tester.widget<Text>(inCard(en1)).textDirection, TextDirection.ltr);
    });

    testWidgets('content with verses but no fullText shows the verses',
        (tester) async {
      final poem = nazm(contents: [
        content('ur', '', verses: [
          VerseModel(text: ur1, coupletNumber: 1),
          VerseModel(text: ur2, coupletNumber: 1),
          VerseModel(text: '-', coupletNumber: 2),
        ]),
      ]);
      await pump(tester, poem, 'ur');

      expect(spinner(), findsNothing);
      expect(inCard(ur1), findsOneWidget);
      expect(inCard(ur2), findsOneWidget);
      expect(inCard('-'), findsNothing);
    });

    testWidgets('only an excerpt (list-style response): the excerpt shows',
        (tester) async {
      await pump(tester, nazm(excerpt: '$en1\n$en2'), 'en');

      expect(spinner(), findsNothing);
      expect(inCard(en1), findsOneWidget);
    });

    for (final (lang, message) in [
      ('ur', 'اس کلام کا متن دستیاب نہیں'),
      ('en', 'The text of this poem is not available.'),
    ]) {
      testWidgets('$lang: no text at all shows an empty state, not a spinner',
          (tester) async {
        await pump(tester, nazm(excerpt: '-'), lang);

        expect(spinner(), findsNothing);
        expect(find.byKey(PoemReadingCard.emptyTextKey), findsOneWidget);
        expect(find.text(message), findsOneWidget);
        expect(tester.widget<Text>(find.text(message)).textDirection,
            lang == 'ur' ? TextDirection.rtl : TextDirection.ltr);
      });
    }
  });

  group('PoemReadingCard.sherBlocksFor', () {
    test('fullText is split into shers at blank lines', () {
      expect(PoemReadingCard.sherBlocksFor(bilingual, 'ur'),
          ['$ur1\n$ur2', '$ur2\n$ur1']);
    });

    test('verses group by couplet number; "-" lines are dropped', () {
      final poem = nazm(contents: [
        content('ur', '  ', verses: [
          VerseModel(text: ur1, coupletNumber: 1),
          VerseModel(text: ur2, coupletNumber: 1),
          VerseModel(text: ur2, coupletNumber: 2),
          VerseModel(text: '-', coupletNumber: 2),
          VerseModel(text: ur1),
        ]),
      ]);
      expect(
          PoemReadingCard.sherBlocksFor(poem, 'ur'), ['$ur1\n$ur2', ur2, ur1]);
    });

    test('no text anywhere: no blocks', () {
      expect(PoemReadingCard.sherBlocksFor(nazm(), 'ur'), isEmpty);
      expect(
          PoemReadingCard.sherBlocksFor(nazm(excerpt: ' - '), 'en'), isEmpty);
    });
  });
}
