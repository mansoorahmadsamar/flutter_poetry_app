import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:logger/logger.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../config/app_config.dart';
import '../storage/secure_storage.dart';

/// Firebase Authentication Service
/// Handles Google Sign-In via Firebase Auth and backend token verification
class FirebaseAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile', 'openid'],
  );
  final SecureStorageService _secureStorage;
  final Logger _logger = Logger();

  // Token storage keys
  static const String _firebaseTokenKey = 'firebase_token';

  FirebaseAuthService(this._secureStorage);

  /// Create HTTP client that accepts self-signed certificates for production server
  http.Client _createHttpClient() {
    if (appConfig.baseApiUrl.contains('134.199.243.167')) {
      final ioClient = HttpClient()
        ..badCertificateCallback = (X509Certificate cert, String host, int port) {
          // Accept self-signed certificate for the production server
          return host == '134.199.243.167';
        };
      return IOClient(ioClient);
    }
    return http.Client();
  }

  /// Get current Firebase user
  User? get currentUser => _firebaseAuth.currentUser;

  /// Auth state changes stream
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final accessToken = await _secureStorage.getAccessToken();
    final refreshToken = await _secureStorage.getRefreshToken();
    return accessToken != null && refreshToken != null;
  }

  /// Sign in with Google using Firebase Auth
  Future<Map<String, dynamic>> signInWithGoogle() async {
    _logger.i('═══════════════════════════════════════════════════════');
    _logger.i('🔐 FIREBASE AUTH SERVICE - STARTING GOOGLE SIGN-IN');
    _logger.i('═══════════════════════════════════════════════════════');

    try {
      _logger.i('');
      _logger.i('📱 Step 1: Triggering native Google Sign-In...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        _logger.w('⚠️  User cancelled Google Sign-In');
        return {};
      }

      _logger.i('✅ Google user signed in: ${googleUser.email}');

      _logger.i('');
      _logger.i('🔐 Step 2: Getting Google Auth credentials...');
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      _logger.i('✅ Got Google auth credentials');

      _logger.i('');
      _logger.i('🔥 Step 3: Creating Firebase credential...');
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      _logger.i('✅ Firebase credential created');

      _logger.i('');
      _logger.i('🔥 Step 4: Signing in to Firebase...');
      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      _logger.i('✅ Firebase sign-in successful');
      _logger.i('   User: ${userCredential.user?.email}');

      _logger.i('');
      _logger.i('🔑 Step 5: Getting Firebase ID token...');
      final String? firebaseToken = await userCredential.user?.getIdToken();

      if (firebaseToken == null) {
        throw Exception('Failed to get Firebase ID token');
      }

      _logger.i('✅ Firebase ID token obtained (length: ${firebaseToken.length})');

      _logger.i('');
      _logger.i('📤 Step 6: Sending Firebase token to backend...');
      _logger.i('   Endpoint: ${appConfig.baseApiUrl}/api/auth/firebase/verify');

      final client = _createHttpClient();
      final response = await client.post(
        Uri.parse('${appConfig.baseApiUrl}/api/auth/firebase/verify'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'firebaseToken': firebaseToken,
          'email': userCredential.user?.email,
          'deviceType': 'android', // or detect dynamically
        }),
      );
      client.close();

      _logger.i('📡 Backend response:');
      _logger.i('   Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        _logger.i('   Response Data: ${json.encode(data)}');

        if (data['success'] == true && data['data'] != null) {
          final tokenData = data['data'];
          final accessToken = tokenData['accessToken'] as String?;
          final refreshToken = tokenData['refreshToken'] as String?;
          final email = tokenData['email'] as String? ?? googleUser.email;
          final userId = tokenData['userId']?.toString() ??
              tokenData['id']?.toString();

          if (accessToken == null || refreshToken == null) {
            throw Exception('Backend did not return required tokens');
          }

          _logger.i('');
          _logger.i('💾 Step 7: Saving tokens to secure storage...');

          // Save Firebase token
          await _secureStorage.saveToken(_firebaseTokenKey, firebaseToken);

          // Save backend JWT tokens
          await _secureStorage.saveAccessToken(accessToken);
          await _secureStorage.saveRefreshToken(refreshToken);

          if (email.isNotEmpty) {
            await _secureStorage.saveUserEmail(email);
          }

          // Save user ID for personalization (X-User-Id header)
          if (userId != null && userId.isNotEmpty) {
            await _secureStorage.saveUserId(userId);
            _logger.i('   User ID saved: $userId');
          }

          _logger.i('✅ Tokens saved successfully');

          _logger.i('');
          _logger.i('═══════════════════════════════════════════════════════');
          _logger.i('✅ FIREBASE GOOGLE SIGN-IN COMPLETED SUCCESSFULLY');
          _logger.i('   Email: $email');
          _logger.i('═══════════════════════════════════════════════════════');

          return {
            'accessToken': accessToken,
            'refreshToken': refreshToken,
            'email': email,
            'firebaseToken': firebaseToken,
            'success': true,
          };
        } else {
          throw Exception(data['message'] ?? 'Backend authentication failed');
        }
      } else if (response.statusCode == 503) {
        throw Exception('Firebase authentication service is unavailable');
      } else {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Authentication failed');
      }
    } on FirebaseAuthException catch (e) {
      _logger.e('');
      _logger.e('═══════════════════════════════════════════════════════');
      _logger.e('❌ FIREBASE AUTH EXCEPTION');
      _logger.e('   Code: ${e.code}');
      _logger.e('   Message: ${e.message}');
      _logger.e('═══════════════════════════════════════════════════════');
      rethrow;
    } catch (e, stackTrace) {
      _logger.e('');
      _logger.e('═══════════════════════════════════════════════════════');
      _logger.e('❌ FIREBASE SIGN-IN ERROR');
      _logger.e('   Error: $e');
      _logger.e('   Stack: $stackTrace');
      _logger.e('═══════════════════════════════════════════════════════');
      rethrow;
    }
  }

  /// Sign in with Apple via Firebase Auth.
  ///
  /// Flow: native Apple Sign-In sheet → Apple identity token + raw nonce →
  /// Firebase OAuth credential (provider: apple.com) → Firebase ID token →
  /// backend `/api/auth/firebase/verify` (same endpoint as Google). Backend
  /// links the account by email; new users get `provider = "apple"`.
  ///
  /// Required for App Store Guideline 4.8 — any app offering a third-party
  /// login (Google here) must offer Sign in with Apple at equal prominence.
  Future<Map<String, dynamic>> signInWithApple() async {
    _logger.i('═══════════════════════════════════════════════════════');
    _logger.i('🍎 FIREBASE AUTH SERVICE - STARTING APPLE SIGN-IN');
    _logger.i('═══════════════════════════════════════════════════════');

    try {
      // Step 1 — generate nonce. Apple receives the SHA-256 hash; Firebase
      // recomputes it server-side and validates against the raw value sent
      // below. Mismatch is the #1 cause of auth/invalid-credential.
      _logger.i('');
      _logger.i('🎲 Step 1: Generating cryptographic nonce...');
      final rawNonce = _generateNonce();
      final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

      // Step 2 — native Apple sheet
      _logger.i('');
      _logger.i('🍎 Step 2: Triggering native Apple Sign-In...');
      final AuthorizationCredentialAppleID appleCredential;
      try {
        appleCredential = await SignInWithApple.getAppleIDCredential(
          scopes: const [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
          nonce: hashedNonce,
        );
      } on SignInWithAppleAuthorizationException catch (e) {
        if (e.code == AuthorizationErrorCode.canceled) {
          _logger.w('⚠️  User cancelled Apple Sign-In');
          return {};
        }
        // error 1000 / AuthorizationErrorCode.unknown is Apple's catch-all
        // for "I don't know what's wrong with your config". It fires when
        // the Apple Developer Portal capability or Firebase Console
        // provider isn't fully wired, and randomly on the iOS Simulator
        // (incomplete Authentication Services support). Surface a clear
        // message instead of the cryptic raw exception.
        if (e.code == AuthorizationErrorCode.unknown) {
          throw Exception(
            'Sign in with Apple isn\'t available on this build. '
            'Try a real device, or verify the Apple Developer Portal '
            'capability and Firebase Console provider are configured.',
          );
        }
        rethrow;
      }

      if (appleCredential.identityToken == null) {
        throw Exception('Apple returned no identity token');
      }
      _logger.i('✅ Got Apple credential (email: ${appleCredential.email ?? "<hidden>"})');

      // Step 3 — Firebase OAuth credential. rawNonce here MUST match the
      // value whose SHA-256 was sent to Apple in step 2.
      _logger.i('');
      _logger.i('🔥 Step 3: Creating Firebase OAuth credential...');
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      // Step 4 — sign in to Firebase
      _logger.i('');
      _logger.i('🔥 Step 4: Signing in to Firebase with Apple credential...');
      final userCredential =
          await _firebaseAuth.signInWithCredential(oauthCredential);
      _logger.i('✅ Firebase sign-in successful');

      // Step 5 — persist Apple's name on first sign-in. Apple ONLY sends
      // givenName/familyName on the very first sign-in for an app —
      // capture it now or it's gone forever.
      if (appleCredential.givenName != null ||
          appleCredential.familyName != null) {
        final fullName = [
          appleCredential.givenName,
          appleCredential.familyName,
        ].where((s) => s != null && s.isNotEmpty).join(' ');
        if (fullName.isNotEmpty) {
          _logger.i('💾 Persisting display name on first sign-in: $fullName');
          await userCredential.user?.updateDisplayName(fullName);
        }
      }

      // Step 6 — Firebase ID token
      _logger.i('');
      _logger.i('🔑 Step 6: Getting Firebase ID token...');
      final String? firebaseToken = await userCredential.user?.getIdToken();
      if (firebaseToken == null) {
        throw Exception('Failed to get Firebase ID token');
      }
      _logger.i('✅ Firebase ID token obtained (length: ${firebaseToken.length})');

      // Step 7 — backend verification (same endpoint as Google).
      _logger.i('');
      _logger.i('📤 Step 7: Sending Firebase token to backend...');
      _logger.i('   Endpoint: ${appConfig.baseApiUrl}/api/auth/firebase/verify');

      final email = userCredential.user?.email ?? appleCredential.email;
      final client = _createHttpClient();
      final response = await client.post(
        Uri.parse('${appConfig.baseApiUrl}/api/auth/firebase/verify'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'firebaseToken': firebaseToken,
          'email': email,
          'deviceType': Platform.isIOS ? 'ios' : 'android',
        }),
      );
      client.close();

      _logger.i('📡 Backend response:');
      _logger.i('   Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final tokenData = data['data'];
          final accessToken = tokenData['accessToken'] as String?;
          final refreshToken = tokenData['refreshToken'] as String?;
          final returnedEmail =
              tokenData['email'] as String? ?? email ?? '';
          final userId = tokenData['userId']?.toString() ??
              tokenData['id']?.toString();

          if (accessToken == null || refreshToken == null) {
            throw Exception('Backend did not return required tokens');
          }

          _logger.i('');
          _logger.i('💾 Step 8: Saving tokens to secure storage...');
          await _secureStorage.saveToken(_firebaseTokenKey, firebaseToken);
          await _secureStorage.saveAccessToken(accessToken);
          await _secureStorage.saveRefreshToken(refreshToken);
          if (returnedEmail.isNotEmpty) {
            await _secureStorage.saveUserEmail(returnedEmail);
          }
          if (userId != null && userId.isNotEmpty) {
            await _secureStorage.saveUserId(userId);
            _logger.i('   User ID saved: $userId');
          }
          _logger.i('✅ Tokens saved successfully');

          _logger.i('');
          _logger.i('═══════════════════════════════════════════════════════');
          _logger.i('✅ FIREBASE APPLE SIGN-IN COMPLETED SUCCESSFULLY');
          _logger.i('   Email: $returnedEmail');
          _logger.i('═══════════════════════════════════════════════════════');

          return {
            'accessToken': accessToken,
            'refreshToken': refreshToken,
            'email': returnedEmail,
            'firebaseToken': firebaseToken,
            'success': true,
          };
        } else {
          throw Exception(data['message'] ?? 'Backend authentication failed');
        }
      } else if (response.statusCode == 503) {
        throw Exception('Firebase authentication service is unavailable');
      } else {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Authentication failed');
      }
    } on FirebaseAuthException catch (e) {
      _logger.e('');
      _logger.e('═══════════════════════════════════════════════════════');
      _logger.e('❌ FIREBASE AUTH EXCEPTION (APPLE)');
      _logger.e('   Code: ${e.code}');
      _logger.e('   Message: ${e.message}');
      _logger.e('═══════════════════════════════════════════════════════');
      rethrow;
    } catch (e, stackTrace) {
      _logger.e('');
      _logger.e('═══════════════════════════════════════════════════════');
      _logger.e('❌ APPLE SIGN-IN ERROR');
      _logger.e('   Error: $e');
      _logger.e('   Stack: $stackTrace');
      _logger.e('═══════════════════════════════════════════════════════');
      rethrow;
    }
  }

  /// Generates a cryptographically-random URL-safe nonce. The SHA-256 hash
  /// is sent to Apple; the raw value is sent to Firebase, which recomputes
  /// the hash on its end to validate. See [signInWithApple].
  String _generateNonce([int length = 32]) {
    const charset =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  /// Refresh access token using refresh token
  Future<String?> refreshAccessToken() async {
    _logger.i('🔄 Attempting to refresh access token...');

    try {
      final refreshToken = await _secureStorage.getRefreshToken();

      if (refreshToken == null) {
        _logger.e('❌ No refresh token found');
        return null;
      }

      _logger.i('   Sending refresh request to backend...');

      final client = _createHttpClient();
      final response = await client.post(
        Uri.parse('${appConfig.baseApiUrl}/api/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'refreshToken': refreshToken}),
      );
      client.close();

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true && data['data'] != null) {
          final newAccessToken = data['data']['accessToken'] as String?;
          final newRefreshToken = data['data']['refreshToken'] as String?;

          if (newAccessToken == null) {
            _logger.e('❌ Backend did not return access token');
            return null;
          }

          // Save new tokens
          await _secureStorage.saveAccessToken(newAccessToken);
          if (newRefreshToken != null) {
            await _secureStorage.saveRefreshToken(newRefreshToken);
          }

          _logger.i('✅ Token refreshed successfully');
          return newAccessToken;
        }
      }

      _logger.e('❌ Token refresh failed: ${response.statusCode}');
      return null;
    } catch (e) {
      _logger.e('❌ Token refresh error: $e');
      return null;
    }
  }

  /// Make authenticated HTTP request with automatic token refresh
  Future<http.Response> authenticatedRequest(
    String endpoint, {
    String method = 'GET',
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    String? token = await _secureStorage.getAccessToken();

    final requestHeaders = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      ...(headers ?? {}),
    };

    http.Response response;

    final uri = Uri.parse('${appConfig.baseApiUrl}$endpoint');

    if (method == 'GET') {
      response = await http.get(uri, headers: requestHeaders);
    } else if (method == 'POST') {
      response = await http.post(
        uri,
        headers: requestHeaders,
        body: body != null ? json.encode(body) : null,
      );
    } else if (method == 'PUT') {
      response = await http.put(
        uri,
        headers: requestHeaders,
        body: body != null ? json.encode(body) : null,
      );
    } else if (method == 'DELETE') {
      response = await http.delete(uri, headers: requestHeaders);
    } else {
      throw UnsupportedError('HTTP method $method is not supported');
    }

    // If unauthorized, try refreshing token once
    if (response.statusCode == 401) {
      _logger.w('⚠️  Received 401 Unauthorized, attempting token refresh...');

      token = await refreshAccessToken();

      if (token != null) {
        requestHeaders['Authorization'] = 'Bearer $token';

        // Retry request with new token
        if (method == 'GET') {
          response = await http.get(uri, headers: requestHeaders);
        } else if (method == 'POST') {
          response = await http.post(
            uri,
            headers: requestHeaders,
            body: body != null ? json.encode(body) : null,
          );
        } else if (method == 'PUT') {
          response = await http.put(
            uri,
            headers: requestHeaders,
            body: body != null ? json.encode(body) : null,
          );
        } else if (method == 'DELETE') {
          response = await http.delete(uri, headers: requestHeaders);
        }

        _logger.i('✅ Request retried with new token');
      } else {
        _logger.e('❌ Token refresh failed, request not retried');
      }
    }

    return response;
  }

  /// Get stored access token
  Future<String?> getAccessToken() {
    return _secureStorage.getAccessToken();
  }

  /// Get stored refresh token
  Future<String?> getRefreshToken() {
    return _secureStorage.getRefreshToken();
  }

  /// Get stored Firebase token
  Future<String?> getFirebaseToken() {
    return _secureStorage.getToken(_firebaseTokenKey);
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      _logger.i('🔐 Signing out...');

      // Get refresh token for logout endpoint
      final refreshToken = await _secureStorage.getRefreshToken();

      // Call backend logout endpoint
      if (refreshToken != null) {
        try {
          _logger.i('   Calling backend logout endpoint...');
          final client = _createHttpClient();
          await client.post(
            Uri.parse('${appConfig.baseApiUrl}/api/auth/logout'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'refreshToken': refreshToken}),
          );
          client.close();
          _logger.i('✅ Backend logout successful');
        } catch (e) {
          _logger.e('⚠️  Backend logout failed: $e');
          // Continue with client-side logout even if backend fails
        }
      }

      // Sign out from Firebase
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();

      // Clear all stored tokens and data
      await _secureStorage.deleteAccessToken();
      await _secureStorage.deleteRefreshToken();
      await _secureStorage.deleteToken(_firebaseTokenKey);
      await _secureStorage.deleteUserEmail();
      await _secureStorage.deleteUserId();

      _logger.i('✅ Sign out completed successfully');
    } catch (e) {
      _logger.e('❌ Sign out error: $e');
      rethrow;
    }
  }
}
