import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_poetry_app/features/search/utils/app_search_urdu_normalizer.dart';

void main() {
  // Pins the behaviour search queries rely on. Every row is also checked
  // against normalizeWithOffsets, which the highlighter uses, so the two can
  // never disagree about what the normalised text is.
  const table = <String, String>{
    '': '',
    'محبّت': 'محبت', // shadda
    'دِل': 'دل', // kasra
    'دـــل': 'دل', // tatweel
    'كتاب': 'کتاب', // Arabic kaf → Urdu kaf
    'علي': 'علی', // Arabic ya → Urdu ya
    'آسمان': 'اسمان', // alef madda → alef
    'محبۃ': 'محبہ', // ta marbuta → gol he
    '  dil   dil  ': 'dil dil', // collapse + trim
    'a\t\nb': 'a b',
    'Dil Nawaz': 'Dil Nawaz', // Latin passes through, case kept
    'दिल की बात': 'दिल की बात', // Devanagari passes through
    'دل ِ کا': 'دل کا', // a lone diacritic between spaces
  };

  group('AppSearchUrduNormalizer.normalize', () {
    table.forEach((input, expected) {
      test('normalises ${_show(input)} to ${_show(expected)}', () {
        expect(AppSearchUrduNormalizer.normalize(input), expected);
      });
    });
  });

  group('AppSearchUrduNormalizer.normalizeWithOffsets', () {
    table.forEach((input, expected) {
      test('text agrees with normalize for ${_show(input)}', () {
        final result = AppSearchUrduNormalizer.normalizeWithOffsets(input);
        expect(result.text, expected);
        expect(result.sourceToNormalized, hasLength(input.length));
      });
    });

    test('every kept source character maps to the same normalised character',
        () {
      for (final input in table.keys) {
        final result = AppSearchUrduNormalizer.normalizeWithOffsets(input);
        for (var i = 0; i < input.length; i++) {
          final n = result.sourceToNormalized[i];
          if (n < 0) continue;
          expect(
            result.text[n],
            AppSearchUrduNormalizer.normalize(input[i]).isEmpty
                ? ' ' // only a whitespace run can normalise to nothing yet be kept
                : AppSearchUrduNormalizer.normalize(input[i]),
            reason: 'source[$i] of ${_show(input)}',
          );
        }
      }
    });

    test('regression: a space keeps its own index instead of being dropped',
        () {
      final result = AppSearchUrduNormalizer.normalizeWithOffsets('دل کا دیار');
      // د ل ␠ ک ا ␠ د ی ا ر  → indices 0..9, nothing dropped
      expect(result.sourceToNormalized, List.generate(10, (i) => i));
    });

    test('drops leading, trailing and repeated whitespace', () {
      final result = AppSearchUrduNormalizer.normalizeWithOffsets(' ab  cd ');
      expect(result.text, 'ab cd');
      expect(result.sourceToNormalized, [-1, 0, 1, 2, -1, 3, 4, -1]);
    });

    test('drops diacritics and tatweel', () {
      final result = AppSearchUrduNormalizer.normalizeWithOffsets('دِـل');
      expect(result.text, 'دل');
      expect(result.sourceToNormalized, [0, -1, -1, 1]);
    });
  });

  group('AppSearchUrduNormalizer.isDroppedMark', () {
    test('diacritics and tatweel are dropped marks', () {
      expect(AppSearchUrduNormalizer.isDroppedMark('ِ'), isTrue); // kasra
      expect(AppSearchUrduNormalizer.isDroppedMark('ّ'), isTrue); // shadda
      expect(AppSearchUrduNormalizer.isDroppedMark('ـ'), isTrue); // tatweel
    });

    test('letters and spaces are not', () {
      expect(AppSearchUrduNormalizer.isDroppedMark('د'), isFalse);
      expect(AppSearchUrduNormalizer.isDroppedMark(' '), isFalse);
      expect(AppSearchUrduNormalizer.isDroppedMark('a'), isFalse);
    });
  });
}

String _show(String s) => '"${s.replaceAll('\t', r'\t').replaceAll('\n', r'\n')}"';
