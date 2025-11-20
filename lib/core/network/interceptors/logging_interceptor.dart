import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../config/app_config.dart';

/// Interceptor for logging HTTP requests and responses
/// Only enabled in development mode
class LoggingInterceptor extends Interceptor {
  final Logger _logger = Logger();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (appConfig.enableLogging) {
      _logger.i('→ REQUEST: ${options.method} ${options.path}');
      _logger.i('→ Headers: ${jsonEncode(options.headers)}');
      if (options.queryParameters.isNotEmpty) {
        _logger.i('→ Query: ${jsonEncode(options.queryParameters)}');
      }
      if (options.data != null) {
        _logger.i('→ Body: ${jsonEncode(options.data)}');
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (appConfig.enableLogging) {
      _logger.i('← RESPONSE: ${response.statusCode} ${response.requestOptions.path}');
      if (response.data != null) {
        _logger.i('← Body: ${jsonEncode(response.data)}');
      }
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (appConfig.enableLogging) {
      _logger.e('✗ ERROR: ${err.requestOptions.method} ${err.requestOptions.path}');
      _logger.e('✗ Status: ${err.response?.statusCode ?? 'N/A'}');
      _logger.e('✗ Message: ${err.message}');
      if (err.response?.data != null) {
        _logger.e('✗ Body: ${jsonEncode(err.response?.data)}');
      }
    }
    handler.next(err);
  }
}
