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

  factory CreatorImage.fromJson(Map<String, dynamic> json) {
    return CreatorImage(
      publicId: json['publicId'] as String,
      imageUrl: (json['imageUrl'] as String?) ?? '',
      thumbnailUrl: json['thumbnailUrl'] as String?,
      caption: json['caption'] as String?,
      altText: json['altText'] as String?,
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
      isProfileImage: json['isProfileImage'] as bool? ?? false,
      imageType: (json['imageType'] as String?) ?? 'GALLERY',
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
      bookmarkCount: (json['bookmarkCount'] as num?)?.toInt() ?? 0,
      shareCount: (json['shareCount'] as num?)?.toInt() ?? 0,
    );
  }
}
