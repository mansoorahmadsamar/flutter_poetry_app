import 'package:flutter/foundation.dart';
import '../utils/platform_utils.dart';

/// Application environment configuration
enum AppEnvironment {
  dev,
  stage,
  prod,
}

/// Central configuration for the entire application
/// Manages environment-specific settings and feature flags
class AppConfig {
  final AppEnvironment environment;
  final String appName;
  final String baseApiUrl;
  final int apiTimeout;
  final int feedTTL;
  final int poemTTL;
  final bool enableLogging;
  final bool enableAnalytics;
  final String googleOAuthRedirectUri;
  final String? googleWebClientId; // Web Client ID for native Google Sign-In

  const AppConfig._({
    required this.environment,
    required this.appName,
    required this.baseApiUrl,
    required this.apiTimeout,
    required this.feedTTL,
    required this.poemTTL,
    required this.enableLogging,
    required this.enableAnalytics,
    required this.googleOAuthRedirectUri,
    this.googleWebClientId,
  });

  /// Development environment configuration
  factory AppConfig.dev() {
    // Get platform-specific localhost URL
    final baseUrl = PlatformUtils.getLocalhostUrl(8080);

    return AppConfig._(
      environment: AppEnvironment.dev,
      appName: 'Poetry DEV',
      baseApiUrl: baseUrl,
      apiTimeout: 30000, // 30 seconds
      feedTTL: 300, // 5 minutes
      poemTTL: 1800, // 30 minutes
      enableLogging: true,
      enableAnalytics: false,
      googleOAuthRedirectUri: 'http://localhost:3000/auth/callback',
      // Web Client ID from Google Cloud Console (used for native Google Sign-In)
      googleWebClientId: '461228119902-8s3jjf9m60ql21odr0sfsc583cqrnds0.apps.googleusercontent.com',
    );
  }

  /// Staging environment configuration
  factory AppConfig.stage() {
    return const AppConfig._(
      environment: AppEnvironment.stage,
      appName: 'Poetry STAGE',
      baseApiUrl: 'https://stage-api.poetry.app',
      apiTimeout: 30000,
      feedTTL: 600, // 10 minutes
      poemTTL: 3600, // 1 hour
      enableLogging: true,
      enableAnalytics: true,
      googleOAuthRedirectUri: 'https://stage.poetry.app/auth/callback',
      googleWebClientId: null, // TODO: Add staging Web Client ID
    );
  }

  /// Production environment configuration
  factory AppConfig.prod() {
    return const AppConfig._(
      environment: AppEnvironment.prod,
      appName: 'Poetry',
      baseApiUrl: 'https://api.poetry.app',
      apiTimeout: 30000,
      feedTTL: 900, // 15 minutes
      poemTTL: 7200, // 2 hours
      enableLogging: false,
      enableAnalytics: true,
      googleOAuthRedirectUri: 'https://poetry.app/auth/callback',
      googleWebClientId: null, // TODO: Add production Web Client ID
    );
  }

  bool get isDevelopment => environment == AppEnvironment.dev;
  bool get isStaging => environment == AppEnvironment.stage;
  bool get isProduction => environment == AppEnvironment.prod;

  @override
  String toString() {
    return 'AppConfig(env: ${environment.name}, baseUrl: $baseApiUrl)';
  }
}

/// Global app configuration instance
/// Initialize this at app startup
late AppConfig appConfig;

/// Initialize app configuration based on build flavor
void initializeAppConfig() {
  // In a real app, this would be determined by build flavor
  // For now, default to dev
  if (kDebugMode) {
    appConfig = AppConfig.dev();
  } else if (kReleaseMode) {
    appConfig = AppConfig.prod();
  } else {
    appConfig = AppConfig.stage();
  }
}
