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
}
