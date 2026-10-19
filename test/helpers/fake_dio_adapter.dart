import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// What a [FakeDioAdapter] route answers with.
///
/// Either an HTTP response ([status] + JSON [body]) or a transport failure
/// ([offline] / [timeout]) that never reaches the server.
class FakeReply {
  final int status;
  final Object? body;
  final bool offline;
  final bool timeout;

  const FakeReply(this.status, [this.body])
      : offline = false,
        timeout = false;

  /// No network: the request fails like a dropped connection.
  const FakeReply.offline()
      : status = 0,
        body = null,
        offline = true,
        timeout = false;

  /// The server never answered within the timeout.
  const FakeReply.timeout()
      : status = 0,
        body = null,
        offline = false,
        timeout = true;
}

typedef FakeRoute = FutureOr<FakeReply> Function(RequestOptions options);

/// An [HttpClientAdapter] that answers from in-memory routes and records
/// every request. No real network is ever touched.
///
/// Routes are keyed by `'METHOD /path'` (no query string). An unknown route
/// answers 404 so a missing stub fails loudly instead of hanging.
class FakeDioAdapter implements HttpClientAdapter {
  final Map<String, FakeRoute> _routes = {};
  final List<RequestOptions> requests = [];

  void on(String method, String path, FakeRoute route) {
    _routes['${method.toUpperCase()} $path'] = route;
  }

  /// Requests made to [path] (any method), in order.
  List<RequestOptions> requestsTo(String path) =>
      requests.where((r) => r.path == path).toList();

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    // Snapshot: a retried request reuses (and mutates) the same options.
    requests.add(options.copyWith(headers: Map.of(options.headers)));
    final route = _routes['${options.method.toUpperCase()} ${options.path}'];
    final reply = route == null
        ? const FakeReply(404, {'success': false, 'message': 'no fake route'})
        : await route(options);

    if (reply.offline) {
      throw DioException.connectionError(
        requestOptions: options,
        reason: 'Fake adapter: offline',
      );
    }
    if (reply.timeout) {
      throw DioException.connectionTimeout(
        requestOptions: options,
        timeout: const Duration(seconds: 30),
      );
    }
    return ResponseBody.fromString(
      jsonEncode(reply.body),
      reply.status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
