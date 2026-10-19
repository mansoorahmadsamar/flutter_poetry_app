import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_poetry_app/core/utils/api_placeholder.dart';

void main() {
  group('presentOrNull', () {
    test('keeps real values unchanged, Urdu and Latin', () {
      expect(presentOrNull('حسرتؔ موہانی'), 'حسرتؔ موہانی');
      expect(presentOrNull('0ee4a0ab-9c6e'), '0ee4a0ab-9c6e');
    });

    test('regression: "-" is absent, not a value', () {
      expect(presentOrNull('-'), isNull);
      expect(presentOrNull(' - '), isNull);
    });

    test('null, empty and blank are absent', () {
      expect(presentOrNull(null), isNull);
      expect(presentOrNull(''), isNull);
      expect(presentOrNull('   '), isNull);
    });

    test('a value that merely contains a dash is kept', () {
      expect(presentOrNull('dil-navaz'), 'dil-navaz');
      expect(presentOrNull('--'), '--');
    });
  });

  group('PlaceholderStringConverter.fromJson', () {
    const converter = PlaceholderStringConverter();

    test('strings pass through presentOrNull', () {
      expect(converter.fromJson('abc'), 'abc');
      expect(converter.fromJson('-'), isNull);
      expect(converter.fromJson(''), isNull);
    });

    test('null and non-string values are absent', () {
      expect(converter.fromJson(null), isNull);
      expect(converter.fromJson(42), isNull);
      expect(converter.fromJson(const {'publicId': 'x'}), isNull);
    });
  });
}
