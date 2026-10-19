import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_poetry_app/core/utils/api_placeholder.dart';

void main() {
  group('presentOrNull', () {
    test('"-" placeholder is absent', () {
      expect(presentOrNull('-'), isNull);
      expect(presentOrNull(' - '), isNull);
    });

    test('null, empty and blank are absent', () {
      expect(presentOrNull(null), isNull);
      expect(presentOrNull(''), isNull);
      expect(presentOrNull('  \n '), isNull);
    });

    test('real Urdu text is kept and trimmed', () {
      const misra = 'دل ہی تو ہے نہ سنگ و خشت درد سے بھر نہ آئے کیوں';
      expect(presentOrNull(' $misra '), misra);
    });

    test('text that merely contains a dash is kept', () {
      expect(presentOrNull('Ghalib - Diwan'), 'Ghalib - Diwan');
      expect(presentOrNull('--'), '--');
    });
  });
}
