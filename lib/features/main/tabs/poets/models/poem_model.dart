import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:collection/collection.dart';

part 'poem_model.freezed.dart';
part 'poem_model.g.dart';

@freezed
class PoemModel with _$PoemModel {
  const factory PoemModel({
    required String publicId,
    required String poetPublicId,
    required String poetName,
    String? poetProfileImageUrl,
    String? categoryPublicId,
    String? categoryName,
    required String poetryType,
    @JsonKey(name: 'poetryTypeName') String? poetryTypeName,
    String? poetryTypeUrduName,
    String? poetryTypeEnglishName,
    required String contentType,
    bool? requiresStructuredParsing,
    String? imageUrl,
    String? thumbnailUrl,
    int? yearWritten,
    String? source,
    String? license,
    String? uploadedByUsername,
    @Default(true) bool isPublic,
    @Default(false) bool isFeatured,
    @Default(0) int viewCount,
    @Default(0) int likeCount,
    @Default(0) int shareCount,
    bool? isLikedByCurrentUser,
    bool? isBookmarkedByCurrentUser,
    int? commentCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? bookmarkedAt,
    DateTime? likedAt,
    @Default([]) List<TagModel> tags,
    @Default([]) List<PoemContentModel> contents,
    PoemContentModel? originalContent,
    // Simple list API fields (for backward compatibility)
    String? title,
    String? excerpt,
  }) = _PoemModel;

  factory PoemModel.fromJson(Map<String, dynamic> json) =>
      _$PoemModelFromJson(json);
}

@freezed
class PoemContentModel with _$PoemContentModel {
  const factory PoemContentModel({
    required String publicId,
    required String languageCode,
    required String languageName,
    required String languageNativeName,
    required String script,
    String? scriptUrduName,
    String? scriptEnglishName,
    String? scriptDirection,
    required String title,
    required String fullText,
    @Default(true) bool isOriginal,
    String? translatedBy,
    String? notes,
    @Default([]) List<VerseModel> verses,
    @Default(0) int totalVerses,
    @Default(0) int totalCouplets,
  }) = _PoemContentModel;

  factory PoemContentModel.fromJson(Map<String, dynamic> json) =>
      _$PoemContentModelFromJson(json);
}

@freezed
class TagModel with _$TagModel {
  const factory TagModel({
    required String publicId,
    required String name,
    required String slug,
    String? color,
    required String tagType,
    String? description,
  }) = _TagModel;

  factory TagModel.fromJson(Map<String, dynamic> json) =>
      _$TagModelFromJson(json);
}

@freezed
class VerseModel with _$VerseModel {
  const factory VerseModel({
    required String publicId,
    @JsonKey(name: 'verseText') required String text,
    String? verseType,
    int? verseNumber,
  }) = _VerseModel;

  factory VerseModel.fromJson(Map<String, dynamic> json) =>
      _$VerseModelFromJson(json);
}

extension PoemModelExtensions on PoemModel {
  /// Get content for user's preferred language, fallback to available content
  PoemContentModel? getContentForLanguage(String preferredLanguageCode) {
    // Try to find content in preferred language
    final preferred = contents.firstWhereOrNull(
      (c) => c.languageCode == preferredLanguageCode,
    );

    if (preferred != null) return preferred;

    // Fallback to original content
    if (originalContent != null) return originalContent;

    // Fallback to any available content
    return contents.isNotEmpty ? contents.first : null;
  }

  /// Get display title based on language preference
  /// Handles both list API (title field) and detail API (contents array)
  String getDisplayTitle(String preferredLanguageCode) {
    // If title field exists (list API), use it
    if (title != null && title!.isNotEmpty) {
      return title!;
    }

    // Otherwise use contents array (detail API)
    final content = getContentForLanguage(preferredLanguageCode);
    return content?.title ?? 'Untitled';
  }

  /// Get display text based on language preference
  /// Handles both list API (excerpt field) and detail API (contents array)
  String getDisplayText(String preferredLanguageCode) {
    // If excerpt field exists (list API), use it
    if (excerpt != null && excerpt!.isNotEmpty) {
      return excerpt!;
    }

    // Otherwise use contents array (detail API)
    final content = getContentForLanguage(preferredLanguageCode);
    return content?.fullText ?? '';
  }

  /// Check if content uses RTL script
  /// For list API, assume RTL for Urdu language
  bool isRTL(String preferredLanguageCode) {
    // For list API responses, assume RTL based on language code
    if (contents.isEmpty && preferredLanguageCode == 'ur') {
      return true;
    }

    // For detail API, check script direction
    final content = getContentForLanguage(preferredLanguageCode);
    return content?.scriptDirection?.toLowerCase() == 'rtl';
  }
}
