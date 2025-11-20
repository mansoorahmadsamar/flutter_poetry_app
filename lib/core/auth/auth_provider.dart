import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../storage/secure_storage.dart';
import 'firebase_auth_service.dart';
import 'auth_state.dart';

/// Authentication provider for managing auth state
/// Uses Firebase Authentication with backend JWT verification
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return AuthNotifier(secureStorage, ref);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final SecureStorageService _secureStorage;
  final Logger _logger = Logger();
  late final FirebaseAuthService _firebaseAuthService;

  AuthNotifier(this._secureStorage, Ref ref) : super(const AuthState()) {
    // Initialize Firebase Auth Service
    _firebaseAuthService = FirebaseAuthService(_secureStorage);
    _checkAuthStatus();
  }

  /// Check if user is already authenticated on app start
  Future<void> _checkAuthStatus() async {
    _logger.i('🔍 Checking authentication status on app start...');
    state = state.copyWith(isLoading: true);

    try {
      final accessToken = await _secureStorage.getAccessToken();
      final refreshToken = await _secureStorage.getRefreshToken();
      final userEmail = await _secureStorage.getUserEmail();

      if (accessToken != null && refreshToken != null) {
        _logger.i('✅ User is authenticated, restoring session');
        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          accessToken: accessToken,
          refreshToken: refreshToken,
          userEmail: userEmail,
        );
      } else {
        _logger.i('⚠️  No stored tokens found, user is not authenticated');
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      _logger.e('❌ Error checking auth status: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to check authentication status',
      );
    }
  }

  /// Sign in with Google using Firebase Auth
  /// This now uses Firebase Authentication with backend verification
  Future<void> signInWithGoogle() async {
    _logger.i('');
    _logger.i('═══════════════════════════════════════════════════════');
    _logger.i('🔐 AUTH NOTIFIER - STARTING FIREBASE GOOGLE SIGN-IN');
    _logger.i('═══════════════════════════════════════════════════════');

    try {
      _logger.i('⏳ Setting loading state...');
      state = state.copyWith(isLoading: true, errorMessage: null);

      _logger.i('');
      _logger.i('🔥 Calling Firebase Auth Service...');
      final result = await _firebaseAuthService.signInWithGoogle();

      if (result.isEmpty) {
        _logger.w('⚠️  User cancelled the sign-in');
        state = state.copyWith(isLoading: false);
        return;
      }

      final accessToken = result['accessToken'] as String?;
      final refreshToken = result['refreshToken'] as String?;
      final email = result['email'] as String?;

      if (accessToken == null || refreshToken == null) {
        throw Exception('Backend did not return required tokens');
      }

      _logger.i('');
      _logger.i('📝 Updating auth state...');
      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        accessToken: accessToken,
        refreshToken: refreshToken,
        userEmail: email,
        errorMessage: null,
      );

      _logger.i('');
      _logger.i('═══════════════════════════════════════════════════════');
      _logger.i('✅ FIREBASE SIGN-IN COMPLETED - AUTH STATE UPDATED');
      _logger.i('   Email: $email');
      _logger.i('═══════════════════════════════════════════════════════');
      _logger.i('');

      // Note: Profile provider will automatically re-fetch due to auth state change
      // since it watches authProvider for isAuthenticated changes
    } on FirebaseAuthException catch (e) {
      _logger.e('❌ Firebase Auth Exception: ${e.code} - ${e.message}');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Firebase Auth failed: ${e.message}',
      );
    } catch (e, stackTrace) {
      _logger.e('');
      _logger.e('═══════════════════════════════════════════════════════');
      _logger.e('❌ ERROR IN FIREBASE SIGN-IN');
      _logger.e('   Error: $e');
      _logger.e('   Stack Trace: $stackTrace');
      _logger.e('═══════════════════════════════════════════════════════');

      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to sign in: ${e.toString()}',
      );

      // Sign out from Firebase on error to clean up state
      await _firebaseAuthService.signOut();
    }
  }

  /// Refresh access token
  Future<bool> refreshAccessToken() async {
    _logger.i('🔄 Auth Notifier - Refreshing access token...');

    try {
      final newAccessToken = await _firebaseAuthService.refreshAccessToken();

      if (newAccessToken != null) {
        state = state.copyWith(accessToken: newAccessToken);
        _logger.i('✅ Access token refreshed successfully');
        return true;
      } else {
        _logger.e('❌ Token refresh failed');
        // Token refresh failed, force logout
        await logout();
        return false;
      }
    } catch (e) {
      _logger.e('❌ Token refresh error: $e');
      await logout();
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    _logger.i('');
    _logger.i('═══════════════════════════════════════════════════════');
    _logger.i('🔐 LOGGING OUT USER');
    _logger.i('═══════════════════════════════════════════════════════');

    try {
      state = state.copyWith(isLoading: true);

      _logger.i('   Calling Firebase Auth Service logout...');
      await _firebaseAuthService.signOut();

      _logger.i('✅ Logout successful');

      state = const AuthState();

      _logger.i('═══════════════════════════════════════════════════════');
      _logger.i('✅ USER LOGGED OUT - STATE CLEARED');
      _logger.i('═══════════════════════════════════════════════════════');
      _logger.i('');
    } catch (e) {
      _logger.e('❌ Logout error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Logout failed: $e',
      );
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
