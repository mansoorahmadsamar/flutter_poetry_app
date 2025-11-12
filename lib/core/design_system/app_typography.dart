import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography system for the app
/// Supports both English and Urdu text with proper fonts and styling
class AppTypography {
  AppTypography._();

  // Font Families
  static const String englishFontFamily = 'Roboto';
  static const String urduFontFamily = 'NotoNaskhArabic'; // Good for Urdu

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
  /// Uses Noto Nasakh Arabic which supports Urdu ligatures properly
  static TextTheme getUrduTextTheme(BuildContext context) {
    return GoogleFonts.notoNaskhArabicTextTheme(Theme.of(context).textTheme).copyWith(
      // For Urdu, we need better line height for proper ligature rendering
      displayLarge: GoogleFonts.notoNaskhArabic(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        height: 1.8, // Increased height for Urdu
      ),
      displayMedium: GoogleFonts.notoNaskhArabic(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        height: 1.8,
      ),
      displaySmall: GoogleFonts.notoNaskhArabic(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        height: 1.8,
      ),

      headlineLarge: GoogleFonts.notoNaskhArabic(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        height: 1.8,
      ),
      headlineMedium: GoogleFonts.notoNaskhArabic(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        height: 1.8,
      ),
      headlineSmall: GoogleFonts.notoNaskhArabic(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.8,
      ),

      titleLarge: GoogleFonts.notoNaskhArabic(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        height: 1.8,
      ),
      titleMedium: GoogleFonts.notoNaskhArabic(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.8,
      ),
      titleSmall: GoogleFonts.notoNaskhArabic(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.8,
      ),

      bodyLarge: GoogleFonts.notoNaskhArabic(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 2.0, // Poetry needs even more height
      ),
      bodyMedium: GoogleFonts.notoNaskhArabic(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 2.0,
      ),
      bodySmall: GoogleFonts.notoNaskhArabic(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.8,
      ),

      labelLarge: GoogleFonts.notoNaskhArabic(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.6,
      ),
      labelMedium: GoogleFonts.notoNaskhArabic(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.6,
      ),
      labelSmall: GoogleFonts.notoNaskhArabic(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 1.6,
      ),
    );
  }

  /// Special style for Urdu poetry verses
  static TextStyle urduVerseStyle = GoogleFonts.notoNaskhArabic(
    fontSize: 20,
    fontWeight: FontWeight.w400,
    height: 2.2,
    letterSpacing: 0.5,
  );

  /// Special style for poet names in Urdu
  static TextStyle urduPoetNameStyle = GoogleFonts.notoNaskhArabic(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.8,
  );
}
