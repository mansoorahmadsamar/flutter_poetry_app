import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_poetry_app/core/network/guest_service.dart';
import 'package:flutter_poetry_app/features/discover/models/discover_bundle_model.dart';
import 'package:flutter_poetry_app/features/feed/models/feed_content_data.dart';
import 'package:flutter_poetry_app/features/feed/models/feed_response.dart';

import '../../../helpers/fixture_dio_client.dart';
import '../../../helpers/fixtures.dart';

DiscoverBundle _bundleWithPoems(List<ContentCard> poems) => DiscoverBundle(
      trendingSearches: const TrendingSearches(),
      editorsPicks: ContentSection(items: poems),
      recommended: const ContentSection(),
      featuredPoets: const ContentSection(),
      categories: const ContentSection(),
      language: 'ur',
    );

void main() {
  group('FeedResponse.fromGuestBundle poem cards', () {
    test('regression: guest poem cards carry the excerpt, not the title',
        () async {
      final body = loadJsonFixture('guest/discover_ur.json');
      final apiPoems = ((body['data'] as Map<String, dynamic>)['featuredPoems']
              as List)
          .cast<Map<String, dynamic>>();
      final bundle =
          await GuestService(FixtureDioClient(body)).getDiscoverBundle(lang: 'ur');

      final feed = FeedResponse.fromGuestBundle(bundle);
      final poems = feed.items.where((i) => i.type == 'POEM').toList();

      expect(poems, hasLength(apiPoems.length));
      for (var i = 0; i < poems.length; i++) {
        final data = poems[i].contentData as PoemContentData;
        expect(data.title, apiPoems[i]['title']);
        expect(data.excerpt, apiPoems[i]['excerpt']);
        expect(data.poetName, apiPoems[i]['poetName']);
      }
    });

    test('a poem without an excerpt shows its title once, not twice', () {
      const title = 'یک بیک شورش فغاں کی طرح';
      final feed = FeedResponse.fromGuestBundle(_bundleWithPoems(const [
        ContentCard(type: 'POEM', publicId: 'p1', primaryText: title),
      ]));

      final data = feed.items.single.contentData as PoemContentData;
      expect(data.title, title);
      expect(data.excerpt, isNull);
    });

    test('an excerpt identical to the title is not repeated', () {
      const text = 'ہر حقیقت مجاز ہو جائے';
      final feed = FeedResponse.fromGuestBundle(_bundleWithPoems(const [
        ContentCard(
            type: 'POEM', publicId: 'p1', primaryText: text, excerpt: text),
      ]));

      final data = feed.items.single.contentData as PoemContentData;
      expect(data.excerpt, isNull);
    });
  });

  group('ContentCard.fromJson excerpt', () {
    Map<String, dynamic> card(Object? excerpt) => {
          'type': 'POEM',
          'publicId': 'p1',
          'primaryText': 'title',
          'excerpt': excerpt,
        };

    test('"-" placeholder and blank are null', () {
      expect(ContentCard.fromJson(card('-')).excerpt, isNull);
      expect(ContentCard.fromJson(card('')).excerpt, isNull);
      expect(ContentCard.fromJson(card(null)).excerpt, isNull);
    });

    test('missing excerpt is null (older API responses)', () {
      expect(
        ContentCard.fromJson(
            {'type': 'POEM', 'publicId': 'p1', 'primaryText': 'title'}).excerpt,
        isNull,
      );
    });

    test('Urdu lines are kept', () {
      const lines = 'ہر حقیقت مجاز ہو جائے\nکافروں کی نماز ہو جائے';
      expect(ContentCard.fromJson(card(lines)).excerpt, lines);
    });
  });

  group('guest poet public id (T-109)', () {
    test('regression: guest poem cards keep the poet\'s poetPublicId', () async {
      final body = loadJsonFixture('guest/discover_ur.json');
      final apiPoems = ((body['data'] as Map<String, dynamic>)['featuredPoems']
              as List)
          .cast<Map<String, dynamic>>();
      final bundle =
          await GuestService(FixtureDioClient(body)).getDiscoverBundle(lang: 'ur');

      final poems = FeedResponse.fromGuestBundle(bundle)
          .items
          .where((i) => i.type == 'POEM')
          .map((i) => i.contentData as PoemContentData)
          .toList();
      expect(poems, hasLength(apiPoems.length));
      for (var i = 0; i < poems.length; i++) {
        expect(poems[i].poetPublicId, apiPoems[i]['poetPublicId']);
      }
    });

    test('guest couplet cards keep the poet\'s poetPublicId', () {
      final feed = FeedResponse.fromGuestBundle(const DiscoverBundle(
        trendingSearches: TrendingSearches(),
        editorsPicks: ContentSection(),
        recommended: ContentSection(items: [
          ContentCard(
            type: 'COUPLET',
            publicId: 'c1',
            primaryText: 'misra',
            poetPublicId: 'poet-1',
          ),
        ]),
        featuredPoets: ContentSection(),
        categories: ContentSection(),
        language: 'ur',
      ));
      final data = feed.items.single.contentData as CoupletContentData;
      expect(data.poetPublicId, 'poet-1');
    });

    test('ContentCard.fromJson: "-", blank, null and missing are absent', () {
      Map<String, dynamic> card(Object? id) => {
            'type': 'POEM',
            'publicId': 'p1',
            'primaryText': 'title',
            'poetPublicId': id,
          };
      for (final id in ['-', '', null]) {
        expect(ContentCard.fromJson(card(id)).poetPublicId, isNull);
      }
      expect(
        ContentCard.fromJson(
            {'type': 'POEM', 'publicId': 'p1', 'primaryText': 't'}).poetPublicId,
        isNull,
      );
      expect(ContentCard.fromJson(card('poet-1')).poetPublicId, 'poet-1');
    });
  });
}
