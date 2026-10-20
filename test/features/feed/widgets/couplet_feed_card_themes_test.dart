import 'package:flutter/material.dart';
import 'package:flutter_poetry_app/core/design_system/app_typography.dart';
import 'package:flutter_poetry_app/features/feed/models/feed_content_data.dart';
import 'package:flutter_poetry_app/features/feed/models/feed_item.dart';
import 'package:flutter_poetry_app/features/feed/widgets/couplet_feed_card.dart';
import 'package:flutter_poetry_app/features/hashtags/widgets/couplet_theme_chips.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../helpers/feed_card_harness.dart';
import '../../../helpers/fixtures.dart';

/// Theme chips on the feed couplet card, and the card opening its poem at
/// the couplet (`?couplet=`) when the item says which couplet it is.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  const misra1 = 'گلوں میں رنگ بھرے باد نو بہار چلے';
  const misra2 = 'چلے بھی آؤ کہ گلشن کا کاروبار چلے';
  final themes = loadJsonFixture('themes/couplet_themes.json');

  /// A signed-in feed couplet item shaped like `FeedItemHydrator`'s output.
  /// [themesValue] / [coupletNumber] null leave the field out (production).
  FeedItem feedItem({Object? themesValue, Object? coupletNumber}) =>
      FeedItem.fromJson({
        'type': 'COUPLET',
        'publicId': 'cpl-1',
        'reason': 'TRENDING',
        'lang': 'ur',
        'contentData': {
          'versesTextArabic': '$misra1\n$misra2',
          'poetPublicId': 'poet-faiz',
          'poetName': 'فیض احمد فیض',
          'poemPublicId': 'poem-bahar',
          'likeCount': 0,
          'shareCount': 0,
          'bookmarkCount': 0,
          if (themesValue != null) 'themes': themesValue,
          if (coupletNumber != null) 'coupletNumber': coupletNumber,
        },
      });

  Future<GoRouter> pumpCard(WidgetTester tester, FeedItem item,
          {String appLang = 'ur'}) =>
      pumpFeedCardInRouter(
        tester,
        CoupletFeedCard(
            item: item, data: item.contentData as CoupletContentData),
        appLang: appLang,
      );

  Finder chip(String slug) => find.byKey(CoupletThemeChips.chipKey(slug));

  group('theme chips on the feed couplet card', () {
    testWidgets('Urdu UI: Urdu chips in Nastaliq, RTL', (tester) async {
      await pumpCard(tester, feedItem(themesValue: themes['ranked']));

      expect(find.text('#ہجر'), findsOneWidget);
      expect(find.text('#انتظار'), findsOneWidget);
      expect(find.text('#یاد'), findsOneWidget);
      expect(tester.widget<Text>(find.text('#ہجر')).style?.fontFamily,
          AppTypography.urduFontFamily);
      expect(
          Directionality.of(tester.element(chip('hijr'))), TextDirection.rtl);
    });

    testWidgets('English UI: English chips, LTR', (tester) async {
      await pumpCard(tester, feedItem(themesValue: themes['ranked']),
          appLang: 'en');

      expect(find.text('#Separation'), findsOneWidget);
      expect(
          Directionality.of(tester.element(chip('hijr'))), TextDirection.ltr);
    });

    for (final lang in ['ur', 'en']) {
      testWidgets('$lang: a chip opens its hashtag page, not the poem',
          (tester) async {
        final router = await pumpCard(
            tester, feedItem(themesValue: themes['ranked']),
            appLang: lang);

        await tester.tap(chip('hijr'));
        await tester.pumpAndSettle();

        expect(router.state.uri.path, '/hashtags/hijr');
        expect(find.text('hashtag:hijr'), findsOneWidget);
        expect(find.textContaining('poem:'), findsNothing);
      });
    }

    testWidgets('production item (no themes): no chips', (tester) async {
      await pumpCard(tester, feedItem());

      expect(find.byType(CoupletThemeChips), findsOneWidget);
      expect(find.textContaining('#'), findsNothing);
      expect(find.byType(Wrap), findsNothing);
    });
  });

  group('feed couplet opens its poem at the couplet', () {
    testWidgets('with a couplet number: /main/poems/:id?couplet=<n>',
        (tester) async {
      final router = await pumpCard(tester, feedItem(coupletNumber: 3));

      await tester.tap(find.text('$misra1\n$misra2'));
      await tester.pumpAndSettle();

      expect(router.state.uri.path, '/main/poems/poem-bahar');
      expect(router.state.uri.queryParameters, {'couplet': '3'});
    });

    testWidgets(
        'production item (no couplet number): the plain poem link, as before',
        (tester) async {
      final router =
          await pumpCard(tester, feedItem(coupletNumber: 0), appLang: 'en');

      await tester.tap(find.text('Open poem →'));
      await tester.pumpAndSettle();

      expect(router.state.uri.toString(), '/main/poems/poem-bahar');
    });
  });
}
