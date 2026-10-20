import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../helpers/fake_hashtag_service.dart';
import '../../../helpers/fixtures.dart';

const _meta = {
  'slug': 'bahar',
  'name': 'بہار',
  'color': '-',
  'coupletCount': 27,
  'poemCount': 3,
};

Future<void> _pumpWith(WidgetTester tester, String fixture,
        {String lang = 'ur'}) =>
    pumpHashtagScreen(
      tester,
      slug: 'bahar',
      lang: lang,
      service: hashtagServiceOverAdapter(
        slug: 'bahar',
        meta: _meta,
        couplets: loadJsonFixture(fixture),
      ),
    );

Finder _tile(String id) => find.byKey(ValueKey('hashtag-couplet-$id'));

InkWell _inkWellOf(WidgetTester tester, String id) => tester.widget<InkWell>(
    find.descendant(of: _tile(id), matching: find.byType(InkWell)).first);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  const firstLine = 'گلوں میں رنگ بھرے باد نو بہار چلے';

  group('Hashtag couplets tab against production CoupletDto (T-177)', () {
    testWidgets(
        'regression: Urdu, the couplets render instead of "لوڈ نہیں ہو سکا"',
        (tester) async {
      await _pumpWith(tester, 'hashtags/couplets_page_main.json');

      expect(find.text('لوڈ نہیں ہو سکا'), findsNothing);
      expect(find.textContaining(firstLine), findsOneWidget);
      expect(_tile('cpl-bahar-1'), findsOneWidget);
      expect(_tile('cpl-bahar-2'), findsOneWidget);
      expect(Directionality.of(tester.element(_tile('cpl-bahar-1'))),
          TextDirection.rtl);
    });

    testWidgets('no poem id: no tap handler, no chevron, no "-" shown',
        (tester) async {
      await _pumpWith(tester, 'hashtags/couplets_page_main.json');

      expect(_inkWellOf(tester, 'cpl-bahar-1').onTap, isNull);
      expect(
          find.descendant(
              of: _tile('cpl-bahar-1'),
              matching: find.byIcon(Icons.chevron_left_rounded)),
          findsNothing);
      expect(find.text('-'), findsNothing);

      await tester.tap(find.textContaining(firstLine));
      await tester.pumpAndSettle();
      expect(find.textContaining('poem:'), findsNothing);
    });

    testWidgets('English (LTR) renders the Roman couplet', (tester) async {
      await _pumpWith(tester, 'hashtags/couplets_page_main.json', lang: 'en');

      expect(find.text('Failed to load'), findsNothing);
      expect(find.textContaining('Bahar aai'), findsOneWidget);
      expect(Directionality.of(tester.element(_tile('cpl-bahar-2'))),
          TextDirection.ltr);
    });
  });

  group('Hashtag couplets tab against develop CoupletDto', () {
    testWidgets('a couplet with a poem id opens its poem (not the couplet)',
        (tester) async {
      await _pumpWith(tester, 'hashtags/couplets_page_develop.json');

      expect(find.text('فیض احمد فیض'), findsOneWidget);
      expect(
          find.descendant(
              of: _tile('cpl-bahar-1'),
              matching: find.byIcon(Icons.chevron_left_rounded)),
          findsOneWidget);

      await tester.tap(find.textContaining(firstLine));
      await tester.pumpAndSettle();
      expect(find.text('poem:poem-bahar'), findsOneWidget);
    });

    testWidgets('"-" poem id is not tappable', (tester) async {
      await _pumpWith(tester, 'hashtags/couplets_page_develop.json');
      expect(_inkWellOf(tester, 'cpl-bahar-2').onTap, isNull);
      expect(find.text('-'), findsNothing);
    });

    testWidgets('English: the chevron points right', (tester) async {
      await _pumpWith(tester, 'hashtags/couplets_page_develop.json',
          lang: 'en');
      expect(
          find.descendant(
              of: _tile('cpl-bahar-1'),
              matching: find.byIcon(Icons.chevron_right_rounded)),
          findsOneWidget);
    });
  });
}
