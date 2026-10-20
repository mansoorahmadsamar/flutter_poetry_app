import 'package:flutter_poetry_app/core/constants/app_constants.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/auth_harness.dart';
import '../../helpers/fake_dio_adapter.dart';

const _refresh = AppConstants.authRefreshPath;

void main() {
  late AuthHarness h;
  tearDown(() => h.dispose());

  group('AuthNotifier startup', () {
    test('a valid stored session is restored without any network call', () async {
      h = await AuthHarness.create(
        accessToken: validAccessToken,
        refreshToken: validRefreshToken,
      );
      final state = await h.restored();
      expect(state.isAuthenticated, isTrue);
      expect(state.isLoading, isFalse);
      expect(state.sessionExpired, isFalse);
      expect(h.adapter.requests, isEmpty);
    });

    test('no stored tokens is a guest, not an expired session', () async {
      h = await AuthHarness.create();
      final state = await h.restored();
      expect(state.isGuest, isTrue);
      expect(state.sessionExpired, isFalse);
      expect(h.adapter.requests, isEmpty);
    });

    test('regression: an expired access token whose refresh is refused signs out to login',
        () async {
      h = await AuthHarness.create(
        accessToken: expiredAccessToken,
        refreshToken: validRefreshToken,
      );
      h.adapter.on('POST', _refresh, (_) => const FakeReply(401));

      final state = await h.restored();
      expect(state.isAuthenticated, isFalse);
      expect(state.sessionExpired, isTrue);
      expect(await h.storage.getAccessToken(), isNull);
      expect(await h.storage.getRefreshToken(), isNull);
      expect(await h.storage.getUserId(), isNull);
    });

    test('expired access and refresh tokens sign out without calling the server', () async {
      h = await AuthHarness.create(
        accessToken: expiredAccessToken,
        refreshToken: expiredRefreshToken,
      );
      final state = await h.restored();
      expect(state.sessionExpired, isTrue);
      expect(state.isAuthenticated, isFalse);
      expect(h.adapter.requests, isEmpty);
    });

    test('an expired access token is refreshed and the session restored', () async {
      h = await AuthHarness.create(
        accessToken: expiredAccessToken,
        refreshToken: validRefreshToken,
      );
      h.adapter.on('POST', _refresh, (_) => FakeReply(200, refreshSuccessBody()));

      final state = await h.restored();
      expect(state.isAuthenticated, isTrue);
      expect(state.accessToken, refreshedAccessToken);
      expect(state.refreshToken, refreshedRefreshToken);
      expect(await h.storage.getAccessToken(), refreshedAccessToken);
    });

    test('an expired access token while offline keeps the session (no logout offline)',
        () async {
      h = await AuthHarness.create(
        accessToken: expiredAccessToken,
        refreshToken: validRefreshToken,
      );
      h.adapter.on('POST', _refresh, (_) => const FakeReply.offline());

      final state = await h.restored();
      expect(state.isAuthenticated, isTrue);
      expect(state.sessionExpired, isFalse);
      expect(await h.storage.getRefreshToken(), validRefreshToken);
    });

    test('an unreadable (non-JWT) access token is left for the server to judge', () async {
      h = await AuthHarness.create(
        accessToken: 'opaque-token',
        refreshToken: validRefreshToken,
      );
      final state = await h.restored();
      expect(state.isAuthenticated, isTrue);
      expect(h.adapter.requests, isEmpty);
    });
  });

  group('AuthNotifier.expireSession', () {
    test('does nothing for a guest', () async {
      h = await AuthHarness.create();
      await h.restored();
      await h.notifier.expireSession();
      expect(h.auth.sessionExpired, isFalse);
      expect(h.firebaseAuth.signOutCalls, 0);
    });

    test('concurrent calls sign out once', () async {
      h = await AuthHarness.create(
        accessToken: validAccessToken,
        refreshToken: validRefreshToken,
      );
      await h.restored();
      await Future.wait([
        h.notifier.expireSession(),
        h.notifier.expireSession(),
        h.notifier.expireSession(),
      ]);
      expect(h.auth.sessionExpired, isTrue);
      expect(h.firebaseAuth.signOutCalls, 1);
    });

    test('acknowledgeSessionExpired clears the notice', () async {
      h = await AuthHarness.create(
        accessToken: validAccessToken,
        refreshToken: validRefreshToken,
      );
      await h.restored();
      await h.notifier.expireSession();
      h.notifier.acknowledgeSessionExpired();
      expect(h.auth.sessionExpired, isFalse);
      expect(h.auth.isGuest, isTrue);
    });
  });

  group('AuthNotifier.refreshAccessToken', () {
    Future<void> signedIn() async {
      h = await AuthHarness.create(
        accessToken: validAccessToken,
        refreshToken: validRefreshToken,
      );
      await h.restored();
    }

    test('success updates the tokens', () async {
      await signedIn();
      h.adapter.on('POST', _refresh, (_) => FakeReply(200, refreshSuccessBody()));
      expect(await h.notifier.refreshAccessToken(), isTrue);
      expect(h.auth.accessToken, refreshedAccessToken);
      expect(h.auth.isAuthenticated, isTrue);
    });

    test('offline returns false and keeps the user signed in', () async {
      await signedIn();
      h.adapter.on('POST', _refresh, (_) => const FakeReply.offline());
      expect(await h.notifier.refreshAccessToken(), isFalse);
      expect(h.auth.isAuthenticated, isTrue);
      expect(await h.storage.getAccessToken(), validAccessToken);
    });

    test('a refused refresh signs out with the session-expired notice', () async {
      await signedIn();
      h.adapter.on('POST', _refresh, (_) => const FakeReply(401));
      expect(await h.notifier.refreshAccessToken(), isFalse);
      expect(h.auth.isAuthenticated, isFalse);
      expect(h.auth.sessionExpired, isTrue);
    });

    test('a 200 without success/accessToken counts as refused', () async {
      await signedIn();
      h.adapter.on('POST', _refresh,
          (_) => const FakeReply(200, {'success': false, 'message': 'nope'}));
      expect(await h.notifier.refreshAccessToken(), isFalse);
      expect(h.auth.sessionExpired, isTrue);
    });
  });

  group('AuthNotifier.logout', () {
    test('revokes the refresh token on the backend and clears the device session',
        () async {
      h = await AuthHarness.create(
        accessToken: validAccessToken,
        refreshToken: validRefreshToken,
      );
      await h.restored();
      await h.notifier.logout();

      expect(h.auth.isGuest, isTrue);
      expect(h.auth.sessionExpired, isFalse);
      expect(h.authHttpCalls.single.url.path, '/api/auth/logout');
      expect(await h.storage.getAccessToken(), isNull);
      expect(await h.storage.getRefreshToken(), isNull);
      expect(h.firebaseAuth.signOutCalls, 1);
    });
  });
}
