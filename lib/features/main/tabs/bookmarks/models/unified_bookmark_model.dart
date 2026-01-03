import 'package:freezed_annotation/freezed_annotation.dart';

part 'unified_bookmark_model.freezed.dart';
part 'unified_bookmark_model.g.dart';

/// Unified bookmark model for all content types
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

    // POEM fields
    String? poemTitle,
    String? poetName,
    String? poetId,

    // COUPLET fields
    @JsonKey(name: 'coupletFirstVerse') String? coupletVerse1,
    @JsonKey(name: 'coupletSecondVerse') String? coupletVerse2,
    @JsonKey(name: 'parentPoemTitle') String? coupletPoemTitle,
    @JsonKey(name: 'parentPoemId') String? coupletPoemPublicId,

    // IMAGE fields
    String? imageUrl,
    String? thumbnailUrl,
    String? templateName,

    // Common metrics
    @Default(0) int likeCount,
    int? bookmarkCount,
    @Default(0) int shareCount,
  }) = _UnifiedBookmark;

  factory UnifiedBookmark.fromJson(Map<String, dynamic> json) {
    // Helper to convert "-" strings to null
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
        poemTitle: cleanString(json['poemTitle']),
        poetName: cleanString(json['poetName']),
        poetId: cleanString(json['poetId']),
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

  /// Helper to get language display name
  String get languageName {
    switch (languageCode.toLowerCase()) {
      case 'ur':
        return 'Urdu';
      case 'en':
        return 'English';
      case 'hi':
        return 'Hindi';
      default:
        return languageCode.toUpperCase();
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
    required bool first,
    required bool last,
    required bool empty,
  }) = _UnifiedBookmarksResponse;

  factory UnifiedBookmarksResponse.fromJson(Map<String, dynamic> json) {
    // Parse content array manually using our custom UnifiedBookmark.fromJson
    final contentList = (json['content'] as List<dynamic>)
        .map((item) => UnifiedBookmark.fromJson(item as Map<String, dynamic>))
        .toList();

    return UnifiedBookmarksResponse(
      content: contentList,
      totalElements: json['totalElements'] as int,
      totalPages: json['totalPages'] as int,
      number: json['number'] as int,
      size: json['size'] as int,
      first: json['first'] as bool,
      last: json['last'] as bool,
      empty: json['empty'] as bool,
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
    @Default('bookmarkedAt') String sortBy,
    @Default('desc') String sortDir,
  }) = _BookmarkFilters;
}

/// Bookmark statistics
@freezed
class BookmarkStats with _$BookmarkStats {
  const factory BookmarkStats({
    @Default(0) int totalBookmarks,
    @Default(0) int poemCount,
    @Default(0) int coupletCount,
    @Default(0) int imageCount,
    @Default(0) int urduCount,
    @Default(0) int englishCount,
    @Default(0) int hindiCount,
  }) = _BookmarkStats;

  factory BookmarkStats.fromJson(Map<String, dynamic> json) =>
      _$BookmarkStatsFromJson(json);
}
