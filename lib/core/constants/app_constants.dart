/// Application-wide constants
class AppConstants {
  AppConstants._();

  // API Constants
  static const String authorizationHeader = 'Authorization';
  static const String bearerPrefix = 'Bearer';
  static const String contentTypeHeader = 'Content-Type';
  static const String contentTypeJson = 'application/json';

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String userEmailKey = 'user_email';
  static const String onboardingCompletedKey = 'onboarding_completed';
  static const String languagePreferenceKey = 'language_preference';
  static const String themePreferenceKey = 'theme_preference';

  // Pagination
  static const int defaultPageSize = 10;
  static const int defaultPage = 0;

  // Cache Keys
  static const String feedCacheKey = 'feed_cache';
  static const String categoriesCacheKey = 'categories_cache';
  static const String poetsCacheKey = 'poets_cache';

  // Deep Link Schemes
  static const String deepLinkScheme = 'poetry';
  static const String deepLinkHost = 'app';

  // Timeouts (milliseconds)
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;
  static const int sendTimeout = 30000;

  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // Retry Configuration
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);
}
