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

/// Sukhan poet-mode typography helpers — pulls Fraunces (display serif),
/// JetBrains Mono (eyebrow caps), and Nastaleeq (urdu) on demand.
///
/// Use these in any new poet-mode screen. Existing screens keep using
/// AppTypography to avoid disrupting current layouts.
class SukhanText {
  SukhanText._();

  /// Small mono caps eyebrow (`STEP 1 OF 2`, `47 POEMS`, `LANGUAGE`).
  /// Default 9pt, gold, with wide tracking that mimics CSS `0.22em`.
  static TextStyle eyebrow({
    double size = 9,
    Color? color,
    FontWeight weight = FontWeight.w500,
  }) =>
      GoogleFonts.jetBrainsMono(
        fontSize: size,
        fontWeight: weight,
        letterSpacing: size * 0.22,
        color: color,
      );

  /// Display serif (Fraunces) — for screen titles, hero names, poem titles.
  static TextStyle display({
    double size = 22,
    Color? color,
    FontWeight weight = FontWeight.w500,
    double letterSpacing = -0.18,
    double height = 1.15,
  }) =>
      GoogleFonts.fraunces(
        fontSize: size,
        fontWeight: weight,
        letterSpacing: letterSpacing,
        height: height,
        color: color,
      );

  /// Italic Fraunces — used for soft sub-labels ("Saved 4 days ago",
  /// "or claim existing"). 12pt default, muted ink.
  static TextStyle italic({
    double size = 12,
    Color? color,
    FontWeight weight = FontWeight.w400,
    double height = 1.5,
  }) =>
      GoogleFonts.fraunces(
        fontSize: size,
        fontWeight: weight,
        fontStyle: FontStyle.italic,
        height: height,
        color: color,
      );

  /// Sans UI text (Inter/Roboto fallback). For body, buttons, labels.
  static TextStyle sans({
    double size = 13,
    Color? color,
    FontWeight weight = FontWeight.w500,
    double letterSpacing = 0,
    double height = 1.4,
  }) =>
      GoogleFonts.inter(
        fontSize: size,
        fontWeight: weight,
        letterSpacing: letterSpacing,
        height: height,
        color: color,
      );

  /// Nastaleeq Urdu — wraps the bundled Jameel Noori family.
  static TextStyle nastaleeq({
    double size = 16,
    Color? color,
    FontWeight weight = FontWeight.w400,
    double height = 1.7,
  }) =>
      TextStyle(
        fontFamily: AppTypography.urduFontFamily,
        fontSize: size,
        fontWeight: weight,
        height: height,
        color: color,
      );
}
