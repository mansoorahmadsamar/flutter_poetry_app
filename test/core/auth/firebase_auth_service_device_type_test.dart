import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_poetry_app/core/auth/firebase_auth_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../../helpers/fake_secure_storage.dart';
import '../../helpers/test_config.dart';

class _FakeGoogleAuthentication implements GoogleSignInAuthentication {
  @override
  String? get accessToken => 'google-access';
  @override
  String? get idToken => 'google-id';
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeGoogleAccount implements GoogleSignInAccount {
  @override
  String get email => 'reader@example.com';
  @override
  Future<GoogleSignInAuthentication> get authentication async =>
      _FakeGoogleAuthentication();
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeGoogleSignIn implements GoogleSignIn {
  @override
  Future<GoogleSignInAccount?> signIn() async => _FakeGoogleAccount();
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeUser implements User {
  @override
  String? get email => 'reader@example.com';
  @override
  Future<String?> getIdToken([bool forceRefresh = false]) async => 'firebase-id-token';
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeUserCredential implements UserCredential {
  @override
  User? get user => _FakeUser();
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeFirebaseAuth implements FirebaseAuth {
  @override
  Future<UserCredential> signInWithCredential(AuthCredential credential) async =>
      _FakeUserCredential();
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUpAll(setUpTestConfig);

  /// Runs Google sign-in and returns the body sent to /api/auth/firebase/verify.
  Future<Map<String, dynamic>> googleVerifyBody({TargetPlatform? platform}) async {
    final requests = <http.Request>[];
    final service = FirebaseAuthService(
      fakeSecureStorage(),
      firebaseAuth: _FakeFirebaseAuth(),
      googleSignIn: _FakeGoogleSignIn(),
      platform: platform,
      httpClientFactory: () => MockClient((request) async {
        requests.add(request);
        return http.Response(
          jsonEncode({
            'success': true,
            'data': {'accessToken': 'a', 'refreshToken': 'r', 'userId': 7},
          }),
          200,
        );
      }),
    );
    final result = await service.signInWithGoogle();
    expect(result['success'], isTrue);
    final verify = requests.singleWhere((r) => r.url.path == '/api/auth/firebase/verify');
    return jsonDecode(verify.body) as Map<String, dynamic>;
  }

  group('FirebaseAuthService Google sign-in deviceType', () {
    test('regression: an iPhone reports ios, not android (T-047)', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      try {
        expect((await googleVerifyBody())['deviceType'], 'ios');
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    test('an injected platform is reported', () async {
      expect((await googleVerifyBody(platform: TargetPlatform.iOS))['deviceType'], 'ios');
      expect((await googleVerifyBody(platform: TargetPlatform.android))['deviceType'],
          'android');
    });
  });

  group('deviceTypeFor', () {
    test('maps the platforms the backend knows', () {
      expect(deviceTypeFor(TargetPlatform.iOS), 'ios');
      expect(deviceTypeFor(TargetPlatform.android), 'android');
      expect(deviceTypeFor(TargetPlatform.android, isWeb: true), 'web');
    });
  });
}
