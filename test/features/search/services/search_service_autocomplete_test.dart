import 'package:dio/dio.dart';
import 'package:flutter_poetry_app/features/search/models/search_models.dart';
import 'package:flutter_poetry_app/features/search/services/search_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_auth_notifier.dart';
import '../../../helpers/fake_dio_adapter.dart';
import '../helpers/search_test_harness.dart';

/// A real [SearchService] whose `/api/search/autocomplete` answers [reply].
({SearchService service, FakeDioAdapter adapter, ProviderContainer container})
    _service({required bool signedIn, FakeReply? reply}) {
  final adapter = FakeDioAdapter()
    ..on('GET', '/api/search/autocomplete',
        (_) => reply ?? FakeReply(200, searchFixture('autocomplete_dil_main.json')));
  final dio = Dio(BaseOptions(baseUrl: 'http://fake.test'))
    ..httpClientAdapter = adapter;
  final container = ProviderContainer(overrides: [
    authOverride(
        signedIn ? FakeAuthNotifier.signedIn() : FakeAuthNotifier.guest()),
  ]);
  final provider = Provider<SearchService>((ref) => SearchService(dio, ref));
  return (
    service: container.read(provider),
    adapter: adapter,
    container: container,
  );
}

void main() {
  group('SearchService.getAutocomplete (T-182)', () {
    test('parses the backend AutocompleteSuggestions shape (main/develop)',
        () async {
      final s = _service(signedIn: true);
      addTearDown(s.container.dispose);

      final r = await s.service.getAutocomplete(query: 'دل', lang: 'ur');

      expect(r.totalCount, 8);
      expect(r.poets.map((p) => p.name), ['داغ دہلوی', 'دلاور فگار']);
      expect(r.poets[1].score, 0.0, reason: 'null Float score');
      expect(r.poets[1].era, isNull, reason: '"-" era is absent');
      expect(r.poets[0].profileImageUrl, isNull);
      expect(r.poems.first.poetName, 'مرزا غالب');
      expect(r.poems[1].poetName, isNull, reason: '"-" poet is absent');
      expect(r.poems[1].poetryType, isNull);
      expect(r.tags.map((t) => t.slug), ['dil', 'dilli']);
      expect(r.tags[1].tagType, isNull);
      expect(r.categories.single.poemCount, 42);
      expect(s.adapter.requests.single.queryParameters,
          {'q': 'دل', 'lang': 'ur'});
    });

    test(
        'regression: guests get suggestions too — /api/search/** is public '
        '(SecurityConfig permitAll on main and develop)', () async {
      final s = _service(signedIn: false);
      addTearDown(s.container.dispose);

      final r = await s.service.getAutocomplete(query: 'دل');

      expect(s.adapter.requestsTo('/api/search/autocomplete'), hasLength(1));
      expect(r.poets, isNotEmpty);
    });

    test('a query under 2 characters makes no request', () async {
      final s = _service(signedIn: true);
      addTearDown(s.container.dispose);

      final r = await s.service.getAutocomplete(query: ' د ');
      expect(r, const AutocompleteResponse());
      expect(s.adapter.requests, isEmpty);
    });

    test('a server error surfaces (the notifier decides), not silent empty',
        () async {
      final s = _service(
          signedIn: true, reply: const FakeReply(500, {'success': false}));
      addTearDown(s.container.dispose);

      expect(s.service.getAutocomplete(query: 'دل'),
          throwsA(isA<DioException>()));
    });

    test('tag/poem fields absent or null (a NON_NULL DTO) still parse', () {
      final r = AutocompleteResponse.fromJson(const {
        'poems': [
          {'publicId': 'p1', 'title': 'غزل'},
        ],
        'tags': [
          {'publicId': 't1', 'name': 'دل', 'slug': 'dil', 'tagType': null},
        ],
      });
      expect(r.poems.single.poetName, isNull);
      expect(r.tags.single.tagType, isNull);
    });
  });
}
