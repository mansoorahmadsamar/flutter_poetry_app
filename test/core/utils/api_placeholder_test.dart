import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_poetry_app/core/utils/api_placeholder.dart';

void main() {
  group('presentOrNull', () {
    test('regression: "-" is absent, not a value', () {
      expect(presentOrNull('-'), isNull);
      expect(presentOrNull(' - '), isNull);
    });

    test('null, empty and blank are absent', () {
      expect(presentOrNull(null), isNull);
      expect(presentOrNull(''), isNull);
      expect(presentOrNull('   '), isNull);
      expect(presentOrNull('  \n '), isNull);
    });

    test('keeps real values, Urdu and Latin', () {
      expect(presentOrNull('حسرتؔ موہانی'), 'حسرتؔ موہانی');
      expect(presentOrNull('0ee4a0ab-9c6e'), '0ee4a0ab-9c6e');
    });

    test('real Urdu text is kept and trimmed', () {
      const misra = 'دل ہی تو ہے نہ سنگ و خشت درد سے بھر نہ آئے کیوں';
      expect(presentOrNull(' $misra '), misra);
    });

    test('a value that merely contains a dash is kept', () {
      expect(presentOrNull('Ghalib - Diwan'), 'Ghalib - Diwan');
      expect(presentOrNull('dil-navaz'), 'dil-navaz');
      expect(presentOrNull('--'), '--');
    });
  });

  group('PlaceholderStringConverter', () {
    const converter = PlaceholderStringConverter();

    test('reads "-" and blank as null', () {
      expect(converter.fromJson('-'), isNull);
      expect(converter.fromJson(''), isNull);
      expect(converter.fromJson(null), isNull);
    });

    test('non-string values are absent', () {
      expect(converter.fromJson(42), isNull);
      expect(converter.fromJson(const {'publicId': 'x'}), isNull);
    });

    test('keeps real values and writes them back unchanged', () {
      expect(converter.fromJson('abc'), 'abc');
      expect(converter.fromJson('غزل'), 'غزل');
      expect(converter.toJson('غزل'), 'غزل');
      expect(converter.toJson(null), isNull);
    });
  });
}
