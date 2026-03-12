import 'package:freezed_annotation/freezed_annotation.dart';
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
    @JsonKey(name: 'isLiked') required bool isLikedByCurrentUser,
    @JsonKey(name: 'isBookmarked') required bool isBookmarkedByCurrentUser,
    @Default([]) List<String> tagSlugs,
    DateTime? createdAt,
  }) = _CoupletModel;

  factory CoupletModel.fromJson(Map<String, dynamic> json) =>
      _$CoupletModelFromJson(json);
}

/// CoupletDetailResponse - Couplet with poem and poet context
@freezed
class CoupletDetailResponse with _$CoupletDetailResponse {
  const factory CoupletDetailResponse({
    required String publicId,
    required int coupletNumber,
    required String coupletType,
    String? coupletTypeName,
    required List<VerseModel> verses,
    // Poem context
    required String poemPublicId,
    String? poemTitle,
    int? totalCoupletsInPoem,
    String? poetryType,
    // Poet context
    required String poetPublicId,
    required String poetName,
    String? poetProfileImageUrl,
    // Engagement
    @Default(0) int likeCount,
    @Default(0) int bookmarkCount,
    @Default(0) int shareCount,
    @JsonKey(name: 'isLiked') required bool isLikedByCurrentUser,
    @JsonKey(name: 'isBookmarked') required bool isBookmarkedByCurrentUser,
    @Default([]) List<String> tagSlugs,
    DateTime? createdAt,
    DateTime? updatedAt,
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
    @JsonKey(name: 'isLiked') required bool isLikedByCurrentUser,
    @JsonKey(name: 'isBookmarked') required bool isBookmarkedByCurrentUser,
    @Default([]) List<String> tagSlugs,
    DateTime? bookmarkedAt,
  }) = _BookmarkedCoupletResponse;

  factory BookmarkedCoupletResponse.fromJson(Map<String, dynamic> json) =>
      _$BookmarkedCoupletResponseFromJson(json);
}
