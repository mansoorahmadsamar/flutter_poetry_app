/// A poem authored by the current user, returned from
/// `GET /api/me/poet/poems`. Includes the private `isPublic` flag so
/// drafts can be shown alongside published poems.
class CreatorPoem {
  const CreatorPoem({
    required this.publicId,
    required this.title,
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
    return CreatorPoem(
      publicId: json['publicId'] as String,
      title: (json['title'] as String?) ?? '',
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
