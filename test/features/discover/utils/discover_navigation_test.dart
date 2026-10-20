import 'package:flutter/material.dart';
import 'package:flutter_poetry_app/features/discover/models/discover_bundle_model.dart';
import 'package:flutter_poetry_app/features/discover/utils/discover_navigation.dart';
import 'package:flutter_poetry_app/features/discover/widgets/horizontal_content_rail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

const _couplet = ContentCard(
  type: 'COUPLET',
  publicId: 'couplet-1',
  primaryText: 'دل ہی تو ہے نہ سنگ و خشت',
  poemPublicId: 'poem-1',
);
const _coupletWithoutPoem = ContentCard(
  type: 'COUPLET',
  publicId: 'couplet-2',
  primaryText: 'درد سے بھر نہ آئے کیوں',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  group('discoverCardDestination (T-181)', () {
    test('regression: a couplet opens its poem, not /main/poems/<couplet id>',
        () {
      expect(discoverCardDestination(_couplet)?.path, '/main/poems/poem-1');
      expect(
          discoverCardDestination(_couplet.copyWith(type: 'VERSE'))?.path,
          '/main/poems/poem-1');
    });

    test('a couplet without a poem id opens nothing', () {
      expect(discoverCardDestination(_coupletWithoutPoem), isNull);
    });

    test('poets, poems, categories and tags', () {
      const poet = ContentCard(type: 'POET', publicId: 'g', primaryText: 'غالب');
      const poem = ContentCard(type: 'POEM', publicId: 'p', primaryText: 'غزل');
      expect(discoverCardDestination(poet)?.path, '/main/poets/g');
      expect(discoverCardDestination(poem)?.path, '/main/poems/p');
      expect(discoverCardDestination(poem.copyWith(publicId: '-')), isNull);
      final category = discoverCardDestination(
          const ContentCard(type: 'CATEGORY', publicId: 'c', primaryText: 'نعت'));
      expect(category?.path, '/search');
      expect(category?.extra, {'query': 'نعت', 'origin': 'browse'});
      expect(
          discoverCardDestination(
              const ContentCard(type: 'UNKNOWN', publicId: 'x', primaryText: 'x')),
          isNull);
    });
  });

  group('Discover rail couplet tap', () {
    Future<GoRouter> pumpRail(WidgetTester tester, ContentCard card,
        {bool isRtl = true}) async {
      final router = GoRouter(routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => Scaffold(
            body: HorizontalContentRail(
              title: isRtl ? 'آپ کے لیے' : 'Recommended For You',
              items: [card],
              totalCount: 1,
              isRtl: isRtl,
              onItemTap: openDiscoverCard,
            ),
          ),
        ),
        GoRoute(
          path: '/main/poems/:publicId',
          builder: (_, s) => Text('poem:${s.pathParameters['publicId']}'),
        ),
      ]);
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();
      return router;
    }

    testWidgets('Urdu: tapping a guest trending couplet opens its poem',
        (tester) async {
      await pumpRail(tester, _couplet);
      await tester.tap(find.textContaining('دل ہی تو ہے'));
      await tester.pumpAndSettle();
      expect(find.text('poem:poem-1'), findsOneWidget);
      expect(find.text('poem:couplet-1'), findsNothing);
    });

    testWidgets('English: a couplet without a poem id stays put',
        (tester) async {
      final router = await pumpRail(tester, _coupletWithoutPoem, isRtl: false);
      await tester.tap(find.textContaining('درد سے'));
      await tester.pumpAndSettle();
      expect(router.state.uri.path, '/');
    });
  });
}
