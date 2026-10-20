import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_poetry_app/core/network/dio_client.dart';
import 'package:flutter_poetry_app/core/network/guest_service.dart';

/// Search results open poet and poem detail. For guests those screens load
/// through GuestService; this pins that they use the anonymous /api/guest/**
/// paths (authenticated paths 401 for guests).
void main() {
  final data = (jsonDecode(
    File('test/fixtures/search/unified_search_dil_ur.json').readAsStringSync(),
  ) as Map<String, dynamic>)['data'] as Map<String, dynamic>;
  final poemJson = (data['poems'] as List).first as Map<String, dynamic>;
  final poetJson = (data['poets'] as List).first as Map<String, dynamic>;

  test('getPoemById calls GET /api/guest/poems/:publicId', () async {
    final client = _FakeDioClient({'success': true, 'data': poemJson});
    final poem = await GuestService(client)
        .getPoemById(poemJson['publicId'] as String, lang: 'ur');

    expect(client.paths, ['/api/guest/poems/${poemJson['publicId']}']);
    expect(client.queries.single, {'lang': 'ur'});
    expect(poem.publicId, poemJson['publicId']);
  });

  test('getPoetById calls GET /api/guest/poets/:publicId', () async {
    final client = _FakeDioClient({'success': true, 'data': poetJson});
    final poet = await GuestService(client)
        .getPoetById(poetJson['publicId'] as String, lang: 'ur');

    expect(client.paths, ['/api/guest/poets/${poetJson['publicId']}']);
    expect(poet.publicId, poetJson['publicId']);
    expect(poet.name, poetJson['name']);
  });
}

class _FakeDioClient implements DioClient {
  _FakeDioClient(this.body);

  final Map<String, dynamic> body;
  final paths = <String>[];
  final queries = <Map<String, dynamic>?>[];

  @override
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    paths.add(path);
    queries.add(queryParameters);
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      statusCode: 200,
      data: body as T,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}
