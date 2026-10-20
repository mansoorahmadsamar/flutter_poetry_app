import 'package:flutter/material.dart';
import 'package:flutter_poetry_app/core/providers/language_provider.dart';
import 'package:flutter_poetry_app/core/routing/app_router.dart';
import 'package:flutter_poetry_app/features/engagement/models/reaction_models.dart';
import 'package:flutter_poetry_app/features/engagement/providers/reaction_providers.dart';
import 'package:flutter_poetry_app/features/engagement/widgets/reaction_button.dart';
import 'package:flutter_poetry_app/features/hashtags/models/couplet_theme.dart';
import 'package:flutter_poetry_app/features/hashtags/widgets/couplet_theme_chips.dart';
import 'package:flutter_poetry_app/features/main/tabs/creator/providers/creator_providers.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/models/couplet_model.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/models/poem_model.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/providers/poem_providers.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/screens/poem_detail_screen.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/widgets/poem_reading_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../helpers/fake_hashtag_service.dart';
import '../../../../../helpers/fixtures.dart';

/// `/main/poems/:publicId?couplet=<n>`: the poem opens scrolled to couplet n,
/// highlighted with the existing selection; old links open at the top.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  const poemId = 'poem-bahar';
  const coupletCount = 40;

  // Real misras from the hashtag fixture (never retyped by hand).
  final fixtureVerses =
      (((loadJsonFixture('hashtags/couplets_page_main.json')['data']
              as Map)['content'] as List)
          .first as Map)['verses'] as List;
  final misra1 = (fixtureVerses[0] as Map)['verseText'] as String;
  final misra2 = (fixtureVerses[1] as Map)['verseText'] as String;
  final ranked = parseCoupletThemes(
      loadJsonFixture('themes/couplet_themes.json')['ranked']);

  /// A 40-couplet ghazal; couplet 1 carries themes.
  PoemModel ghazal() => PoemModel(
        publicId: poemId,
        poetPublicId: 'poet-faiz',
        poetName: 'فیض احمد فیض',
        poetryType: 'GHAZAL',
        title: misra1,
        couplets: [
          for (var n = 1; n <= coupletCount; n++)
            CoupletModel(
              publicId: 'cpl-$n',
              coupletNumber: n,
              coupletType: 'REGULAR',
              verses: [
                VerseModel(text: '$misra1 $n'),
                VerseModel(text: '$misra2 $n'),
              ],
              themes: n == 1 ? ranked : const [],
            ),
        ],
      );

  /// The app's real poem route (from `appRoutesProvider`), so the test covers
  /// how the route reads `?couplet=`.
  GoRoute realPoemRoute() {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final main = container
        .read(appRoutesProvider)
        .whereType<GoRoute>()
        .firstWhere((r) => r.path == AppRoutes.main);
    return main.routes
        .whereType<GoRoute>()
        .firstWhere((r) => r.name == AppRoutes.poemDetailName);
  }

  Future<GoRouter> pumpPoem(WidgetTester tester, String location,
      {String lang = 'ur', PoemModel? poem}) async {
    final router = GoRouter(
      initialLocation: location,
      routes: [
        GoRoute(
          path: AppRoutes.main,
          builder: (_, __) => const SizedBox(),
          routes: [realPoemRoute()],
        ),
        GoRoute(
          path: '/hashtags/:slug',
          builder: (_, state) =>
              Text('hashtag:${state.pathParameters['slug']}'),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        selectedLanguageProvider.overrideWithValue(lang),
        poemDetailProvider.overrideWith((ref, id) async => poem ?? ghazal()),
        poetPoemsProvider
            .overrideWith((ref, params) async => emptyHashtagPage<PoemModel>()),
        ownedPoetProvider.overrideWith((ref) async => null),
        reactionTypesProvider
            .overrideWith((ref) async => const <ReactionType>[]),
      ],
      child: MaterialApp.router(routerConfig: router),
    ));
    await tester.pumpAndSettle();
    return router;
  }

  Finder couplet(int n) => find.byKey(PoemReadingCard.coupletKey(n));

  ScrollPosition scrollPosition(WidgetTester tester) => tester
      .state<ScrollableState>(find
          .descendant(
              of: find.byType(PoemDetailScreen),
              matching: find.byType(Scrollable))
          .first)
      .position;

  bool isOnScreen(WidgetTester tester, Finder finder) {
    final screen = tester.getRect(find.byType(PoemDetailScreen));
    final rect = tester.getRect(finder);
    return rect.top >= screen.top && rect.bottom <= screen.bottom;
  }

  /// The selection highlight (the existing one): the couplet's action tray.
  bool isSelected(WidgetTester tester, int n) => find
      .descendant(of: couplet(n), matching: find.byType(ReactionButton))
      .evaluate()
      .isNotEmpty;

  group('route parsing', () {
    testWidgets('?couplet=7 reaches PoemDetailScreen.initialCoupletNumber',
        (tester) async {
      await pumpPoem(tester, '/main/poems/$poemId?couplet=7');
      final screen =
          tester.widget<PoemDetailScreen>(find.byType(PoemDetailScreen));
      expect(screen.publicId, poemId);
      expect(screen.initialCoupletNumber, 7);
    });

    for (final location in [
      '/main/poems/$poemId',
      '/main/poems/$poemId?couplet=abc',
      '/main/poems/$poemId?couplet=0',
    ]) {
      testWidgets('$location: no couplet', (tester) async {
        await pumpPoem(tester, location);
        expect(
            tester
                .widget<PoemDetailScreen>(find.byType(PoemDetailScreen))
                .initialCoupletNumber,
            isNull);
      });
    }
  });

  group('opening a poem at a couplet', () {
    for (final lang in ['ur', 'en']) {
      testWidgets(
          '$lang: a deep couplet (30 of 40) is scrolled into view and '
          'highlighted', (tester) async {
        await pumpPoem(tester, '/main/poems/$poemId?couplet=30', lang: lang);

        expect(scrollPosition(tester).pixels, greaterThan(0));
        expect(isOnScreen(tester, couplet(30)), isTrue);
        expect(isSelected(tester, 30), isTrue);
        expect(isSelected(tester, 1), isFalse);
        expect(isOnScreen(tester, couplet(1)), isFalse);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('the last couplet (40) is reachable', (tester) async {
      await pumpPoem(tester, '/main/poems/$poemId?couplet=$coupletCount');

      expect(isOnScreen(tester, couplet(coupletCount)), isTrue);
      expect(isSelected(tester, coupletCount), isTrue);
    });

    testWidgets('old link (no ?couplet): opens at the top, nothing selected',
        (tester) async {
      await pumpPoem(tester, '/main/poems/$poemId');

      expect(scrollPosition(tester).pixels, 0);
      expect(isOnScreen(tester, couplet(30)), isFalse);
      for (final n in [1, 30]) {
        expect(isSelected(tester, n), isFalse);
      }
    });

    testWidgets('a number with no such couplet: opens at the top',
        (tester) async {
      await pumpPoem(tester, '/main/poems/$poemId?couplet=99');

      expect(scrollPosition(tester).pixels, 0);
      for (final n in [1, 30, coupletCount]) {
        expect(isSelected(tester, n), isFalse);
      }
    });

    testWidgets(
        'couplets with unknown numbers (production sends 0) render, and '
        '?couplet=0 links nowhere', (tester) async {
      final unnumbered = ghazal().copyWith(couplets: [
        for (final c in ghazal().couplets.take(3)) c.copyWith(coupletNumber: 0),
      ]);
      await pumpPoem(tester, '/main/poems/$poemId?couplet=0', poem: unnumbered);

      expect(tester.takeException(), isNull);
      expect(couplet(0), findsNWidgets(3));
      expect(find.byType(ReactionButton), findsOneWidget); // poem bar only
    });

    testWidgets('the reader can still deselect the deep-linked couplet',
        (tester) async {
      await pumpPoem(tester, '/main/poems/$poemId?couplet=30');

      await tester.tapAt(tester.getTopLeft(couplet(30)) + const Offset(20, 20));
      await tester.pumpAndSettle();

      expect(isSelected(tester, 30), isFalse);
    });
  });

  group('theme chips on poem couplets', () {
    testWidgets('Urdu: chips under the couplet; a chip opens its hashtag',
        (tester) async {
      final router = await pumpPoem(tester, '/main/poems/$poemId');

      final chip = find.descendant(
          of: couplet(1),
          matching: find.byKey(CoupletThemeChips.chipKey('hijr')));
      expect(find.descendant(of: chip, matching: find.text('#ہجر')),
          findsOneWidget);
      expect(Directionality.of(tester.element(chip)), TextDirection.rtl);
      // Couplets without themes show none.
      expect(find.descendant(of: couplet(2), matching: find.byType(InkWell)),
          findsNothing);

      await tester.tap(chip);
      await tester.pumpAndSettle();

      expect(router.state.uri.path, '/hashtags/hijr');
      expect(find.text('hashtag:hijr'), findsOneWidget);
    });

    testWidgets('English: English chip names, LTR', (tester) async {
      await pumpPoem(tester, '/main/poems/$poemId', lang: 'en');

      final chip = find.byKey(CoupletThemeChips.chipKey('hijr'));
      expect(find.descendant(of: chip, matching: find.text('#Separation')),
          findsOneWidget);
      expect(Directionality.of(tester.element(chip)), TextDirection.ltr);
    });
  });
}
