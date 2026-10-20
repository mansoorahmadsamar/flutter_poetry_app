import 'dart:io';

import 'package:dio/dio.dart';

/// Why a request failed, in the terms the user needs: is it their connection,
/// their session, or our server?
enum RequestFailureKind {
  /// No connection to the server.
  offline,

  /// The server took too long to answer.
  timeout,

  /// 401: the session is gone. (The app normally signs the user out and
  /// shows the login screen before a screen ever renders this.)
  sessionExpired,

  /// 5xx: the server failed.
  server,

  /// Anything else.
  other,
}

RequestFailureKind classifyRequestFailure(Object error) {
  if (error is! DioException) return RequestFailureKind.other;
  switch (error.type) {
    case DioExceptionType.connectionError:
      return RequestFailureKind.offline;
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
      return RequestFailureKind.timeout;
    case DioExceptionType.unknown:
      return error.error is SocketException
          ? RequestFailureKind.offline
          : RequestFailureKind.other;
    case DioExceptionType.badResponse:
      final status = error.response?.statusCode ?? 0;
      if (status == 401) return RequestFailureKind.sessionExpired;
      if (status >= 500) return RequestFailureKind.server;
      return RequestFailureKind.other;
    case DioExceptionType.cancel:
    case DioExceptionType.badCertificate:
      return RequestFailureKind.other;
  }
}
