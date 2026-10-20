import 'package:flutter/material.dart';
import 'package:flutter_poetry_app/features/hashtags/models/hashtag_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../helpers/fake_hashtag_service.dart';

int _selectedTab(WidgetTester tester) =>
    tester.widget<TabBar>(find.byType(TabBar)).controller!.index;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  const politics = HashtagDto(
    slug: 'politics',
    name: 'Politics',
    coupletCount: 0,
    poemCount: 1,
  );

  group('HashtagDetailScreen initial tab (T-178)', () {
    testWidgets(
        'regression: English, 0 couplets and 1 poem opens on Poems and never '
        'loads the empty Couplets tab', (tester) async {
      final service = FakeHashtagService(politics);
      await pumpHashtagScreen(tester, slug: 'politics', service: service);

      expect(_selectedTab(tester), 1);
      expect(find.text('Poems (1)'), findsOneWidget);
      expect(find.text('No poems found'), findsOneWidget);
      expect(service.tabRequests, ['poems']);
      expect(
          Directionality.of(tester.element(find.text('Poems (1)'))),
          TextDirection.ltr);
    });

    testWidgets('Urdu: opens on نظمیں, RTL', (tester) async {
      final service = FakeHashtagService(politics);
      await pumpHashtagScreen(tester,
          slug: 'politics', service: service, lang: 'ur');

      expect(_selectedTab(tester), 1);
      expect(find.text('نظمیں (1)'), findsOneWidget);
      expect(service.tabRequests, ['poems']);
      expect(Directionality.of(tester.element(find.text('نظمیں (1)'))),
          TextDirection.rtl);
    });

    testWidgets('couplets with content still open first', (tester) async {
      final service = FakeHashtagService(
          const HashtagDto(slug: 'bahar', coupletCount: 27, poemCount: 4));
      await pumpHashtagScreen(tester, slug: 'bahar', service: service);

      expect(_selectedTab(tester), 0);
      expect(service.tabRequests, ['couplets']);
    });

    testWidgets('every tab empty keeps اشعار', (tester) async {
      final service = FakeHashtagService(const HashtagDto(slug: 'khali'));
      await pumpHashtagScreen(tester,
          slug: 'khali', service: service, lang: 'ur');

      expect(_selectedTab(tester), 0);
      expect(find.text('کوئی اشعار نہیں ملے'), findsOneWidget);
    });

    testWidgets('only poets: opens on the last tab, and the user can still '
        'switch back to Couplets', (tester) async {
      final service =
          FakeHashtagService(const HashtagDto(slug: 'x', poetCount: 2));
      await pumpHashtagScreen(tester, slug: 'x', service: service);
      expect(_selectedTab(tester), 3);

      await tester.tap(find.text('Couplets (0)'));
      await tester.pumpAndSettle();
      expect(_selectedTab(tester), 0);
      expect(service.tabRequests, contains('couplets'));
    });
  });
}
