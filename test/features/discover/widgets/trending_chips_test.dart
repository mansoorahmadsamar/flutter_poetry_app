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
    testWidgets('English: chips are ordered by count, rank badge follows',
        (tester) async {
      await _pump(tester, outOfOrder);
      expect(_chipText(tester, 0), '1 Rubai');
      expect(_chipText(tester, 1), '2 Naat');
      expect(_chipText(tester, 2), '3 Nazam');
      expect(_chipText(tester, 3), '4 Ghazal');
    });

    testWidgets('Urdu (RTL): same order, tap searches the chip query',
        (tester) async {
      final taps = await _pump(tester, outOfOrder, isRtl: true);
      expect(find.text('مقبول تلاش'), findsOneWidget);
      expect(_chipText(tester, 0), '1 Rubai');
      expect(
          Directionality.of(
              tester.element(find.byKey(const ValueKey('trending-chip-0')))),
          TextDirection.rtl);

      await tester.tap(find.byKey(const ValueKey('trending-chip-0')));
      expect(taps, ['Rubai']);
    });
  });
}
