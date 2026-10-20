import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/providers/language_provider.dart';
import 'package:flutter_poetry_app/features/hashtags/models/hashtag_model.dart';
import 'package:flutter_poetry_app/features/hashtags/screens/hashtag_detail_screen.dart';
import 'package:flutter_poetry_app/features/hashtags/services/hashtag_service.dart';

import '../../../helpers/fake_hashtag_service.dart';

Future<void> _pump(WidgetTester tester, HashtagDto meta,
    {String lang = 'en'}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        selectedLanguageProvider.overrideWithValue(lang),
        hashtagServiceProvider.overrideWithValue(FakeHashtagService(meta)),
      ],
      child: MaterialApp(home: HashtagDetailScreen(slug: meta.slug)),
    ),
  );
  // Let the metadata future and the tabs' first loads complete.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

Color? _tabLabelColour(WidgetTester tester) =>
    tester.widget<TabBar>(find.byType(TabBar)).labelColor;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  group('HashtagDetailScreen colour', () {
    testWidgets('regression: "-" colour does not throw and uses the primary',
        (tester) async {
      await _pump(tester, const HashtagDto(slug: 'ishq', name: 'ishq', color: '-'));
      expect(tester.takeException(), isNull);
      expect(find.text('#ishq'), findsOneWidget);
      expect(_tabLabelColour(tester), AppColors.primary);
    });

    testWidgets('a valid colour tints the tabs', (tester) async {
      await _pump(tester, const HashtagDto(slug: 'dil', color: '#1A2B3C'));
      expect(_tabLabelColour(tester), const Color(0xFF1A2B3C));
    });

    testWidgets('Urdu: "-" colour renders the RTL screen', (tester) async {
      const name = 'محبت';
      await _pump(
        tester,
        const HashtagDto(slug: 'mohabbat', name: name, color: '-'),
        lang: 'ur',
      );
      expect(tester.takeException(), isNull);
      expect(find.text('#$name'), findsOneWidget);
      expect(Directionality.of(tester.element(find.text('#$name'))),
          TextDirection.rtl);
      expect(_tabLabelColour(tester), AppColors.primary);
    });
  });
}
