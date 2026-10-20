import 'package:flutter/material.dart';
import 'package:flutter_poetry_app/core/design_system/app_typography.dart';
import 'package:flutter_poetry_app/core/providers/language_provider.dart';
import 'package:flutter_poetry_app/features/hashtags/models/hashtag_model.dart';
import 'package:flutter_poetry_app/features/hashtags/screens/hashtag_detail_screen.dart';
import 'package:flutter_poetry_app/features/hashtags/services/hashtag_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../helpers/fake_hashtag_service.dart';
import '../../../helpers/fixtures.dart';

/// A theme tag's page shows its name in the app language and its definition;
/// every other tag (and production today) looks as before.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  final themeJson = loadJsonFixture('hashtags/hashtag_meta_theme.json');
  final themeMeta = HashtagDto.fromJson(themeJson);
  const definitionStart = 'Parting from or absence of the beloved';

  Future<void> pump(WidgetTester tester, HashtagDto meta,
      {String lang = 'en'}) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        selectedLanguageProvider.overrideWithValue(lang),
        hashtagServiceProvider.overrideWithValue(FakeHashtagService(meta)),
      ],
      child: MaterialApp(home: HashtagDetailScreen(slug: meta.slug)),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  Text title(WidgetTester tester) => tester.widget<Text>(find.descendant(
      of: find.byType(AppBar), matching: find.textContaining('#')));

  group('theme tag metadata', () {
    testWidgets('Urdu: Urdu name in Nastaliq RTL, definition shown',
        (tester) async {
      await pump(tester, themeMeta, lang: 'ur');

      final t = title(tester);
      expect(t.data, '#ہجر');
      expect(t.style?.fontFamily, AppTypography.urduFontFamily);
      expect(t.textDirection, TextDirection.rtl);
      expect(find.byKey(HashtagDetailScreen.definitionKey), findsOneWidget);
      expect(find.textContaining(definitionStart), findsOneWidget);
      // The definition is English text: LTR even on the Urdu screen.
      expect(
          tester
              .widget<Text>(find.textContaining(definitionStart))
              .textDirection,
          TextDirection.ltr);
      expect(tester.takeException(), isNull);
    });

    testWidgets('English: English name, LTR', (tester) async {
      await pump(tester, themeMeta);

      final t = title(tester);
      expect(t.data, '#Separation');
      expect(t.textDirection, TextDirection.ltr);
      expect(find.byKey(HashtagDetailScreen.definitionKey), findsOneWidget);
    });

    testWidgets('Hindi: Devanagari name', (tester) async {
      await pump(tester, themeMeta, lang: 'hi');

      final t = title(tester);
      expect(t.data, '#हिज्र');
      expect(t.style?.fontFamily, contains('NotoSansDevanagari'));
      expect(t.textDirection, TextDirection.ltr);
    });

    testWidgets('an Urdu definition is RTL in Nastaliq', (tester) async {
      await pump(tester, themeMeta.copyWith(definition: 'محبوب سے جدائی، فراق'),
          lang: 'en');

      final def = tester.widget<Text>(find.text('محبوب سے جدائی، فراق'));
      expect(def.textDirection, TextDirection.rtl);
      expect(def.style?.fontFamily, AppTypography.urduFontFamily);
    });

    testWidgets('tabs still load under the definition', (tester) async {
      await pump(tester, themeMeta);

      expect(find.byType(TabBarView), findsOneWidget);
      expect(find.text('Couplets (12)'), findsOneWidget);
    });
  });

  group('tags without localized metadata (production today)', () {
    for (final lang in ['ur', 'en']) {
      testWidgets('$lang: the name as before, no definition', (tester) async {
        await pump(
            tester, const HashtagDto(slug: 'bahar', name: 'بہار', color: '-'),
            lang: lang);

        expect(title(tester).data, '#بہار');
        expect(find.byKey(HashtagDetailScreen.definitionKey), findsNothing);
      });
    }

    testWidgets('no name: the slug, as before', (tester) async {
      await pump(tester, const HashtagDto(slug: 'ishq'));
      expect(title(tester).data, '#ishq');
    });

    testWidgets('"-" localized names and definition: as before',
        (tester) async {
      await pump(
        tester,
        HashtagDto.fromJson({
          ...themeJson,
          'nameUr': '-',
          'nameEn': '-',
          'nameHi': '-',
          'definition': '-',
        }),
      );
      expect(title(tester).data, '#Separation'); // `name`
      expect(find.byKey(HashtagDetailScreen.definitionKey), findsNothing);
    });
  });
}
