import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/features/hashtags/models/hashtag_model.dart';
import 'package:flutter_poetry_app/features/hashtags/widgets/hashtag_pill.dart';

Future<void> _pumpPill(WidgetTester tester, HashtagDto hashtag,
    {TextDirection direction = TextDirection.ltr}) {
  return tester.pumpWidget(
    MaterialApp(
      home: Directionality(
        textDirection: direction,
        child: Scaffold(body: Center(child: HashtagPill(hashtag: hashtag))),
      ),
    ),
  );
}

Color _textColour(WidgetTester tester, String label) =>
    tester.widget<Text>(find.text(label)).style!.color!;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  group('HashtagPill colour', () {
    testWidgets('regression: "-" colour does not throw', (tester) async {
      await _pumpPill(tester, const HashtagDto(slug: 'ishq', color: '-'));
      expect(tester.takeException(), isNull);
      expect(find.text('#ishq'), findsOneWidget);
      expect(_textColour(tester, '#ishq'), AppColors.primary);
    });

    testWidgets('null and junk colours fall back to the primary colour',
        (tester) async {
      for (final colour in [null, '', '#zzz']) {
        await _pumpPill(tester, HashtagDto(slug: 'gham', color: colour));
        expect(tester.takeException(), isNull, reason: 'colour "$colour"');
        expect(_textColour(tester, '#gham'), AppColors.primary);
      }
    });

    testWidgets('a valid colour is used', (tester) async {
      await _pumpPill(tester, const HashtagDto(slug: 'dil', color: '#1A2B3C'));
      expect(_textColour(tester, '#dil'), const Color(0xFF1A2B3C));
    });

    testWidgets('an Urdu hashtag name renders right-to-left with a "-" colour',
        (tester) async {
      const name = 'محبت';
      await _pumpPill(
        tester,
        const HashtagDto(slug: 'mohabbat', name: name, color: '-'),
        direction: TextDirection.rtl,
      );
      expect(tester.takeException(), isNull);
      expect(find.text('#$name'), findsOneWidget);
      expect(
        Directionality.of(tester.element(find.text('#$name'))),
        TextDirection.rtl,
      );
    });
  });
}
