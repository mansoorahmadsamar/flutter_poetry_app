import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_poetry_app/core/utils/api_placeholder.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/models/poem_model.dart';

part 'couplet_model.freezed.dart';
part 'couplet_model.g.dart';

/// CoupletModel - Basic couplet with engagement data
@freezed
class CoupletModel with _$CoupletModel {
  const factory CoupletModel({
    required String publicId,
    required int coupletNumber,
    required String coupletType,
    String? coupletTypeName,
    required List<VerseModel> verses,
    @Default(0) int likeCount,
    @Default(0) int bookmarkCount,
    @Default(0) int shareCount,
    @JsonKey(name: 'isLiked') bool? isLikedByCurrentUser,
    @JsonKey(name: 'isBookmarked') bool? isBookmarkedByCurrentUser,
    @Default([]) List<String> tagSlugs,
    DateTime? createdAt,
    // Reactions system (Section 19)
    Map<String, dynamic>? reactions,
  }) = _CoupletModel;

  factory CoupletModel.fromJson(Map<String, dynamic> json) =>
      _$CoupletModelFromJson(json);
}

/// CoupletDetailResponse - Couplet with poem and poet context.
///
/// Also parses the plain `CoupletDto` that `/api/hashtags/{slug}/couplets`
/// returns. In production (backend `main`) that DTO has **no** poem or poet
/// fields, and its `coupletType` (an enum) can be `null`; from backend
/// `develop` (T-012) it carries `poemPublicId`/`poemTitle`/`poetPublicId`/
/// `poetName`, sent as `"-"` when unknown. So every context field is
/// optional and `"-"` reads as absent (T-177): a couplet without a poem id
/// cannot open its poem, and one without a poet name shows none.
@freezed
class CoupletDetailResponse with _$CoupletDetailResponse {
  const factory CoupletDetailResponse({
    required String publicId,
    @Default(0) int coupletNumber,
    @PlaceholderStringConverter() String? coupletType,
    @PlaceholderStringConverter() String? coupletTypeName,
    @Default([]) List<VerseModel> verses,
    // Poem context
    @PlaceholderStringConverter() String? poemPublicId,
    @PlaceholderStringConverter() String? poemTitle,
    int? totalCoupletsInPoem,
    String? poetryType,
    // Poet context
    @PlaceholderStringConverter() String? poetPublicId,
    @PlaceholderStringConverter() String? poetName,
    @PlaceholderStringConverter() String? poetProfileImageUrl,
    // Engagement
    @Default(0) int likeCount,
    @Default(0) int bookmarkCount,
    @Default(0) int shareCount,
    @JsonKey(name: 'isLiked') bool? isLikedByCurrentUser,
    @JsonKey(name: 'isBookmarked') bool? isBookmarkedByCurrentUser,
    @Default([]) List<String> tagSlugs,
    DateTime? createdAt,
    DateTime? updatedAt,
    // Reactions system (Section 19)
    Map<String, dynamic>? reactions,
  }) = _CoupletDetailResponse;

  factory CoupletDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$CoupletDetailResponseFromJson(json);
}

/// BookmarkedCoupletResponse - For bookmarks collection
@freezed
class BookmarkedCoupletResponse with _$BookmarkedCoupletResponse {
  const factory BookmarkedCoupletResponse({
    required String coupletPublicId,
    required int coupletNumber,
    required String coupletType,
    String? coupletTypeName,
    required List<VerseModel> verses,
    // Poem context
    required String poemPublicId,
    String? poemTitle,
    String? poemExcerpt,
    String? poetryType,
    int? totalCoupletsInPoem,
    // Poet context
    required String poetPublicId,
    required String poetName,
    String? poetProfileImageUrl,
    // Engagement
    @Default(0) int likeCount,
    @Default(0) int bookmarkCount,
    @JsonKey(name: 'isLiked') bool? isLikedByCurrentUser,
    @JsonKey(name: 'isBookmarked') bool? isBookmarkedByCurrentUser,
    @Default([]) List<String> tagSlugs,
    DateTime? bookmarkedAt,
  }) = _BookmarkedCoupletResponse;

  factory BookmarkedCoupletResponse.fromJson(Map<String, dynamic> json) =>
      _$BookmarkedCoupletResponseFromJson(json);
}
