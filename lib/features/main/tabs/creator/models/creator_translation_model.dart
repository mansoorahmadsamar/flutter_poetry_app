import '_json_helpers.dart';

class CreatorTranslation {
  const CreatorTranslation({
    required this.languageCode,
    required this.languageName,
    this.name,
    this.penName,
    this.shortBio,
    this.biography,
    this.hasShortBio = false,
    this.hasBiography = false,
    this.isPrimary = false,
  });

  final String languageCode;
  final String languageName;
  final String? name;
  final String? penName;
  final String? shortBio;
  final String? biography;
  final bool hasShortBio;
  final bool hasBiography;
  final bool isPrimary;

  factory CreatorTranslation.fromJson(Map<String, dynamic> json) {
    return CreatorTranslation(
      languageCode: (json['languageCode'] as String?) ?? 'ur',
      languageName: (json['languageName'] as String?) ?? 'Urdu',
      name: nullableStr(json['name']),
      penName: nullableStr(json['penName']),
      shortBio: nullableStr(json['shortBio']),
      biography: nullableStr(json['biography']),
      hasShortBio: json['hasShortBio'] as bool? ?? false,
      hasBiography: json['hasBiography'] as bool? ?? false,
      isPrimary: json['isPrimary'] as bool? ?? false,
    );
  }

  CreatorTranslation copyWith({
    String? name,
    String? penName,
    String? shortBio,
    String? biography,
  }) =>
      CreatorTranslation(
        languageCode: languageCode,
        languageName: languageName,
        name: name ?? this.name,
        penName: penName ?? this.penName,
        shortBio: shortBio ?? this.shortBio,
        biography: biography ?? this.biography,
        hasShortBio: hasShortBio,
        hasBiography: hasBiography,
        isPrimary: isPrimary,
      );
}

/// Languages that the backend currently supports for poet content.
class SupportedLanguage {
  const SupportedLanguage(this.code, this.englishName, this.nativeName, this.isUrdu);
  final String code;
  final String englishName;
  final String nativeName;
  final bool isUrdu;

  static const all = <SupportedLanguage>[
    SupportedLanguage('ur', 'Urdu', 'اردو', true),
    SupportedLanguage('en', 'English', 'English', false),
    SupportedLanguage('hi', 'Hindi', 'हिंदी', false),
    SupportedLanguage('fa', 'Persian', 'فارسی', true),
    SupportedLanguage('ar', 'Arabic', 'العربية', true),
    SupportedLanguage('pa', 'Punjabi', 'پنجابی', true),
  ];

  static SupportedLanguage byCode(String code) =>
      all.firstWhere((l) => l.code == code, orElse: () => all.first);
}
