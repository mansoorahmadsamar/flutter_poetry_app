import 'claim_status.dart';

/// The current user's own poet profile, returned from
/// `GET /api/me/poet-profile`. Includes the private fields not exposed
/// on the public endpoint (claimStatus, ownerUserId, isPublic counts).
class OwnedPoet {
  const OwnedPoet({
    required this.publicId,
    required this.name,
    required this.claimStatus,
    this.penName,
    this.shortBio,
    this.biography,
    this.profileImageUrl,
    this.primaryLanguageCode = 'ur',
    this.primaryLanguageName = 'Urdu',
    this.era,
    this.gender,
    this.birthYear,
    this.deathYear,
    this.viewCount = 0,
    this.poemCount = 0,
    this.followerCount = 0,
    this.ownerUserId,
    this.isVerified = false,
    this.claimedAt,
  });

  final String publicId;
  final String name;
  final String? penName;
  final String? shortBio;
  final String? biography;
  final String? profileImageUrl;
  final String primaryLanguageCode;
  final String primaryLanguageName;
  final String? era;
  final String? gender;
  final int? birthYear;
  final int? deathYear;
  final int viewCount;
  final int poemCount;
  final int followerCount;
  final ClaimStatus claimStatus;
  final int? ownerUserId;
  final bool isVerified;
  final DateTime? claimedAt;

  factory OwnedPoet.fromJson(Map<String, dynamic> json) {
    return OwnedPoet(
      publicId: json['publicId'] as String,
      name: (json['name'] as String?) ?? '',
      penName: json['penName'] as String?,
      shortBio: json['shortBio'] as String?,
      biography: json['biography'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      primaryLanguageCode: (json['primaryLanguageCode'] as String?) ?? 'ur',
      primaryLanguageName: (json['primaryLanguageName'] as String?) ?? 'Urdu',
      era: json['era'] as String?,
      gender: json['gender'] as String?,
      birthYear: (json['birthYear'] as num?)?.toInt(),
      deathYear: (json['deathYear'] as num?)?.toInt(),
      viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
      poemCount: (json['poemCount'] as num?)?.toInt() ?? 0,
      followerCount: (json['followerCount'] as num?)?.toInt() ?? 0,
      claimStatus: ClaimStatus.fromString(json['claimStatus'] as String?),
      ownerUserId: (json['ownerUserId'] as num?)?.toInt(),
      isVerified: json['isVerified'] as bool? ?? false,
      claimedAt: json['claimedAt'] != null
          ? DateTime.tryParse(json['claimedAt'].toString())
          : null,
    );
  }

  /// First initial — used as avatar fallback. Prefers the Urdu pen name's
  /// first character so the design's gold initial reads as Urdu.
  String get displayInitial {
    final source = (penName?.isNotEmpty == true ? penName! : name);
    if (source.isEmpty) return 'م';
    final runes = source.runes.toList();
    return String.fromCharCode(runes.first);
  }

  bool get isVerifiedOwner => claimStatus == ClaimStatus.verified;
}
