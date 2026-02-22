import 'package:flutter/material.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/features/search/utils/app_search_urdu_normalizer.dart';

/// Renders text with the search query highlighted in a distinct color.
///
/// Uses Urdu normalization for matching — so "محبّت" (with shadda) will
/// match "محبت" in the text. Matching is case-insensitive for Latin text.
///
/// Highlighted spans get a semi-transparent gold background and bold weight.
/// Non-matching spans keep the provided [style] unchanged.
class HighlightedText extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle style;
  final TextDirection? textDirection;
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const HighlightedText({
    super.key,
    required this.text,
    required this.query,
    required this.style,
    this.textDirection,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    // If no query or empty, just render plain text
    if (query.trim().isEmpty) {
      return Text(
        text,
        style: style,
        textDirection: textDirection,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      );
    }

    final spans = _buildSpans(context);

    return RichText(
      text: TextSpan(children: spans),
      textDirection: textDirection,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
    );
  }

  List<TextSpan> _buildSpans(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final highlightBg = isDark
        ? AppColors.secondary.withValues(alpha: 0.25)
        : AppColors.secondary.withValues(alpha: 0.2);
    final highlightStyle = style.copyWith(
      fontWeight: FontWeight.w700,
      backgroundColor: highlightBg,
    );

    // Normalize both text and query for matching
    final normalizedText = AppSearchUrduNormalizer.normalize(text);
    final normalizedQuery = AppSearchUrduNormalizer.normalize(query.trim());

    if (normalizedQuery.isEmpty) {
      return [TextSpan(text: text, style: style)];
    }

    // Find all match positions in the normalized text
    final lowerText = normalizedText.toLowerCase();
    final lowerQuery = normalizedQuery.toLowerCase();

    // Build a character-level mapping: original index → normalized index
    // Since normalization can remove characters, we need to map positions back.
    final matchRanges = <_Range>[];
    int searchFrom = 0;
    while (true) {
      final pos = lowerText.indexOf(lowerQuery, searchFrom);
      if (pos == -1) break;
      matchRanges.add(_Range(pos, pos + lowerQuery.length));
      searchFrom = pos + 1; // Allow overlapping for short queries
    }

    if (matchRanges.isEmpty) {
      return [TextSpan(text: text, style: style)];
    }

    // Map normalized positions back to original text positions.
    // Build a mapping array: for each char in original, what's the index in normalized.
    final origToNorm = _buildOrigToNormMap(text, normalizedText);

    // For each char in the original text, check if its normalized index
    // falls within any match range.
    final highlighted = List.filled(text.length, false);
    for (int i = 0; i < text.length; i++) {
      final normIdx = origToNorm[i];
      if (normIdx < 0) continue; // Char was removed by normalization
      for (final range in matchRanges) {
        if (normIdx >= range.start && normIdx < range.end) {
          highlighted[i] = true;
          break;
        }
      }
    }

    // Build spans from the highlighted flags
    final spans = <TextSpan>[];
    int i = 0;
    while (i < text.length) {
      final isMatch = highlighted[i];
      int j = i + 1;
      while (j < text.length && highlighted[j] == isMatch) {
        j++;
      }
      spans.add(TextSpan(
        text: text.substring(i, j),
        style: isMatch ? highlightStyle : style,
      ));
      i = j;
    }

    return spans;
  }

  /// Build a mapping from original text char index → normalized text char index.
  /// Characters removed by normalization get -1.
  List<int> _buildOrigToNormMap(String original, String normalized) {
    // Re-normalize character by character to build the mapping.
    // This is an approximation: we normalize the full original string
    // and then align the two strings using a simple pointer walk.
    final map = List.filled(original.length, -1);
    int normIdx = 0;

    for (int origIdx = 0; origIdx < original.length; origIdx++) {
      if (normIdx >= normalized.length) break;

      final origChar = original[origIdx];
      final normOfChar = AppSearchUrduNormalizer.normalize(origChar);

      if (normOfChar.isEmpty) {
        // This char was removed (diacritic/tatweel)
        map[origIdx] = -1;
        continue;
      }

      // Check if the normalized version of this char matches what's at normIdx
      if (normIdx < normalized.length &&
          normOfChar.length == 1 &&
          normOfChar[0].toLowerCase() == normalized[normIdx].toLowerCase()) {
        map[origIdx] = normIdx;
        normIdx++;
      } else if (normOfChar.length == 1) {
        // Variant mapping changed the char — still maps to normIdx
        map[origIdx] = normIdx;
        normIdx++;
      } else {
        // Edge case: normalization expanded? Shouldn't happen but be safe
        map[origIdx] = normIdx;
        normIdx++;
      }
    }

    return map;
  }
}

class _Range {
  final int start;
  final int end;
  const _Range(this.start, this.end);
}
