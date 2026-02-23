import 'package:freezed_annotation/freezed_annotation.dart';

part 'unified_bookmark_model.freezed.dart';
part 'unified_bookmark_model.g.dart';

/// Unified bookmark model for all content types (POEM, COUPLET, IMAGE).
///
/// Backend now omits null fields entirely — no more "-" placeholders.
/// Fields absent from JSON are equivalent to null in Dart.
@freezed
class UnifiedBookmark with _$UnifiedBookmark {
  const UnifiedBookmark._();

  const factory UnifiedBookmark({
    required String bookmarkId,
    required String type, // POEM, COUPLET, IMAGE
    required String contentId,
    required String languageCode,
    required DateTime bookmarkedAt,
    String? notes,

    // POEM + COUPLET shared fields
    String? poetName,
    String? poetId,
    String? poetProfileImageUrl, // 36x36 poet avatar thumbnail
    String? contentSubType, // e.g. "GHAZAL", "NAZM"
    String? contentSubTypeUrdu, // e.g. "غزل", "نظم"

    // POEM fields
    String? poemTitle,

    // COUPLET fields
    @JsonKey(name: 'coupletFirstVerse') String? coupletVerse1,
    @JsonKey(name: 'coupletSecondVerse') String? coupletVerse2,
    @JsonKey(name: 'parentPoemTitle') String? coupletPoemTitle,
    @JsonKey(name: 'parentPoemId') String? coupletPoemPublicId,

    // IMAGE fields
    String? imageUrl,
    String? thumbnailUrl,
    String? templateName,

    // Engagement metrics
    @Default(0) int likeCount,
    int? bookmarkCount,
    @Default(0) int shareCount,
  }) = _UnifiedBookmark;

  factory UnifiedBookmark.fromJson(Map<String, dynamic> json) {
    // Backend now returns null-omitted fields — standard parsing works.
    // Keep cleanString only as a safety net for any legacy responses.
    String? cleanString(dynamic value) {
      if (value == null || value == '-' || value == '') return null;
      return value.toString();
    }

    try {
      return _UnifiedBookmark(
        bookmarkId: json['bookmarkId']?.toString() ?? '',
        type: json['type']?.toString() ?? '',
        contentId: json['contentId']?.toString() ?? '',
        languageCode: json['languageCode']?.toString() ?? 'en',
        bookmarkedAt: json['bookmarkedAt'] != null
            ? DateTime.parse(json['bookmarkedAt'] as String)
            : DateTime.now(),
        notes: cleanString(json['notes']),
        poetName: cleanString(json['poetName']),
        poetId: cleanString(json['poetId']),
        poetProfileImageUrl: cleanString(json['poetProfileImageUrl']),
        contentSubType: cleanString(json['contentSubType']),
        contentSubTypeUrdu: cleanString(json['contentSubTypeUrdu']),
        poemTitle: cleanString(json['poemTitle']),
        coupletVerse1: cleanString(json['coupletFirstVerse']),
        coupletVerse2: cleanString(json['coupletSecondVerse']),
        coupletPoemTitle: cleanString(json['parentPoemTitle']),
        coupletPoemPublicId: cleanString(json['parentPoemId']),
        imageUrl: cleanString(json['imageUrl']),
        thumbnailUrl: cleanString(json['thumbnailUrl']),
        templateName: cleanString(json['templateName']),
        likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
        bookmarkCount: (json['bookmarkCount'] as num?)?.toInt(),
        shareCount: (json['shareCount'] as num?)?.toInt() ?? 0,
      );
    } catch (e) {
      print('ERROR parsing bookmark: $e');
      print('JSON: $json');
      rethrow;
    }
  }

  /// Language display name
  String get languageName {
    switch (languageCode.toLowerCase()) {
      case 'ur':
        return 'اردو';
      case 'en':
        return 'English';
      case 'hi':
        return 'हिंदी';
      default:
        return languageCode.toUpperCase();
    }
  }

  /// Whether this bookmark's content is Urdu
  bool get isUrdu => languageCode == 'ur';

  /// Type label for chips (use contentSubTypeUrdu for Urdu-first display)
  String get typeLabel {
    if (contentSubTypeUrdu != null) return contentSubTypeUrdu!;
    switch (type.toUpperCase()) {
      case 'POEM':
        return 'غزل';
      case 'COUPLET':
        return 'شعر';
      case 'IMAGE':
        return 'تصویر';
      default:
        return type;
    }
  }

  /// Type label in English
  String get typeLabelEn {
    if (contentSubType != null) return contentSubType!;
    return type;
  }

  /// API type path segment for PATCH/DELETE endpoints
  String get apiTypePath {
    switch (type.toUpperCase()) {
      case 'POEM':
        return 'poems';
      case 'COUPLET':
        return 'couplets';
      case 'IMAGE':
        return 'images';
      default:
        return type.toLowerCase();
    }
  }
}

/// Paginated response for unified bookmarks
@freezed
class UnifiedBookmarksResponse with _$UnifiedBookmarksResponse {
  const factory UnifiedBookmarksResponse({
    required List<UnifiedBookmark> content,
    required int totalElements,
    required int totalPages,
    required int number,
    required int size,
    @Default(true) bool first,
    @Default(true) bool last,
    @Default(false) bool empty,
  }) = _UnifiedBookmarksResponse;

  factory UnifiedBookmarksResponse.fromJson(Map<String, dynamic> json) {
    final contentList = (json['content'] as List<dynamic>)
        .map((item) => UnifiedBookmark.fromJson(item as Map<String, dynamic>))
        .toList();

    return UnifiedBookmarksResponse(
      content: contentList,
      totalElements: (json['totalElements'] as num?)?.toInt() ?? 0,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
      number: (json['number'] as num?)?.toInt() ?? 0,
      size: (json['size'] as num?)?.toInt() ?? 20,
      first: json['first'] as bool? ?? true,
      last: json['last'] as bool? ?? true,
      empty: json['empty'] as bool? ?? false,
    );
  }
}

/// Filter parameters for bookmarks
@freezed
class BookmarkFilters with _$BookmarkFilters {
  const factory BookmarkFilters({
    @Default('ALL') String type, // ALL, POEM, COUPLET, IMAGE
    @Default('ALL') String language, // ALL, ur, en, hi
    String? searchQuery,
    @Default(0) int page,
    @Default(20) int size,
    @Default('bookmarkedAt') String sortBy, // bookmarkedAt, likeCount, shareCount
    @Default('desc') String sortDir,
  }) = _BookmarkFilters;
}

/// Bookmark statistics with language breakdown
@freezed
class BookmarkStats with _$BookmarkStats {
  const factory BookmarkStats({
    @Default(0) int totalBookmarks,
    @Default(0) int poemBookmarks,
    @Default(0) int coupletBookmarks,
    @Default(0) int imageBookmarks,
    @Default({}) Map<String, int> byLanguage,
    @Default([]) List<TopPoet> topPoets,
    @Default(0) int recentBookmarks,
  }) = _BookmarkStats;

  factory BookmarkStats.fromJson(Map<String, dynamic> json) {
    return BookmarkStats(
      totalBookmarks: (json['totalBookmarks'] as num?)?.toInt() ?? 0,
      poemBookmarks: (json['poemBookmarks'] as num?)?.toInt() ?? 0,
      coupletBookmarks: (json['coupletBookmarks'] as num?)?.toInt() ?? 0,
      imageBookmarks: (json['imageBookmarks'] as num?)?.toInt() ?? 0,
      byLanguage: Map<String, int>.from(
        (json['byLanguage'] as Map? ?? {}),
      ),
      topPoets: (json['topPoets'] as List? ?? [])
          .map((e) => TopPoet.fromJson(e as Map<String, dynamic>))
          .toList(),
      recentBookmarks: (json['recentBookmarks'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Top poet in bookmark stats
@freezed
class TopPoet with _$TopPoet {
  const factory TopPoet({
    required String poetId,
    required String poetName,
    @Default(0) int bookmarkCount,
  }) = _TopPoet;

  factory TopPoet.fromJson(Map<String, dynamic> json) =>
      _$TopPoetFromJson(json);
}
