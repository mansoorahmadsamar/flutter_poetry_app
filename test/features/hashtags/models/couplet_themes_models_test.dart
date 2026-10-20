import 'dart:convert';

import 'package:flutter_poetry_app/core/network/guest_service.dart';
import 'package:flutter_poetry_app/features/discover/models/discover_bundle_model.dart';
import 'package:flutter_poetry_app/features/feed/models/feed_content_data.dart';
import 'package:flutter_poetry_app/features/feed/models/feed_item.dart';
import 'package:flutter_poetry_app/features/feed/models/feed_response.dart';
import 'package:flutter_poetry_app/features/hashtags/models/couplet_theme.dart';
import 'package:flutter_poetry_app/features/hashtags/models/hashtag_model.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/models/couplet_model.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/models/poem_model.dart';
import 'package:flutter_poetry_app/features/search/models/search_models.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fixture_dio_client.dart';
import '../../../helpers/fixtures.dart';

/// Every app model that parses a couplet reads `themes[]` tolerantly
/// (theme tags, app half). Production sends no `themes` field anywhere yet,
/// so the real fixtures below must parse exactly as before, with no themes.
void main() {
  final themes = loadJsonFixture('themes/couplet_themes.json');

  Map<String, dynamic> copy(Object json) =>
      jsonDecode(jsonEncode(json)) as Map<String, dynamic>;

  /// [base] with `themes` set to [value]; [absent] removes the key.
  Map<String, dynamic> withThemes(Map<String, dynamic> base, Object? value,
      {bool absent = false}) {
    final json = copy(base);
    if (absent) {
      json.remove('themes');
    } else {
      json['themes'] = value;
    }
    return json;
  }

  /// The shared contract, run against one model's parser.
  void themesContract(
    String model,
    Map<String, dynamic> Function() realJson,
    List<CoupletTheme> Function(Map<String, dynamic> json) parse,
  ) {
    group('$model.themes', () {
      test('production shape (no themes field) parses with no themes', () {
        expect(realJson().containsKey('themes'), isFalse);
        expect(parse(realJson()), isEmpty);
      });

      test('null, "-", a map and an empty list mean no themes', () {
        for (final value in <Object?>[null, '-', const {}, const []]) {
          expect(parse(withThemes(realJson(), value)), isEmpty,
              reason: 'themes: $value');
        }
      });

      test('ranked themes keep the server order', () {
        expect(
            parse(withThemes(realJson(), themes['ranked'])).map((t) => t.slug),
            ['hijr', 'intezar', 'yaad']);
      });

      test('malformed entries are dropped, the rest kept', () {
        expect(
            parse(withThemes(realJson(), themes['messy'])).map((t) => t.slug),
            ['wafa', 'naam-nahin', 'tanhai']);
      });
    });
  }

  // ── Hashtag couplets tab: production CoupletDto (`main`) and develop ──
  final hashtagMain = loadJsonFixture('hashtags/couplets_page_main.json');
  final hashtagDevelop = loadJsonFixture('hashtags/couplets_page_develop.json');
  Map<String, dynamic> firstCouplet(Map<String, dynamic> page) => copy(
      ((page['data'] as Map)['content'] as List).first as Map<String, dynamic>);

  themesContract(
      'CoupletDetailResponse (hashtag couplets, main)',
      () => firstCouplet(hashtagMain),
      (json) => CoupletDetailResponse.fromJson(json).themes);
  themesContract(
      'CoupletDetailResponse (hashtag couplets, develop)',
      () => firstCouplet(hashtagDevelop),
      (json) => CoupletDetailResponse.fromJson(json).themes);

  // ── Poem detail couplets (CoupletModel, embedded in PoemModel) ──
  themesContract('CoupletModel', () => firstCouplet(hashtagMain),
      (json) => CoupletModel.fromJson(json).themes);

  test('PoemModel.couplets carry their themes', () {
    final couplet = withThemes(firstCouplet(hashtagMain), themes['ranked']);
    final poem = PoemModel.fromJson({
      'publicId': 'poem-bahar',
      'poetPublicId': 'poet-faiz',
      'poetName': 'فیض احمد فیض',
      'poetryType': 'GHAZAL',
      'couplets': [couplet, firstCouplet(hashtagMain)],
    });
    expect(poem.couplets.first.themes.map((t) => t.nameUr),
        ['ہجر', 'انتظار', 'یاد']);
    expect(poem.couplets.last.themes, isEmpty);
  });

  // ── Bookmarked couplets ──
  themesContract('BookmarkedCoupletResponse', () {
    final json = firstCouplet(hashtagDevelop);
    return {...json, 'coupletPublicId': json['publicId']};
  }, (json) => BookmarkedCoupletResponse.fromJson(json).themes);

  // ── Search: couplet results (production couplet, 2026-10-19) ──
  final searchVariants = loadJsonFixture('search/couplet_result_variants.json');
  themesContract(
      'CoupletSearchResult',
      () => copy(searchVariants['withoutNewFields'] as Map),
      (json) => CoupletSearchResult.fromJson(json).themes);

  test('UnifiedSearchResponse with themed and plain couplets', () {
    final data = copy(
        loadJsonFixture('search/unified_search_dil_ur.json')['data'] as Map);
    final couplets = data['couplets'] as List;
    (couplets.first as Map)['themes'] = themes['ranked'];
    final response = UnifiedSearchResponse.fromJson(data);
    expect(response.couplets.first.themes, hasLength(3));
    expect(response.couplets.skip(1).every((c) => c.themes.isEmpty), isTrue);
  });

  // ── Search: verse (misra) results (production `jigar`) ──
  final jigar =
      loadJsonFixture('search/unified_search_jigar.json')['data'] as Map;
  themesContract(
      'VerseSearchResult',
      () => copy((jigar['verses'] as List).first as Map),
      (json) => VerseSearchResult.fromJson(json).themes);

  // ── Signed-in feed couplet item (FeedItemHydrator's contentData) ──
  Map<String, dynamic> feedCouplet() => {
        'versesTextArabic': 'گلوں میں رنگ بھرے باد نو بہار چلے\n'
            'چلے بھی آؤ کہ گلشن کا کاروبار چلے',
        'versesTextRoman': 'gulon men rang bhare\nchale bhi aao',
        'poetPublicId': 'poet-faiz',
        'poetName': 'فیض احمد فیض',
        'poemPublicId': 'poem-bahar',
        'likeCount': 4,
        'shareCount': 0,
        'bookmarkCount': 1,
        'reactions': {'total': 4, 'byType': <String, int>{}},
      };
  themesContract('CoupletContentData (feed)', feedCouplet,
      (json) => CoupletContentData.fromJson(json).themes);

  test('FeedItem.fromJson keeps a couplet item whose themes are junk', () {
    final item = FeedItem.fromJson({
      'type': 'COUPLET',
      'publicId': 'cpl-1',
      'lang': 'ur',
      'contentData': withThemes(feedCouplet(), 'not-a-list'),
    });
    expect((item.contentData as CoupletContentData).themes, isEmpty);
  });

  // ── Discover / guest couplet cards ──
  Map<String, dynamic> coupletCard() => {
        'type': 'COUPLET',
        'publicId': 'cpl-1',
        'primaryText': 'misra',
        'poemPublicId': 'poem-bahar',
      };
  themesContract('ContentCard (COUPLET)', coupletCard,
      (json) => ContentCard.fromJson(json).themes);

  group('coupletNumber (opens the poem at the couplet)', () {
    test('ContentCard and CoupletContentData: 0, "-", junk and absent are null',
        () {
      for (final value in <Object?>[0, -2, '-', 'abc', 1.5, null]) {
        expect(
            ContentCard.fromJson({...coupletCard(), 'coupletNumber': value})
                .coupletNumber,
            isNull,
            reason: '$value');
        expect(
            CoupletContentData.fromJson(
                {...feedCouplet(), 'coupletNumber': value}).coupletNumber,
            isNull,
            reason: '$value');
      }
      expect(ContentCard.fromJson(coupletCard()).coupletNumber, isNull);
      expect(
          ContentCard.fromJson({...coupletCard(), 'coupletNumber': 7})
              .coupletNumber,
          7);
      expect(
          CoupletContentData.fromJson({...feedCouplet(), 'coupletNumber': '12'})
              .coupletNumber,
          12);
    });

    test('search couplets and verses expose a positive number or null', () {
      final couplet = CoupletSearchResult.fromJson(
          copy(searchVariants['withoutNewFields'] as Map));
      expect(couplet.coupletNumberToOpen, 4);
      expect(couplet.copyWith(coupletNumber: 0).coupletNumberToOpen, isNull);

      final verse = VerseSearchResult.fromJson(
          copy((jigar['verses'] as List).first as Map));
      expect(verse.coupletNumberToOpen, 1);
      final noNumber = copy((jigar['verses'] as List).first as Map);
      (noNumber['verse'] as Map).remove('coupletNumber');
      expect(VerseSearchResult.fromJson(noNumber).coupletNumberToOpen, isNull);
    });
  });

  group('guest couplets (GuestService → ContentCard → feed)', () {
    Map<String, dynamic> guestBody(Object? themesValue) {
      final body = copy(loadJsonFixture('guest/discover_ur.json'));
      (body['data'] as Map<String, dynamic>)['trendingCouplets'] = [
        {
          'publicId': 'couplet-1',
          'coupletNumber': 5,
          'coupletType': 'SHER',
          'verses': [
            {'verseText': 'ہزاروں خواہشیں ایسی کہ ہر خواہش پہ دم نکلے'},
            {'verseText': 'بہت نکلے مرے ارمان لیکن پھر بھی کم نکلے'},
          ],
          'poemPublicId': 'poem-ghalib-1',
          'poetName': 'مرزا غالب',
          'themes': themesValue,
        },
      ];
      return body;
    }

    Future<CoupletContentData> guestCouplet(Object? themesValue) async {
      final bundle =
          await GuestService(FixtureDioClient(guestBody(themesValue)))
              .getDiscoverBundle(lang: 'ur');
      return FeedResponse.fromGuestBundle(bundle)
          .items
          .firstWhere((i) => i.type == 'COUPLET')
          .contentData as CoupletContentData;
    }

    test('themes and the couplet number reach the feed card data', () async {
      final data = await guestCouplet(themes['ranked']);
      expect(data.themes.map((t) => t.slug), ['hijr', 'intezar', 'yaad']);
      expect(data.coupletNumber, 5);
    });

    test('missing / junk themes give none', () async {
      expect((await guestCouplet(null)).themes, isEmpty);
      expect((await guestCouplet('-')).themes, isEmpty);
      expect((await guestCouplet(themes['messy'])).themes.map((t) => t.slug),
          ['wafa', 'naam-nahin', 'tanhai']);
    });

    test('the real guest bundle (no couplets, no themes) still parses',
        () async {
      final bundle = await GuestService(
              FixtureDioClient(loadJsonFixture('guest/discover_ur.json')))
          .getDiscoverBundle(lang: 'ur');
      expect(bundle.recommended.items, isEmpty);
    });
  });

  group('HashtagDto localized names (theme tags)', () {
    final themeMeta = loadJsonFixture('hashtags/hashtag_meta_theme.json');

    test('reads nameUr/nameEn/nameHi/definition and ignores parent', () {
      final dto = HashtagDto.fromJson(themeMeta);
      expect(dto.nameUr, 'ہجر');
      expect(dto.nameEn, 'Separation');
      expect(dto.nameHi, 'हिज्र');
      expect(dto.definition, startsWith('Parting from'));
      expect(dto.displayName('ur'), 'ہجر');
      expect(dto.displayName('en'), 'Separation');
      expect(dto.displayName('hi'), 'हिज्र');
    });

    test('production metadata (no localized fields) shows name, else slug', () {
      final plain = HashtagDto.fromJson(
          {'slug': 'bahar', 'name': 'بہار', 'color': '-', 'coupletCount': 2});
      expect(plain.localizedName('en'), isNull);
      expect(plain.definition, isNull);
      expect(plain.displayName('en'), 'بہار');
      expect(HashtagDto.fromJson({'slug': 'bahar'}).displayName('ur'), 'bahar');
    });

    test('"-" localized names and definition are absent', () {
      final dto = HashtagDto.fromJson({
        ...themeMeta,
        'nameUr': '-',
        'nameEn': '-',
        'nameHi': null,
        'definition': '-',
        'name': '-',
      });
      expect(dto.localizedName('ur'), isNull);
      expect(dto.definition, isNull);
      // A "-" name used to show as "#-"; it now falls back to the slug.
      expect(dto.displayName('ur'), 'hijr');
    });

    test('a missing app-language name falls back to Urdu, then English', () {
      final dto = HashtagDto.fromJson({...themeMeta, 'nameHi': '-'});
      expect(dto.localizedName('hi'), (text: 'ہجر', languageCode: 'ur'));
      final enOnly =
          HashtagDto.fromJson({...themeMeta, 'nameHi': null, 'nameUr': null});
      expect(
          enOnly.localizedName('ur'), (text: 'Separation', languageCode: 'en'));
    });
  });
}
