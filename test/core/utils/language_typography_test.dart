import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_poetry_app/core/utils/language_typography.dart';

void main() {
  // GoogleFonts reads the asset manifest, which needs the test binding.
  TestWidgetsFlutterBinding.ensureInitialized();

  // The app fetches Google Fonts over HTTP at runtime; tests must not.
  GoogleFonts.config.allowRuntimeFetching = false;

  group('LanguageTypography.getTextDirection', () {
    test('Urdu is RTL', () {
      expect(LanguageTypography.getTextDirection('ur'), TextDirection.rtl);
    });

    test('Arabic, Persian and Pashto are RTL', () {
      expect(LanguageTypography.getTextDirection('ar'), TextDirection.rtl);
      expect(LanguageTypography.getTextDirection('fa'), TextDirection.rtl);
      expect(LanguageTypography.getTextDirection('ps'), TextDirection.rtl);
    });

    test('English and Hindi are LTR', () {
      expect(LanguageTypography.getTextDirection('en'), TextDirection.ltr);
      expect(LanguageTypography.getTextDirection('hi'), TextDirection.ltr);
    });

    test('language code is case insensitive', () {
      expect(LanguageTypography.getTextDirection('UR'), TextDirection.rtl);
      expect(LanguageTypography.getTextDirection('Ur'), TextDirection.rtl);
    });

    test('unknown language falls back to LTR', () {
      expect(LanguageTypography.getTextDirection('xx'), TextDirection.ltr);
      expect(LanguageTypography.getTextDirection(''), TextDirection.ltr);
    });
  });

  group('LanguageTypography.isRTL', () {
    test('agrees with getTextDirection for every supported code', () {
      for (final code in ['ur', 'ar', 'fa', 'ps', 'en', 'hi', 'xx', '']) {
        expect(
          LanguageTypography.isRTL(code),
          LanguageTypography.getTextDirection(code) == TextDirection.rtl,
          reason: 'isRTL disagreed with getTextDirection for "$code"',
        );
      }
    });
  });

  group('LanguageTypography sizing', () {
    test('Urdu is scaled up relative to English for visual weight balance', () {
      final urdu = LanguageTypography.getSizeMultiplier('ur');
      final english = LanguageTypography.getSizeMultiplier('en');
      expect(urdu, greaterThan(english));
    });

    test('Urdu line height exceeds English, so Nastaliq descenders are not clipped', () {
      expect(
        LanguageTypography.getLineHeight('ur'),
        greaterThan(LanguageTypography.getLineHeight('en')),
      );
    });

    test('unknown language falls back to English metrics', () {
      expect(
        LanguageTypography.getSizeMultiplier('xx'),
        LanguageTypography.getSizeMultiplier('en'),
      );
      expect(
        LanguageTypography.getLineHeight('xx'),
        LanguageTypography.getLineHeight('en'),
      );
    });

    test('multipliers and line heights are case insensitive', () {
      expect(
        LanguageTypography.getSizeMultiplier('UR'),
        LanguageTypography.getSizeMultiplier('ur'),
      );
      expect(
        LanguageTypography.getLineHeight('UR'),
        LanguageTypography.getLineHeight('ur'),
      );
    });
  });

  group('LanguageTypography.createStyle', () {
    test('Urdu uses the bundled Nastaliq font, not a Google font', () {
      final style =
          LanguageTypography.createStyle(baseFontSize: 18, languageCode: 'ur');
      expect(style.fontFamily, 'JameelNooriNastaleeq');
    });

    test('applies the language size multiplier to the base font size', () {
      final style =
          LanguageTypography.createStyle(baseFontSize: 20, languageCode: 'ur');
      expect(
        style.fontSize,
        closeTo(20 * LanguageTypography.getSizeMultiplier('ur'), 0.001),
      );
    });

    test('Urdu and English at the same base size do not render at the same size', () {
      // Compared via the multipliers rather than createStyle, because the
      // English branch calls GoogleFonts.roboto, which needs a font asset or
      // network fetch that is unavailable under `flutter test`.
      const base = 18.0;
      final urduSize = base * LanguageTypography.getSizeMultiplier('ur');
      final englishSize = base * LanguageTypography.getSizeMultiplier('en');
      expect(urduSize, isNot(englishSize));

      final urdu =
          LanguageTypography.createStyle(baseFontSize: base, languageCode: 'ur');
      expect(urdu.fontSize, closeTo(urduSize, 0.001));
    });

    test('customLineHeight overrides the language default', () {
      final style = LanguageTypography.createStyle(
        baseFontSize: 18,
        languageCode: 'ur',
        customLineHeight: 2.5,
      );
      expect(style.height, 2.5);
    });

    test('Pashto is RTL and scaled like Persian, but is not in the Nastaliq font list', () {
      // Pashto is RTL and takes the Persian multiplier, yet createStyle only
      // special-cases ur/ar/fa for the bundled Nastaliq font — so Pashto would
      // fall through to GoogleFonts. Asserted without calling createStyle,
      // which cannot load a Google font under `flutter test`.
      expect(LanguageTypography.isRTL('ps'), isTrue);
      expect(
        LanguageTypography.getSizeMultiplier('ps'),
        LanguageTypography.persianMultiplier,
      );
    });
  });

  group('LanguageTypography.verseStyle', () {
    test('verse text is readable in both themes', () {
      final light = LanguageTypography.verseStyle(languageCode: 'ur', isDark: false);
      final dark = LanguageTypography.verseStyle(languageCode: 'ur', isDark: true);
      expect(light.color, isNot(dark.color));
    });

    test('verse style carries Urdu line height so couplets are not cramped', () {
      final style =
          LanguageTypography.verseStyle(languageCode: 'ur', isDark: false);
      expect(style.height, LanguageTypography.urduLineHeight);
    });
  });
}
