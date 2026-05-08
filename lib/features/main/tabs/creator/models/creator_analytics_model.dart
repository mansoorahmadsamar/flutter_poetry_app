class CreatorAnalytics {
  const CreatorAnalytics({
    this.followerCount = 0,
    this.profileViews = 0,
    this.poemCount = 0,
    this.totalPoemViews = 0,
    this.totalPoemLikes = 0,
    this.totalPoemBookmarks = 0,
    this.totalImageLikes = 0,
    this.topPoems = const [],
  });

  final int followerCount;
  final int profileViews;
  final int poemCount;
  final int totalPoemViews;
  final int totalPoemLikes;
  final int totalPoemBookmarks;
  final int totalImageLikes;
  final List<TopPoem> topPoems;

  factory CreatorAnalytics.fromJson(Map<String, dynamic> json) {
    return CreatorAnalytics(
      followerCount: (json['followerCount'] as num?)?.toInt() ?? 0,
      profileViews: (json['profileViews'] as num?)?.toInt() ?? 0,
      poemCount: (json['poemCount'] as num?)?.toInt() ?? 0,
      totalPoemViews: (json['totalPoemViews'] as num?)?.toInt() ?? 0,
      totalPoemLikes: (json['totalPoemLikes'] as num?)?.toInt() ?? 0,
      totalPoemBookmarks: (json['totalPoemBookmarks'] as num?)?.toInt() ?? 0,
      totalImageLikes: (json['totalImageLikes'] as num?)?.toInt() ?? 0,
      topPoems: (json['topPoems'] as List?)
              ?.map((e) => TopPoem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}

class TopPoem {
  const TopPoem({
    required this.publicId,
    required this.title,
    this.poetryType = 'GHAZAL',
    this.viewCount = 0,
    this.likeCount = 0,
    this.shareCount = 0,
    this.createdAt,
  });

  final String publicId;
  final String title;
  final String poetryType;
  final int viewCount;
  final int likeCount;
  final int shareCount;
  final DateTime? createdAt;

  factory TopPoem.fromJson(Map<String, dynamic> json) {
    return TopPoem(
      publicId: json['publicId'] as String,
      title: (json['title'] as String?) ?? '',
      poetryType: (json['poetryType'] as String?) ?? 'GHAZAL',
      viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
      shareCount: (json['shareCount'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }
}
