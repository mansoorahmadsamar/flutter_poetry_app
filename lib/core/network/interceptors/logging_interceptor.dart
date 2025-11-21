import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../config/app_config.dart';

/// Interceptor for logging HTTP requests and responses
/// Logs full details without truncation in development mode
class LoggingInterceptor extends Interceptor {
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 8,
      lineLength: 2000, // Increased line length to prevent truncation
      colors: true,
      printEmojis: true,
    ),
  );

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (appConfig.enableLogging) {
      _logger.d('');
      _logger.d('═══════════════════════════════════════════════════════════════════════════════');
      _logger.d('📡 API REQUEST');
      _logger.d('   Method: ${options.method}');
      _logger.d('   Path: ${options.path}');
      _logger.d('   Full URL: ${options.uri}');

      _logger.d('');
      _logger.d('   📋 Headers:');
      _prettyPrintMap(options.headers);

      if (options.queryParameters.isNotEmpty) {
        _logger.d('');
        _logger.d('   🔗 Query Parameters:');
        _prettyPrintMap(options.queryParameters);
      }

      if (options.data != null) {
        _logger.d('');
        _logger.d('   💾 Request Body:');
        _prettyPrintData(options.data);
      }

      _logger.d('═══════════════════════════════════════════════════════════════════════════════');
      _logger.d('');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (appConfig.enableLogging) {
      _logger.d('');
      _logger.d('═══════════════════════════════════════════════════════════════════════════════');
      _logger.d('✅ API RESPONSE');
      _logger.d('   Status Code: ${response.statusCode}');
      _logger.d('   Path: ${response.requestOptions.path}');
      _logger.d('   Full URL: ${response.requestOptions.uri}');

      _logger.d('');
      _logger.d('   📋 Response Headers:');
      _prettyPrintMap(response.headers.map);

      if (response.data != null) {
        _logger.d('');
        _logger.d('   📦 Response Body:');
        _prettyPrintData(response.data);
      }

      _logger.d('═══════════════════════════════════════════════════════════════════════════════');
      _logger.d('');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (appConfig.enableLogging) {
      _logger.e('');
      _logger.e('═══════════════════════════════════════════════════════════════════════════════');
      _logger.e('❌ API ERROR');
      _logger.e('   Method: ${err.requestOptions.method}');
      _logger.e('   Path: ${err.requestOptions.path}');
      _logger.e('   Full URL: ${err.requestOptions.uri}');
      _logger.e('   Status Code: ${err.response?.statusCode ?? 'N/A'}');
      _logger.e('   Error Type: ${err.type.name}');
      _logger.e('   Message: ${err.message}');

      if (err.requestOptions.headers.isNotEmpty) {
        _logger.e('');
        _logger.e('   📋 Request Headers:');
        _prettyPrintMap(err.requestOptions.headers);
      }

      if (err.response?.data != null) {
        _logger.e('');
        _logger.e('   📦 Error Response Body:');
        _prettyPrintData(err.response?.data);
      }

      _logger.e('');
      _logger.e('   Stack Trace:');
      _logger.e(err.stackTrace.toString());

      _logger.e('═══════════════════════════════════════════════════════════════════════════════');
      _logger.e('');
    }
    handler.next(err);
  }

  /// Pretty print a map with proper indentation
  void _prettyPrintMap(Map<String, dynamic>? map) {
    if (map == null || map.isEmpty) {
      _logger.d('      (empty)');
      return;
    }

    try {
      final encoded = jsonEncode(map);
      final decoded = jsonDecode(encoded);
      final pretty = _formatJson(decoded, 6);
      _logger.d(pretty);
    } catch (e) {
      // Fallback to simple string representation
      map.forEach((key, value) {
        _logger.d('      $key: $value');
      });
    }
  }

  /// Pretty print various data types
  void _prettyPrintData(dynamic data) {
    if (data == null) {
      _logger.d('      (null)');
      return;
    }

    try {
      if (data is String) {
        // Try to parse as JSON if it looks like JSON
        if (data.startsWith('{') || data.startsWith('[')) {
          final decoded = jsonDecode(data);
          final pretty = _formatJson(decoded, 6);
          _logger.d(pretty);
        } else {
          _logger.d('      $data');
        }
      } else if (data is Map || data is List) {
        final encoded = jsonEncode(data);
        final decoded = jsonDecode(encoded);
        final pretty = _formatJson(decoded, 6);
        _logger.d(pretty);
      } else {
        _logger.d('      $data');
      }
    } catch (e) {
      // Fallback to simple string representation
      _logger.d('      ${data.toString()}');
    }
  }

  /// Format JSON with proper indentation
  String _formatJson(dynamic json, int indent) {
    final encoder = JsonEncoder.withIndent('   ');
    final encoded = encoder.convert(json);
    // Add proper indentation
    return encoded.split('\n').map((line) => '      $line').join('\n');
  }
}
