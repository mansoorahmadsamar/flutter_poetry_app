import '_json_helpers.dart';

class CreatorFact {
  const CreatorFact({
    required this.publicId,
    required this.fact,
    this.languageCode = 'ur',
    this.languageName,
    this.displayOrder = 0,
    this.factGroupId,
  });

  final String publicId;
  final String fact;
  final String languageCode;
  final String? languageName;
  final int displayOrder;
  final String? factGroupId;

  factory CreatorFact.fromJson(Map<String, dynamic> json) {
    return CreatorFact(
      publicId: json['publicId'] as String,
      fact: (json['fact'] as String?) ?? '',
      languageCode: (json['languageCode'] as String?) ?? 'ur',
      languageName: nullableStr(json['languageName']),
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
      factGroupId: nullableStr(json['factGroupId']),
    );
  }
}
