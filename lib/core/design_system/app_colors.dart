import 'package:flutter/material.dart';

/// Application color palette - Abstract base
/// Defines the interface for color palettes that can be swapped
abstract class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF2A004F); // Deep Violet (Deep Serenity) - Darker
  static const Color primaryLight = Color(0xFF38006B);
  static const Color primaryDark = Color(0xFF2A004F);

  // Secondary Colors
  static const Color secondary = Color(0xFFFFD700); // Pure Gold (Deep Serenity)
  static const Color secondaryLight = Color(0xFFFFE54C);
  static const Color secondaryDark = Color(0xFFF9A825);

  // Accent Colors
  static const Color accent = Color(0xFFFFD700); // Same as secondary
  static const Color accentLight = Color(0xFFFFE54C);
  static const Color accentDark = Color(0xFFF9A825);

  // Background Colors
  static const Color backgroundLight = Color(0xFFF5F5F5); // Off-White/Smoke (Deep Serenity)
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF212121); // Deep Slate (Deep Serenity)

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF212121); // Almost Black (Deep Serenity)
  static const Color textSecondaryLight = Color(0xFF757575); // Light Gray (Deep Serenity)
  static const Color textDisabledLight = Color(0xFFBDBDBD);

  static const Color textPrimaryDark = Color(0xFFFFFFFF); // White on Dark
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  static const Color textDisabledDark = Color(0xFF616161);

  // Semantic Colors
  static const Color success = Color(0xFF388E3C);
  static const Color error = Color(0xFFD32F2F);
  static const Color warning = Color(0xFFFFA726);
  static const Color info = Color(0xFF42A5F5);

  // Border & Divider
  static const Color borderLight = Color(0xFFE0E0E0);
  static const Color borderDark = Color(0xFF424242);
  static const Color dividerLight = Color(0xFFEEEEEE);
  static const Color dividerDark = Color(0xFF2C2C2C);

  // Overlay & Shadow
  static const Color overlay = Color(0x66000000);
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);

  // Special Colors for Poetry
  static const Color urduTextAccent = Color(0xFF4A148C); // Deep Violet for Urdu text
  static const Color verseBackground = Color(0xFFFFF8E7); // Subtle background for verse cards
  static const Color poetBadge = Color(0xFFFFD700); // Pure Gold for poet name badges
}

/// Deep Serenity Theme Colors
/// Primary: Deep Violet, Secondary: Pure Gold, Background: Off-White, Surface: Deep Slate
class DeepSerenityColors extends AppColors {
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
