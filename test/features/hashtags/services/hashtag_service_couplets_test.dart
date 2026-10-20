import 'package:dio/dio.dart';
import 'package:flutter_poetry_app/features/hashtags/services/hashtag_service.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/models/couplet_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_dio_adapter.dart';
import '../../../helpers/fixtures.dart';

/// A [HashtagService] whose Dio answers `/api/hashtags/bahar/couplets` with
/// [body]. No network.
HashtagService _serviceAnswering(Map<String, dynamic> body) {
  final adapter = FakeDioAdapter()
    ..on('GET', '/api/hashtags/bahar/couplets', (_) => FakeReply(200, body));
  final dio = Dio(BaseOptions(baseUrl: 'http://fake'))
    ..httpClientAdapter = adapter;
  return HashtagService(dio);
}

void main() {
  group('HashtagService.getCoupletsByHashtag (T-177)', () {
    test(
        'regression: production CoupletDto (no poem/poet fields) parses '
        'instead of failing the whole page', () async {
      final page = await _serviceAnswering(
              loadJsonFixture('hashtags/couplets_page_main.json'))
          .getCoupletsByHashtag('bahar', page: 0, size: 15);

      expect(page.totalElements, 27);
      expect(page.last, isFalse);
      expect(page.content, hasLength(2));

      final first = page.content.first;
      expect(first.publicId, 'cpl-bahar-1');
      expect(first.verses.map((v) => v.text), [
        'گلوں میں رنگ بھرے باد نو بہار چلے',
        'چلے بھی آؤ کہ گلشن کا کاروبار چلے',
      ]);
      expect(first.tagSlugs, ['bahar', 'ishq']);
      // Production sends none of these: they are absent, not "".
      expect(first.poemPublicId, isNull);
      expect(first.poetPublicId, isNull);
      expect(first.poetName, isNull);
      expect(first.poemTitle, isNull);
    });

    test('null coupletType, null tagSlugs and null createdAt are tolerated',
        () async {
      final page = await _serviceAnswering(
              loadJsonFixture('hashtags/couplets_page_main.json'))
          .getCoupletsByHashtag('bahar');
      final second = page.content[1];
      expect(second.coupletType, isNull);
      expect(second.tagSlugs, isEmpty);
      expect(second.createdAt, isNull);
      expect(second.coupletTypeName, isNull, reason: '"-" is absent');
    });

    test('develop CoupletDto: poem/poet fields are read, "-" is absent',
        () async {
      final page = await _serviceAnswering(
              loadJsonFixture('hashtags/couplets_page_develop.json'))
          .getCoupletsByHashtag('bahar');

      final withPoem = page.content[0];
      expect(withPoem.poemPublicId, 'poem-bahar');
      expect(withPoem.poemTitle, 'گلوں میں رنگ بھرے');
      expect(withPoem.poetPublicId, 'poet-faiz');
      expect(withPoem.poetName, 'فیض احمد فیض');

      final placeholders = page.content[1];
      expect(placeholders.poemPublicId, isNull);
      expect(placeholders.poemTitle, isNull);
      expect(placeholders.poetPublicId, isNull);
      expect(placeholders.poetName, isNull);
    });
  });

  group('CoupletDetailResponse.fromJson', () {
    test('missing verses read as an empty list', () {
      final couplet = CoupletDetailResponse.fromJson(const {
        'publicId': 'c1',
        'coupletNumber': 1,
      });
      expect(couplet.verses, isEmpty);
      expect(couplet.poemPublicId, isNull);
    });

    test('a full couplet detail (GET /api/couplets/{id}) still parses', () {
      final couplet = CoupletDetailResponse.fromJson(const {
        'publicId': 'c1',
        'coupletNumber': 2,
        'coupletType': 'MATLA',
        'verses': [
          {'verseText': 'دل ہی تو ہے نہ سنگ و خشت'},
        ],
        'poemPublicId': 'p1',
        'poemTitle': 'غزل',
        'poetPublicId': 'g1',
        'poetName': 'غالب',
        'likeCount': 3,
        'isLiked': true,
      });
      expect(couplet.coupletType, 'MATLA');
      expect(couplet.poemPublicId, 'p1');
      expect(couplet.poetName, 'غالب');
      expect(couplet.likeCount, 3);
      expect(couplet.isLikedByCurrentUser, isTrue);
    });
  });
}
