import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Enum representing available color themes
enum AppThemeType {
  poeticGreen,
  // passionEarth, // To be implemented
  // turquoiseSilver, // To be implemented
}

/// Extension to get theme display name
extension AppThemeTypeExtension on AppThemeType {
  String get displayName {
    switch (this) {
      case AppThemeType.poeticGreen:
        return 'Poetic Green';
      // case AppThemeType.passionEarth:
      //   return 'Passion & Earth';
      // case AppThemeType.turquoiseSilver:
      //   return 'Turquoise & Silver';
    }
  }

  String get description {
    switch (this) {
      case AppThemeType.poeticGreen:
        return 'Deep Green & Accent Gold theme';
      // case AppThemeType.passionEarth:
      //   return 'Deep Red & Earth Brown theme';
      // case AppThemeType.turquoiseSilver:
      //   return 'Turquoise & Silver theme';
    }
  }
}

/// Riverpod provider for current theme selection
/// This allows the app to change themes dynamically throughout the app
final themeProvider = StateProvider<AppThemeType>((ref) {
  return AppThemeType.poeticGreen; // Default theme
});

/// Riverpod provider for theme change
final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, AppThemeType>(
  (ref) => ThemeNotifier(),
);

/// StateNotifier for managing theme changes
class ThemeNotifier extends StateNotifier<AppThemeType> {
  ThemeNotifier() : super(AppThemeType.poeticGreen);

  /// Change the current theme
  void setTheme(AppThemeType theme) {
    state = theme;
  }

  /// Get all available themes
  List<AppThemeType> getAvailableThemes() {
    return AppThemeType.values;
  }

  /// Reset to default theme
  void resetToDefault() {
    state = AppThemeType.poeticGreen;
  }
}
