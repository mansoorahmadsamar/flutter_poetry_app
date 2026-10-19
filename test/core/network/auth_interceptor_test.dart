import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_poetry_app/core/constants/app_constants.dart';
import 'package:flutter_poetry_app/core/network/request_failure.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/auth_harness.dart';
import '../../helpers/fake_dio_adapter.dart';

const _feed = '/api/feed';
const _refresh = AppConstants.authRefreshPath;

String? _bearer(RequestOptions o) =>
    (o.headers[AppConstants.authorizationHeader] as String?)
        ?.replaceFirst('${AppConstants.bearerPrefix} ', '');

/// 200 for the refreshed token, 401 for anything else.
FakeReply _acceptsOnlyRefreshedToken(RequestOptions o) =>
    _bearer(o) == refreshedAccessToken
        ? const FakeReply(200, {'success': true, 'data': 'feed'})
        : const FakeReply(401, {'error': 'Unauthorized'});

Future<DioException> _failure(Future<Object?> request) async {
  try {
    await request.timeout(const Duration(seconds: 5));
  } on DioException catch (e) {
    return e;
  }
  fail('expected the request to fail');
}

void main() {
  late AuthHarness h;

  Future<void> signedIn() async {
    h = await AuthHarness.create(
      accessToken: validAccessToken,
      refreshToken: validRefreshToken,
    );
    await h.restored();
    expect(h.auth.isAuthenticated, isTrue);
  }

  tearDown(() => h.dispose());

  group('AuthInterceptor 401 + refused refresh', () {
    test('regression: refresh 401 signs the user out instead of leaving them stuck',
        () async {
      await signedIn();
      h.adapter
        ..on('GET', _feed, (_) => const FakeReply(401, {'error': 'Unauthorized'}))
        ..on('POST', _refresh, (_) => const FakeReply(401, {'error': 'Unauthorized'}));

      final error = await _failure(h.dio.get(_feed));
      expect(error.response?.statusCode, 401);

      final state = await h.authWhere((s) => s.sessionExpired);
      expect(state.isAuthenticated, isFalse);
      expect(state.isGuest, isTrue);
      expect(await h.storage.getAccessToken(), isNull);
      expect(await h.storage.getRefreshToken(), isNull);
      expect(await h.storage.getUserId(), isNull);
      expect(h.firebaseAuth.signOutCalls, 1);
      // The backend already ended the session; no logout call is made.
      expect(h.authHttpCalls, isEmpty);
    });

    test('regression: a 401 from the refresh endpoint fails the request, it does not hang',
        () async {
      await signedIn();
      h.adapter
        ..on('GET', _feed, (_) => const FakeReply(401))
        ..on('POST', _refresh, (_) => const FakeReply(401));

      // _failure times out after 5 s; the old interceptor queued the refresh
      // 401 behind itself and never completed.
      final error = await _failure(h.dio.get(_feed));
      expect(error.response?.statusCode, 401);
      expect(h.refreshCalls, 1);
    });

    test('refresh 500 (backend answer for a revoked refresh token) signs out', () async {
      await signedIn();
      h.adapter
        ..on('GET', _feed, (_) => const FakeReply(401))
        ..on('POST', _refresh, (_) => const FakeReply(500, {'status': 500}));

      await _failure(h.dio.get(_feed));
      final state = await h.authWhere((s) => s.sessionExpired);
      expect(state.isAuthenticated, isFalse);
    });

    test('the refresh request carries the refresh token and no stale bearer', () async {
      await signedIn();
      h.adapter
        ..on('GET', _feed, (_) => const FakeReply(401))
        ..on('POST', _refresh, (_) => const FakeReply(401));

      await _failure(h.dio.get(_feed));
      final refresh = h.adapter.requestsTo(_refresh).single;
      expect(refresh.data, {'refreshToken': validRefreshToken});
      expect(refresh.headers[AppConstants.authorizationHeader], isNull);
    });

    test('concurrent 401s with a refused refresh refresh once and sign out once', () async {
      await signedIn();
      h.adapter
        ..on('GET', _feed, (_) => const FakeReply(401))
        ..on('POST', _refresh, (_) => const FakeReply(401));

      final errors = await Future.wait([
        _failure(h.dio.get(_feed)),
        _failure(h.dio.get(_feed)),
        _failure(h.dio.get(_feed)),
      ]);
      expect(errors.map((e) => e.response?.statusCode), [401, 401, 401]);
      await h.authWhere((s) => s.sessionExpired);
      expect(h.refreshCalls, 1);
      expect(h.firebaseAuth.signOutCalls, 1);
    });
  });

  group('AuthInterceptor 401 + unreachable refresh', () {
    test('refresh offline keeps the user signed in and reports offline, not 401', () async {
      await signedIn();
      h.adapter
        ..on('GET', _feed, (_) => const FakeReply(401))
        ..on('POST', _refresh, (_) => const FakeReply.offline());

      final error = await _failure(h.dio.get(_feed));
      expect(error.type, DioExceptionType.connectionError);
      expect(classifyRequestFailure(error), RequestFailureKind.offline);
      expect(error.requestOptions.path, _feed);

      expect(h.auth.isAuthenticated, isTrue);
      expect(h.auth.sessionExpired, isFalse);
      expect(await h.storage.getAccessToken(), validAccessToken);
      expect(await h.storage.getRefreshToken(), validRefreshToken);
    });

    test('refresh timeout keeps the user signed in and reports a timeout', () async {
      await signedIn();
      h.adapter
        ..on('GET', _feed, (_) => const FakeReply(401))
        ..on('POST', _refresh, (_) => const FakeReply.timeout());

      final error = await _failure(h.dio.get(_feed));
      expect(classifyRequestFailure(error), RequestFailureKind.timeout);
      expect(h.auth.isAuthenticated, isTrue);
    });

    test('refresh 503 (API down behind the gateway) keeps the user signed in', () async {
      await signedIn();
      h.adapter
        ..on('GET', _feed, (_) => const FakeReply(401))
        ..on('POST', _refresh, (_) => const FakeReply(503));

      final error = await _failure(h.dio.get(_feed));
      expect(classifyRequestFailure(error), RequestFailureKind.server);
      expect(h.auth.isAuthenticated, isTrue);
      expect(await h.storage.getRefreshToken(), validRefreshToken);
    });
  });

  group('AuthInterceptor 401 + successful refresh', () {
    test('stores the new tokens and retries the original request once', () async {
      await signedIn();
      h.adapter
        ..on('GET', _feed, _acceptsOnlyRefreshedToken)
        ..on('POST', _refresh, (_) => FakeReply(200, refreshSuccessBody()));

      final response = await h.dio.get<Map<String, dynamic>>(_feed);
      expect(response.data?['data'], 'feed');

      final feedCalls = h.adapter.requestsTo(_feed);
      expect(feedCalls.map(_bearer), [validAccessToken, refreshedAccessToken]);
      expect(h.refreshCalls, 1);
      expect(await h.storage.getAccessToken(), refreshedAccessToken);
      expect(await h.storage.getRefreshToken(), refreshedRefreshToken);
      expect(h.auth.isAuthenticated, isTrue);
    });

    test('a retried request that 401s again is not refreshed again (no loop)', () async {
      await signedIn();
      h.adapter
        ..on('GET', _feed, (_) => const FakeReply(401))
        ..on('POST', _refresh, (_) => FakeReply(200, refreshSuccessBody()));

      final error = await _failure(h.dio.get(_feed));
      expect(error.response?.statusCode, 401);
      expect(h.adapter.requestsTo(_feed), hasLength(2));
      expect(h.refreshCalls, 1);
      expect(h.auth.isAuthenticated, isTrue);
    });

    test('concurrent 401s share a single refresh and all succeed', () async {
      await signedIn();
      final gate = Completer<void>();
      h.adapter
        ..on('GET', _feed, _acceptsOnlyRefreshedToken)
        ..on('POST', _refresh, (_) async {
          await gate.future;
          return FakeReply(200, refreshSuccessBody());
        });

      final requests = [
        h.dio.get<Map<String, dynamic>>(_feed),
        h.dio.get<Map<String, dynamic>>(_feed),
        h.dio.get<Map<String, dynamic>>(_feed),
      ];
      for (var i = 0; i < 100 && h.refreshCalls == 0; i++) {
        await Future<void>.delayed(Duration.zero);
      }
      gate.complete();

      final responses = await Future.wait(requests);
      expect(responses.map((r) => r.data?['data']), ['feed', 'feed', 'feed']);
      expect(h.refreshCalls, 1);
    });

    test('a 401 that arrives after another request refreshed is retried without refreshing',
        () async {
      await signedIn();
      h.adapter.on('GET', _feed, (o) async {
        if (_bearer(o) == refreshedAccessToken) {
          return const FakeReply(200, {'success': true, 'data': 'feed'});
        }
        // Meanwhile another request completed a refresh.
        await h.storage.saveAccessToken(refreshedAccessToken);
        return const FakeReply(401);
      });

      final response = await h.dio.get<Map<String, dynamic>>(_feed);
      expect(response.data?['data'], 'feed');
      expect(h.refreshCalls, 0);
    });
  });

  group('AuthInterceptor never signs out guests', () {
    test('a 401 on a request sent without a token neither refreshes nor signs out',
        () async {
      h = await AuthHarness.create();
      await h.restored();
      expect(h.auth.isGuest, isTrue);
      h.adapter.on('GET', '/api/bookmarks', (_) => const FakeReply(401));

      final error = await _failure(h.dio.get('/api/bookmarks'));
      expect(error.response?.statusCode, 401);
      expect(h.refreshCalls, 0);
      expect(h.auth.sessionExpired, isFalse);
    });

    test('guest endpoints carry no credentials and are never refreshed', () async {
      await signedIn();
      h.adapter.on('GET', '/api/guest/discover', (_) => const FakeReply(401));

      await _failure(h.dio.get('/api/guest/discover'));
      final call = h.adapter.requestsTo('/api/guest/discover').single;
      expect(call.headers[AppConstants.authorizationHeader], isNull);
      expect(call.headers['X-User-Id'], isNull);
      expect(h.refreshCalls, 0);
      expect(h.auth.isAuthenticated, isTrue);
    });

    test('other errors (404, 500) pass through without a refresh', () async {
      await signedIn();
      h.adapter
        ..on('GET', '/api/poems/x', (_) => const FakeReply(404))
        ..on('GET', _feed, (_) => const FakeReply(500));

      expect((await _failure(h.dio.get('/api/poems/x'))).response?.statusCode, 404);
      expect((await _failure(h.dio.get(_feed))).response?.statusCode, 500);
      expect(h.refreshCalls, 0);
      expect(h.auth.isAuthenticated, isTrue);
    });
  });
}
