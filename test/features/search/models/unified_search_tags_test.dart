import 'package:flutter_poetry_app/features/search/models/search_models.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/search_test_harness.dart';

/// `/api/search` tags are `TagDto`s whose `tagType` is an enum: a null one is
/// sent as JSON null (the "-" replacement covers Strings only), which used to
/// fail the whole search response (T-181).
void main() {
  Map<String, dynamic> withTags(List<Map<String, dynamic>> tags) {
    final data = Map<String, dynamic>.from(
        searchFixture('unified_search_dil_ur.json')['data'] as Map);
    return data
      ..['tags'] = tags
      ..['tagCount'] = tags.length
      ..['totalTags'] = tags.length;
  }

  test('regression: a tag with a null tagType does not fail the search', () {
    final r = UnifiedSearchResponse.fromJson(withTags([
      {
        'publicId': 'tag-dil',
        'name': 'دل',
        'slug': 'dil',
        'color': '-',
        'tagType': null,
        'description': '-',
        'isActive': null,
      },
    ]));
    expect(r.tags.single.slug, 'dil');
    expect(r.tags.single.tagType, isNull);
    expect(r.poems, isNotEmpty, reason: 'the rest of the response survives');
  });

  test('a tag with a type keeps it', () {
    final r = UnifiedSearchResponse.fromJson(withTags([
      {'publicId': 't', 'name': 'ishq', 'slug': 'ishq', 'tagType': 'THEME'},
    ]));
    expect(r.tags.single.tagType, 'THEME');
  });
}
