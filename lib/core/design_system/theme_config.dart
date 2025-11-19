import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'theme_provider.dart';

/// Centralized theme configuration
/// This file makes it easy to swap between different color themes
/// and maintain consistency across the app
class ThemeConfig {
  /// Get colors based on the current theme type
  static AppColors getColors(AppThemeType themeType) {
    switch (themeType) {
      case AppThemeType.deepSerenity:
        return DeepSerenityColors();
      // case AppThemeType.passionEarth:
      //   return PassionEarthColors();
      // case AppThemeType.turquoiseSilver:
      //   return TurquoiseSilverColors();
    }
  }

  /// Get theme description for settings/preferences
  static String getThemeDescription(AppThemeType themeType) {
    return '''
${themeType.displayName}

${themeType.description}

${_getThemeDetails(themeType)}
    '''.trim();
  }

  /// Get detailed color information for a theme
  static String _getThemeDetails(AppThemeType themeType) {
    switch (themeType) {
      case AppThemeType.deepSerenity:
        return '''
Primary Color: Deep Violet (#4A148C)
Secondary Color: Pure Gold (#FFD700)
Background: Off-White (#F5F5F5)
Surface: Deep Slate (#212121)

Perfect for: Poetry apps, elegant & serene interfaces
        ''';
      // Add other themes here
    }
  }

  /// Validate theme type can be used
  static bool isThemeAvailable(AppThemeType themeType) {
    return AppThemeType.values.contains(themeType);
  }

  /// Get all available themes with metadata
  static List<ThemeMetadata> getAvailableThemes() {
    return [
      ThemeMetadata(
        type: AppThemeType.deepSerenity,
        name: 'Deep Serenity',
        description: 'Deep Violet & Pure Gold - Elegant and serene',
        primaryColor: AppColors.primary,
        secondaryColor: AppColors.secondary,
        isAvailable: true,
      ),
      // ThemeMetadata(
      //   type: AppThemeType.passionEarth,
      //   name: 'Passion & Earth',
      //   description: 'Deep Red & Earth Brown - Warm and inviting',
      //   primaryColor: Color(0xFF8B0000),
      //   secondaryColor: Color(0xFF8B4513),
      //   isAvailable: false, // To be implemented
      // ),
      // ThemeMetadata(
      //   type: AppThemeType.turquoiseSilver,
      //   name: 'Turquoise & Silver',
      //   description: 'Turquoise & Silver - Modern and fresh',
      //   primaryColor: Color(0xFF00BCD4),
      //   secondaryColor: Color(0xFFC0C0C0),
      //   isAvailable: false, // To be implemented
      // ),
    ];
  }
}

/// Metadata for a theme
class ThemeMetadata {
  final AppThemeType type;
  final String name;
  final String description;
  final Color primaryColor;
  final Color secondaryColor;
  final bool isAvailable;

  ThemeMetadata({
    required this.type,
    required this.name,
    required this.description,
    required this.primaryColor,
    required this.secondaryColor,
    required this.isAvailable,
  });
}
