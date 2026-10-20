import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_poetry_app/core/design_system/app_typography.dart';
import 'package:flutter_poetry_app/features/hashtags/widgets/couplet_theme_chips.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../helpers/fake_hashtag_service.dart';
import '../../../helpers/fixtures.dart';

/// Theme chips on the hashtag page's couplet tiles, and a tile opening its
/// poem at the couplet.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  const slug = 'bahar';
  const meta = {
    'slug': slug,
    'name': 'بہار',
    'color': '-',
    'coupletCount': 2,
  };
  final ranked =
      loadJsonFixture('themes/couplet_themes.json')['ranked'] as List;

  /// [fixture]'s page with [themes] on its first couplet.
  Map<String, dynamic> page(String fixture, {List<Object?>? themes}) {
    final body = jsonDecode(jsonEncode(loadJsonFixture(fixture)))
        as Map<String, dynamic>;
    if (themes != null) {
      final first = ((body['data'] as Map)['content'] as List).first as Map;
      first['themes'] = themes;
    }
    return body;
  }

  Future<GoRouter> pump(WidgetTester tester, Map<String, dynamic> couplets,
          {String lang = 'ur'}) =>
      pumpHashtagScreen(
        tester,
        slug: slug,
        lang: lang,
        service: hashtagServiceOverAdapter(
            slug: slug, meta: meta, couplets: couplets),
      );

  Finder tile(String id) => find.byKey(ValueKey('hashtag-couplet-$id'));
  Finder chipIn(Finder scope, String slug) => find.descendant(
      of: scope, matching: find.byKey(CoupletThemeChips.chipKey(slug)));

  group('theme chips on hashtag couplet tiles', () {
    testWidgets('Urdu: chips in Nastaliq, RTL', (tester) async {
      await pump(
          tester, page('hashtags/couplets_page_develop.json', themes: ranked));

      final chip = chipIn(tile('cpl-bahar-1'), 'hijr');
      expect(chip, findsOneWidget);
      final text = tester
          .widget<Text>(find.descendant(of: chip, matching: find.byType(Text)));
      expect(text.data, '#ہجر');
      expect(text.style?.fontFamily, AppTypography.urduFontFamily);
      expect(Directionality.of(tester.element(chip)), TextDirection.rtl);
    });

    testWidgets('English: chips in English, LTR', (tester) async {
      await pump(
          tester, page('hashtags/couplets_page_develop.json', themes: ranked),
          lang: 'en');

      final chip = chipIn(tile('cpl-bahar-1'), 'hijr');
      expect(find.descendant(of: chip, matching: find.text('#Separation')),
          findsOneWidget);
      expect(Directionality.of(tester.element(chip)), TextDirection.ltr);
    });

    for (final lang in ['ur', 'en']) {
      testWidgets('$lang: a chip opens that theme\'s hashtag page',
          (tester) async {
        final router = await pump(
            tester, page('hashtags/couplets_page_develop.json', themes: ranked),
            lang: lang);

        await tester.tap(chipIn(tile('cpl-bahar-1'), 'intezar'));
        await tester.pumpAndSettle();

        expect(router.state.uri.path, '/hashtags/intezar');
        expect(find.text('hashtag:intezar'), findsOneWidget);
      });
    }

    testWidgets('the page\'s own theme is not shown as a chip on its couplets',
        (tester) async {
      await pump(
        tester,
        page('hashtags/couplets_page_develop.json', themes: [
          {'slug': slug, 'nameUr': 'بہار', 'nameEn': 'Spring'},
          ...ranked,
        ]),
      );

      expect(chipIn(tile('cpl-bahar-1'), slug), findsNothing);
      expect(chipIn(tile('cpl-bahar-1'), 'hijr'), findsOneWidget);
    });

    testWidgets('production couplets (no themes): no chips', (tester) async {
      await pump(tester, page('hashtags/couplets_page_main.json'));

      expect(tile('cpl-bahar-1'), findsOneWidget);
      expect(find.byKey(CoupletThemeChips.chipKey('hijr')), findsNothing);
    });
  });

  group('hashtag couplet opens its poem at the couplet', () {
    testWidgets('develop CoupletDto: /main/poems/:poemId?couplet=<n>',
        (tester) async {
      final router =
          await pump(tester, page('hashtags/couplets_page_develop.json'));

      await tester.tap(tile('cpl-bahar-1'));
      await tester.pumpAndSettle();

      expect(router.state.uri.path, '/main/poems/poem-bahar');
      expect(router.state.uri.queryParameters, {'couplet': '3'});
      expect(find.text('poem:poem-bahar'), findsOneWidget);
    });
  });
}
