import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_poetry_app/core/auth/auth_provider.dart';
import 'package:flutter_poetry_app/core/auth/auth_state.dart';
import 'package:flutter_poetry_app/core/auth/firebase_auth_service.dart';
import 'package:flutter_poetry_app/core/constants/app_constants.dart';
import 'package:flutter_poetry_app/core/network/dio_client.dart';
import 'package:flutter_poetry_app/core/storage/preferences_service.dart';
import 'package:flutter_poetry_app/core/storage/secure_storage.dart';
import 'package:flutter_poetry_app/core/utils/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_dio_adapter.dart';
import 'fake_jwt.dart';
import 'fake_secure_storage.dart';
import 'test_config.dart';

/// The fixed "now" of auth tests.
final testNow = DateTime.utc(2026, 10, 19, 12);

/// An access token as production issues it: valid for ~100 days.
final validAccessToken = fakeJwt(exp: testNow.add(const Duration(days: 100)));

/// A refresh token as production issues it: valid for 7 days.
final validRefreshToken = fakeJwt(exp: testNow.add(const Duration(days: 7)));

final expiredAccessToken =
    fakeJwt(exp: testNow.subtract(const Duration(days: 1)));
final expiredRefreshToken =
    fakeJwt(exp: testNow.subtract(const Duration(hours: 1)));

/// The access token the fake backend hands out on a successful refresh.
final refreshedAccessToken =
    fakeJwt(exp: testNow.add(const Duration(days: 100)), subject: 'new');
final refreshedRefreshToken =
    fakeJwt(exp: testNow.add(const Duration(days: 7)), subject: 'new-r');

/// The `POST /api/auth/refresh` success body.
Map<String, Object?> refreshSuccessBody() => {
      'success': true,
      'message': 'Token refreshed successfully!',
      'data': {
        'accessToken': refreshedAccessToken,
        'refreshToken': refreshedRefreshToken,
      },
    };

class FakeFirebaseAuth implements FirebaseAuth {
  int signOutCalls = 0;

  @override
  Future<void> signOut() async => signOutCalls++;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeGoogleSignIn implements GoogleSignIn {
  @override
  Future<GoogleSignInAccount?> signOut() async => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// A [ProviderContainer] running the real auth stack (AuthNotifier,
/// DioClient, AuthInterceptor, TokenRefresher, SecureStorageService) with
/// the network, keychain, Firebase/Google plugins, prefs and clock faked.
class AuthHarness {
  final FakeDioAdapter adapter;
  final SecureStorageService storage;
  final FakeFirebaseAuth firebaseAuth;
  final SharedPreferences prefs;
  final List<http.Request> authHttpCalls;
  final ProviderContainer container;

  AuthHarness._(
    this.adapter,
    this.storage,
    this.firebaseAuth,
    this.prefs,
    this.authHttpCalls,
    this.container,
  );

  static Future<AuthHarness> create({
    String? accessToken,
    String? refreshToken,
    String? userId = '7',
    Map<String, Object> prefs = const {},
    List<Override> overrides = const [],
  }) async {
    setUpTestConfig();
    SharedPreferences.setMockInitialValues(prefs);
    final sharedPrefs = await SharedPreferences.getInstance();
    final storage = fakeSecureStorage(
      accessToken: accessToken,
      refreshToken: refreshToken,
      userId: accessToken == null ? null : userId,
    );
    final adapter = FakeDioAdapter();
    final firebaseAuth = FakeFirebaseAuth();
    final httpCalls = <http.Request>[];
    final firebaseAuthService = FirebaseAuthService(
      storage,
      firebaseAuth: firebaseAuth,
      googleSignIn: FakeGoogleSignIn(),
      httpClientFactory: () => MockClient((request) async {
        httpCalls.add(request);
        return http.Response('{"success":true}', 200);
      }),
    );
    final container = ProviderContainer(overrides: [
      secureStorageProvider.overrideWithValue(storage),
      httpClientAdapterProvider.overrideWithValue(adapter),
      clockProvider.overrideWithValue(() => testNow),
      firebaseAuthServiceProvider.overrideWithValue(firebaseAuthService),
      preferencesServiceProvider
          .overrideWithValue(PreferencesService(sharedPrefs)),
      ...overrides,
    ]);
    return AuthHarness._(
      adapter,
      storage,
      firebaseAuth,
      sharedPrefs,
      httpCalls,
      container,
    );
  }

  AuthState get auth => container.read(authProvider);
  AuthNotifier get notifier => container.read(authProvider.notifier);
  DioClient get dio => container.read(dioClientProvider);

  int get refreshCalls => adapter.requestsTo(AppConstants.authRefreshPath).length;

  /// Completes once the auth state satisfies [condition].
  Future<AuthState> authWhere(bool Function(AuthState) condition) {
    final done = Completer<AuthState>();
    final sub = container.listen<AuthState>(
      authProvider,
      (_, next) {
        if (condition(next) && !done.isCompleted) done.complete(next);
      },
      fireImmediately: true,
    );
    return done.future
        .timeout(const Duration(seconds: 5))
        .whenComplete(sub.close);
  }

  /// Waits for app-start session restore to finish.
  Future<AuthState> restored() => authWhere((s) => !s.isRestoringSession);

  void dispose() => container.dispose();
}
