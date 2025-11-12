import 'package:flutter/material.dart';

/// Application color palette
/// Defines all colors used throughout the app
class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF2E5077);
  static const Color primaryLight = Color(0xFF4A7BA7);
  static const Color primaryDark = Color(0xFF1E3A5F);

  // Secondary Colors
  static const Color secondary = Color(0xFFD4A574);
  static const Color secondaryLight = Color(0xFFE5C8A8);
  static const Color secondaryDark = Color(0xFFA67C52);

  // Accent Colors
  static const Color accent = Color(0xFFE8AA42);
  static const Color accentLight = Color(0xFFF5C563);
  static const Color accentDark = Color(0xFFCF9436);

  // Background Colors
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textDisabledLight = Color(0xFFBDBDBD);

  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  static const Color textDisabledDark = Color(0xFF616161);

  // Semantic Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
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
  static const Color urduTextAccent = Color(0xFF8B4513); // For highlighted Urdu text
  static const Color verseBackground = Color(0xFFFFF8E7); // Subtle background for verse cards
  static const Color poetBadge = Color(0xFFB8860B); // For poet name badges
}
