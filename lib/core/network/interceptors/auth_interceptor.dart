import 'package:dio/dio.dart';
import '../../constants/app_constants.dart';
import '../../storage/secure_storage.dart';

/// Interceptor to add authentication token to requests
class AuthInterceptor extends Interceptor {
  final SecureStorageService _secureStorage;

  AuthInterceptor(this._secureStorage);

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
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // If we get 401, the token might be expired
    // The calling code should handle token refresh
    handler.next(err);
  }
}
