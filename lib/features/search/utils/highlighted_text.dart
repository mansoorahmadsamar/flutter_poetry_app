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

    final ranges = highlightRanges(text, query);
    if (ranges.isEmpty) {
      return [TextSpan(text: text, style: style)];
    }

    final spans = <TextSpan>[];
    var cursor = 0;
    for (final range in ranges) {
      if (range.start > cursor) {
        spans.add(TextSpan(
          text: text.substring(cursor, range.start),
          style: style,
        ));
      }
      spans.add(TextSpan(text: range.textInside(text), style: highlightStyle));
      cursor = range.end;
    }
    if (cursor < text.length) {
      spans.add(TextSpan(text: text.substring(cursor), style: style));
    }
    return spans;
  }

  /// The ranges of [text] (UTF-16 offsets, end exclusive, sorted and
  /// non-overlapping) that match [query] after Urdu normalization and
  /// case folding.
  ///
  /// A range covers the matched characters plus any diacritics, tatweel or
  /// extra whitespace inside them, and diacritics/tatweel directly after the
  /// last matched letter, so a word is never split from its marks (that
  /// would break Nastaliq joining).
  static List<TextRange> highlightRanges(String text, String query) {
    final normalizedQuery = _foldCase(AppSearchUrduNormalizer.normalize(query));
    if (normalizedQuery.isEmpty || text.isEmpty) return const [];

    final normalized = AppSearchUrduNormalizer.normalizeWithOffsets(text);
    final haystack = _foldCase(normalized.text);
    final sourceToNormalized = normalized.sourceToNormalized;

    // normalized index → source index (every normalized char has one source).
    final normalizedToSource = List<int>.filled(haystack.length, -1);
    for (var i = 0; i < sourceToNormalized.length; i++) {
      final n = sourceToNormalized[i];
      if (n >= 0) normalizedToSource[n] = i;
    }

    final ranges = <TextRange>[];
    var searchFrom = 0;
    while (true) {
      final pos = haystack.indexOf(normalizedQuery, searchFrom);
      if (pos == -1) break;
      searchFrom = pos + 1; // overlapping matches merge below

      final start = normalizedToSource[pos];
      var end = normalizedToSource[pos + normalizedQuery.length - 1] + 1;
      while (end < text.length &&
          sourceToNormalized[end] < 0 &&
          AppSearchUrduNormalizer.isDroppedMark(text[end])) {
        end++;
      }

      if (ranges.isNotEmpty && start <= ranges.last.end) {
        final last = ranges.removeLast();
        ranges.add(TextRange(start: last.start, end: end > last.end ? end : last.end));
      } else {
        ranges.add(TextRange(start: start, end: end));
      }
    }
    return ranges;
  }

  /// Lower-cases [s] one code unit at a time so indices never shift (a few
  /// characters, e.g. 'İ', lower-case to two code units; those are kept).
  static String _foldCase(String s) {
    final buffer = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      final lower = s[i].toLowerCase();
      buffer.write(lower.length == 1 ? lower : s[i]);
    }
    return buffer.toString();
  }
}
