import 'dart:async';

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../constants/app_constants.dart';
import '../storage/secure_storage.dart';
import 'jwt_expiry.dart';

/// How a refresh attempt ended.
enum RefreshOutcomeKind {
  /// New tokens are stored.
  refreshed,

  /// The session is over: there is no refresh token, it has expired, or the
  /// server refused it. Only signing in again helps.
  rejected,

  /// The server could not be reached (offline, timeout, gateway error). The
  /// session may still be fine — never log out for this.
  unavailable,
}

class RefreshOutcome {
  final RefreshOutcomeKind kind;
  final String? accessToken;

  /// The transport failure behind [RefreshOutcomeKind.unavailable].
  final DioException? error;

  const RefreshOutcome._(this.kind, {this.accessToken, this.error});

  const RefreshOutcome.refreshed(String accessToken)
      : this._(RefreshOutcomeKind.refreshed, accessToken: accessToken);
  const RefreshOutcome.rejected() : this._(RefreshOutcomeKind.rejected);
  const RefreshOutcome.unavailable(DioException error)
      : this._(RefreshOutcomeKind.unavailable, error: error);
}

/// Exchanges the stored refresh token for new tokens, once at a time.
///
/// - Single flight: concurrent callers share one `POST /api/auth/refresh`.
/// - Uses its own [Dio] with no auth interceptor, so the refresh call can
///   never be queued behind itself or trigger another refresh.
/// - Sends no `Authorization` header: the endpoint is public and only reads
///   the refresh token from the body.
class TokenRefresher {
  final Dio _dio;
  final SecureStorageService _storage;
  final DateTime Function() _now;
  final Logger _logger = Logger();

  Future<RefreshOutcome>? _inFlight;

  TokenRefresher({
    required Dio dio,
    required SecureStorageService storage,
    required DateTime Function() now,
  })  : _dio = dio,
        _storage = storage,
        _now = now;

  Future<RefreshOutcome> refresh() {
    return _inFlight ??= _refresh().whenComplete(() => _inFlight = null);
  }

  Future<RefreshOutcome> _refresh() async {
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      _logger.w('Token refresh: no refresh token stored');
      return const RefreshOutcome.rejected();
    }
    // Refresh tokens are JWTs that live 7 days; an expired one is refused by
    // the server, so don't spend a request on it.
    if (isJwtExpired(refreshToken, now: _now(), leeway: Duration.zero)) {
      _logger.w('Token refresh: refresh token has expired');
      return const RefreshOutcome.rejected();
    }

    final Response<dynamic> response;
    try {
      response = await _dio.post<dynamic>(
        AppConstants.authRefreshPath,
        data: {'refreshToken': refreshToken},
      );
    } on DioException catch (e) {
      if (_sessionIsOver(e)) {
        _logger.w('Token refresh refused (${e.response?.statusCode})');
        return const RefreshOutcome.rejected();
      }
      _logger.w('Token refresh unavailable (${e.type.name})');
      return RefreshOutcome.unavailable(e);
    }

    final body = response.data;
    final data = body is Map ? body['data'] : null;
    final accessToken = data is Map ? data['accessToken'] : null;
    if (body is! Map ||
        body['success'] != true ||
        accessToken is! String ||
        accessToken.isEmpty) {
      _logger.w('Token refresh: unexpected response shape');
      return const RefreshOutcome.rejected();
    }
    final newRefreshToken = data['refreshToken'];
    await _storage.saveAccessToken(accessToken);
    await _storage.saveRefreshToken(
      newRefreshToken is String && newRefreshToken.isNotEmpty
          ? newRefreshToken
          : refreshToken,
    );
    _logger.i('Token refreshed');
    return RefreshOutcome.refreshed(accessToken);
  }

  /// Whether a failed refresh means the refresh token is dead.
  ///
  /// Any 4xx is a refusal. So is a plain 500: the backend throws an
  /// unhandled RuntimeException for an unknown, expired or revoked refresh
  /// token (AuthController.refreshToken / RefreshTokenService.verifyExpiration),
  /// which Spring turns into a 500. 502/503/504 come from the gateway while
  /// the API is down and are treated as "unavailable", like a lost connection.
  static bool _sessionIsOver(DioException e) {
    if (e.type != DioExceptionType.badResponse) return false;
    final status = e.response?.statusCode;
    if (status == null) return false;
    return (status >= 400 && status < 500) || status == 500;
  }
}
