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

  /// Development environment configuration.
  ///
  /// TEMPORARY: pointed at the Mac's LAN IP (192.168.10.2:8081) so a real
  /// iPhone on the same Wi-Fi can hit the local backend. Restore the
  /// `PlatformUtils.getLocalhostUrl(8081)` line below for normal local dev
  /// on the iOS simulator (localhost) or Android emulator (10.0.2.2).
  factory AppConfig.dev() {
    const baseUrl = 'http://192.168.10.2:8081';
    // final localBackend = PlatformUtils.getLocalhostUrl(8081);
    return AppConfig._(
      environment: AppEnvironment.dev,
      appName: 'Poetry DEV',
      baseApiUrl: baseUrl,
      apiTimeout: 30000, // 30 seconds
      feedTTL: 300, // 5 minutes
      poemTTL: 1800, // 30 minutes
      enableLogging: true,
      enableAnalytics: false,
      googleOAuthRedirectUri: '$baseUrl/auth/callback',
      // Web Client ID from Google Cloud Console (used for native Google Sign-In)
      googleWebClientId: '461228119902-ofi032jvtvsqrenp0349rs06rahfpkru.apps.googleusercontent.com',
    );
  }

  /// Staging environment configuration
  factory AppConfig.stage() {
    // TEMPORARY: pointed at the Mac's LAN IP so a Profile build on the real
    // iPhone can hit the local backend without needing the Flutter run process
    // attached. Restore the stage URLs (or wire build-flavor selection) before
    // releasing a staging build to TestFlight.
    const baseUrl = 'http://192.168.10.2:8081';
    return const AppConfig._(
      environment: AppEnvironment.stage,
      appName: 'Poetry STAGE',
      baseApiUrl: baseUrl,
      apiTimeout: 30000,
      feedTTL: 600, // 10 minutes
      poemTTL: 3600, // 1 hour
      enableLogging: true,
      enableAnalytics: true,
      googleOAuthRedirectUri: '$baseUrl/auth/callback',
      // Reusing the prod/dev Web Client ID for native Google Sign-In on this
      // local-test profile build. Replace with a real staging client when
      // staging is wired up properly.
      googleWebClientId:
          '461228119902-ofi032jvtvsqrenp0349rs06rahfpkru.apps.googleusercontent.com',
    );
  }

  /// Production environment configuration
  factory AppConfig.prod() {
    return const AppConfig._(
      environment: AppEnvironment.prod,
      appName: 'Poetry',
      baseApiUrl: 'https://134.199.243.167',
      apiTimeout: 30000,
      feedTTL: 900, // 15 minutes
      poemTTL: 7200, // 2 hours
      enableLogging: false,
      enableAnalytics: true,
      googleOAuthRedirectUri: 'https://134.199.243.167/auth/callback',
      googleWebClientId: '461228119902-ofi032jvtvsqrenp0349rs06rahfpkru.apps.googleusercontent.com',
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
