import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated_image_model.freezed.dart';
part 'generated_image_model.g.dart';

@freezed
class GeneratedImageModel with _$GeneratedImageModel {
  const factory GeneratedImageModel({
    required String publicId,
    required List<String> coupletIds,
    String? poemPublicId,
    String? poetPublicId,
    String? poetName,
    required String languageCode,
    String? templateId,
    String? templateName,
    @Default(false) bool isCustom,
    required String imageUrl,
    String? thumbnailUrl,
    int? width,
    int? height,
    int? fileSizeBytes,
    @Default('PNG') String format,
    @Default(0) int shareCount,
    @Default(0) int viewCount,
    int? userId,
    @Default(false) bool isUserCreated,
    DateTime? createdAt,
    // Bookmark fields (NEW - Phase 1 & 2)
    bool? isBookmarkedByCurrentUser,
    DateTime? bookmarkedAt,
  }) = _GeneratedImageModel;

  factory GeneratedImageModel.fromJson(Map<String, dynamic> json) =>
      _$GeneratedImageModelFromJson(json);
}

@freezed
class GenerateImageRequest with _$GenerateImageRequest {
  const factory GenerateImageRequest({
    required String generationType, // "SYSTEM" or "CUSTOM"
    String? templateId,
    String? customBackgroundUrl,
    @Default('ur') String languageCode,
    @Default(true) bool includePoetImage,
    @Default(true) bool includeWatermark,
    String? customTextColor,
    Map<String, dynamic>? customizations,
  }) = _GenerateImageRequest;

  factory GenerateImageRequest.fromJson(Map<String, dynamic> json) =>
      _$GenerateImageRequestFromJson(json);
}
