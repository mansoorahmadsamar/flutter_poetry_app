import 'package:flutter_poetry_app/features/discover/models/discover_bundle_model.dart';
import 'package:flutter_poetry_app/features/discover/utils/trending_order.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fixtures.dart';

void main() {
  group('byCountDescending (T-180)', () {
    test('production order (already by count) is kept', () {
      final prod = TrendingSearches.fromJson(
          loadJsonFixture('discover/trending_searches_prod.json'));
      expect(byCountDescending(prod.daily).map((q) => q.query),
          ['Ghazal', 'Nazam', 'Naat', 'Rubai']);
    });

    test('an out-of-order list is sorted by count, highest first', () {
      const unordered = [
        TrendingQuery(query: 'Ghazal', searchCount: 1),
        TrendingQuery(query: 'Nazam', searchCount: 2),
        TrendingQuery(query: 'Naat', searchCount: 3),
        TrendingQuery(query: 'رباعی', searchCount: 4),
      ];
      expect(byCountDescending(unordered).map((q) => q.query),
          ['رباعی', 'Naat', 'Nazam', 'Ghazal']);
    });

    test('equal and missing counts keep the server order', () {
      final queries = [
        TrendingQuery.fromJson(const {'query': 'a'}),
        const TrendingQuery(query: 'b', searchCount: 5),
        TrendingQuery.fromJson(const {'query': 'c'}),
        const TrendingQuery(query: 'd', searchCount: 5),
      ];
      expect(byCountDescending(queries).map((q) => q.query),
          ['b', 'd', 'a', 'c']);
    });

    test('empty stays empty', () {
      expect(byCountDescending(const []), isEmpty);
    });
  });
}
