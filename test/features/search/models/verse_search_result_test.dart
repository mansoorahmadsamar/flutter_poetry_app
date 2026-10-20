import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_poetry_app/features/search/models/search_models.dart';

import '../helpers/search_test_harness.dart';

void main() {
  final fixture = searchFixture('unified_search_jigar.json')['data']
      as Map<String, dynamic>;
  final rawVerses = (fixture['verses'] as List).cast<Map<String, dynamic>>();

  group('VerseSearchResult.fromJson', () {
    test('real response: every verse parses with its poem id', () {
      final response = UnifiedSearchResponse.fromJson(fixture);

      expect(response.verses, hasLength(rawVerses.length));
      for (var i = 0; i < rawVerses.length; i++) {
        final v = response.verses[i];
        expect(v.poemPublicId, rawVerses[i]['poemPublicId']);
        expect(v.poemIdToOpen, rawVerses[i]['poemPublicId']);
        expect(v.poemIdToOpen, isNot(v.verse.publicId));
        expect(v.verse.text,
            (rawVerses[i]['verse'] as Map<String, dynamic>)['verseText']);
      }
    });

    test('"-" poet fields (backend before T-073) read as absent', () {
      final v = VerseSearchResult.fromJson(rawVerses.first);
      expect(v.poetPublicId, isNull);
      expect(v.poetName, isNull);
      expect(v.poetProfileImageUrl, isNull);
      expect(v.poemTitle, 'ہندو اور مسلمان');
    });

    test('poet id, name and image (backend after T-073) are kept', () {
      final v = VerseSearchResult.fromJson({
        ...rawVerses.first,
        'poetPublicId': 'poet-1',
        'poetName': 'جگر مراد آبادی',
        'poetProfileImageUrl': 'https://example.test/p.png',
      });
      expect(v.poetPublicId, 'poet-1');
      expect(v.poetName, 'جگر مراد آبادی');
      expect(v.poetProfileImageUrl, 'https://example.test/p.png');
    });

    test('a null, missing or "-" poem id parses and is not openable', () {
      for (final poemId in [null, '-', '']) {
        final v = VerseSearchResult.fromJson({
          'verse': {'verseText': 'جگر'},
          'poemPublicId': poemId,
        });
        expect(v.poemIdToOpen, isNull, reason: 'poemPublicId: $poemId');
      }
      final missing = VerseSearchResult.fromJson({
        'verse': {'verseText': 'جگر'},
      });
      expect(missing.poemIdToOpen, isNull);
    });

    test('regression: one verse without a poem id does not fail the search',
        () {
      final response = UnifiedSearchResponse.fromJson({
        ...fixture,
        'verses': [
          ...rawVerses,
          {
            'verse': {'verseText': 'جگر'},
            'poemPublicId': null,
            'poemTitle': null,
            'poetryType': null,
            'poetPublicId': null,
            'poetName': null,
          },
        ],
      });
      expect(response.verses, hasLength(rawVerses.length + 1));
      expect(response.poems, isNotEmpty);
    });

    test('romanizedText: kept when present, null for "-"', () {
      final v = VerseSearchResult.fromJson(rawVerses.first);
      expect(v.romanizedText, 'donon jigar jigar hain lekin digar digar hain');
      final dash = VerseSearchResult.fromJson({
        'verse': {'verseText': 'جگر', 'romanizedText': '-'},
      });
      expect(dash.romanizedText, isNull);
    });

    test('resultKey is the verse id, else poem id + verse number', () {
      expect(VerseSearchResult.fromJson(rawVerses.first).resultKey,
          (rawVerses.first['verse'] as Map<String, dynamic>)['publicId']);
      final noId = VerseSearchResult.fromJson({
        'verse': {'verseText': 'جگر', 'publicId': '-', 'verseNumber': 3},
        'poemPublicId': 'poem-1',
      });
      expect(noId.resultKey, 'poem-1#3');
    });
  });
}
