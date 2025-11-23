import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography system for the app
/// Supports both English and Urdu text with proper fonts and styling
class AppTypography {
  AppTypography._();

  // Font Families
  static const String englishFontFamily = 'Roboto';
  static const String urduFontFamily = 'Jameel Noori Nastaleeq'; // Traditional Nastaleeq for Urdu

  /// Get text theme for English content
  static TextTheme getEnglishTextTheme(BuildContext context) {
    return GoogleFonts.robotoTextTheme(Theme.of(context).textTheme).copyWith(
      // Display
      displayLarge: GoogleFonts.roboto(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        height: 1.12,
      ),
      displayMedium: GoogleFonts.roboto(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.15,
      ),
      displaySmall: GoogleFonts.roboto(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.22,
      ),

      // Headline
      headlineLarge: GoogleFonts.roboto(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.25,
      ),
      headlineMedium: GoogleFonts.roboto(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.28,
      ),
      headlineSmall: GoogleFonts.roboto(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.33,
      ),

      // Title
      titleLarge: GoogleFonts.roboto(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        height: 1.27,
      ),
      titleMedium: GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
        height: 1.5,
      ),
      titleSmall: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.42,
      ),

      // Body
      bodyLarge: GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 1.42,
      ),
      bodySmall: GoogleFonts.roboto(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 1.33,
      ),

      // Label
      labelLarge: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.42,
      ),
      labelMedium: GoogleFonts.roboto(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.33,
      ),
      labelSmall: GoogleFonts.roboto(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.45,
      ),
    );
  }

  /// Get text theme for Urdu content
  /// Uses Jameel Noori Nastaleeq which is the traditional Nastaleeq style for Urdu
  static TextTheme getUrduTextTheme(BuildContext context) {
    final baseTheme = Theme.of(context).textTheme;
    return baseTheme.copyWith(
      // For Urdu, we need better line height for proper ligature rendering
      displayLarge: const TextStyle(
        fontFamily: urduFontFamily,
        fontSize: 57,
        fontWeight: FontWeight.w400,
        height: 1.8, // Increased height for Urdu
      ),
      displayMedium: const TextStyle(
        fontFamily: urduFontFamily,
        fontSize: 45,
        fontWeight: FontWeight.w400,
        height: 1.8,
      ),
      displaySmall: const TextStyle(
        fontFamily: urduFontFamily,
        fontSize: 36,
        fontWeight: FontWeight.w400,
        height: 1.8,
      ),

      headlineLarge: const TextStyle(
        fontFamily: urduFontFamily,
        fontSize: 32,
        fontWeight: FontWeight.w600,
        height: 1.8,
      ),
      headlineMedium: const TextStyle(
        fontFamily: urduFontFamily,
        fontSize: 28,
        fontWeight: FontWeight.w600,
        height: 1.8,
      ),
      headlineSmall: const TextStyle(
        fontFamily: urduFontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.8,
      ),

      titleLarge: const TextStyle(
        fontFamily: urduFontFamily,
        fontSize: 22,
        fontWeight: FontWeight.w500,
        height: 1.8,
      ),
      titleMedium: const TextStyle(
        fontFamily: urduFontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.8,
      ),
      titleSmall: const TextStyle(
        fontFamily: urduFontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.8,
      ),

      bodyLarge: const TextStyle(
        fontFamily: urduFontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 2.0, // Poetry needs even more height
      ),
      bodyMedium: const TextStyle(
        fontFamily: urduFontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 2.0,
      ),
      bodySmall: const TextStyle(
        fontFamily: urduFontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.8,
      ),

      labelLarge: const TextStyle(
        fontFamily: urduFontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.6,
      ),
      labelMedium: const TextStyle(
        fontFamily: urduFontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.6,
      ),
      labelSmall: const TextStyle(
        fontFamily: urduFontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 1.6,
      ),
    );
  }

  /// Special style for Urdu poetry verses
  static const TextStyle urduVerseStyle = TextStyle(
    fontFamily: urduFontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w400,
    height: 2.2,
    letterSpacing: 0.5,
  );

  /// Special style for poet names in Urdu
  static const TextStyle urduPoetNameStyle = TextStyle(
    fontFamily: urduFontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.8,
  );
}
