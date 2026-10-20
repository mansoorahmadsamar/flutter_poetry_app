import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_poetry_app/features/search/models/search_models.dart';

Map<String, dynamic> _fixture(String name) =>
    jsonDecode(File('test/fixtures/search/$name').readAsStringSync())
        as Map<String, dynamic>;

void main() {
  final variants = _fixture('couplet_result_variants.json');
  CoupletSearchResult variant(String key) => CoupletSearchResult.fromJson(
        variants[key] as Map<String, dynamic>,
      );

  // Values are read from the fixtures, never retyped by hand.
  final withFields = variants['withNewFields'] as Map<String, dynamic>;

  group('UnifiedSearchResponse.fromJson (real production fixtures)', () {
    test('Urdu query: couplets parse, and today they carry no poem link', () {
      final data = _fixture('unified_search_dil_ur.json')['data']
          as Map<String, dynamic>;
      final response = UnifiedSearchResponse.fromJson(data);
      final rawCouplets = data['couplets'] as List<dynamic>;

      expect(response.couplets, hasLength(rawCouplets.length));
      expect(response.couplets, isNotEmpty);
      final first = response.couplets.first;
      final rawFirst = rawCouplets.first as Map<String, dynamic>;
      expect(first.publicId, rawFirst['publicId']);
      expect(
        first.verses.map((v) => v.text),
        (rawFirst['verses'] as List)
            .map((v) => (v as Map<String, dynamic>)['verseText']),
      );
      // The bug: nothing in today's payload says which poem to open.
      expect(first.poem, isNull);
      expect(first.poemPublicId, isNull);
      expect(first.poemIdToOpen, isNull);
    });

    test('Roman query parses, including "-" placeholders on poems/verses', () {
      final data =
          _fixture('unified_search_jigar.json')['data'] as Map<String, dynamic>;
      final response = UnifiedSearchResponse.fromJson(data);
      expect(response.poems, hasLength((data['poems'] as List).length));
      expect(response.poets, hasLength((data['poets'] as List).length));
      expect(response.verses, hasLength((data['verses'] as List).length));
      expect(response.couplets, isEmpty);
    });
  });

  group('CoupletSearchResult poem/poet fields', () {
    test('without the new fields: no poem to open, nothing to attribute', () {
      final couplet = variant('withoutNewFields');
      expect(couplet.poemPublicId, isNull);
      expect(couplet.poemTitle, isNull);
      expect(couplet.poetPublicId, isNull);
      expect(couplet.poetName, isNull);
      expect(couplet.poemIdToOpen, isNull);
      expect(couplet.displayPoetName, isNull);
      expect(couplet.displayPoemTitle, isNull);
    });

    test('with the new fields: opens its poem, not the couplet id', () {
      final couplet = variant('withNewFields');
      expect(couplet.poemPublicId, withFields['poemPublicId']);
      expect(couplet.poemTitle, withFields['poemTitle']);
      expect(couplet.poetPublicId, withFields['poetPublicId']);
      expect(couplet.poetName, withFields['poetName']);
      expect(couplet.poemIdToOpen, withFields['poemPublicId']);
      expect(couplet.poemIdToOpen, isNot(couplet.publicId));
      expect(couplet.displayPoetName, withFields['poetName']);
      expect(couplet.displayPoemTitle, withFields['poemTitle']);
    });

    test('"-" placeholders are absent, not ids', () {
      final couplet = variant('placeholders');
      expect(couplet.poemPublicId, isNull);
      expect(couplet.poemTitle, isNull);
      expect(couplet.poetPublicId, isNull);
      expect(couplet.poetName, isNull);
      expect(couplet.poemIdToOpen, isNull);
    });

    test('explicit nulls are absent', () {
      final couplet = variant('nulls');
      expect(couplet.poemIdToOpen, isNull);
      expect(couplet.displayPoetName, isNull);
    });

    test('falls back to the legacy nested poem/poet objects', () {
      final raw = variants['legacyNestedPoem'] as Map<String, dynamic>;
      final couplet = variant('legacyNestedPoem');
      final poem = raw['poem'] as Map<String, dynamic>;
      final poet = raw['poet'] as Map<String, dynamic>;
      expect(couplet.poemPublicId, isNull);
      expect(couplet.poemIdToOpen, poem['publicId']);
      expect(couplet.displayPoemTitle, poem['title']);
      expect(couplet.displayPoetName, poet['name']);
    });

    test('the flat field wins over a nested poem', () {
      final json = Map<String, dynamic>.of(
        variants['legacyNestedPoem'] as Map<String, dynamic>,
      )..['poemPublicId'] = 'flat-poem-id';
      expect(CoupletSearchResult.fromJson(json).poemIdToOpen, 'flat-poem-id');
    });

    test('a nested poem whose id is "-" is not openable', () {
      final json = Map<String, dynamic>.of(
        variants['withoutNewFields'] as Map<String, dynamic>,
      )..['poem'] = {'publicId': '-', 'title': '-', 'poetName': '-'};
      final couplet = CoupletSearchResult.fromJson(json);
      expect(couplet.poemIdToOpen, isNull);
      expect(couplet.displayPoemTitle, isNull);
    });

    test('unknown extra fields are ignored', () {
      final json = Map<String, dynamic>.of(
        variants['withNewFields'] as Map<String, dynamic>,
      )..['someFutureField'] = {'x': 1};
      expect(
        CoupletSearchResult.fromJson(json).poemIdToOpen,
        withFields['poemPublicId'],
      );
    });
  });
}
