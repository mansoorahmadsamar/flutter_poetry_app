import 'package:equatable/equatable.dart';

/// Base class for all application errors
abstract class AppError extends Equatable {
  final String message;
  final String? userMessage;
  final StackTrace? stackTrace;

  const AppError({
    required this.message,
    this.userMessage,
    this.stackTrace,
  });

  /// User-friendly message to display in UI
  String get displayMessage => userMessage ?? message;

  @override
  List<Object?> get props => [message, userMessage];
}

/// Network-related errors
class NetworkError extends AppError {
  const NetworkError({
    required super.message,
    super.userMessage,
    super.stackTrace,
  });

  factory NetworkError.offline() {
    return const NetworkError(
      message: 'No internet connection',
      userMessage: 'Please check your internet connection and try again',
    );
  }

  factory NetworkError.timeout() {
    return const NetworkError(
      message: 'Request timeout',
      userMessage: 'The request took too long. Please try again',
    );
  }

  factory NetworkError.serverError() {
    return const NetworkError(
      message: 'Server error',
      userMessage: 'Something went wrong on our end. Please try again later',
    );
  }
}

/// Authentication-related errors
class AuthError extends AppError {
  const AuthError({
    required super.message,
    super.userMessage,
    super.stackTrace,
  });

  factory AuthError.unauthorized() {
    return const AuthError(
      message: 'Unauthorized',
      userMessage: 'Your session has expired. Please login again',
    );
  }

  factory AuthError.forbidden() {
    return const AuthError(
      message: 'Forbidden',
      userMessage: 'You don\'t have permission to access this resource',
    );
  }

  factory AuthError.tokenExpired() {
    return const AuthError(
      message: 'Token expired',
      userMessage: 'Your session has expired. Please login again',
    );
  }

  factory AuthError.invalidCredentials() {
    return const AuthError(
      message: 'Invalid credentials',
      userMessage: 'Invalid email or password',
    );
  }
}

/// Validation-related errors
class ValidationError extends AppError {
  final Map<String, String>? fieldErrors;

  const ValidationError({
    required super.message,
    super.userMessage,
    this.fieldErrors,
    super.stackTrace,
  });

  @override
  List<Object?> get props => [...super.props, fieldErrors];
}

/// Cache-related errors
class CacheError extends AppError {
  const CacheError({
    required super.message,
    super.userMessage,
    super.stackTrace,
  });

  factory CacheError.notFound() {
    return const CacheError(
      message: 'Cache not found',
      userMessage: 'Data not available offline',
    );
  }

  factory CacheError.writeError() {
    return const CacheError(
      message: 'Failed to write to cache',
      userMessage: 'Failed to save data locally',
    );
  }
}

/// Generic errors
class GenericError extends AppError {
  const GenericError({
    required super.message,
    super.userMessage,
    super.stackTrace,
  });

  factory GenericError.unknown() {
    return const GenericError(
      message: 'Unknown error',
      userMessage: 'Something went wrong. Please try again',
    );
  }
}

/// Parse HTTP status code to appropriate error
AppError errorFromStatusCode(int statusCode, String message) {
  switch (statusCode) {
    case 401:
      return AuthError.unauthorized();
    case 403:
      return AuthError.forbidden();
    case 400:
      return ValidationError(message: message, userMessage: message);
    case 404:
      return GenericError(message: 'Resource not found', userMessage: 'The requested resource was not found');
    case >= 500:
      return NetworkError.serverError();
    default:
      return GenericError(message: message, userMessage: 'An error occurred: $message');
  }
}
