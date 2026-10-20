import 'package:flutter_poetry_app/core/routing/content_locations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ContentLocations.poem', () {
    test('without a couplet number: the plain poem link, as before', () {
      expect(ContentLocations.poem('poem-1'), '/main/poems/poem-1');
      expect(ContentLocations.poem('poem-1', coupletNumber: null),
          '/main/poems/poem-1');
    });

    test('with a couplet number: ?couplet=<n>', () {
      expect(ContentLocations.poem('poem-1', coupletNumber: 7),
          '/main/poems/poem-1?couplet=7');
    });

    test('0 and negative numbers (unknown) are left out', () {
      expect(ContentLocations.poem('poem-1', coupletNumber: 0),
          '/main/poems/poem-1');
      expect(ContentLocations.poem('poem-1', coupletNumber: -3),
          '/main/poems/poem-1');
    });

    test('poemQuery matches, for pushNamed', () {
      expect(ContentLocations.poemQuery(7), {'couplet': '7'});
      expect(ContentLocations.poemQuery(null), isEmpty);
      expect(ContentLocations.poemQuery(0), isEmpty);
    });
  });

  group('ContentLocations.coupletFrom (route parsing)', () {
    test('reads a positive couplet number', () {
      expect(ContentLocations.coupletFrom({'couplet': '7'}), 7);
      expect(
          ContentLocations.coupletFrom(
              Uri.parse('/main/poems/p?couplet=12').queryParameters),
          12);
    });

    test('old links (no parameter) and junk give null', () {
      expect(ContentLocations.coupletFrom(const {}), isNull);
      for (final value in ['', '0', '-1', 'abc', '2.5', '-']) {
        expect(ContentLocations.coupletFrom({'couplet': value}), isNull,
            reason: value);
      }
    });

    test('round-trips through ContentLocations.poem', () {
      final uri = Uri.parse(ContentLocations.poem('p', coupletNumber: 40));
      expect(uri.path, '/main/poems/p');
      expect(ContentLocations.coupletFrom(uri.queryParameters), 40);
    });
  });

  group('ContentLocations.hashtag', () {
    test('ASCII theme slugs are used as-is', () {
      expect(ContentLocations.hashtag('hijr'), '/hashtags/hijr');
      expect(
          ContentLocations.hashtag('gham-e-dauran'), '/hashtags/gham-e-dauran');
    });

    test('Urdu and spaced slugs are percent-encoded and decode back', () {
      final location = ContentLocations.hashtag('بہار');
      expect(location, isNot(contains('بہار')));
      expect(Uri.decodeComponent(location), '/hashtags/بہار');
      expect(ContentLocations.hashtag('a b'), '/hashtags/a%20b');
    });
  });
}
