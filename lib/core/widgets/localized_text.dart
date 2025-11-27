import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../design_system/app_typography.dart';
import '../providers/language_provider.dart';
import '../utils/text_direction_helper.dart';

/// Smart Text widget that automatically applies correct font and text direction
/// based on the user's language preference.
///
/// This widget is a drop-in replacement for Flutter's Text widget with the
/// added benefit of automatically:
/// - Applying Jameel Noori Nastaleeq font for Urdu text
/// - Setting correct text direction (RTL for Urdu, LTR for others)
/// - Using appropriate base styles from AppTypography
///
/// Usage:
/// ```dart
/// LocalizedText(
///   'Sample text',
///   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
///   maxLines: 2,
///   overflow: TextOverflow.ellipsis,
/// )
/// ```
///
/// The `style` parameter will be merged with the base style, so you can
/// override specific properties like fontSize, fontWeight, color, etc.
class LocalizedText extends ConsumerWidget {
  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;
  final bool? softWrap;
  final TextScaler? textScaler;
  final String? semanticsLabel;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;

  const LocalizedText(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.softWrap,
    this.textScaler,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageCode = ref.watch(selectedLanguageProvider);
    final isUrdu = languageCode == 'ur';

    // Get base style from typography system
    // For Urdu, use the specially configured style with proper line height
    // For English and other languages, use the theme's default body style
    final baseStyle = isUrdu
        ? AppTypography.urduVerseStyle
        : Theme.of(context).textTheme.bodyMedium;

    // Merge base style with user-provided style
    // User style properties will override base style properties
    final mergedStyle = baseStyle?.merge(style);

    // Auto-center Urdu text if textAlign is not explicitly provided
    // Urdu poetry traditionally looks better centered
    final effectiveTextAlign = textAlign ?? (isUrdu ? TextAlign.center : TextAlign.start);

    return Text(
      text,
      style: mergedStyle,
      textDirection: TextDirectionHelper.getTextDirection(languageCode),
      maxLines: maxLines,
      overflow: overflow,
      textAlign: effectiveTextAlign,
      softWrap: softWrap,
      textScaler: textScaler,
      semanticsLabel: semanticsLabel,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
    );
  }
}
