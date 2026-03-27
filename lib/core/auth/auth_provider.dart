import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../network/dio_client.dart';
import '../storage/preferences_service.dart';
import '../storage/secure_storage.dart';
import '../../features/discover/providers/discover_provider.dart';
import '../../features/engagement/providers/bookmark_providers.dart';
import '../../features/engagement/providers/bookmark_search_history_provider.dart';
import '../../features/engagement/providers/bookmark_search_provider.dart';
import '../../features/engagement/providers/couplet_providers.dart';
import '../../features/engagement/providers/unified_bookmark_provider.dart';
import '../../features/feed/providers/feed_engagement_provider.dart';
import '../../features/feed/providers/feed_provider.dart';
import '../../features/search/providers/search_providers.dart';
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
  final Ref _ref;
  final Logger _logger = Logger();
  late final FirebaseAuthService _firebaseAuthService;

  AuthNotifier(this._secureStorage, this._ref) : super(const AuthState()) {
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

        // Backfill numeric userId for X-User-Id header if not stored or stale UUID
        final storedUserId = await _secureStorage.getUserId();
        if (storedUserId == null || storedUserId.isEmpty || storedUserId.contains('-')) {
          _logger.i('🔄 User ID missing or stale, fetching from profile...');
          _backfillUserId();
        }
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

  /// Backfill userId from /api/auth/me for existing sessions
  Future<void> _backfillUserId() async {
    try {
      final dioClient = _ref.read(dioClientProvider);
      final response =
          await dioClient.get<Map<String, dynamic>>('/api/auth/me');

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data!;
        if (data['success'] == true && data['data'] != null) {
          final userId = data['data']['userId']?.toString();
          if (userId != null && userId.isNotEmpty) {
            await _secureStorage.saveUserId(userId);
            _logger.i('✅ User ID backfilled: $userId');
          }
        }
      }
    } catch (e) {
      _logger.w('⚠️  Failed to backfill user ID: $e');
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

      // Clear search history from SharedPreferences
      _logger.i('   Clearing SharedPreferences...');
      try {
        final prefs = _ref.read(preferencesServiceProvider);
        await prefs.clearAll();
      } catch (e) {
        _logger.w('⚠️  Failed to clear preferences: $e');
      }

      // Invalidate all user-specific providers to clear cached data
      _logger.i('   Invalidating cached providers...');
      _ref.invalidate(feedProvider);
      _ref.invalidate(feedEngagementProvider);
      _ref.invalidate(discoverProvider);
      _ref.invalidate(bookmarkedCoupletsProvider);
      _ref.invalidate(unifiedBookmarksProvider);
      _ref.invalidate(bookmarkActionProvider);
      _ref.invalidate(bookmarkSearchProvider);
      _ref.invalidate(bookmarkSearchHistoryProvider);
      _ref.invalidate(coupletsProvider);
      _ref.invalidate(coupletProvider);
      _ref.invalidate(coupletActionProvider);
      _ref.invalidate(searchHistoryProvider);
      _ref.invalidate(searchQueryProvider);

      _logger.i('✅ Logout successful');

      state = const AuthState();

      _logger.i('═══════════════════════════════════════════════════════');
      _logger.i('✅ USER LOGGED OUT - ALL DATA CLEARED');
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
