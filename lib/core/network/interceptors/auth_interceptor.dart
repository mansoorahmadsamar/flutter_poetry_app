import 'dart:async';

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../auth/token_refresher.dart';
import '../../constants/app_constants.dart';
import '../../storage/secure_storage.dart';

/// Called when the session can no longer be refreshed. Must be idempotent:
/// several failing requests can report the same expiry.
typedef SessionExpiredCallback = Future<void> Function();

/// Adds credentials to requests and recovers from 401s.
///
/// On a 401 for a request that carried an access token:
/// - if another request already refreshed the token, retry with the new one;
/// - otherwise refresh once (shared by every concurrent 401, see
///   [TokenRefresher]) and retry the request once;
/// - if the refresh is refused, report [onSessionExpired] (the app signs the
///   user out and shows the login screen) and fail the request with its 401;
/// - if the refresh can't reach the server, fail the request with that
///   network error so the screen says "offline", and keep the user signed in.
///
/// Requests to the `/api/guest/**` surface (anonymous-only endpoints) bypass
/// auth-header injection AND the 401 handling — the backend strips
/// personalization for those calls and would otherwise see leftover
/// credentials. Requests sent without a token (a guest calling an
/// account-only endpoint) also never refresh or sign anyone out.
class AuthInterceptor extends Interceptor {
  final SecureStorageService _secureStorage;
  final Dio _dio;
  final TokenRefresher _refresher;
  final SessionExpiredCallback? _onSessionExpired;
  final Logger _logger = Logger();

  /// All paths starting with this prefix are treated as anonymous —
  /// no Authorization header, no X-User-Id, no 401 refresh.
  static const _guestPathPrefix = '/api/guest/';

  /// Marks a request that was already retried after a refresh, so a second
  /// 401 is passed on instead of refreshing in a loop.
  static const retriedAfterRefreshKey = 'auth.retriedAfterRefresh';

  AuthInterceptor(
    this._secureStorage,
    this._dio,
    this._refresher, {
    SessionExpiredCallback? onSessionExpired,
  }) : _onSessionExpired = onSessionExpired;

  bool _isGuestPath(String path) => path.startsWith(_guestPathPrefix);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Always set Content-Type regardless of path
    options.headers[AppConstants.contentTypeHeader] =
        AppConstants.contentTypeJson;

    // Guest endpoints must NEVER carry auth credentials, even if the user has
    // a valid token stored. The backend's caching + personalization-stripping
    // depend on a clean anonymous request.
    if (_isGuestPath(options.path)) {
      options.headers.remove(AppConstants.authorizationHeader);
      options.headers.remove('X-User-Id');
      return handler.next(options);
    }

    final accessToken = await _secureStorage.getAccessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers[AppConstants.authorizationHeader] =
          '${AppConstants.bearerPrefix} $accessToken';
    } else {
      // A retried request must not keep a stale header from its first try.
      options.headers.remove(AppConstants.authorizationHeader);
    }

    // Add user ID for personalization
    final userId = await _secureStorage.getUserId();
    if (userId != null && userId.isNotEmpty) {
      options.headers['X-User-Id'] = userId;
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final sentToken = _bearerToken(options);

    final canRecover = err.response?.statusCode == 401 &&
        !_isGuestPath(options.path) &&
        options.path != AppConstants.authRefreshPath &&
        options.extra[retriedAfterRefreshKey] != true &&
        sentToken != null;
    if (!canRecover) {
      _logError(err);
      return handler.next(err);
    }

    // Another request may have refreshed while this one was in flight.
    final storedToken = await _secureStorage.getAccessToken();
    if (storedToken != null &&
        storedToken.isNotEmpty &&
        storedToken != sentToken) {
      return _retry(options, handler);
    }

    _logger.w('401 on ${options.method} ${options.path}; refreshing token');
    final outcome = await _refresher.refresh();
    switch (outcome.kind) {
      case RefreshOutcomeKind.refreshed:
        return _retry(options, handler);
      case RefreshOutcomeKind.rejected:
        _logger.w('Session expired; signing out');
        // Not awaited: the caller gets its 401 now; sign-out (clearing tokens,
        // invalidating providers, routing to login) follows.
        final onSessionExpired = _onSessionExpired;
        if (onSessionExpired != null) {
          unawaited(onSessionExpired().catchError((Object e) {
            _logger.e('Session-expiry handler failed: $e');
          }));
        }
        return handler.next(err);
      case RefreshOutcomeKind.unavailable:
        // Report the network failure, not the 401: the user is offline, not
        // signed out.
        final cause = outcome.error!;
        return handler.next(DioException(
          requestOptions: options,
          response: cause.response,
          type: cause.type,
          error: cause.error,
          message: cause.message,
        ));
    }
  }

  Future<void> _retry(
    RequestOptions options,
    ErrorInterceptorHandler handler,
  ) async {
    options.extra[retriedAfterRefreshKey] = true;
    try {
      // onRequest attaches the current (new) token.
      final response = await _dio.fetch<dynamic>(options);
      handler.resolve(response);
    } on DioException catch (e) {
      // Already passed through the interceptors once; don't process it again.
      handler.reject(e);
    }
  }

  static String? _bearerToken(RequestOptions options) {
    final header = options.headers[AppConstants.authorizationHeader];
    if (header is! String) return null;
    const prefix = '${AppConstants.bearerPrefix} ';
    if (!header.startsWith(prefix)) return null;
    final token = header.substring(prefix.length);
    return token.isEmpty ? null : token;
  }

  void _logError(DioException err) {
    final hasToken = _bearerToken(err.requestOptions) != null;
    _logger.e(
      'API error ${err.response?.statusCode ?? err.type.name} on '
      '${err.requestOptions.method} ${err.requestOptions.path} '
      '(token attached: $hasToken)',
    );
  }
}
