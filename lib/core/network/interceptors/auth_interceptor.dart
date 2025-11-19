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

        final response = await _dio.post(
          '/api/auth/refresh',
          data: {
            'refreshToken': refreshToken,
          },
          options: Options(
            headers: {'Content-Type': 'application/json'},
          ),
        );

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

            // Update the original request with new token
            err.requestOptions.headers[AppConstants.authorizationHeader] =
                '${AppConstants.bearerPrefix} $newAccessToken';

            // Retry the original request with new token
            _isRefreshing = false;
            final retryResponse = await _dio.fetch(err.requestOptions);
            handler.resolve(retryResponse);

            // Retry all queued requests
            _retryQueuedRequests(newAccessToken);
            return;
          }
        }

        _logger.e('❌ Token refresh failed');
        _isRefreshing = false;
        handler.reject(err);
        _clearPendingRequests(err);
      } catch (refreshError) {
        _logger.e('❌ Token refresh error: $refreshError');
        _isRefreshing = false;
        handler.reject(err);
        _clearPendingRequests(err);
      }
    } else {
      // Handle other errors
      _handleErrorResponse(err);
      handler.next(err);
    }
  }

  /// Retry all queued requests with new token
  void _retryQueuedRequests(String newAccessToken) {
    _logger.i('🔁 Retrying ${_pendingRequests.length} queued requests...');

    for (final handler in _pendingRequests) {
      handler.next(RequestOptions(path: ''));
    }
    _pendingRequests.clear();
  }

  /// Clear pending requests on error
  void _clearPendingRequests(DioException err) {
    _logger.e('❌ Clearing ${_pendingRequests.length} pending requests');

    for (final handler in _pendingRequests) {
      handler.reject(err);
    }
    _pendingRequests.clear();
  }

  /// Log detailed error information
  void _handleErrorResponse(DioException err) {
    _logger.e('');
    _logger.e('═══════════════════════════════════════════════════════');
    _logger.e('❌ API REQUEST ERROR');
    _logger.e('   Status Code: ${err.response?.statusCode}');
    _logger.e('   Message: ${err.message}');
    _logger.e('   Path: ${err.requestOptions.path}');
    _logger.e('   Type: ${err.type.name}');
    _logger.e('═══════════════════════════════════════════════════════');
  }
}
