import 'package:flutter_poetry_app/features/hashtags/models/couplet_theme.dart';
import 'package:flutter_poetry_app/features/hashtags/utils/localized_name.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fixtures.dart';

void main() {
  final fixture = loadJsonFixture('themes/couplet_themes.json');

  group('parseCoupletThemes', () {
    test('reads the ranked shape in server order', () {
      final themes = parseCoupletThemes(fixture['ranked']);

      expect(themes.map((t) => t.slug), ['hijr', 'intezar', 'yaad']);
      expect(themes.first.nameUr, 'ہجر');
      expect(themes.first.nameEn, 'Separation');
      expect(themes.first.nameHi, 'हिज्र');
      expect(themes.first.confidence, 0.91);
    });

    test('absent, null, empty and non-list mean no themes', () {
      expect(parseCoupletThemes(null), isEmpty);
      expect(parseCoupletThemes(const []), isEmpty);
      expect(parseCoupletThemes('-'), isEmpty);
      expect(parseCoupletThemes({'slug': 'hijr'}), isEmpty);
      expect(parseCoupletThemes(3), isEmpty);
    });

    test('drops entries without a usable slug, non-objects and repeats', () {
      final themes = parseCoupletThemes(fixture['messy']);

      // "-" / missing / null slugs, a bare string, a number and null are
      // dropped; the second "wafa" repeats the first.
      expect(themes.map((t) => t.slug), ['wafa', 'naam-nahin', 'tanhai']);
    });

    test('"-" and blank names are absent; a non-numeric confidence is null',
        () {
      final wafa = parseCoupletThemes(fixture['messy']).first;

      expect(wafa.nameUr, isNull);
      expect(wafa.nameEn, 'Fidelity');
      expect(wafa.nameHi, isNull);
      expect(wafa.confidence, isNull);

      final nameless = parseCoupletThemes(fixture['messy'])[1];
      expect(nameless.nameUr, isNull);
      expect(nameless.nameEn, isNull);
    });

    test('the converter round-trips through toJson', () {
      const converter = CoupletThemesConverter();
      final themes = converter.fromJson(fixture['ranked']);
      expect(converter.fromJson(converter.toJson(themes)), themes);
    });
  });

  group('CoupletTheme.labelFor', () {
    final hijr = parseCoupletThemes(fixture['ranked']).first;

    test('uses the app language: Urdu, English, Hindi', () {
      expect(hijr.labelFor('ur'), (text: 'ہجر', languageCode: 'ur'));
      expect(hijr.labelFor('en'), (text: 'Separation', languageCode: 'en'));
      expect(hijr.labelFor('hi'), (text: 'हिज्र', languageCode: 'hi'));
    });

    test('falls back to Urdu, then English, and says which it used', () {
      const urOnly = CoupletTheme(slug: 'tanhai', nameUr: 'تنہائی');
      const enOnly = CoupletTheme(slug: 'wafa', nameEn: 'Fidelity');

      expect(urOnly.labelFor('en'), (text: 'تنہائی', languageCode: 'ur'));
      expect(urOnly.labelFor('hi'), (text: 'تنہائی', languageCode: 'ur'));
      expect(enOnly.labelFor('ur'), (text: 'Fidelity', languageCode: 'en'));
      expect(enOnly.labelFor('hi'), (text: 'Fidelity', languageCode: 'en'));
    });

    test('an unknown app language falls back to Urdu', () {
      expect(hijr.labelFor('fr'), (text: 'ہجر', languageCode: 'ur'));
    });

    test('no name in any language gives no label (the slug is never shown)',
        () {
      const nameless = CoupletTheme(slug: 'naam-nahin');
      expect(nameless.labelFor('ur'), isNull);
      expect(nameless.labelFor('en'), isNull);
    });
  });

  group('pickLocalizedName', () {
    test('treats "-" and blank names as absent', () {
      expect(pickLocalizedName('ur', ur: '-', en: 'Love'),
          (text: 'Love', languageCode: 'en'));
      expect(pickLocalizedName('en', ur: 'عشق', en: '  '),
          (text: 'عشق', languageCode: 'ur'));
      expect(pickLocalizedName('hi', ur: null, en: '-', hi: ''), isNull);
    });

    test('the app language code is case-insensitive', () {
      expect(pickLocalizedName('HI', hi: 'इश्क़', ur: 'عشق'),
          (text: 'इश्क़', languageCode: 'hi'));
    });
  });
}
