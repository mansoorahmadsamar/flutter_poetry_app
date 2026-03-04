import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Language-aware typography utilities for proper visual weight balance
class LanguageTypography {
  /// Font size multipliers for visual weight balance
  static const double urduMultiplier = 1.18;
  static const double englishMultiplier = 1.00;
  static const double hindiMultiplier = 1.06;
  static const double arabicMultiplier = 1.18;
  static const double persianMultiplier = 1.18;

  /// Line height multipliers
  static const double urduLineHeight = 1.75;
  static const double englishLineHeight = 1.4;
  static const double hindiLineHeight = 1.5;
  static const double arabicLineHeight = 1.75;
  static const double persianLineHeight = 1.75;

  /// Get font size multiplier for language
  static double getSizeMultiplier(String languageCode) {
    switch (languageCode.toLowerCase()) {
      case 'ur':
        return urduMultiplier;
      case 'en':
        return englishMultiplier;
      case 'hi':
        return hindiMultiplier;
      case 'ar':
        return arabicMultiplier;
      case 'fa':
      case 'ps':
        return persianMultiplier;
      default:
        return englishMultiplier;
    }
  }

  /// Get line height for language
  static double getLineHeight(String languageCode) {
    switch (languageCode.toLowerCase()) {
      case 'ur':
        return urduLineHeight;
      case 'en':
        return englishLineHeight;
      case 'hi':
        return hindiLineHeight;
      case 'ar':
        return arabicLineHeight;
      case 'fa':
      case 'ps':
        return persianLineHeight;
      default:
        return englishLineHeight;
    }
  }

  /// Get text direction for language
  static TextDirection getTextDirection(String languageCode) {
    switch (languageCode.toLowerCase()) {
      case 'ur':
      case 'ar':
      case 'fa':
      case 'ps':
        return TextDirection.rtl;
      default:
        return TextDirection.ltr;
    }
  }

  /// Check if language uses RTL
  static bool isRTL(String languageCode) {
    return getTextDirection(languageCode) == TextDirection.rtl;
  }

  /// Create language-aware text style
  static TextStyle createStyle({
    required double baseFontSize,
    required String languageCode,
    FontWeight? fontWeight,
    Color? color,
    double? customLineHeight,
    double? letterSpacing,
  }) {
    final multiplier = getSizeMultiplier(languageCode);
    final lineHeight = customLineHeight ?? getLineHeight(languageCode);
    final adjustedSize = baseFontSize * multiplier;

    // Use Jameel Noori Nastaleeq for Urdu/Arabic/Persian
    if (languageCode.toLowerCase() == 'ur' ||
        languageCode.toLowerCase() == 'ar' ||
        languageCode.toLowerCase() == 'fa') {
      return TextStyle(
        fontFamily: 'JameelNooriNastaleeq',
        fontSize: adjustedSize,
        height: lineHeight,
        fontWeight: fontWeight ?? FontWeight.w400,
        color: color,
        letterSpacing: letterSpacing,
      );
    }

    // Use Google Fonts for others
    return GoogleFonts.roboto(
      fontSize: adjustedSize,
      height: lineHeight,
      fontWeight: fontWeight ?? FontWeight.w400,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  /// Create verse text style (for poetry content)
  static TextStyle verseStyle({
    required String languageCode,
    required bool isDark,
    double baseFontSize = 18.0,
  }) {
    return createStyle(
      baseFontSize: baseFontSize,
      languageCode: languageCode,
      fontWeight: FontWeight.w400,
      color: isDark ? Colors.white : const Color(0xFF2C2C2C),
    );
  }

  /// Create title text style
  static TextStyle titleStyle({
    required String languageCode,
    required bool isDark,
    double baseFontSize = 16.0,
  }) {
    return createStyle(
      baseFontSize: baseFontSize,
      languageCode: languageCode,
      fontWeight: FontWeight.w600,
      color: isDark ? Colors.white : const Color(0xFF2C2C2C),
    );
  }

  /// Create metadata/caption style (always consistent, no language scaling)
  static TextStyle metadataStyle({
    required bool isDark,
    double fontSize = 12.0,
  }) {
    return GoogleFonts.roboto(
      fontSize: fontSize,
      height: 1.4,
      fontWeight: FontWeight.w400,
      color: isDark
          ? Colors.white.withValues(alpha: 0.7)
          : Colors.black.withValues(alpha: 0.6),
    );
  }

  /// Create label style (for chips, buttons)
  static TextStyle labelStyle({
    required bool isDark,
    double fontSize = 13.0,
    FontWeight? fontWeight,
  }) {
    return GoogleFonts.roboto(
      fontSize: fontSize,
      height: 1.3,
      fontWeight: fontWeight ?? FontWeight.w500,
      color: isDark ? Colors.white : const Color(0xFF2C2C2C),
    );
  }
}
