import 'package:dio/dio.dart';
import 'package:flutter_poetry_app/features/main/tabs/creator/utils/api_error_messages.dart';
import 'package:flutter_test/flutter_test.dart';

DioException _dio(DioExceptionType type, {int? status, Object? data}) {
  final options = RequestOptions(path: '/api/me/poet/poems');
  return DioException(
    requestOptions: options,
    type: type,
    response: status == null
        ? null
        : Response(requestOptions: options, statusCode: status, data: data),
  );
}

void main() {
  const slow = 'Slow connection — please try again.';

  group('friendlyApiMessage — every DioExceptionType', () {
    // A dio upgrade that adds an enum value must not break the release build
    // or reach users as an empty message (dio 5.10 added transformTimeout and
    // the non-exhaustive switch failed CI release builds).
    for (final type in DioExceptionType.values) {
      test('$type yields a non-empty message', () {
        final message = friendlyApiMessage(_dio(type), CreatorAction.composePoem);
        expect(message, isNotEmpty);
      });
    }
  });

  group('friendlyApiMessage — timeouts', () {
    for (final type in [
      DioExceptionType.connectionTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.receiveTimeout,
      DioExceptionType.transformTimeout,
    ]) {
      test('$type is reported as a slow connection', () {
        expect(friendlyApiMessage(_dio(type), CreatorAction.uploadImage), slow);
      });
    }
  });

  group('friendlyApiMessage — existing behaviour is unchanged', () {
    test('connection error', () {
      expect(
        friendlyApiMessage(_dio(DioExceptionType.connectionError), CreatorAction.claimPoet),
        "Can't reach Sukhan right now. Check your connection.",
      );
    });

    test('401 and 403 ask the user to sign in again', () {
      for (final status in [401, 403]) {
        expect(
          friendlyApiMessage(_dio(DioExceptionType.badResponse, status: status), CreatorAction.addFact),
          'Your session expired — please sign in again.',
        );
      }
    });

    test('5xx is a temporary server problem', () {
      expect(
        friendlyApiMessage(_dio(DioExceptionType.badResponse, status: 503), CreatorAction.deleteBook),
        'Sukhan is having a moment. Try again in a few seconds.',
      );
    });

    test('a non-Dio error falls back to the per-action generic message', () {
      expect(friendlyApiMessage(StateError('boom'), CreatorAction.composePoem),
          "Couldn't publish — please try again.");
    });

    test('a backend stack trace is never shown', () {
      final error = _dio(DioExceptionType.badResponse,
          status: 422, data: {'message': 'java.lang.NullPointerException at com.techhikes'});
      expect(friendlyApiMessage(error, CreatorAction.updatePoem), "Couldn't save changes to your poem.");
    });
  });
}
