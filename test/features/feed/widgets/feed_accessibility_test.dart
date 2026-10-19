import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_poetry_app/core/providers/language_provider.dart';
import 'package:flutter_poetry_app/features/engagement/models/reaction_models.dart';
import 'package:flutter_poetry_app/features/engagement/providers/reaction_providers.dart';
import 'package:flutter_poetry_app/features/feed/models/feed_content_data.dart';
import 'package:flutter_poetry_app/features/feed/models/feed_item.dart';
import 'package:flutter_poetry_app/features/feed/widgets/couplet_feed_card.dart';
import 'package:flutter_poetry_app/features/feed/widgets/feed_engagement_row.dart';
import 'package:flutter_poetry_app/features/feed/widgets/poem_feed_card.dart';
import 'package:flutter_poetry_app/features/feed/widgets/poet_image_feed_card.dart';

import '../../../helpers/feed_card_harness.dart';

// Urdu content copied from the guest discover fixture.
const _poetUr = 'فیض احمد فیض';
const _misras = 'یک بیک شورش فغاں کی طرح\nفصل گل آئی امتحاں کی طرح';

FeedItem _poem(String lang) => FeedItem(
      type: 'POEM',
      publicId: 'poem-1',
      lang: lang,
      contentData: PoemContentData(
        title: lang == 'ur' ? 'یک بیک شورش فغاں کی طرح' : 'The Rain',
        excerpt: lang == 'ur' ? _misras : 'line one\nline two',
        poetPublicId: 'poet-1',
        poetName: lang == 'ur' ? _poetUr : 'Faiz Ahmad Faiz',
        likeCount: 12,
      ),
    );

const _couplet = FeedItem(
  type: 'COUPLET',
  publicId: 'couplet-1',
  lang: 'ur',
  contentData: CoupletContentData(
    versesTextArabic: _misras,
    poetPublicId: 'poet-1',
    poetName: _poetUr,
  ),
);

const _image = FeedItem(
  type: 'POET_IMAGE',
  publicId: 'image-1',
  lang: 'ur',
  contentData: PoetImageContentData(
    contentText: _misras,
    poetPublicId: 'poet-1',
    poetName: _poetUr,
  ),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  group('feed cards expose labelled tap targets', () {
    for (final lang in ['ur', 'en']) {
      testWidgets('PoemFeedCard ($lang)', (tester) async {
        final handle = tester.ensureSemantics();
        final item = _poem(lang);
        await pumpFeedCard(
          tester,
          PoemFeedCard(item: item, data: item.contentData as PoemContentData),
          appLang: lang,
        );

        final poet = (item.contentData as PoemContentData).poetName!;
        expect(find.bySemanticsLabel('$poet, poet profile'), findsOneWidget);
        expect(find.bySemanticsLabel('Share'), findsOneWidget);
        expect(find.bySemanticsLabel('Bookmark'), findsOneWidget);
        expect(find.bySemanticsLabel('React'), findsOneWidget);
        handle.dispose();
      });
    }

    testWidgets('CoupletFeedCard', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpFeedCard(
        tester,
        CoupletFeedCard(
            item: _couplet, data: _couplet.contentData as CoupletContentData),
        appLang: 'ur',
      );
      expect(find.bySemanticsLabel('$_poetUr, poet profile'), findsOneWidget);
      expect(find.bySemanticsLabel('Share'), findsOneWidget);
      expect(find.bySemanticsLabel('Bookmark'), findsOneWidget);
      expect(find.bySemanticsLabel('React'), findsOneWidget);
      expect(find.bySemanticsLabel('Copy verses'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('PoetImageFeedCard', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpFeedCard(
        tester,
        PoetImageFeedCard(
            item: _image, data: _image.contentData as PoetImageContentData),
        appLang: 'ur',
      );
      expect(find.bySemanticsLabel('$_poetUr, poet profile'), findsOneWidget);
      expect(find.bySemanticsLabel('Share'), findsOneWidget);
      expect(find.bySemanticsLabel('Bookmark'), findsOneWidget);
      expect(find.bySemanticsLabel('React'), findsOneWidget);
      handle.dispose();
    });
  });

  group('FeedEngagementRow semantics', () {
    Future<void> pumpRow(WidgetTester tester, FeedEngagementRow row) =>
        tester.pumpWidget(ProviderScope(
          overrides: [
            selectedLanguageProvider.overrideWithValue('en'),
            reactionTypesProvider
                .overrideWith((ref) async => const <ReactionType>[]),
          ],
          child: MaterialApp(home: Scaffold(body: row)),
        ));

    testWidgets('share and bookmark are labelled buttons that act on tap',
        (tester) async {
      final handle = tester.ensureSemantics();
      var shared = 0;
      var bookmarked = 0;
      await pumpRow(
        tester,
        FeedEngagementRow(
          onShare: () => shared++,
          onBookmark: () => bookmarked++,
          onLike: () {},
        ),
      );

      expect(
        tester.getSemantics(find.bySemanticsLabel('Share')),
        matchesSemantics(
            label: 'Share', isButton: true, hasTapAction: true),
      );
      await tester.tap(find.bySemanticsLabel('Share'));
      await tester.tap(find.bySemanticsLabel('Bookmark'));
      expect(shared, 1);
      expect(bookmarked, 1);
      handle.dispose();
    });

    testWidgets('bookmark announces its state', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpRow(tester, FeedEngagementRow(isBookmarked: true, onBookmark: () {}));
      expect(find.bySemanticsLabel('Remove bookmark'), findsOneWidget);
      expect(find.bySemanticsLabel('Bookmark'), findsNothing);
      handle.dispose();
    });

    testWidgets('the like button says what it is, not just the count',
        (tester) async {
      final handle = tester.ensureSemantics();
      await pumpRow(
          tester, FeedEngagementRow(likeCount: 12, isLiked: true, onLike: () {}));
      expect(
        tester.getSemantics(find.bySemanticsLabel('Unlike')),
        matchesSemantics(
          label: 'Unlike',
          value: '12 likes',
          isButton: true,
          hasTapAction: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('the reaction button says what it is, with count and state',
        (tester) async {
      final handle = tester.ensureSemantics();
      String? reacted;
      await pumpRow(
        tester,
        FeedEngagementRow(
          totalReactions: 1800,
          userReaction: 'WAH_WAH',
          onReact: (r) => reacted = r,
        ),
      );

      final reactNode = tester.getSemantics(find.bySemanticsLabel('React'));
      expect(reactNode.value, 'Your reaction: wah wah, 1.8K reactions');
      expect(reactNode.flagsCollection.isButton, isTrue);
      await tester.tap(find.bySemanticsLabel('React'));
      await tester.pump(const Duration(seconds: 1));
      expect(reacted, 'LOVE');
      handle.dispose();
    });
  });

  group('FeedPoetAvatar', () {
    testWidgets('tapping the labelled avatar opens the poet profile',
        (tester) async {
      final handle = tester.ensureSemantics();
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, __) {
              final item = _poem('ur');
              return Scaffold(
                body: SingleChildScrollView(
                  child: PoemFeedCard(
                      item: item, data: item.contentData as PoemContentData),
                ),
              );
            },
          ),
          GoRoute(
            path: '/main/poets/:id',
            builder: (_, state) =>
                Text('poet page ${state.pathParameters['id']}'),
          ),
        ],
      );
      await tester.pumpWidget(ProviderScope(
        overrides: [
          selectedLanguageProvider.overrideWithValue('ur'),
          reactionTypesProvider
              .overrideWith((ref) async => const <ReactionType>[]),
        ],
        child: MaterialApp.router(routerConfig: router),
      ));
      await tester.pump();

      await tester.tap(find.bySemanticsLabel('$_poetUr, poet profile'));
      await tester.pumpAndSettle();
      expect(find.text('poet page poet-1'), findsOneWidget);
      handle.dispose();
    });
  });
}
