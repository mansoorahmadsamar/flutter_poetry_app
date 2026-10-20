import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_provider.dart';
import '../auth/token_refresher.dart';
import '../config/app_config.dart';
import '../constants/app_constants.dart';
import '../storage/secure_storage.dart';
import '../utils/clock.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';

/// HTTP client facade using Dio
/// Provides a configured Dio instance with interceptors
class DioClient {
  late final Dio _dio;
  late final TokenRefresher tokenRefresher;

  /// [httpClientAdapter] replaces the real network (tests only).
  /// [onSessionExpired] runs when a 401 can't be fixed by a token refresh.
  DioClient(
    SecureStorageService secureStorage, {
    HttpClientAdapter? httpClientAdapter,
    DateTime Function() now = DateTime.now,
    SessionExpiredCallback? onSessionExpired,
  }) {
    final options = BaseOptions(
      baseUrl: appConfig.baseApiUrl,
      connectTimeout: Duration(milliseconds: AppConstants.connectionTimeout),
      receiveTimeout: Duration(milliseconds: AppConstants.receiveTimeout),
      sendTimeout: Duration(milliseconds: AppConstants.sendTimeout),
      headers: {
        AppConstants.contentTypeHeader: AppConstants.contentTypeJson,
      },
      // Decode response bytes leniently: some catalog records have a
      // stray U+FFFD byte saved mid-string in the DB. Strict UTF-8
      // decoding throws and aborts the whole response parse, killing
      // any screen that loads the bad record. allowMalformed turns the
      // bad bytes into the replacement glyph instead of crashing.
      responseDecoder: (responseBytes, options, responseBody) =>
          utf8.decode(responseBytes, allowMalformed: true),
    );
    _dio = Dio(options);

    // The refresh call gets its own Dio without the auth interceptor, so it
    // can never wait on itself or trigger another refresh.
    final refreshDio = Dio(options.copyWith());
    for (final dio in [_dio, refreshDio]) {
      if (httpClientAdapter != null) {
        dio.httpClientAdapter = httpClientAdapter;
      } else {
        _acceptLegacyProdCertificate(dio);
      }
    }
    tokenRefresher = TokenRefresher(
      dio: refreshDio,
      storage: secureStorage,
      now: now,
    );

    // Add interceptors
    // Auth interceptor must be added first to intercept requests
    _dio.interceptors.addAll([
      AuthInterceptor(
        secureStorage,
        _dio,
        tokenRefresher,
        onSessionExpired: onSessionExpired,
      ),
      if (appConfig.enableLogging) LoggingInterceptor(),
    ]);
  }

  // Configure SSL certificate handling for production server with self-signed cert
  // Note: In production with a proper domain, remove this and use valid certificates
  static void _acceptLegacyProdCertificate(Dio dio) {
    if (appConfig.baseApiUrl.contains('134.199.243.167')) {
      (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.badCertificateCallback = (X509Certificate cert, String host, int port) {
          // Accept self-signed certificate for the production server
          return host == '134.199.243.167';
        };
        return client;
      };
    }
  }

  Dio get dio => _dio;

  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    return await _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return await _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return await _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }
}

/// Replaces the network adapter of [dioClientProvider]. Null (the default)
/// means the real network; tests override it with a fake.
final httpClientAdapterProvider = Provider<HttpClientAdapter?>((ref) => null);

/// Riverpod provider for DioClient
final dioClientProvider = Provider<DioClient>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return DioClient(
    secureStorage,
    httpClientAdapter: ref.watch(httpClientAdapterProvider),
    now: ref.watch(clockProvider),
    // Read lazily: authProvider itself uses this client.
    onSessionExpired: () => ref.read(authProvider.notifier).expireSession(),
  );
});
