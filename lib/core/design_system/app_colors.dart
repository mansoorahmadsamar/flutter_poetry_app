import 'package:flutter/material.dart';

/// Application color palette - Abstract base
/// Defines the interface for color palettes that can be swapped
abstract class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF1B4D3E); // Deep Poetic Green (Poetic Green Theme)
  static const Color primaryLight = Color(0xFF2A6F5C); // Lighter green for hover states
  static const Color primaryDark = Color(0xFF14392E); // Darker green for pressed states

  // Secondary Colors
  static const Color secondary = Color(0xFFC5A059); // Accent Gold (Poetic Green Theme)
  static const Color secondaryLight = Color(0xFFD4B374); // Lighter gold for subtle accents
  static const Color secondaryDark = Color(0xFFB08F42); // Darker gold for emphasis

  // Accent Colors
  static const Color accent = Color(0xFFC5A059); // Same as secondary
  static const Color accentLight = Color(0xFFD4B374);
  static const Color accentDark = Color(0xFFB08F42);

  // Background Colors
  static const Color backgroundLight = Color(0xFFF5F5DC); // Soft Cream - paper-like background (Poetic Green)
  static const Color backgroundDark = Color(0xFF1A1A1A); // Warm black for dark mode
  static const Color surfaceLight = Color(0xFFFFFFFF); // Pure white for elevated cards
  static const Color surfaceDark = Color(0xFF2C2C2C); // Text Charcoal for dark mode surfaces

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF2C2C2C); // Text Charcoal - high-readability (Poetic Green)
  static const Color textSecondaryLight = Color(0xFF5C5C5C); // Medium gray for secondary text
  static const Color textDisabledLight = Color(0xFFA8A8A8); // Light gray for disabled state

  static const Color textPrimaryDark = Color(0xFFF5F5DC); // Soft Cream for dark mode primary text
  static const Color textSecondaryDark = Color(0xFFC5C5B4); // Muted cream for secondary text
  static const Color textDisabledDark = Color(0xFF7C7C74); // Darker cream for disabled state

  // Semantic Colors
  static const Color success = Color(0xFF2D7A5A); // Harmonious green - complements primary
  static const Color error = Color(0xFFC84B31); // Warm terracotta - earth-tone red
  static const Color warning = Color(0xFFD4A259); // Warm amber-gold - ties to accent
  static const Color info = Color(0xFF4A7C8E); // Muted teal-blue - cool complement

  // Border & Divider
  static const Color borderLight = Color(0xFFD8D8C8); // Cream-tinted gray - harmonizes with soft cream bg
  static const Color borderDark = Color(0xFF3F3F3F); // Warm dark gray
  static const Color dividerLight = Color(0xFFE8E8DC); // Very light cream-gray - subtle separation
  static const Color dividerDark = Color(0xFF333333); // Slightly darker for subtle division

  // Overlay & Shadow
  static const Color overlay = Color(0x661B4D3E); // Primary green at 40% opacity - branded overlays
  static const Color shimmerBase = Color(0xFFE8E8DC); // Cream-tinted for light mode
  static const Color shimmerHighlight = Color(0xFFF5F5DC); // Soft cream highlight

  // Special Colors for Poetry
  static const Color urduTextAccent = Color(0xFF2A6F5C); // Lighter green for Urdu text emphasis
  static const Color verseBackground = Color(0xFFFAFAED); // Very pale cream with green undertone - paper-like feel
  static const Color poetBadge = Color(0xFFC5A059); // Accent Gold for poet name badges
}

/// Poetic Green Theme Colors
/// Primary: Deep Poetic Green, Secondary: Accent Gold, Background: Soft Cream, Text: Charcoal
class PoeticGreenColors extends AppColors {
  // All values inherited from AppColors
  // This class allows for easy theme management
}

/// Placeholder for alternative theme (Passion & Earth)
/// Can be implemented when needed
class PassionEarthColors extends AppColors {
  // To be implemented with:
  // Primary: Deep Red/Burgundy
  // Secondary: Warm Earth Brown
  // Background: Cream/Beige
}

/// Placeholder for alternative theme (Turquoise & Silver)
/// Can be implemented when needed
class TurquoiseSilverColors extends AppColors {
  // To be implemented with:
  // Primary: Turquoise
  // Secondary: Silver
  // Background: Light Gray
}
