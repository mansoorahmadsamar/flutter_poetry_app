import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/language_provider.dart';

/// Helper utility for determining text direction based on language
///
/// This centralizes RTL/LTR logic for consistent text direction
/// throughout the app. Currently supports Urdu (RTL) and English (LTR).
///
/// Usage:
/// ```dart
/// // Direct usage with language code
/// final direction = TextDirectionHelper.getTextDirection('ur');
///
/// // Boolean check
/// if (TextDirectionHelper.isRTL('ur')) { ... }
///
/// // With WidgetRef in a ConsumerWidget
/// final direction = TextDirectionHelper.getTextDirectionFromProvider(ref);
/// ```
class TextDirectionHelper {
  TextDirectionHelper._(); // Private constructor to prevent instantiation

  /// Returns the text direction for a given language code
  ///
  /// Currently:
  /// - 'ur' (Urdu) -> TextDirection.rtl
  /// - All other languages -> TextDirection.ltr
  static TextDirection getTextDirection(String languageCode) {
    return languageCode == 'ur' ? TextDirection.rtl : TextDirection.ltr;
  }

  /// Returns true if the language uses RTL (Right-to-Left) text direction
  ///
  /// Currently only Urdu ('ur') is RTL
  static bool isRTL(String languageCode) {
    return languageCode == 'ur';
  }

  /// Convenience method to get text direction from the app's language provider
  ///
  /// Use this in ConsumerWidget builds to automatically get direction
  /// based on user's selected language preference
  static TextDirection getTextDirectionFromProvider(WidgetRef ref) {
    final languageCode = ref.watch(selectedLanguageProvider);
    return getTextDirection(languageCode);
  }
}
