import 'package:flutter_poetry_app/features/hashtags/widgets/hashtag_images_tab.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('hashtagImageUrl (T-181)', () {
    test('regression: a "-" thumbnail falls back to the image URL', () {
      expect(
          hashtagImageUrl(const {
            'thumbnailUrl': '-',
            'imageUrl': 'https://img.test/full.jpg',
          }),
          'https://img.test/full.jpg');
    });

    test('thumbnail first; null, blank and missing fall back', () {
      expect(
          hashtagImageUrl(const {
            'thumbnailUrl': 'https://img.test/t.jpg',
            'imageUrl': 'https://img.test/full.jpg',
          }),
          'https://img.test/t.jpg');
      expect(hashtagImageUrl(const {'thumbnailUrl': null, 'imageUrl': 'u'}), 'u');
      expect(hashtagImageUrl(const {'thumbnailUrl': ' ', 'imageUrl': 'u'}), 'u');
      expect(hashtagImageUrl(const {'imageUrl': 'u'}), 'u');
    });

    test('nothing usable is null', () {
      expect(hashtagImageUrl(const {'thumbnailUrl': '-', 'imageUrl': '-'}),
          isNull);
      expect(hashtagImageUrl(const {}), isNull);
    });
  });
}
