import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_poetry_app/core/utils/text_direction_helper.dart';
import 'package:flutter_poetry_app/core/utils/language_typography.dart';

void main() {
  group('TextDirectionHelper', () {
    test('Urdu is RTL', () {
      expect(TextDirectionHelper.getTextDirection('ur'), TextDirection.rtl);
      expect(TextDirectionHelper.isRTL('ur'), isTrue);
    });

    test('English is LTR', () {
      expect(TextDirectionHelper.getTextDirection('en'), TextDirection.ltr);
      expect(TextDirectionHelper.isRTL('en'), isFalse);
    });

    test('unknown language falls back to LTR', () {
      expect(TextDirectionHelper.getTextDirection('xx'), TextDirection.ltr);
      expect(TextDirectionHelper.getTextDirection(''), TextDirection.ltr);
    });

    test('isRTL agrees with getTextDirection', () {
      for (final code in ['ur', 'en', 'ar', 'fa', 'ps', 'hi', 'xx', '']) {
        expect(
          TextDirectionHelper.isRTL(code),
          TextDirectionHelper.getTextDirection(code) == TextDirection.rtl,
          reason: 'isRTL disagreed with getTextDirection for "$code"',
        );
      }
    });
  });

  group('RTL definition consistency across helpers', () {
    test('both helpers agree that Urdu is RTL and English is LTR', () {
      for (final code in ['ur', 'en']) {
        expect(
          TextDirectionHelper.getTextDirection(code),
          LanguageTypography.getTextDirection(code),
          reason: 'helpers disagreed on "$code"',
        );
      }
    });

    test(
      'the two helpers disagree on Arabic, Persian and Pashto',
      () {
        // Documents a real divergence rather than asserting it is correct:
        // LanguageTypography treats ar/fa/ps as RTL, TextDirectionHelper does
        // not. Any screen that picks direction via TextDirectionHelper will lay
        // Arabic out left-to-right while styling it with RTL typography.
        //
        // Only 'ur' and 'en' are user-selectable today, so this is latent, not
        // a live bug. If a third language is ever added, reconcile the two
        // lists and this test should be updated to assert agreement.
        for (final code in ['ar', 'fa', 'ps']) {
          expect(
            LanguageTypography.getTextDirection(code),
            TextDirection.rtl,
            reason: 'LanguageTypography should treat "$code" as RTL',
          );
          expect(
            TextDirectionHelper.getTextDirection(code),
            TextDirection.ltr,
            reason: 'TextDirectionHelper currently treats "$code" as LTR',
          );
        }
      },
    );

    test('TextDirectionHelper is case sensitive while LanguageTypography is not', () {
      // Another latent divergence: an uppercase code from an API or stored
      // preference would be handled differently by the two helpers.
      expect(TextDirectionHelper.getTextDirection('UR'), TextDirection.ltr);
      expect(LanguageTypography.getTextDirection('UR'), TextDirection.rtl);
    });
  });
}
