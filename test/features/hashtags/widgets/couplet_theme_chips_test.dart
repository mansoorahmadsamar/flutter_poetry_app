import 'package:flutter/material.dart';
import 'package:flutter_poetry_app/core/design_system/app_typography.dart';
import 'package:flutter_poetry_app/core/providers/language_provider.dart';
import 'package:flutter_poetry_app/features/hashtags/models/couplet_theme.dart';
import 'package:flutter_poetry_app/features/hashtags/widgets/couplet_theme_chips.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../helpers/fixtures.dart';

final _fixture = loadJsonFixture('themes/couplet_themes.json');
final _ranked = parseCoupletThemes(_fixture['ranked']);
final _four = parseCoupletThemes(_fixture['four']);
final _messy = parseCoupletThemes(_fixture['messy']);

Finder _chip(String slug) => find.byKey(CoupletThemeChips.chipKey(slug));

Text _chipText(WidgetTester tester, String slug) => tester.widget<Text>(
    find.descendant(of: _chip(slug), matching: find.byType(Text)));

/// [chips] at `/` of a router whose hashtag route shows `hashtag:<slug>`.
Future<GoRouter> _pump(
  WidgetTester tester,
  Widget chips, {
  required String lang,
}) async {
  final router = GoRouter(routes: [
    GoRoute(
        path: '/', builder: (_, __) => Scaffold(body: Center(child: chips))),
    GoRoute(
      path: '/hashtags/:slug',
      builder: (_, state) => Text('hashtag:${state.pathParameters['slug']}'),
    ),
  ]);
  addTearDown(router.dispose);
  await tester.pumpWidget(ProviderScope(
    overrides: [selectedLanguageProvider.overrideWithValue(lang)],
    child: MaterialApp.router(routerConfig: router),
  ));
  await tester.pump();
  return router;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  group('CoupletThemeChips rendering', () {
    testWidgets('Urdu: Urdu names in Nastaliq, chips laid out right-to-left',
        (tester) async {
      await _pump(tester, CoupletThemeChips(themes: _ranked), lang: 'ur');

      for (final (slug, name) in [
        ('hijr', 'ہجر'),
        ('intezar', 'انتظار'),
        ('yaad', 'یاد'),
      ]) {
        final text = _chipText(tester, slug);
        expect(text.data, '#$name');
        expect(text.style?.fontFamily, AppTypography.urduFontFamily);
        expect(text.textDirection, TextDirection.rtl);
      }
      expect(
          Directionality.of(tester.element(_chip('hijr'))), TextDirection.rtl);
      // Server order, laid out from the right in RTL.
      expect(tester.getCenter(_chip('hijr')).dx,
          greaterThan(tester.getCenter(_chip('intezar')).dx));
    });

    testWidgets('English: English names, left-to-right', (tester) async {
      await _pump(tester, CoupletThemeChips(themes: _ranked), lang: 'en');

      final text = _chipText(tester, 'hijr');
      expect(text.data, '#Separation');
      expect(text.textDirection, TextDirection.ltr);
      expect(text.style?.fontFamily, isNot(AppTypography.urduFontFamily));
      expect(find.text('#Waiting'), findsOneWidget);
      expect(find.text('#Remembrance'), findsOneWidget);
      expect(
          Directionality.of(tester.element(_chip('hijr'))), TextDirection.ltr);
      expect(tester.getCenter(_chip('hijr')).dx,
          lessThan(tester.getCenter(_chip('intezar')).dx));
    });

    testWidgets('Hindi: Devanagari names in Noto Sans Devanagari, LTR',
        (tester) async {
      await _pump(tester, CoupletThemeChips(themes: _ranked), lang: 'hi');

      final text = _chipText(tester, 'hijr');
      expect(text.data, '#हिज्र');
      expect(text.style?.fontFamily, contains('NotoSansDevanagari'));
      expect(text.textDirection, TextDirection.ltr);
    });

    testWidgets('at most three chips, in server order', (tester) async {
      await _pump(tester, CoupletThemeChips(themes: _four), lang: 'en');

      expect(_chip('hijr'), findsOneWidget);
      expect(_chip('intezar'), findsOneWidget);
      expect(_chip('yaad'), findsOneWidget);
      expect(_chip('wafa'), findsNothing);
    });

    testWidgets(
        'fallback: a missing English name shows the Urdu one in Nastaliq; a '
        'theme with no name is hidden (never its slug)', (tester) async {
      await _pump(tester, CoupletThemeChips(themes: _messy), lang: 'en');

      expect(_chipText(tester, 'wafa').data, '#Fidelity');
      final tanhai = _chipText(tester, 'tanhai');
      expect(tanhai.data, '#تنہائی');
      expect(tanhai.style?.fontFamily, AppTypography.urduFontFamily);
      expect(tanhai.textDirection, TextDirection.rtl);
      expect(_chip('naam-nahin'), findsNothing);
      expect(find.textContaining('naam-nahin'), findsNothing);
    });

    testWidgets('no themes (production today): nothing is rendered',
        (tester) async {
      await _pump(tester, const CoupletThemeChips(themes: []), lang: 'ur');

      expect(find.byType(Wrap), findsNothing);
      expect(find.byType(InkWell), findsNothing);
      expect(tester.getSize(find.byType(CoupletThemeChips)), Size.zero);
    });

    testWidgets('padding is applied only when there are chips', (tester) async {
      await _pump(
        tester,
        const CoupletThemeChips(themes: [], padding: EdgeInsets.only(top: 40)),
        lang: 'en',
      );
      expect(tester.getSize(find.byType(CoupletThemeChips)), Size.zero);
    });

    testWidgets('excludeSlug hides the current hashtag page\'s own chip',
        (tester) async {
      await _pump(tester, CoupletThemeChips(themes: _four, excludeSlug: 'hijr'),
          lang: 'en');

      expect(_chip('hijr'), findsNothing);
      // The fourth theme moves up into the three shown.
      expect(_chip('wafa'), findsOneWidget);
    });

    testWidgets('accessible label names the theme in the app language',
        (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, CoupletThemeChips(themes: _ranked), lang: 'ur');
      expect(
        find.bySemanticsLabel('موضوع: ہجر'),
        findsOneWidget,
      );
      expect(
          tester.getSemantics(_chip('hijr')),
          matchesSemantics(
              label: 'موضوع: ہجر', isButton: true, hasTapAction: true));
      handle.dispose();
    });

    testWidgets('accessible label in English and Hindi', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, CoupletThemeChips(themes: _ranked), lang: 'en');
      expect(find.bySemanticsLabel('Theme: Separation'), findsOneWidget);
      await _pump(tester, CoupletThemeChips(themes: _ranked), lang: 'hi');
      expect(find.bySemanticsLabel('विषय: हिज्र'), findsOneWidget);
      handle.dispose();
    });
  });

  group('CoupletThemeChips tap', () {
    for (final lang in ['ur', 'en']) {
      testWidgets('$lang: a chip opens /hashtags/:slug', (tester) async {
        final router =
            await _pump(tester, CoupletThemeChips(themes: _ranked), lang: lang);

        await tester.tap(_chip('intezar'));
        await tester.pumpAndSettle();

        expect(router.state.uri.path, '/hashtags/intezar');
        expect(find.text('hashtag:intezar'), findsOneWidget);
      });
    }

    testWidgets('an Urdu-script slug is encoded and arrives intact',
        (tester) async {
      final router = await _pump(
        tester,
        const CoupletThemeChips(
            themes: [CoupletTheme(slug: 'بہار', nameUr: 'بہار')]),
        lang: 'ur',
      );

      await tester.tap(_chip('بہار'));
      await tester.pumpAndSettle();

      expect(Uri.decodeComponent(router.state.uri.path), '/hashtags/بہار');
      expect(find.text('hashtag:بہار'), findsOneWidget);
    });
  });

  group('CoupletThemeChips.visibleThemes', () {
    test('caps at three after dropping excluded and nameless themes', () {
      final visible = CoupletThemeChips.visibleThemes(
        [const CoupletTheme(slug: 'x'), ..._four],
        'en',
        excludeSlug: 'intezar',
      );
      expect(visible.map((v) => v.theme.slug), ['hijr', 'yaad', 'wafa']);
    });
  });
}
