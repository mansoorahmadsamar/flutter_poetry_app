import '_json_helpers.dart';
import 'claim_status.dart';

/// The current user's own poet profile, returned from
/// `GET /api/me/poet-profile`. Includes the ownership-related fields
/// (claimStatus + claimedAt + ownerUserId + claimRejectionReason +
/// claimReviewerNote) that distinguish PENDING/VERIFIED/REJECTED states.
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
    this.claimRejectionReason,
    this.claimReviewerNote,
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

  /// Ownership lifecycle — orthogonal to [isVerified] (the editorial
  /// "notable poet" badge). See FLUTTER_API_DOCUMENTATION.md §20.2.
  final ClaimStatus claimStatus;

  /// `publicId` of the owning User (string, not numeric).
  final String? ownerUserId;

  /// Editorial badge — set by editors for notable poets like Ghalib.
  /// Independent of who owns the row.
  final bool isVerified;

  /// Last claim action timestamp (submission, approval, or rejection).
  final DateTime? claimedAt;

  /// Populated when [claimStatus] is `REJECTED` — admin's reason text.
  final String? claimRejectionReason;

  /// Optional admin note left on approve or reject.
  final String? claimReviewerNote;

  factory OwnedPoet.fromJson(Map<String, dynamic> json) {
    return OwnedPoet(
      publicId: json['publicId'] as String,
      name: (json['name'] as String?) ?? '',
      penName: nullableStr(json['penName']),
      shortBio: nullableStr(json['shortBio']),
      biography: nullableStr(json['biography']),
      profileImageUrl: nullableStr(json['profileImageUrl']),
      primaryLanguageCode: (json['primaryLanguageCode'] as String?) ?? 'ur',
      primaryLanguageName: (json['primaryLanguageName'] as String?) ?? 'Urdu',
      era: nullableStr(json['era']),
      gender: nullableStr(json['gender']),
      birthYear: (json['birthYear'] as num?)?.toInt(),
      deathYear: (json['deathYear'] as num?)?.toInt(),
      viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
      poemCount: (json['poemCount'] as num?)?.toInt() ?? 0,
      followerCount: (json['followerCount'] as num?)?.toInt() ?? 0,
      claimStatus: ClaimStatus.fromString(json['claimStatus'] as String?),
      ownerUserId: nullableStr(json['ownerUserId']),
      isVerified: json['isVerified'] as bool? ?? false,
      claimedAt: parseApiDate(json['claimedAt']),
      claimRejectionReason: nullableStr(json['claimRejectionReason']),
      claimReviewerNote: nullableStr(json['claimReviewerNote']),
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
