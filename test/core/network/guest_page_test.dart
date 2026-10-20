import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_poetry_app/core/network/guest_service.dart';

import '../../helpers/fake_dio_adapter.dart';
import '../../helpers/fake_guest_api.dart';

/// T-122: the guest API clamps `page` to 0..4, so with more than five pages
/// the app asked for page 5, got page 4 again and showed it twice.
void main() {
  GuestPage<int> page(int number, int totalPages, {bool serverLast = false}) =>
      GuestPage<int>(
        items: const [1],
        page: number,
        totalPages: totalPages,
        totalElements: totalPages * 10,
        serverLast: serverLast,
      );

  group('GuestPage.isLast', () {
    test('the app\'s max page matches the backend clamp', () {
      expect(GuestService.maxPage, fakeGuestMaxPage);
      expect(GuestService.maxPageSize, fakeGuestMaxSize);
    });

    test('regression: page 4 is the last page even when more exist', () {
      expect(page(4, 12).isLast, isTrue);
      expect(page(3, 12).isLast, isFalse);
    });

    test('the server\'s last page is the last page', () {
      expect(page(1, 2).isLast, isTrue);
      expect(page(0, 0).isLast, isTrue);
      expect(page(0, 3, serverLast: true).isLast, isTrue);
    });

    test('nextPage never goes past the clamp', () {
      expect(page(3, 12).nextPage, 4);
      expect(page(4, 12).nextPage, GuestService.maxPage);
    });
  });

  group('GuestService.getPoets paging', () {
    test('page 4 of 12 is reported as the last page', () async {
      final adapter = FakeDioAdapter()
        ..on('GET', '/api/guest/poets', clampedGuestPoetsRoute(total: 120));
      final service = GuestService(AdapterDioClient(adapter));

      final fourth = await service.getPoets(page: 4, size: 10);
      expect(fourth.page, 4);
      expect(fourth.totalPages, 12);
      expect(fourth.isLast, isTrue);

      final third = await service.getPoets(page: 3, size: 10);
      expect(third.isLast, isFalse);
    });

    test('the envelope\'s "last" flag is read', () async {
      final adapter = FakeDioAdapter()
        ..on('GET', '/api/guest/poets', (_) {
          final body =
              guestPoetPage(['a'], page: 0, totalElements: 30, size: 10);
          (body['data'] as Map<String, dynamic>)['last'] = true;
          return FakeReply(200, body);
        });
      final first =
          await GuestService(AdapterDioClient(adapter)).getPoets(size: 10);
      expect(first.isLast, isTrue);
    });
  });
}
