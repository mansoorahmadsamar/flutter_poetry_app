/// A poem authored by the current user, returned from
/// `GET /api/me/poet/poems`. Includes the private `isPublic` flag so
/// drafts can be shown alongside published poems.
class CreatorPoem {
  const CreatorPoem({
    required this.publicId,
    required this.title,
    this.firstMisra,
    required this.poetryType,
    this.languageCode = 'ur',
    this.script = 'ARABIC',
    this.isPublic = true,
    this.viewCount = 0,
    this.likeCount = 0,
    this.bookmarkCount = 0,
    this.shareCount = 0,
    this.createdAt,
    this.updatedAt,
    this.tagSlugs = const [],
  });

  final String publicId;
  final String title;
  /// First verse of the primary-language body, server-trimmed and capped at
  /// 80 chars. Used as the display title when [title] is blank/dash-only.
  /// Per FLUTTER_API_DOCUMENTATION.md §20.10.1.
  final String? firstMisra;
  final String poetryType;
  final String languageCode;
  final String script;
  final bool isPublic;
  final int viewCount;
  final int likeCount;
  final int bookmarkCount;
  final int shareCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<String> tagSlugs;

  factory CreatorPoem.fromJson(Map<String, dynamic> json) {
    final resolvedTitle = _resolveTitle(json);
    final firstMisraRaw = (json['firstMisra'] as String?)?.trim();
    return CreatorPoem(
      publicId: json['publicId'] as String,
      title: resolvedTitle,
      firstMisra:
          (firstMisraRaw == null || firstMisraRaw.isEmpty) ? null : firstMisraRaw,
      poetryType: (json['poetryType'] as String?) ?? 'GHAZAL',
      languageCode: (json['languageCode'] as String?) ?? 'ur',
      script: (json['script'] as String?) ?? 'ARABIC',
      isPublic: json['isPublic'] as bool? ?? true,
      viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
      bookmarkCount: (json['bookmarkCount'] as num?)?.toInt() ?? 0,
      shareCount: (json['shareCount'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
      tagSlugs: (json['tagSlugs'] as List?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }

  /// True when the title is missing or a placeholder. Many scraped poems
  /// store a bare dash ("-", "—", "–") or punctuation-only string as the
  /// title; treat those as "no title" so the UI can fall back gracefully.
  static bool _isBlankTitle(String? t) {
    if (t == null) return true;
    final s = t.trim();
    if (s.isEmpty) return true;
    // Only dashes / punctuation / whitespace → not a real title.
    return RegExp(r'^[-–—_.·•…\s]+$').hasMatch(s);
  }

  /// Title can arrive at the top level (composed via app) or nested under
  /// `originalContent.title` / `contents[*].title` for scraped poems.
  /// Try the top level first, then fall back through the content list.
  /// Returns an empty string when no real title exists (callers render a
  /// typed placeholder instead).
  static String _resolveTitle(Map<String, dynamic> json) {
    final top = (json['title'] as String?)?.trim();
    if (!_isBlankTitle(top)) return top!;

    final original = json['originalContent'];
    if (original is Map<String, dynamic>) {
      final t = (original['title'] as String?)?.trim();
      if (!_isBlankTitle(t)) return t!;
    }

    final contents = json['contents'];
    if (contents is List && contents.isNotEmpty) {
      // Prefer the Urdu/Arabic-script content if available, else first.
      Map<String, dynamic>? best;
      for (final c in contents) {
        if (c is! Map<String, dynamic>) continue;
        final t = (c['title'] as String?)?.trim();
        if (_isBlankTitle(t)) continue;
        if ((c['languageCode'] as String?) == 'ur' &&
            (c['script'] as String?) == 'ARABIC') {
          best = c;
          break;
        }
        best ??= c;
      }
      if (best != null) {
        final t = ((best['title'] as String?) ?? '').trim();
        if (!_isBlankTitle(t)) return t;
      }
    }

    // Server-provided first verse as the final fallback (FLUTTER_API
    // §20.10.1). Trim + cap defensively in case an older server returns
    // an over-long value.
    final misra = (json['firstMisra'] as String?)?.trim();
    if (misra != null && !_isBlankTitle(misra)) {
      return misra.length > 80 ? '${misra.substring(0, 80)}…' : misra;
    }

    return '';
  }
}

/// Server-supported poetry types — labelled in Urdu where possible.
class PoetryType {
  const PoetryType(this.apiKey, this.urduLabel, this.englishLabel);
  final String apiKey;
  final String urduLabel;
  final String englishLabel;

  static const all = <PoetryType>[
    PoetryType('GHAZAL', 'غزل', 'Ghazal'),
    PoetryType('NAZAM', 'نظم', 'Nazam'),
    PoetryType('QITA', 'قطعہ', 'Qita'),
    PoetryType('RUBAI', 'رباعی', "Rubai"),
    PoetryType('MASNAVI', 'مثنوی', 'Masnavi'),
    PoetryType('MARSIYA', 'مرثیہ', 'Marsiya'),
    PoetryType('QASIDA', 'قصیدہ', 'Qasida'),
    PoetryType('OTHER', 'دیگر', 'Other'),
  ];

  static PoetryType byKey(String key) =>
      all.firstWhere((p) => p.apiKey == key, orElse: () => all.last);
}
