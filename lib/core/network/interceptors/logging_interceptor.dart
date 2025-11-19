import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../config/app_config.dart';

/// Interceptor for logging HTTP requests and responses
/// Only enabled in development mode
class LoggingInterceptor extends Interceptor {
  final Logger _logger;

  LoggingInterceptor()
      : _logger = Logger(
          printer: PrettyPrinter(
            methodCount: 0,
            errorMethodCount: 5,
            lineLength: 100,
            colors: true,
            printEmojis: true,
            dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
          ),
        );

  String _formatBody(dynamic body) {
    if (body == null) return 'None';
    if (body is String) return body;
    if (body is Map) return body.toString();
    if (body is List) return body.toString();
    return body.toString();
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (appConfig.enableLogging) {
      _logger.i('');
      _logger.i('╔════════════════════════════════════════════════════════════════════════════════╗');
      _logger.i('║ 🔵 HTTP REQUEST                                                                ║');
      _logger.i('╠════════════════════════════════════════════════════════════════════════════════╣');
      _logger.i('║ Method: ${_padRight(options.method, 20)} ${_padRight('URL: ${options.baseUrl}${options.path}', 55)} ║');
      _logger.i('╠════════════════════════════════════════════════════════════════════════════════╣');

      // Headers
      _logger.i('║ 📋 Headers:                                                                    ║');
      options.headers.forEach((key, value) {
        if (key.toLowerCase() == 'authorization') {
          _logger.i('║   • $key: ${value.toString().replaceRange(20, null, '...TOKEN_TRUNCATED')}');
        } else {
          _logger.i('║   • $key: $value');
        }
      });

      // Query Parameters
      if (options.queryParameters.isNotEmpty) {
        _logger.i('║ 🔍 Query Parameters:                                                          ║');
        options.queryParameters.forEach((key, value) {
          _logger.i('║   • $key: $value');
        });
      }

      // Body
      if (options.data != null) {
        _logger.i('║ 📦 Request Body:                                                             ║');
        final body = _formatBody(options.data);
        _logger.i('║   $body');
      }

      _logger.i('╚════════════════════════════════════════════════════════════════════════════════╝');
      _logger.i('');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (appConfig.enableLogging) {
      final statusCode = response.statusCode ?? 0;
      final statusIcon = statusCode >= 200 && statusCode < 300 ? '✅' : '⚠️ ';

      _logger.i('');
      _logger.i('╔════════════════════════════════════════════════════════════════════════════════╗');
      _logger.i('║ $statusIcon HTTP RESPONSE - Status: $statusCode                                          ║');
      _logger.i('╠════════════════════════════════════════════════════════════════════════════════╣');
      _logger.i('║ URL: ${response.requestOptions.baseUrl}${response.requestOptions.path}');
      _logger.i('╠════════════════════════════════════════════════════════════════════════════════╣');

      // Headers
      if (response.headers.map.isNotEmpty) {
        _logger.i('║ 📋 Response Headers:                                                          ║');
        response.headers.map.forEach((key, values) {
          _logger.i('║   • $key: ${values.join(', ')}');
        });
      }

      // Response Body
      if (response.data != null) {
        _logger.i('║ 📦 Response Body:                                                            ║');
        final body = _formatBody(response.data);
        if (body.length > 80) {
          _logger.i('║   ${body.substring(0, 77)}... ║');
        } else {
          _logger.i('║   $body');
        }
      }

      _logger.i('╚════════════════════════════════════════════════════════════════════════════════╝');
      _logger.i('');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (appConfig.enableLogging) {
      _logger.e('');
      _logger.e('╔════════════════════════════════════════════════════════════════════════════════╗');
      _logger.e('║ ❌ HTTP ERROR                                                                  ║');
      _logger.e('╠════════════════════════════════════════════════════════════════════════════════╣');
      _logger.e('║ Method: ${err.requestOptions.method} | URL: ${err.requestOptions.uri}');
      _logger.e('║ Status Code: ${err.response?.statusCode ?? 'N/A'}');
      _logger.e('║ Error Type: ${err.type}');
      _logger.e('║ Message: ${err.message}');
      _logger.e('╠════════════════════════════════════════════════════════════════════════════════╣');

      if (err.response != null) {
        _logger.e('║ 📦 Error Response:                                                           ║');
        final body = _formatBody(err.response?.data);
        if (body.length > 80) {
          _logger.e('║   ${body.substring(0, 77)}... ║');
        } else {
          _logger.e('║   $body');
        }
      }

      _logger.e('╚════════════════════════════════════════════════════════════════════════════════╝');
      _logger.e('');
    }
    handler.next(err);
  }

  String _padRight(String text, int width) {
    if (text.length >= width) return text.substring(0, width);
    return text + ' ' * (width - text.length);
  }
}
