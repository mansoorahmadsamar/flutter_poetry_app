import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_poetry_app/core/utils/color_parser.dart';

void main() {
  const fallback = Color(0xFF123456);

  group('parseHexColor', () {
    test('regression: "-" colour placeholder does not throw and falls back', () {
      expect(parseHexColor('-', fallback: fallback), fallback);
    });

    test('null and empty fall back', () {
      expect(parseHexColor(null, fallback: fallback), fallback);
      expect(parseHexColor('', fallback: fallback), fallback);
      expect(parseHexColor('   ', fallback: fallback), fallback);
      expect(parseHexColor('#', fallback: fallback), fallback);
    });

    test('#RRGGBB is opaque', () {
      expect(parseHexColor('#1A2B3C', fallback: fallback),
          const Color(0xFF1A2B3C));
    });

    test('lower-case hex and surrounding whitespace are accepted', () {
      expect(parseHexColor('  #1a2b3c ', fallback: fallback),
          const Color(0xFF1A2B3C));
    });

    test('RRGGBB without # is accepted', () {
      expect(parseHexColor('E91E63', fallback: fallback),
          const Color(0xFFE91E63));
    });

    test('#RGB expands each digit', () {
      expect(parseHexColor('#F0A', fallback: fallback),
          const Color(0xFFFF00AA));
    });

    test('#AARRGGBB keeps the alpha channel', () {
      expect(parseHexColor('#801A2B3C', fallback: fallback),
          const Color(0x801A2B3C));
    });

    test('junk falls back', () {
      for (final junk in [
        '#zzz',
        '#12345',
        '#1234567',
        '#123456789',
        'red',
        '0xFF1A2B3C',
        '#12 456',
        '#-12345',
        '#+12345',
      ]) {
        expect(parseHexColor(junk, fallback: fallback), fallback,
            reason: 'input "$junk"');
      }
    });
  });
}
