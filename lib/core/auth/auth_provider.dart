import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../network/dio_client.dart';
import '../utils/clock.dart';
import '../storage/preferences_service.dart';
import '../storage/secure_storage.dart';
import '../../features/discover/providers/discover_provider.dart';
import '../../features/discover/services/discover_service.dart';
import '../../features/main/tabs/poets/providers/poet_providers.dart';
import '../../features/engagement/providers/bookmark_providers.dart';
import '../../features/engagement/providers/bookmark_search_history_provider.dart';
import '../../features/engagement/providers/bookmark_search_provider.dart';
import '../../features/engagement/providers/couplet_providers.dart';
import '../../features/engagement/providers/unified_bookmark_provider.dart';
import '../../features/feed/providers/feed_engagement_provider.dart';
import '../../features/feed/providers/feed_provider.dart';
import '../../features/search/providers/search_providers.dart';
import 'firebase_auth_service.dart';
import 'jwt_expiry.dart';
import 'token_refresher.dart';
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
  late final DateTime Function() _now;

  /// The sign-out in progress after a refused refresh, shared by every
  /// request that reports it.
  Future<void>? _sessionExpiry;

  AuthNotifier(this._secureStorage, this._ref) : super(const AuthState()) {
    _firebaseAuthService = _ref.read(firebaseAuthServiceProvider);
    _now = _ref.read(clockProvider);
    _checkAuthStatus();
  }

  TokenRefresher get _tokenRefresher =>
      _ref.read(dioClientProvider).tokenRefresher;

  /// Restore the stored session on app start.
  ///
  /// Stored tokens are only trusted while the access token's `exp` is in the
  /// future. An expired access token is refreshed first; if the refresh is
  /// refused (or the refresh token has expired too) the user is signed out
  /// and lands on the login screen with a "session expired" message. If the
  /// server can't be reached the user stays signed in — being offline is not
  /// a reason to lose the session.
  Future<void> _checkAuthStatus() async {
    _logger.i('🔍 Checking authentication status on app start...');
    state = state.copyWith(isLoading: true, isRestoringSession: true);

    try {
      var accessToken = await _secureStorage.getAccessToken();
      var refreshToken = await _secureStorage.getRefreshToken();
      final userEmail = await _secureStorage.getUserEmail();

      if (accessToken == null || refreshToken == null) {
        _logger.i('⚠️  No stored tokens found, user is not authenticated');
        state = const AuthState();
        return;
      }

      if (isJwtExpired(accessToken, now: _now())) {
        _logger.i('⏰ Stored access token has expired, refreshing...');
        final outcome = await _tokenRefresher.refresh();
        switch (outcome.kind) {
          case RefreshOutcomeKind.rejected:
            _logger.w('Session could not be refreshed; signing out');
            await _endExpiredSession();
            return;
          case RefreshOutcomeKind.unavailable:
            _logger.w('Server unreachable; keeping the stored session');
            break;
          case RefreshOutcomeKind.refreshed:
            accessToken = outcome.accessToken!;
            refreshToken = await _secureStorage.getRefreshToken() ?? refreshToken;
            break;
        }
      }

      _logger.i('✅ User is authenticated, restoring session');
      state = AuthState(
        isAuthenticated: true,
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
    } catch (e) {
      _logger.e('❌ Error checking auth status: $e');
      state = const AuthState(
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
        sessionExpired: false,
      );

      _logger.i('');
      _logger.i('═══════════════════════════════════════════════════════');
      _logger.i('✅ FIREBASE SIGN-IN COMPLETED - AUTH STATE UPDATED');
      _logger.i('   Email: $email');
      _logger.i('═══════════════════════════════════════════════════════');
      _logger.i('');

      // Drop any guest-cached/anonymous data so the now-authenticated user
      // sees their personalized feed/discover rather than the guest bundle.
      _invalidateGuestSurfaces();

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

  /// Sign in with Apple via Firebase Auth.
  ///
  /// Mirrors [signInWithGoogle]'s state machine — same loading/error/state
  /// shape so the UI doesn't need to special-case Apple. Backend
  /// verification reuses `/api/auth/firebase/verify`; existing accounts
  /// link by email automatically.
  ///
  /// Required for App Store Guideline 4.8.
  Future<void> signInWithApple() async {
    _logger.i('');
    _logger.i('═══════════════════════════════════════════════════════');
    _logger.i('🍎 AUTH NOTIFIER - STARTING FIREBASE APPLE SIGN-IN');
    _logger.i('═══════════════════════════════════════════════════════');

    try {
      _logger.i('⏳ Setting loading state...');
      state = state.copyWith(isLoading: true, errorMessage: null);

      _logger.i('');
      _logger.i('🔥 Calling Firebase Auth Service...');
      final result = await _firebaseAuthService.signInWithApple();

      if (result.isEmpty) {
        _logger.w('⚠️  User cancelled Apple Sign-In');
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
        sessionExpired: false,
      );

      _logger.i('');
      _logger.i('═══════════════════════════════════════════════════════');
      _logger.i('✅ FIREBASE APPLE SIGN-IN COMPLETED - AUTH STATE UPDATED');
      _logger.i('   Email: $email');
      _logger.i('═══════════════════════════════════════════════════════');
      _logger.i('');

      // Drop any guest-cached/anonymous data so the now-authenticated user
      // sees their personalized feed/discover rather than the guest bundle.
      _invalidateGuestSurfaces();
    } on FirebaseAuthException catch (e) {
      _logger.e('❌ Firebase Auth Exception (Apple): ${e.code} - ${e.message}');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Apple Sign-In failed: ${e.message}',
      );
    } catch (e, stackTrace) {
      _logger.e('');
      _logger.e('═══════════════════════════════════════════════════════');
      _logger.e('❌ ERROR IN APPLE SIGN-IN');
      _logger.e('   Error: $e');
      _logger.e('   Stack Trace: $stackTrace');
      _logger.e('═══════════════════════════════════════════════════════');

      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );

      // Sign out from Firebase on error to clean up state
      await _firebaseAuthService.signOut();
    }
  }

  /// Invalidate guest-facing surfaces after a successful sign-in so the
  /// authenticated user gets their personalized data instead of the cached
  /// anonymous guest bundle. Cache clear is best-effort — it must never
  /// break the sign-in flow.
  void _invalidateGuestSurfaces() {
    try {
      _ref.read(discoverServiceProvider).clearCache();
    } catch (_) {
      // Best-effort; ignore.
    }
    final container = _ref.container;
    container.invalidate(feedProvider);
    container.invalidate(discoverProvider);
    container.invalidate(featuredPoetsProvider);
    container.invalidate(trendingPoetsProvider);
    container.invalidate(allPoetsProvider);
  }

  /// Refresh the access token now (e.g. so a new role appears in it).
  ///
  /// Returns false when it could not refresh. A refused refresh signs the
  /// user out (see [expireSession]); a network failure does not.
  Future<bool> refreshAccessToken() async {
    _logger.i('🔄 Auth Notifier - Refreshing access token...');
    final outcome = await _tokenRefresher.refresh();
    switch (outcome.kind) {
      case RefreshOutcomeKind.refreshed:
        state = state.copyWith(
          accessToken: outcome.accessToken,
          refreshToken: await _secureStorage.getRefreshToken(),
        );
        _logger.i('✅ Access token refreshed successfully');
        return true;
      case RefreshOutcomeKind.rejected:
        await expireSession();
        return false;
      case RefreshOutcomeKind.unavailable:
        _logger.w('⚠️  Token refresh unavailable (offline?)');
        return false;
    }
  }

  /// Sign the user out because their session can no longer be refreshed.
  ///
  /// Called by the network layer when a refresh is refused. Clears the
  /// session on this device only (the backend already ended it) and sets
  /// [AuthState.sessionExpired] so the login screen can say why. Safe to call
  /// many times: concurrent calls share one sign-out, and it does nothing for
  /// a user who is not signed in (guests are never sent to login by it).
  Future<void> expireSession() {
    if (!state.isAuthenticated) return Future.value();
    return _sessionExpiry ??=
        _endExpiredSession().whenComplete(() => _sessionExpiry = null);
  }

  Future<void> _endExpiredSession() async {
    _logger.i('🔐 Session expired — clearing local session');
    try {
      await _firebaseAuthService.clearLocalSession();
    } catch (e) {
      _logger.e('❌ Clearing local session failed: $e');
    }
    await _clearUserData();
    state = const AuthState(sessionExpired: true);
  }

  /// The user has read the "session expired" notice (e.g. chose to continue
  /// as a guest).
  void acknowledgeSessionExpired() {
    if (state.sessionExpired) {
      state = state.copyWith(sessionExpired: false);
    }
  }

  /// Remove what belongs to the signed-in user from this device and drop
  /// every provider that may hold their data. The language choice and (unless
  /// [includeSearchHistory]) search history are device settings and stay.
  Future<void> _clearUserData({bool includeSearchHistory = false}) async {
    try {
      final prefs = _ref.read(preferencesServiceProvider);
      await prefs.clearUserData(includeSearchHistory: includeSearchHistory);
    } catch (e) {
      _logger.w('⚠️  Failed to clear preferences: $e');
    }

    // Through the container: in debug builds `Ref.invalidate` asserts by
    // reading the provider, which would first CREATE every provider below
    // (firing their network loads) only to throw them away.
    final container = _ref.container;

    container.invalidate(feedProvider);
    container.invalidate(feedEngagementProvider);
    container.invalidate(discoverProvider);
    container.invalidate(bookmarkedCoupletsProvider);
    container.invalidate(unifiedBookmarksProvider);
    container.invalidate(bookmarkActionProvider);
    container.invalidate(bookmarkSearchProvider);
    container.invalidate(bookmarkSearchHistoryProvider);
    container.invalidate(coupletsProvider);
    container.invalidate(coupletProvider);
    container.invalidate(coupletActionProvider);
    container.invalidate(searchHistoryProvider);
    container.invalidate(searchQueryProvider);
  }

  /// Logout
  Future<void> logout() async {
    _logger.i('🔐 LOGGING OUT USER');

    try {
      state = state.copyWith(isLoading: true);
      await _firebaseAuthService.signOut();
      await _clearUserData();
      state = const AuthState();
      _logger.i('✅ USER LOGGED OUT - ALL DATA CLEARED');
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

  /// Permanently delete the authenticated user's account.
  ///
  /// Calls `DELETE /api/users/me` with `{"confirmation":"DELETE"}` (App Store
  /// Guideline 5.1.1(v)). On 200, hard-deletes the user on the backend, then
  /// clears local session state mirroring [logout].
  Future<void> deleteAccount() async {
    _logger.i('');
    _logger.i('═══════════════════════════════════════════════════════');
    _logger.i('🗑️  DELETING ACCOUNT');
    _logger.i('═══════════════════════════════════════════════════════');

    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final dioClient = _ref.read(dioClientProvider);
      final response = await dioClient.delete<Map<String, dynamic>>(
        '/api/users/me',
        data: {'confirmation': 'DELETE'},
      );

      final body = response.data;
      final success = response.statusCode == 200 && body?['success'] == true;
      if (!success) {
        final message = body?['message']?.toString() ??
            'Failed to delete account (status ${response.statusCode})';
        throw Exception(message);
      }

      _logger.i('✅ Server-side account deletion succeeded');

      _logger.i('   Signing out of Firebase + clearing secure storage...');
      await _firebaseAuthService.signOut();

      // Deleting the account also forgets what was searched on it.
      await _clearUserData(includeSearchHistory: true);

      // Resetting to default AuthState clears tokens and sets isAuthenticated
      // to false; the GoRouter redirect listening on auth state will send the
      // user back to /login automatically.
      state = const AuthState();

      _logger.i('═══════════════════════════════════════════════════════');
      _logger.i('✅ ACCOUNT DELETED — ALL LOCAL DATA CLEARED');
      _logger.i('═══════════════════════════════════════════════════════');
      _logger.i('');
    } on DioException catch (e) {
      final serverMessage =
          (e.response?.data is Map<String, dynamic>
                  ? (e.response?.data as Map<String, dynamic>)['message']
                  : null)
              ?.toString();
      _logger.e('❌ Delete account failed: ${e.message}');
      state = state.copyWith(
        isLoading: false,
        errorMessage:
            serverMessage ?? 'Failed to delete account. Please try again.',
      );
      rethrow;
    } catch (e) {
      _logger.e('❌ Delete account error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }
}
