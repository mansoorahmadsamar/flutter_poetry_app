import 'package:dio/dio.dart';
import 'package:flutter_poetry_app/core/network/dio_client.dart';

import 'fake_dio_adapter.dart';

/// A [DioClient] stand-in over a real [Dio] whose adapter is [adapter], so
/// HTTP errors (404, 401, …) surface as real [DioException]s. Only `get` is
/// supported — the guest API is GET-only.
class AdapterDioClient implements DioClient {
  AdapterDioClient(this.adapter)
      : _dio = Dio(BaseOptions(baseUrl: 'http://fake.test'))
          ..httpClientAdapter = adapter;

  final FakeDioAdapter adapter;
  final Dio _dio;

  @override
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) =>
      _dio.get<T>(path, queryParameters: queryParameters);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// The backend's guest page limits (`GuestController.guestPageable`):
/// `page` clamped to 0..4, `size` to 1..20.
const fakeGuestMaxPage = 4;
const fakeGuestMaxSize = 20;

/// A guest poet as `GuestPoetSummaryDto` (docs/contracts/guest-poets.md).
Map<String, dynamic> guestPoetJson(String id, {String era = 'CLASSICAL'}) => {
      'publicId': id,
      'name': 'Poet $id',
      'shortBio': '-',
      'profileImageUrl': '-',
      'birthYear': 1800,
      'deathYear': 1869,
      'era': era,
      'country': '-',
      'countryFlag': '-',
      'poemCount': 7,
    };

/// A Spring `Page` envelope of [ids] as the guest poet endpoints send it,
/// with the server's page clamp applied to `number`.
Map<String, dynamic> guestPoetPage(
  List<String> ids, {
  required int page,
  required int totalElements,
  required int size,
}) {
  final totalPages = (totalElements / size).ceil();
  return {
    'success': true,
    'message': 'Poets retrieved',
    'data': {
      'content': [for (final id in ids) guestPoetJson(id)],
      'totalElements': totalElements,
      'totalPages': totalPages,
      'number': page,
      'size': size,
      'first': page == 0,
      'last': page >= totalPages - 1,
      'numberOfElements': ids.length,
      'empty': ids.isEmpty,
    },
  };
}

/// Answers [path] like the backend: [total] poets with ids `<prefix>-<i>`,
/// paged with the server's clamp (a request for page 7 gets page 4 again).
FakeRoute clampedGuestPoetsRoute({required int total, String prefix = 'p'}) =>
    (options) {
      final q = options.queryParameters;
      final size = ((q['size'] as int?) ?? 10).clamp(1, fakeGuestMaxSize);
      final page = ((q['page'] as int?) ?? 0).clamp(0, fakeGuestMaxPage);
      final start = page * size;
      final ids = [
        for (var i = start; i < total && i < start + size; i++) '$prefix-$i',
      ];
      return FakeReply(
        200,
        guestPoetPage(ids, page: page, totalElements: total, size: size),
      );
    };
