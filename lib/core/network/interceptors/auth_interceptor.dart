import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../constants/app_constants.dart';
import '../../storage/secure_storage.dart';

/// Enhanced authentication interceptor with automatic token refresh
class AuthInterceptor extends Interceptor {
  final SecureStorageService _secureStorage;
  final Dio _dio;
  final Logger _logger = Logger();

  // Lock to prevent concurrent token refresh attempts
  bool _isRefreshing = false;
  final List<RequestInterceptorHandler> _pendingRequests = [];

  AuthInterceptor(this._secureStorage, this._dio);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Get access token from secure storage
    final accessToken = await _secureStorage.getAccessToken();

    // Add token to headers if available
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers[AppConstants.authorizationHeader] =
          '${AppConstants.bearerPrefix} $accessToken';
      _logger.i('🔐 Authorization token added (${accessToken.length} chars)');
    } else {
      _logger.w('⚠️  No authorization token available');
    }

    // Ensure content type is set
    options.headers[AppConstants.contentTypeHeader] =
        AppConstants.contentTypeJson;

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Handle 401 Unauthorized errors by attempting token refresh
    if (err.response?.statusCode == 401) {
      _logger.w('⚠️  Received 401 Unauthorized, attempting token refresh...');

      if (_isRefreshing) {
        _logger.i('⏳ Token refresh already in progress, queueing request...');
        // Queue this request to be retried after token refresh
        _pendingRequests.add(handler as RequestInterceptorHandler);
        return;
      }

      _isRefreshing = true;

      try {
        // Attempt to refresh the access token
        final refreshToken = await _secureStorage.getRefreshToken();

        if (refreshToken == null) {
          _logger.e('❌ No refresh token available');
          _isRefreshing = false;
          handler.reject(err);
          return;
        }

        _logger.i('🔄 Refreshing access token...');
        _logger.i('   Refresh Token Length: ${refreshToken.length} chars');
        _logger.i('   Original Request: ${err.requestOptions.method} ${err.requestOptions.path}');

        final response = await _dio.post(
          '/api/auth/refresh',
          data: {
            'refreshToken': refreshToken,
          },
          options: Options(
            headers: {'Content-Type': 'application/json'},
          ),
        );

        _logger.i('   Refresh Response Status: ${response.statusCode}');
        _logger.i('   Refresh Response Body: ${response.data}');

        if (response.statusCode == 200 &&
            response.data is Map &&
            response.data['success'] == true) {
          final data = response.data['data'];

          if (data != null && data['accessToken'] != null) {
            final newAccessToken = data['accessToken'] as String;
            final newRefreshToken =
                data['refreshToken'] as String? ?? refreshToken;

            await _secureStorage.saveAccessToken(newAccessToken);
            await _secureStorage.saveRefreshToken(newRefreshToken);

            _logger.i('✅ Token refreshed successfully');
            _logger.i('   New Access Token Length: ${newAccessToken.length} chars');
            _logger.i('   New Refresh Token Length: ${newRefreshToken.length} chars');

            // Update the original request with new token
            err.requestOptions.headers[AppConstants.authorizationHeader] =
                '${AppConstants.bearerPrefix} $newAccessToken';

            // Retry the original request with new token
            _isRefreshing = false;
            _logger.i('🔁 Retrying original request: ${err.requestOptions.method} ${err.requestOptions.path}');
            final retryResponse = await _dio.fetch(err.requestOptions);
            handler.resolve(retryResponse);

            // Retry all queued requests
            _retryQueuedRequests(newAccessToken);
            return;
          }
        }

        _logger.e('❌ Token refresh failed');
        _logger.e('   Status Code: ${response.statusCode}');
        _logger.e('   Response: ${response.data}');
        _isRefreshing = false;
        handler.reject(err);
        _clearPendingRequests(err);
      } catch (refreshError, stackTrace) {
        _logger.e('❌ Token refresh error: $refreshError');
        _logger.e('   Stack Trace: $stackTrace');
        _isRefreshing = false;
        handler.reject(err);
        _clearPendingRequests(err);
      }
    } else {
      // Handle other errors
      await _handleErrorResponse(err);
      handler.next(err);
    }
  }

  /// Retry all queued requests with new token
  void _retryQueuedRequests(String newAccessToken) {
    if (_pendingRequests.isNotEmpty) {
      _logger.i('🔁 Retrying ${_pendingRequests.length} queued requests...');
      _logger.i('   New Token Length: ${newAccessToken.length} chars');

      for (int i = 0; i < _pendingRequests.length; i++) {
        _logger.i('   [${i + 1}/${_pendingRequests.length}] Retrying queued request...');
        _pendingRequests[i].next(RequestOptions(path: ''));
      }
      _pendingRequests.clear();
      _logger.i('✅ All queued requests retried');
    }
  }

  /// Clear pending requests on error
  void _clearPendingRequests(DioException err) {
    if (_pendingRequests.isNotEmpty) {
      _logger.e('❌ Clearing ${_pendingRequests.length} pending requests');
      _logger.e('   Error: ${err.message}');

      for (final handler in _pendingRequests) {
        handler.reject(err);
      }
      _pendingRequests.clear();
      _logger.e('   All pending requests cleared');
    }
  }

  /// Log detailed error information
  Future<void> _handleErrorResponse(DioException err) async {
    final authHeader = err.requestOptions.headers[AppConstants.authorizationHeader];

    _logger.e('');
    _logger.e('═══════════════════════════════════════════════════════');
    _logger.e('❌ API REQUEST ERROR');
    _logger.e('   Status Code: ${err.response?.statusCode}');
    _logger.e('   Message: ${err.message}');
    _logger.e('   Path: ${err.requestOptions.path}');
    _logger.e('   Method: ${err.requestOptions.method}');
    _logger.e('   Type: ${err.type.name}');
    _logger.e('');
    _logger.e('   🔐 Authentication Info:');
    if (authHeader != null && authHeader.isNotEmpty) {
      _logger.e('      Token Attached: ✅ YES');
      _logger.e('      Header Length: ${authHeader.length} characters');
    } else {
      _logger.e('      Token Attached: ❌ NO');
    }
    _logger.e('═══════════════════════════════════════════════════════');
  }
}
