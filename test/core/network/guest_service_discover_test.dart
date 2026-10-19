import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_poetry_app/core/network/guest_service.dart';

import '../../helpers/fixture_dio_client.dart';
import '../../helpers/fixtures.dart';

/// Fixture: a real `GET /api/guest/discover?lang=ur` response from production
/// (public catalogue data only), captured 2026-10-19.
const _fixture = 'guest/discover_ur.json';

Map<String, dynamic> _withFeaturedPoems(List<Map<String, dynamic>> poems) {
  final body = loadJsonFixture(_fixture);
  (body['data'] as Map<String, dynamic>)['featuredPoems'] = poems;
  return body;
}

void main() {
  group('GuestService.getDiscoverBundle featured poems', () {
    test('regression: keeps the poem excerpt from the guest API', () async {
      final body = loadJsonFixture(_fixture);
      final apiPoems = ((body['data'] as Map<String, dynamic>)['featuredPoems']
              as List)
          .cast<Map<String, dynamic>>();
      final client = FixtureDioClient(body);

      final bundle = await GuestService(client).getDiscoverBundle(lang: 'ur');

      expect(client.requestedPaths, ['/api/guest/discover']);
      final cards = bundle.editorsPicks.items;
      expect(cards, hasLength(apiPoems.length));
      for (var i = 0; i < cards.length; i++) {
        expect(cards[i].primaryText, apiPoems[i]['title']);
        expect(cards[i].excerpt, apiPoems[i]['excerpt']);
        expect(cards[i].excerpt, isNot(cards[i].primaryText));
        // Couplet lines are newline-separated misras.
        expect(cards[i].excerpt!.split('\n').length, greaterThanOrEqualTo(2));
      }
    });

    test('"-", blank, null and missing excerpts are absent', () async {
      final base = (loadJsonFixture(_fixture)['data']
              as Map<String, dynamic>)['featuredPoems'][0]
          as Map<String, dynamic>;
      final poems = [
        {...base, 'excerpt': '-'},
        {...base, 'excerpt': '   '},
        {...base, 'excerpt': null},
        Map<String, dynamic>.of(base)..remove('excerpt'),
      ];
      final bundle = await GuestService(FixtureDioClient(
        _withFeaturedPoems(poems),
      )).getDiscoverBundle(lang: 'ur');

      for (final card in bundle.editorsPicks.items) {
        expect(card.excerpt, isNull);
        expect(card.primaryText, base['title']);
      }
    });

    test('a poem with no title falls back to its excerpt as the title',
        () async {
      final base = (loadJsonFixture(_fixture)['data']
              as Map<String, dynamic>)['featuredPoems'][0]
          as Map<String, dynamic>;
      final bundle = await GuestService(FixtureDioClient(
        _withFeaturedPoems([
          {...base, 'title': '-'},
        ]),
      )).getDiscoverBundle(lang: 'ur');

      final card = bundle.editorsPicks.items.single;
      expect(card.primaryText, base['excerpt']);
    });
  });
}
