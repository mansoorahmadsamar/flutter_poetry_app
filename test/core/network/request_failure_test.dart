import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_poetry_app/core/network/request_failure.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final options = RequestOptions(path: '/api/feed');
  DioException status(int code) => DioException.badResponse(
        statusCode: code,
        requestOptions: options,
        response: Response(requestOptions: options, statusCode: code),
      );

  group('classifyRequestFailure', () {
    test('a dropped connection is offline', () {
      expect(
        classifyRequestFailure(DioException.connectionError(
            requestOptions: options, reason: 'no route')),
        RequestFailureKind.offline,
      );
      expect(
        classifyRequestFailure(DioException(
            requestOptions: options, error: const SocketException('down'))),
        RequestFailureKind.offline,
      );
    });

    test('timeouts are timeouts', () {
      for (final type in [
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
        DioExceptionType.transformTimeout,
      ]) {
        expect(classifyRequestFailure(DioException(requestOptions: options, type: type)),
            RequestFailureKind.timeout,
            reason: type.name);
      }
    });

    test('401 is an expired session, not offline', () {
      expect(classifyRequestFailure(status(401)), RequestFailureKind.sessionExpired);
    });

    test('5xx is a server failure', () {
      expect(classifyRequestFailure(status(500)), RequestFailureKind.server);
      expect(classifyRequestFailure(status(503)), RequestFailureKind.server);
    });

    test('other statuses and non-Dio errors are other', () {
      expect(classifyRequestFailure(status(404)), RequestFailureKind.other);
      expect(classifyRequestFailure(Exception('parse')), RequestFailureKind.other);
    });
  });
}
