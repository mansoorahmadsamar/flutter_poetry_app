import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../storage/secure_storage.dart';
import '../config/app_config.dart';
import 'auth_state.dart';

/// Authentication provider for managing auth state
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return AuthNotifier(secureStorage);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final SecureStorageService _secureStorage;
  final Dio _dio = Dio();
  final Logger _logger = Logger();

  // Google Sign-In instance for native authentication
  late final GoogleSignIn _googleSignIn;

  AuthNotifier(this._secureStorage) : super(const AuthState()) {
    // Initialize Google Sign-In with optional server client ID
    _googleSignIn = GoogleSignIn(
      scopes: [
        'email',
        'profile',
        'openid',
      ],
      // Server client ID is required to get ID tokens for backend verification
      serverClientId: appConfig.googleWebClientId,
    );
    _checkAuthStatus();
  }

  /// Check if user is already authenticated on app start
  Future<void> _checkAuthStatus() async {
    state = state.copyWith(isLoading: true);

    try {
      final accessToken = await _secureStorage.getAccessToken();
      final refreshToken = await _secureStorage.getRefreshToken();
      final userEmail = await _secureStorage.getUserEmail();

      if (accessToken != null && refreshToken != null) {
        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          accessToken: accessToken,
          refreshToken: refreshToken,
          userEmail: userEmail,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to check authentication status',
      );
    }
  }

  /// Sign in with Google using native SDK
  Future<void> signInWithGoogle() async {
    _logger.i('═══════════════════════════════════════════════════════');
    _logger.i('🔐 AUTH PROVIDER - STARTING GOOGLE SIGN-IN');
    _logger.i('═══════════════════════════════════════════════════════');

    try {
      _logger.i('⏳ Setting loading state...');
      state = state.copyWith(isLoading: true, errorMessage: null);
      _logger.i('✅ Loading state set');

      _logger.i('');
      _logger.i('📱 Triggering native Google Sign-In...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        _logger.w('⚠️ User cancelled the sign-in');
        state = state.copyWith(isLoading: false);
        return;
      }

      _logger.i('✅ Google user signed in: ${googleUser.email}');

      _logger.i('');
      _logger.i('🔑 Getting authentication details...');
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        _logger.e('❌ Failed to get ID token');
        throw Exception('Failed to get ID token from Google');
      }

      _logger.i('✅ Got ID token (length: ${idToken.length})');

      // Send ID token to backend
      _logger.i('');
      _logger.i('📤 Sending ID token to backend...');
      _logger.i('   API URL: ${appConfig.baseApiUrl}/api/auth/google/android');

      final response = await _dio.post(
        '${appConfig.baseApiUrl}/api/auth/google/android',
        data: {
          'idToken': idToken,
          'deviceType': 'android',
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      _logger.i('📡 Backend response:');
      _logger.i('   Status Code: ${response.statusCode}');
      _logger.i('   Response Data: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final tokens = response.data['data'];
        final accessToken = tokens['accessToken'] as String;
        final refreshToken = tokens['refreshToken'] as String;
        final userEmail = tokens['email'] as String?;

        _logger.i('');
        _logger.i('✅ Authentication successful!');
        _logger.i('   Email: $userEmail');

        // Store tokens securely
        _logger.i('');
        _logger.i('💾 Storing tokens in secure storage...');
        await _secureStorage.saveAccessToken(accessToken);
        await _secureStorage.saveRefreshToken(refreshToken);
        if (userEmail != null) {
          await _secureStorage.saveUserEmail(userEmail);
        }
        _logger.i('✅ Tokens stored successfully');

        // Update state
        _logger.i('');
        _logger.i('📝 Updating auth state...');
        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          accessToken: accessToken,
          refreshToken: refreshToken,
          userEmail: userEmail,
        );
        _logger.i('✅ Auth state updated successfully');

        _logger.i('');
        _logger.i('═══════════════════════════════════════════════════════');
        _logger.i('✅ GOOGLE SIGN-IN COMPLETED SUCCESSFULLY');
        _logger.i('   Authenticated: ${state.isAuthenticated}');
        _logger.i('   User Email: ${state.userEmail ?? "Not available"}');
        _logger.i('═══════════════════════════════════════════════════════');
      } else {
        throw Exception(
            response.data['message'] ?? 'Authentication failed');
      }
    } catch (e, stackTrace) {
      _logger.e('');
      _logger.e('═══════════════════════════════════════════════════════');
      _logger.e('❌ ERROR IN GOOGLE SIGN-IN');
      _logger.e('   Error: $e');
      _logger.e('   Stack Trace: $stackTrace');
      _logger.e('═══════════════════════════════════════════════════════');

      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to sign in with Google: ${e.toString()}',
      );

      // Sign out from Google on error
      await _googleSignIn.signOut();
    }
  }

  /// Logout user and clear tokens
  Future<void> logout() async {
    try {
      state = state.copyWith(isLoading: true);

      final refreshToken = await _secureStorage.getRefreshToken();

      // Call logout API if refresh token exists
      if (refreshToken != null) {
        try {
          await _dio.post(
            '${appConfig.baseApiUrl}/api/auth/logout',
            data: {'refreshToken': refreshToken},
            options: Options(
              headers: {'Content-Type': 'application/json'},
            ),
          );
        } catch (e) {
          // Continue with local logout even if API call fails
          _logger.w('Logout API call failed: $e');
        }
      }

      // Sign out from Google
      await _googleSignIn.signOut();

      // Clear stored tokens
      await _secureStorage.deleteAccessToken();
      await _secureStorage.deleteRefreshToken();
      await _secureStorage.deleteUserEmail();

      // Reset state
      state = const AuthState(isLoading: false);

      _logger.i('✅ Logged out successfully');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to logout: ${e.toString()}',
      );
    }
  }

  /// Clear any error messages
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
