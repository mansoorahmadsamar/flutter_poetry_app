import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_poetry_app/core/network/guest_service.dart';
import 'package:flutter_poetry_app/features/feed/models/feed_content_data.dart';
import 'package:flutter_poetry_app/features/feed/models/feed_item.dart';
import 'package:flutter_poetry_app/features/feed/models/feed_response.dart';
import 'package:flutter_poetry_app/features/feed/widgets/couplet_feed_card.dart';
import 'package:flutter_poetry_app/features/feed/widgets/feed_poet_avatar.dart';
import 'package:flutter_poetry_app/features/feed/widgets/poem_feed_card.dart';

import '../../../helpers/feed_card_harness.dart';
import '../../../helpers/fixture_dio_client.dart';
import '../../../helpers/fixtures.dart';

/// T-109: guests' feed cards showed the poet's avatar and name, but neither
/// opened the poet — the guest adapter dropped the poet's public id, which
/// the guest API sends as `poetPublicId` (the same field the signed-in feed's
/// `contentData` uses).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  const poetId = 'poet-ghalib';
  const poetName = 'مرزا غالب';

  /// The real guest discover body, plus one trending couplet shaped like the
  /// backend's `GuestCoupletDto`. [poetIdValue] replaces every item's
  /// `poetPublicId` (`null` removes the field).
  Map<String, dynamic> guestBody({Object? poetIdValue = poetId}) {
    final body =
        jsonDecode(jsonEncode(loadJsonFixture('guest/discover_ur.json')))
            as Map<String, dynamic>;
    final data = body['data'] as Map<String, dynamic>;
    data['trendingCouplets'] = [
      {
        'publicId': 'couplet-1',
        'coupletNumber': 1,
        'coupletType': 'SHER',
        'verses': [
          {'verseText': 'ہزاروں خواہشیں ایسی کہ ہر خواہش پہ دم نکلے'},
          {'verseText': 'بہت نکلے مرے ارمان لیکن پھر بھی کم نکلے'},
        ],
        'poemPublicId': 'poem-1',
        'poetPublicId': poetId,
        'poetName': poetName,
        'poetProfileImageUrl': '-',
        'likeCount': 3,
        'shareCount': 0,
      },
    ];
    for (final item in [
      ...(data['featuredPoems'] as List).cast<Map<String, dynamic>>(),
      ...(data['trendingCouplets'] as List).cast<Map<String, dynamic>>(),
    ]) {
      if (poetIdValue == null) {
        item.remove('poetPublicId');
      } else {
        item['poetPublicId'] = poetIdValue;
      }
    }
    return body;
  }

  Future<FeedResponse> guestFeed(
      WidgetTester tester, Map<String, dynamic> body) async {
    final bundle = await tester.runAsync(() =>
        GuestService(FixtureDioClient(body)).getDiscoverBundle(lang: 'ur'));
    return FeedResponse.fromGuestBundle(bundle!);
  }

  /// The first guest poem card, with its CloudFront avatar URL dropped so the
  /// test never opens an HttpClient.
  Future<({FeedItem item, PoemContentData data})> guestPoem(
    WidgetTester tester,
    Map<String, dynamic> body,
  ) async {
    final item = (await guestFeed(tester, body))
        .items
        .firstWhere((i) => i.type == 'POEM');
    return (
      item: item,
      data: (item.contentData as PoemContentData)
          .copyWith(poetProfileImageUrl: null),
    );
  }

  Future<({FeedItem item, CoupletContentData data})> guestCouplet(
    WidgetTester tester,
    Map<String, dynamic> body,
  ) async {
    final item = (await guestFeed(tester, body))
        .items
        .firstWhere((i) => i.type == 'COUPLET');
    return (item: item, data: item.contentData as CoupletContentData);
  }

  String path(GoRouter router) => Uri.decodeComponent(router.state.uri.path);

  group('guest feed: poet id present', () {
    for (final lang in ['ur', 'en']) {
      testWidgets('regression: poem card avatar opens the poet ($lang UI)',
          (tester) async {
        final apiPoem = ((loadJsonFixture('guest/discover_ur.json')['data']
                as Map<String, dynamic>)['featuredPoems'] as List)
            .first as Map<String, dynamic>;
        // The real guest response already carries `poetPublicId`.
        final realPoem =
            await guestPoem(tester, loadJsonFixture('guest/discover_ur.json'));
        expect(realPoem.data.poetPublicId, apiPoem['poetPublicId']);

        final handle = tester.ensureSemantics();
        final router = await pumpFeedCardInRouter(
          tester,
          PoemFeedCard(item: realPoem.item, data: realPoem.data),
          appLang: lang,
        );

        await tester
            .tap(find.bySemanticsLabel('${apiPoem['poetName']}, poet profile'));
        await tester.pumpAndSettle();

        expect(path(router), '/main/poets/${apiPoem['poetPublicId']}');
        handle.dispose();
      });
    }

    testWidgets('poem card poet name opens the poet', (tester) async {
      final poem = await guestPoem(tester, guestBody());
      final router = await pumpFeedCardInRouter(
        tester,
        PoemFeedCard(item: poem.item, data: poem.data),
        appLang: 'ur',
      );

      await tester.tap(find.text(poem.data.poetName!));
      await tester.pumpAndSettle();

      expect(path(router), '/main/poets/$poetId');
    });

    testWidgets('couplet card avatar and name open the poet', (tester) async {
      final couplet = await guestCouplet(tester, guestBody());
      expect(couplet.data.poetPublicId, poetId);

      final handle = tester.ensureSemantics();
      final router = await pumpFeedCardInRouter(
        tester,
        CoupletFeedCard(item: couplet.item, data: couplet.data),
        appLang: 'ur',
      );

      await tester.tap(find.bySemanticsLabel('$poetName, poet profile'));
      await tester.pumpAndSettle();
      expect(path(router), '/main/poets/$poetId');

      router.go('/');
      await tester.pumpAndSettle();
      await tester.tap(find.text(poetName));
      await tester.pumpAndSettle();
      expect(path(router), '/main/poets/$poetId');
      handle.dispose();
    });
  });

  group('guest feed: poet id absent (current production)', () {
    /// Neither the avatar (its semantics and gesture) nor the poet name has
    /// a tap handler of its own.
    void expectPoetNotTappable(WidgetTester tester, String name) {
      final avatar = find.byType(FeedPoetAvatar);
      final semantics = tester.widget<Semantics>(
        find.descendant(of: avatar, matching: find.byType(Semantics)).first,
      );
      expect(semantics.properties.label, '$name, poet profile');
      expect(semantics.properties.button, isFalse);
      expect(semantics.properties.onTap, isNull);
      expect(
        tester
            .widgetList<GestureDetector>(
              find.descendant(
                  of: avatar, matching: find.byType(GestureDetector)),
            )
            .where((g) => g.onTap != null),
        isEmpty,
      );

      // The name's own (closest) detector; the card's InkWell further up
      // still opens the item itself.
      final nameDetector = find
          .ancestor(of: find.text(name), matching: find.byType(GestureDetector))
          .first;
      expect(
        tester.widget<GestureDetector>(nameDetector).onTap,
        isNull,
        reason: 'the poet name must not act as a link to /main/poets/-',
      );
    }

    for (final value in [kAbsent, '-', '']) {
      testWidgets(
          'poem card: poetPublicId ${value == kAbsent ? 'missing' : '"$value"'}',
          (tester) async {
        final poem = await guestPoem(
            tester, guestBody(poetIdValue: value == kAbsent ? null : value));
        expect(poem.data.poetPublicId, isNull);

        final handle = tester.ensureSemantics();
        await pumpFeedCardInRouter(
          tester,
          PoemFeedCard(item: poem.item, data: poem.data),
          appLang: 'ur',
        );
        expectPoetNotTappable(tester, poem.data.poetName!);
        handle.dispose();
      });
    }

    testWidgets('couplet card: poetPublicId "-"', (tester) async {
      final couplet = await guestCouplet(tester, guestBody(poetIdValue: '-'));
      expect(couplet.data.poetPublicId, isNull);

      final handle = tester.ensureSemantics();
      await pumpFeedCardInRouter(
        tester,
        CoupletFeedCard(item: couplet.item, data: couplet.data),
        appLang: 'ur',
      );
      expectPoetNotTappable(tester, poetName);
      handle.dispose();
    });

    testWidgets('signed-in card with a "-" poet id is not a link either',
        (tester) async {
      const item = FeedItem(
        type: 'POEM',
        publicId: 'p1',
        lang: 'ur',
        contentData: PoemContentData(
          title: 'یک بیک شورش فغاں کی طرح',
          poetPublicId: '-',
          poetName: poetName,
        ),
      );
      final handle = tester.ensureSemantics();
      await pumpFeedCardInRouter(
        tester,
        PoemFeedCard(item: item, data: item.contentData as PoemContentData),
        appLang: 'ur',
      );
      expectPoetNotTappable(tester, poetName);
      handle.dispose();
    });
  });
}

/// Marks "remove the field" in the absent-id variants.
const kAbsent = '<absent>';
