import 'package:flutter_poetry_app/features/hashtags/models/hashtag_model.dart';
import 'package:flutter_poetry_app/features/hashtags/utils/hashtag_tabs.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('initialHashtagTab (T-178)', () {
    test('couplets first when it has content', () {
      expect(
        initialHashtagTab(
            const HashtagDto(slug: 'bahar', coupletCount: 27, poemCount: 3)),
        HashtagTab.couplets,
      );
    });

    test('regression: #Politics (0 couplets, 1 poem) opens on poems', () {
      expect(
        initialHashtagTab(
            const HashtagDto(slug: 'politics', coupletCount: 0, poemCount: 1)),
        HashtagTab.poems,
      );
    });

    test('skips every empty tab in display order', () {
      expect(initialHashtagTab(const HashtagDto(slug: 'x', imageCount: 2)),
          HashtagTab.images);
      expect(initialHashtagTab(const HashtagDto(slug: 'x', poetCount: 1)),
          HashtagTab.poets);
      expect(
        initialHashtagTab(
            const HashtagDto(slug: 'x', imageCount: 4, poetCount: 9)),
        HashtagTab.images,
        reason: 'order wins over the larger count',
      );
    });

    test('all empty (or counts absent) stays on couplets', () {
      expect(initialHashtagTab(const HashtagDto(slug: 'x')),
          HashtagTab.couplets);
      expect(initialHashtagTab(HashtagDto.fromJson(const {'slug': 'x'})),
          HashtagTab.couplets);
    });

    test('no metadata stays on couplets', () {
      expect(initialHashtagTab(null), HashtagTab.couplets);
    });
  });
}
