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

  /// Pre-built regex for variant replacement (one pass)
  static final _variantPattern = RegExp(
    _variantMap.keys.map(RegExp.escape).join('|'),
  );

  /// Normalize an Urdu/Arabic query for search.
  ///
  /// Returns the normalized, trimmed query string.
  /// Safe to call on English text — it passes through unchanged.
  static String normalize(String input) {
    if (input.isEmpty) return input;

    var result = input;

    // 1. Remove diacritics (tashkeel)
    result = result.replaceAll(_diacriticsPattern, '');

    // 2. Remove tatweel (kashida)
    result = result.replaceAll(_tatweel, '');

    // 3. Normalize Arabic → Urdu letter variants (single regex pass)
    result = result.replaceAllMapped(
      _variantPattern,
      (match) => _variantMap[match.group(0)] ?? match.group(0)!,
    );

    // 4. Collapse multiple spaces
    result = result.replaceAll(RegExp(r'\s+'), ' ');

    return result.trim();
  }
}
