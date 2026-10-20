import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_poetry_app/core/network/dto/api_response.dart';
import 'package:flutter_poetry_app/core/network/guest_service.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/models/poet_model.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/services/poet_service.dart';

import '../../../../../helpers/fake_auth_notifier.dart';
import '../../../../../helpers/fake_dio_adapter.dart';
import '../../../../../helpers/fake_guest_api.dart';
import '../../../../../helpers/fixtures.dart';

/// T-045 (app half): guests' poet filters call the guest filter endpoints of
/// docs/contracts/guest-poets.md. This app ships before the backend, so a
/// backend without them (404, or 401/405 from an old security chain) falls
/// back to the unfiltered `GET /api/guest/poets` — never an error.
void main() {
  late FakeDioAdapter adapter;
  late PoetService service;
  late ProviderContainer container;

  final featuredBody = loadJsonFixture('guest/poets_featured_page.json');

  setUp(() {
    adapter = FakeDioAdapter()
      ..on('GET', '/api/guest/poets', clampedGuestPoetsRoute(total: 30));
    container = ProviderContainer(overrides: [
      authOverride(FakeAuthNotifier.guest()),
      guestServiceProvider
          .overrideWithValue(GuestService(AdapterDioClient(adapter))),
    ]);
    // Signed-in endpoints would fail loudly: this Dio has no routes.
    service = container.read(Provider((ref) => PoetService(Dio(), ref)));
  });

  tearDown(() => container.dispose());

  List<String> paths() => [for (final r in adapter.requests) r.path];

  /// The four filters, each with its contract path and the app call.
  final filters = <({
    String name,
    String path,
    Future<PaginatedResponse<PoetModel>> Function(PoetService s) call,
  })>[
    (
      name: 'featured',
      path: '/api/guest/poets/featured',
      call: (s) => s.getFeaturedPoets(page: 1, size: 8, lang: 'en'),
    ),
    (
      name: 'trending',
      path: '/api/guest/poets/trending',
      call: (s) => s.getTrendingPoets(page: 1, size: 8, lang: 'en'),
    ),
    (
      name: 'era',
      path: '/api/guest/poets/era/CLASSICAL',
      call: (s) =>
          s.getPoetsByEra(era: 'CLASSICAL', page: 1, size: 8, lang: 'en'),
    ),
    (
      name: 'gender',
      path: '/api/guest/poets/gender/FEMALE',
      call: (s) =>
          s.getPoetsByGender(gender: 'FEMALE', page: 1, size: 8, lang: 'en'),
    ),
  ];

  for (final f in filters) {
    group('guest ${f.name}', () {
      test('calls ${f.path} once and parses the contract page', () async {
        adapter.on('GET', f.path, (_) => FakeReply(200, featuredBody));

        final result = await f.call(service);

        expect(paths(), [f.path], reason: 'no unfiltered fallback call');
        expect(adapter.requests.single.queryParameters,
            {'page': 1, 'size': 8, 'lang': 'en'});
        expect(result.content.map((p) => p.publicId), [
          '0d24be0d-4a51-4d33-8a16-4c3809c71155',
          '7a3c1f52-9b0e-4c1d-8e2f-5d6a7b8c9d0e',
        ]);
        expect(result.content.first.name, 'Mirza Ghalib');
        expect(result.content.last.era, isNull);
        expect(result.last, isTrue);
      });

      for (final status in [404, 401, 405]) {
        test(
            'regression: $status (backend without it) falls back to '
            '/api/guest/poets', () async {
          adapter.on(
            'GET',
            f.path,
            (_) => FakeReply(
                status, {'success': false, 'message': 'Poet not found'}),
          );

          final result = await f.call(service);

          expect(paths(), [f.path, '/api/guest/poets']);
          expect(adapter.requests.last.queryParameters,
              {'page': 1, 'size': 8, 'lang': 'en'});
          expect(result.content, hasLength(8));
          expect(result.content.first.publicId, 'p-8');
        });
      }

      test('after a 404 the filter goes straight to the fallback', () async {
        // No route registered: the fake answers 404, like today's backend.
        await f.call(service);
        await f.call(service);

        expect(paths(), [f.path, '/api/guest/poets', '/api/guest/poets']);
      });

      test('a server error is not hidden by the fallback', () async {
        adapter.on(
            'GET', f.path, (_) => const FakeReply(500, {'success': false}));

        await expectLater(f.call(service), throwsA(isA<DioException>()));
        expect(paths(), [f.path]);
      });
    });
  }

  test(
      'one 404 era marks every era unsupported (one wasted call, not one '
      'per era)', () async {
    await service.getPoetsByEra(era: 'CLASSICAL');
    await service.getPoetsByEra(era: 'MODERN');

    expect(paths(), [
      '/api/guest/poets/era/CLASSICAL',
      '/api/guest/poets',
      '/api/guest/poets',
    ]);
  });

  test('a 404 on one filter does not disable the others', () async {
    adapter.on('GET', '/api/guest/poets/trending',
        (_) => FakeReply(200, featuredBody));
    await service.getFeaturedPoets(); // 404 → fallback
    final trending = await service.getTrendingPoets();

    expect(paths(), [
      '/api/guest/poets/featured',
      '/api/guest/poets',
      '/api/guest/poets/trending',
    ]);
    expect(trending.content.first.name, 'Mirza Ghalib');
  });

  test('getAllPoets keeps using /api/guest/poets', () async {
    await service.getAllPoets();
    expect(paths(), ['/api/guest/poets']);
  });
}
