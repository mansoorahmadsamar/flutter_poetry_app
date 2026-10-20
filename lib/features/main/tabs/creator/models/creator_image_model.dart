import '_json_helpers.dart';

class CreatorImage {
  const CreatorImage({
    required this.publicId,
    required this.imageUrl,
    this.thumbnailUrl,
    this.caption,
    this.altText,
    this.displayOrder = 0,
    this.isProfileImage = false,
    this.imageType = 'GALLERY',
    this.likeCount = 0,
    this.bookmarkCount = 0,
    this.shareCount = 0,
  });

  final String publicId;
  final String imageUrl;
  final String? thumbnailUrl;
  final String? caption;
  final String? altText;
  final int displayOrder;
  final bool isProfileImage;
  final String imageType;
  final int likeCount;
  final int bookmarkCount;
  final int shareCount;

  /// Local copy with selected fields swapped. Used by screens that mutate
  /// metadata (e.g. caption / alt text / promotion to profile) and want to
  /// reflect the change before the next `creatorImagesProvider` fetch.
  CreatorImage copyWith({
    String? publicId,
    String? imageUrl,
    String? thumbnailUrl,
    String? caption,
    String? altText,
    int? displayOrder,
    bool? isProfileImage,
    String? imageType,
    int? likeCount,
    int? bookmarkCount,
    int? shareCount,
  }) {
    return CreatorImage(
      publicId: publicId ?? this.publicId,
      imageUrl: imageUrl ?? this.imageUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      caption: caption ?? this.caption,
      altText: altText ?? this.altText,
      displayOrder: displayOrder ?? this.displayOrder,
      isProfileImage: isProfileImage ?? this.isProfileImage,
      imageType: imageType ?? this.imageType,
      likeCount: likeCount ?? this.likeCount,
      bookmarkCount: bookmarkCount ?? this.bookmarkCount,
      shareCount: shareCount ?? this.shareCount,
    );
  }

  factory CreatorImage.fromJson(Map<String, dynamic> json) {
    return CreatorImage(
      publicId: json['publicId'] as String,
      imageUrl: (json['imageUrl'] as String?) ?? '',
      thumbnailUrl: nullableStr(json['thumbnailUrl']),
      caption: nullableStr(json['caption']),
      altText: nullableStr(json['altText']),
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
      isProfileImage: json['isProfileImage'] as bool? ?? false,
      imageType: (json['imageType'] as String?) ?? 'GALLERY',
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
      bookmarkCount: (json['bookmarkCount'] as num?)?.toInt() ?? 0,
      shareCount: (json['shareCount'] as num?)?.toInt() ?? 0,
    );
  }
}
