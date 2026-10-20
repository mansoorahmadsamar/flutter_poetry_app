import 'package:flutter/material.dart';
import 'package:flutter_poetry_app/features/search/models/search_models.dart';
import 'package:flutter_poetry_app/features/search/utils/search_segment_results.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import '../helpers/search_test_harness.dart';

/// T-179: the "All" header said "afsoos کے لیے 23 نتائج" while the غزلیں tab
/// said 693. The backend's `totalResults` is the number of items on this page
/// (≤ 10 per type); the tabs show the per-type totals.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  /// Shaped like production's answer for `afsoos`: 23 items on the page,
  /// far more matches per type.
  UnifiedSearchResponse afsoos() => lastPage(realRomanJigarResponse()).copyWith(
        totalResults: 23,
        totalPoets: 37,
        totalPoems: 693,
        totalCouplets: 120,
        totalVerses: 310,
        totalCategories: 0,
        totalTags: 2,
      );

  group('UnifiedSearchResponse.totalAcrossTabs', () {
    test('is the sum of the tab totals, not the page item count', () {
      final r = afsoos();
      expect(r.totalAcrossTabs, 37 + 693 + 120 + 310 + 0);
      expect(r.totalAcrossTabs, isNot(r.totalResults));
    });

    test('a tab with items but no total counts its loaded items', () {
      final r = afsoos().copyWith(totalPoets: 0);
      expect(r.totalAcrossTabs, r.poets.length + 693 + 120 + 310);
    });

    test('empty response is 0', () {
      expect(const UnifiedSearchResponse().totalAcrossTabs, 0);
    });
  });

  group('"All" results header (T-179)', () {
    testWidgets('regression: Urdu header agrees with the tabs', (tester) async {
      await pumpSearchScreen(tester,
          state: resultsState(afsoos(), query: 'afsoos'));

      expect(find.text('"afsoos" کے لیے 1160 نتائج'), findsOneWidget);
      expect(find.text('"afsoos" کے لیے 23 نتائج'), findsNothing);
      expect(find.text('غزلیں (693)'), findsOneWidget);
      expect(
          Directionality.of(
              tester.element(find.text('"afsoos" کے لیے 1160 نتائج'))),
          TextDirection.rtl);
    });

    testWidgets('English header agrees with the tabs, LTR', (tester) async {
      await pumpSearchScreen(tester,
          state: resultsState(afsoos(), query: 'afsoos'), languageCode: 'en');

      expect(find.text('1160 results for "afsoos"'), findsOneWidget);
      final header = tester.widget<Text>(find.text('1160 results for "afsoos"'));
      expect(header.textDirection, TextDirection.ltr);
    });
  });
}
