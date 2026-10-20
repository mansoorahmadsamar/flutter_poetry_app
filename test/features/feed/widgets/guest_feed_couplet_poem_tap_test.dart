import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_poetry_app/core/network/guest_service.dart';
import 'package:flutter_poetry_app/features/discover/models/discover_bundle_model.dart';
import 'package:flutter_poetry_app/features/feed/models/feed_content_data.dart';
import 'package:flutter_poetry_app/features/feed/models/feed_item.dart';
import 'package:flutter_poetry_app/features/feed/models/feed_response.dart';
import 'package:flutter_poetry_app/features/feed/widgets/couplet_feed_card.dart';

import '../../../helpers/feed_card_harness.dart';
import '../../../helpers/fixture_dio_client.dart';
import '../../../helpers/fixtures.dart';

/// T-111: guest couplet cards never opened their poem — the guest adapter
/// dropped the couplet's `poemPublicId`, which the guest API
/// (`GuestCoupletDto`) sends under the same name signed-in couplets use.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  const poemId = 'poem-ghalib-1';
  const misra1 = 'ہزاروں خواہشیں ایسی کہ ہر خواہش پہ دم نکلے';
  const misra2 = 'بہت نکلے مرے ارمان لیکن پھر بھی کم نکلے';

  /// The real guest discover body with one trending couplet shaped like the
  /// backend's `GuestCoupletDto`. [poemIdValue] `null` removes the field.
  Map<String, dynamic> guestBody({Object? poemIdValue = poemId}) {
    final body =
        jsonDecode(jsonEncode(loadJsonFixture('guest/discover_ur.json')))
            as Map<String, dynamic>;
    final couplet = <String, dynamic>{
      'publicId': 'couplet-1',
      'coupletNumber': 1,
      'coupletType': 'SHER',
      'verses': [
        {'verseText': misra1},
        {'verseText': misra2},
      ],
      'poetPublicId': 'poet-ghalib',
      'poetName': 'مرزا غالب',
      'poetProfileImageUrl': '-',
      'likeCount': 3,
      'shareCount': 0,
    };
    if (poemIdValue != null) couplet['poemPublicId'] = poemIdValue;
    (body['data'] as Map<String, dynamic>)['trendingCouplets'] = [couplet];
    return body;
  }

  Future<({FeedItem item, CoupletContentData data})> guestCouplet(
    WidgetTester tester,
    Map<String, dynamic> body,
  ) async {
    final bundle = await tester.runAsync(() =>
        GuestService(FixtureDioClient(body)).getDiscoverBundle(lang: 'ur'));
    final item = FeedResponse.fromGuestBundle(bundle!)
        .items
        .firstWhere((i) => i.type == 'COUPLET');
    return (item: item, data: item.contentData as CoupletContentData);
  }

  String path(GoRouter router) => Uri.decodeComponent(router.state.uri.path);

  /// The couplet card's own InkWell (the outermost one).
  InkWell cardInkWell(WidgetTester tester) => tester.widget<InkWell>(
        find
            .descendant(
              of: find.byType(CoupletFeedCard),
              matching: find.byType(InkWell),
            )
            .first,
      );

  group('adapter', () {
    test('regression: guest couplets keep their poemPublicId', () async {
      final body = guestBody();
      final bundle = await GuestService(FixtureDioClient(body))
          .getDiscoverBundle(lang: 'ur');
      final data = FeedResponse.fromGuestBundle(bundle)
          .items
          .firstWhere((i) => i.type == 'COUPLET')
          .contentData as CoupletContentData;
      expect(data.poemPublicId, poemId);
    });

    test(
        'ContentCard.fromJson: "-", blank, null and missing poem id are absent',
        () {
      Map<String, dynamic> card(Object? id) => {
            'type': 'COUPLET',
            'publicId': 'c1',
            'primaryText': 'misra',
            'poemPublicId': id,
          };
      for (final id in ['-', '', null]) {
        expect(ContentCard.fromJson(card(id)).poemPublicId, isNull);
      }
      expect(
        ContentCard.fromJson(
                {'type': 'COUPLET', 'publicId': 'c1', 'primaryText': 'm'})
            .poemPublicId,
        isNull,
      );
      expect(ContentCard.fromJson(card(poemId)).poemPublicId, poemId);
    });
  });

  group('guest couplet card with a poem id', () {
    testWidgets('regression: tapping the couplet opens its poem',
        (tester) async {
      final couplet = await guestCouplet(tester, guestBody());
      final router = await pumpFeedCardInRouter(
        tester,
        CoupletFeedCard(item: couplet.item, data: couplet.data),
        appLang: 'ur',
      );

      await tester.tap(find.text('$misra1\n$misra2'));
      await tester.pumpAndSettle();

      expect(path(router), '/main/poems/$poemId');
      expect(path(router), isNot(contains('couplet-1')));
    });

    for (final (lang, cta) in [
      ('ur', 'مزید پڑھیے  ←'),
      ('en', 'Open poem →')
    ]) {
      testWidgets('the "$cta" link opens the poem ($lang UI)', (tester) async {
        final couplet = await guestCouplet(tester, guestBody());
        final router = await pumpFeedCardInRouter(
          tester,
          CoupletFeedCard(item: couplet.item, data: couplet.data),
          appLang: lang,
        );

        await tester.tap(find.text(cta));
        await tester.pumpAndSettle();

        expect(path(router), '/main/poems/$poemId');
      });
    }
  });

  group('couplet card without a poem id is not tappable', () {
    for (final value in [null, '-', '']) {
      testWidgets(
          'guest, poemPublicId ${value == null ? 'missing' : '"$value"'}',
          (tester) async {
        final couplet =
            await guestCouplet(tester, guestBody(poemIdValue: value));
        expect(couplet.data.poemPublicId, isNull);

        final router = await pumpFeedCardInRouter(
          tester,
          CoupletFeedCard(item: couplet.item, data: couplet.data),
          appLang: 'ur',
        );

        expect(find.text('مزید پڑھیے  ←'), findsNothing);
        expect(cardInkWell(tester).onTap, isNull);
        await tester.tap(find.text('$misra1\n$misra2'));
        await tester.pumpAndSettle();
        expect(path(router), '/');
      });
    }

    testWidgets('signed-in couplet with a "-" poem id', (tester) async {
      const item = FeedItem(
        type: 'COUPLET',
        publicId: 'couplet-2',
        lang: 'ur',
        contentData: CoupletContentData(
          versesTextArabic: '$misra1\n$misra2',
          poemPublicId: '-',
          poetName: 'مرزا غالب',
        ),
      );
      final router = await pumpFeedCardInRouter(
        tester,
        CoupletFeedCard(
            item: item, data: item.contentData as CoupletContentData),
        appLang: 'en',
      );

      expect(find.text('Open poem →'), findsNothing);
      expect(cardInkWell(tester).onTap, isNull);
      await tester.tap(find.text('$misra1\n$misra2'));
      await tester.pumpAndSettle();
      expect(path(router), '/');
    });
  });
}
