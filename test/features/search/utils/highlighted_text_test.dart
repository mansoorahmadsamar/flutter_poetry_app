import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_poetry_app/features/search/utils/highlighted_text.dart';

/// The substrings of [text] that [HighlightedText] would highlight for [query].
List<String> _highlighted(String text, String query) => HighlightedText
    .highlightRanges(text, query)
    .map((r) => r.textInside(text))
    .toList();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  group('HighlightedText.highlightRanges', () {
    test('regression: Urdu match after spaces does not drift left', () {
      expect(_highlighted('دل کا دیار', 'دیار'), ['دیار']);
    });

    test('regression: Roman match after a space does not drift left', () {
      expect(_highlighted('ab cd', 'cd'), ['cd']);
    });

    test('regression: drift does not grow with more preceding spaces', () {
      expect(
        _highlighted('dil ki holi dil ki divali', 'divali'),
        ['divali'],
      );
    });

    test('double and leading spaces before the match', () {
      expect(_highlighted('  ab  cd', 'cd'), ['cd']);
      expect(_highlighted('\tab\n cd', 'ab'), ['ab']);
    });

    test('diacritics inside the matched word are highlighted with it', () {
      // Splitting a word around its kasra would break Nastaliq joining.
      expect(_highlighted('دِل کا حال', 'دل'), ['دِل']);
    });

    test('a diacritic right after the match stays with its letter', () {
      expect(_highlighted('دلِ ناداں', 'دل'), ['دلِ']);
    });

    test('a query typed with diacritics matches plain text', () {
      expect(_highlighted('محبت کا دل', 'محبّت'), ['محبت']);
      expect(_highlighted('یہ دل ہے', 'دِل'), ['دل']);
    });

    test('tatweel inside a word is highlighted with it', () {
      expect(_highlighted('یہ دـــل ہے', 'دل'), ['دـــل']);
    });

    test('Arabic letter variants in the text match the Urdu query', () {
      expect(_highlighted('ایک كتاب', 'کتاب'), ['كتاب']);
    });

    test('multiple matches are all highlighted', () {
      expect(
        _highlighted('دل کی ہولی دل کی دیوالی ہے دل کی عید ہے', 'دل'),
        ['دل', 'دل', 'دل'],
      );
      expect(_highlighted('dil dil dil', 'dil'), ['dil', 'dil', 'dil']);
    });

    test('Latin matching is case-insensitive', () {
      expect(_highlighted('Dil Nawaz aur dil', 'DIL'), ['Dil', 'dil']);
    });

    test('a multi-word query spans collapsed whitespace in the text', () {
      expect(_highlighted('gham   nahi uska', 'gham nahi'), ['gham   nahi']);
    });

    test('Devanagari', () {
      expect(_highlighted('दिल की बात', 'बात'), ['बात']);
    });

    test('mixed Urdu and Roman in one line', () {
      expect(_highlighted('ghazal غزل dil دل', 'دل'), ['دل']);
      expect(_highlighted('ghazal غزل dil دل', 'dil'), ['dil']);
    });

    test('no match, empty and whitespace-only queries highlight nothing', () {
      expect(_highlighted('دل کا دیار', 'شہر'), isEmpty);
      expect(_highlighted('دل کا دیار', ''), isEmpty);
      expect(_highlighted('دل کا دیار', '   '), isEmpty);
      expect(_highlighted('', 'دل'), isEmpty);
    });

    test('overlapping matches merge into one range', () {
      expect(_highlighted('aaa', 'aa'), ['aaa']);
    });
  });

  group('HighlightedText widget', () {
    Future<List<TextSpan>> pumpSpans(
      WidgetTester tester, {
      required String text,
      required String query,
      required TextDirection direction,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HighlightedText(
              text: text,
              query: query,
              textDirection: direction,
              style: const TextStyle(
                fontFamily: 'Jameel Noori Nastaleeq',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      );
      final rich = tester.widget<RichText>(find.byType(RichText).first);
      return (rich.text as TextSpan).children!.cast<TextSpan>();
    }

    testWidgets('Urdu: renders RTL with exactly the matched word bold',
        (tester) async {
      final spans = await pumpSpans(
        tester,
        text: 'دل کا دیار',
        query: 'دیار',
        direction: TextDirection.rtl,
      );
      final rich = tester.widget<RichText>(find.byType(RichText).first);
      expect(rich.textDirection, TextDirection.rtl);
      expect(spans.map((s) => s.text).join(), 'دل کا دیار');
      final bold = spans
          .where((s) => s.style?.fontWeight == FontWeight.w700)
          .map((s) => s.text)
          .toList();
      expect(bold, ['دیار']);
    });

    testWidgets('English: renders LTR with exactly the matched word bold',
        (tester) async {
      final spans = await pumpSpans(
        tester,
        text: 'ab cd',
        query: 'cd',
        direction: TextDirection.ltr,
      );
      final bold = spans
          .where((s) => s.style?.fontWeight == FontWeight.w700)
          .map((s) => s.text)
          .toList();
      expect(bold, ['cd']);
    });

    testWidgets('empty query renders plain Text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HighlightedText(
              text: 'دل کا دیار',
              query: ' ',
              style: TextStyle(),
            ),
          ),
        ),
      );
      expect(find.text('دل کا دیار'), findsOneWidget);
    });
  });
}
