import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_poetry_app/features/search/models/global_search_state.dart';
import 'package:flutter_poetry_app/features/search/models/search_models.dart';
import 'package:flutter_poetry_app/features/search/utils/search_segment_results.dart';

import '../helpers/search_test_harness.dart';

void main() {
  final jigar = realRomanJigarResponse();

  group('SearchSegmentResults', () {
    test('each tab pages with its own /api/search type', () {
      expect(DiscoverSegment.poets.apiType, 'poets_only');
      expect(DiscoverSegment.poems.apiType, 'poems_only');
      expect(DiscoverSegment.verses.apiType, 'couplets_only');
      expect(DiscoverSegment.misras.apiType, 'verses_only');
      expect(DiscoverSegment.categories.apiType, 'categories_only');
    });

    test('مصرعے counts, totals and pages verse hits', () {
      expect(DiscoverSegment.misras.loadedCount(jigar), jigar.verses.length);
      expect(DiscoverSegment.misras.total(jigar), jigar.totalVerses);
      expect(DiscoverSegment.misras.hasMore(jigar), jigar.hasMoreVerses);
      // اشعار (couplets) is a different list.
      expect(DiscoverSegment.verses.loadedCount(jigar), 0);
    });

    test('"All" has no list and never pages', () {
      expect(DiscoverSegment.all.loadedCount(jigar), 0);
      expect(DiscoverSegment.all.hasMore(jigar), isFalse);
      expect(DiscoverSegment.all.merge(jigar, jigar), same(jigar));
    });

    test('merge appends the next page of verses', () {
      final page = UnifiedSearchResponse(
        verses: [
          for (final v in jigar.verses)
            v.copyWith(
                verse: v.verse.copyWith(publicId: '${v.verse.publicId}-2')),
        ],
        hasMoreVerses: true,
      );
      final merged = DiscoverSegment.misras.merge(jigar, page);
      expect(merged.verses, hasLength(jigar.verses.length * 2));
      expect(merged.hasMoreVerses, isTrue);
      expect(merged.poems, jigar.poems, reason: 'other tabs untouched');
    });

    test('an item already loaded is not added twice', () {
      final page = UnifiedSearchResponse(
        poems: [jigar.poems.first, jigar.poems.first.copyWith(publicId: 'new')],
        hasMorePoems: true,
      );
      final merged = DiscoverSegment.poems.merge(jigar, page);
      expect(
          merged.poems
              .map((p) => p.publicId)
              .where((id) => id == jigar.poems.first.publicId),
          hasLength(1));
      expect(merged.poems.last.publicId, 'new');
    });

    test('a page that adds nothing new ends paging', () {
      final page =
          UnifiedSearchResponse(verses: jigar.verses, hasMoreVerses: true);
      final merged = DiscoverSegment.misras.merge(jigar, page);
      expect(merged.verses, hasLength(jigar.verses.length));
      expect(merged.hasMoreVerses, isFalse);
    });
  });
}
