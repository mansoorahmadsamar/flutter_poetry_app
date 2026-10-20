import 'package:flutter/material.dart';
import 'package:flutter_poetry_app/features/discover/models/discover_bundle_model.dart';
import 'package:flutter_poetry_app/features/discover/widgets/trending_chips.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

String _chipText(WidgetTester tester, int index) {
  final texts = tester
      .widgetList<Text>(find.descendant(
          of: find.byKey(ValueKey('trending-chip-$index')),
          matching: find.byType(Text)))
      .map((t) => t.data)
      .toList();
  return texts.join(' ');
}

Future<List<String>> _pump(WidgetTester tester, TrendingSearches trending,
    {bool isRtl = false}) async {
  final taps = <String>[];
  await tester.pumpWidget(MaterialApp(
    home: Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: TrendingChips(
            trending: trending, isRtl: isRtl, onQueryTap: taps.add),
      ),
    ),
  ));
  await tester.pumpAndSettle();
  return taps;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  // The owner's report: Rubai shown last. Counts made out of order here to
  // prove the app orders by count whatever the server sends.
  const outOfOrder = TrendingSearches(daily: [
    TrendingQuery(query: 'Ghazal', searchCount: 1, rank: 1),
    TrendingQuery(query: 'Nazam', searchCount: 2, rank: 2),
    TrendingQuery(query: 'Naat', searchCount: 3, rank: 3),
    TrendingQuery(query: 'Rubai', searchCount: 4, rank: 4),
  ]);

  group('TrendingChips order (T-180)', () {
    testWidgets('English: chips are ordered by count and show just the word',
        (tester) async {
      await _pump(tester, outOfOrder);
      expect(_chipText(tester, 0), 'Rubai');
      expect(_chipText(tester, 1), 'Naat');
      expect(_chipText(tester, 2), 'Nazam');
      expect(_chipText(tester, 3), 'Ghazal');
    });

    testWidgets('Urdu (RTL): same order, tap searches the chip query',
        (tester) async {
      final taps = await _pump(tester, outOfOrder, isRtl: true);
      expect(find.text('مقبول تلاش'), findsOneWidget);
      expect(_chipText(tester, 0), 'Rubai');
      expect(
          Directionality.of(
              tester.element(find.byKey(const ValueKey('trending-chip-0')))),
          TextDirection.rtl);

      await tester.tap(find.byKey(const ValueKey('trending-chip-0')));
      expect(taps, ['Rubai']);
    });
  });
  // Owner decision (2026-10-20): popular-search chips show only the word —
  // no rank number (1, 2, 3…) and no "rising" arrow.
  group('TrendingChips without rank badge', () {
    const urduQueries = TrendingSearches(daily: [
      TrendingQuery(query: 'غزل', searchCount: 85, rank: 1),
      TrendingQuery(query: 'نظم', searchCount: 74, rank: 2),
      TrendingQuery(query: 'نعت', searchCount: 57, rank: 3),
      TrendingQuery(query: 'رباعی', searchCount: 37, rank: 4),
    ]);

    for (final isRtl in [false, true]) {
      testWidgets('${isRtl ? 'Urdu (RTL)' : 'English (LTR)'}: no digits, no '
          'arrow, Urdu queries in Nastaliq RTL', (tester) async {
        await _pump(tester, urduQueries, isRtl: isRtl);

        for (var i = 0; i < 4; i++) {
          final chip = find.byKey(ValueKey('trending-chip-$i'));
          final texts = tester
              .widgetList<Text>(
                  find.descendant(of: chip, matching: find.byType(Text)))
              .toList();
          expect(texts, hasLength(1), reason: 'chip $i shows only the word');
          expect(texts.single.data, urduQueries.daily[i].query);
          expect(texts.single.data, isNot(matches(RegExp(r'\d'))));
          expect(texts.single.textDirection, TextDirection.rtl);
          expect(texts.single.style?.fontFamily, 'Jameel Noori Nastaleeq');
          expect(
              find.descendant(of: chip, matching: find.byType(Icon)), findsNothing);
        }
      });
    }

    testWidgets('weekly chips are words too, ordered by count', (tester) async {
      const trending = TrendingSearches(
        daily: [TrendingQuery(query: 'Ghazal', searchCount: 1)],
        weekly: [
          TrendingQuery(query: 'Nazam', searchCount: 2),
          TrendingQuery(query: 'Rubai', searchCount: 9),
        ],
      );
      await _pump(tester, trending);
      await tester.tap(find.text('Weekly'));
      await tester.pumpAndSettle();

      expect(_chipText(tester, 0), 'Rubai');
      expect(_chipText(tester, 1), 'Nazam');
    });
  });
}
