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
            lineLength: 80,
            colors: true,
            printEmojis: true,
            dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
          ),
        );

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (appConfig.enableLogging) {
      _logger.d('┌------------------------------------------------------------------------------');
      _logger.d('| REQUEST: ${options.method} ${options.uri}');
      _logger.d('| Headers: ${options.headers}');
      if (options.data != null) {
        _logger.d('| Body: ${options.data}');
      }
      _logger.d('└------------------------------------------------------------------------------');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (appConfig.enableLogging) {
      _logger.i('┌------------------------------------------------------------------------------');
      _logger.i('| RESPONSE: ${response.statusCode} ${response.requestOptions.uri}');
      _logger.i('| Data: ${response.data}');
      _logger.i('└------------------------------------------------------------------------------');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (appConfig.enableLogging) {
      _logger.e('┌------------------------------------------------------------------------------');
      _logger.e('| ERROR: ${err.requestOptions.method} ${err.requestOptions.uri}');
      _logger.e('| Status: ${err.response?.statusCode}');
      _logger.e('| Message: ${err.message}');
      _logger.e('| Data: ${err.response?.data}');
      _logger.e('└------------------------------------------------------------------------------');
    }
    handler.next(err);
  }
}
