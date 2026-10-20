import 'package:flutter_poetry_app/features/main/tabs/poets/models/poem_model.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/models/poet_profile_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/fixtures.dart';
import '../../../../search/helpers/search_test_harness.dart';

void main() {
  group('PoetProfileModel.fromJson (T-181)', () {
    test('regression: null is* flags and gallery fields do not throw', () {
      final p = PoetProfileModel.fromJson(
          loadJsonFixture('poets/profile_placeholders.json'));
      expect(p.isFeatured, isFalse);
      expect(p.isTrending, isFalse);
      expect(p.isVerified, isFalse);
      final image = p.gallery!.single;
      expect(image.isProfileImage, isFalse);
      expect(image.imageType, 'OTHER');
      expect(image.thumbnailUrl, isNull);
    });

    test('"-" text fields read as absent', () {
      final p = PoetProfileModel.fromJson(
          loadJsonFixture('poets/profile_placeholders.json'));
      expect(p.shortBio, isNull);
      expect(p.biography, isNull);
      expect(p.era, isNull);
      expect(p.primaryLanguageName, isNull);
      expect(p.profileImageUrl, isNull,
          reason: 'so the header falls back to the gallery image');
      expect(p.name, 'نامعلوم شاعر');
    });

    test('a complete profile keeps its values', () {
      final json = loadJsonFixture('poets/profile_placeholders.json')
        ..addAll({
          'shortBio': 'اردو کے عظیم شاعر',
          'era': 'CLASSICAL',
          'isVerified': true,
          'profileImageUrl': 'https://img.test/p.jpg',
        });
      final p = PoetProfileModel.fromJson(json);
      expect(p.shortBio, 'اردو کے عظیم شاعر');
      expect(p.era, 'CLASSICAL');
      expect(p.isVerified, isTrue);
      expect(p.profileImageUrl, 'https://img.test/p.jpg');
    });
  });

  group('PoemModel.fromJson contentType (T-181)', () {
    Map<String, dynamic> realPoem() => Map<String, dynamic>.from(
        (searchFixture('unified_search_dil_ur.json')['data']
            as Map<String, dynamic>)['poems'][0] as Map);

    test('the real poem parses with its contentType', () {
      expect(PoemModel.fromJson(realPoem()).contentType, 'TEXT');
    });

    test('regression: null or missing contentType defaults to TEXT', () {
      expect(PoemModel.fromJson(realPoem()..['contentType'] = null).contentType,
          'TEXT');
      expect(PoemModel.fromJson(realPoem()..remove('contentType')).contentType,
          'TEXT');
    });
  });
}
