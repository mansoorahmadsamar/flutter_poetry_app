/// Urdu text normalizer for search queries.
///
/// Handles:
/// - Diacritics (tashkeel) removal
/// - Arabic → Urdu letter variant normalization
/// - Tatweel (kashida) removal
/// - Whitespace normalization
///
/// Apply before every search API call to ensure consistent matching
/// regardless of keyboard input or copy-pasted text with diacritics.
class AppSearchUrduNormalizer {
  AppSearchUrduNormalizer._();

  /// Diacritics (tashkeel) range: U+064B–U+0652, U+0670, U+06D6–U+06DC
  static final _diacriticsPattern = RegExp(
    r'[\u064B-\u0652\u0670\u06D6-\u06DC]',
  );

  /// Tatweel / kashida character
  static const _tatweel = '\u0640';

  /// Arabic → Urdu letter mappings
  static const _variantMap = <String, String>{
    'ي': 'ی', // Arabic Ya → Urdu Ya
    'ك': 'ک', // Arabic Kaf → Urdu Kaf
    'ۃ': 'ہ', // Ta Marbuta (Urdu form) → Gol He
    'ة': 'ہ', // Ta Marbuta (Arabic form) → Gol He
    'ؤ': 'و', // Waw with Hamza → plain Waw
    'إ': 'ا', // Alef with Hamza Below → plain Alef
    'أ': 'ا', // Alef with Hamza Above → plain Alef
    'آ': 'ا', // Alef Madda → plain Alef
  };

  /// Any single whitespace code unit (the `\s` regex class).
  static final _whitespace = RegExp(r'\s');

  /// Whether [codeUnit] (a one-code-unit string) is a mark that
  /// normalisation drops: a diacritic (tashkeel) or tatweel.
  static bool isDroppedMark(String codeUnit) =>
      codeUnit == _tatweel || _diacriticsPattern.hasMatch(codeUnit);

  /// Normalize an Urdu/Arabic query for search.
  ///
  /// Removes diacritics and tatweel, maps Arabic letter variants to Urdu,
  /// collapses whitespace runs to one space and trims.
  /// Safe to call on English text — it passes through unchanged.
  static String normalize(String input) => normalizeWithOffsets(input).text;

  /// Normalizes [input] like [normalize] and also reports, for every UTF-16
  /// code unit of [input], where it ended up in the normalized text.
  ///
  /// The highlighter needs this to map a match in the normalized text back to
  /// the original characters. Normalizing one character at a time cannot do
  /// that: a lone space normalizes (trims) to nothing, which made every
  /// preceding space shift the highlight one character left.
  static NormalizedText normalizeWithOffsets(String input) {
    final buffer = StringBuffer();
    final sourceToNormalized = List<int>.filled(input.length, -1);
    var length = 0;
    // Source index of the first whitespace in the current run, if that run
    // will become a single space (i.e. it is not leading or trailing).
    int? pendingSpace;

    for (var i = 0; i < input.length; i++) {
      final char = input[i];
      // 1 + 2. Diacritics and tatweel are dropped (before whitespace is
      // collapsed, so "a ِ b" still becomes "a b").
      if (isDroppedMark(char)) continue;
      // 4. Whitespace runs collapse to one space; leading runs are trimmed
      // (String.trim also strips U+0085, which `\s` does not match).
      if (_whitespace.hasMatch(char) || (length == 0 && char.trim().isEmpty)) {
        if (pendingSpace == null && length > 0) pendingSpace = i;
        continue;
      }
      if (pendingSpace != null) {
        buffer.write(' ');
        sourceToNormalized[pendingSpace] = length++;
        pendingSpace = null;
      }
      // 3. Arabic → Urdu letter variants.
      buffer.write(_variantMap[char] ?? char);
      sourceToNormalized[i] = length++;
    }
    // A trailing whitespace run is trimmed: pendingSpace is simply dropped.
    // trimRight catches the rest of String.trim's set (U+0085).
    final text = buffer.toString();
    final trimmed = text.trimRight();
    if (trimmed.length < text.length) {
      for (var i = 0; i < sourceToNormalized.length; i++) {
        if (sourceToNormalized[i] >= trimmed.length) sourceToNormalized[i] = -1;
      }
    }

    return NormalizedText(trimmed, sourceToNormalized);
  }
}

/// Result of [AppSearchUrduNormalizer.normalizeWithOffsets].
class NormalizedText {
  const NormalizedText(this.text, this.sourceToNormalized);

  /// The normalized text, identical to [AppSearchUrduNormalizer.normalize].
  final String text;

  /// For each UTF-16 code unit of the source: its index in [text], or -1 when
  /// normalization dropped it (diacritic, tatweel, extra/edge whitespace).
  final List<int> sourceToNormalized;
}
