import 'package:freezed_annotation/freezed_annotation.dart';

part 'bookmark_model.freezed.dart';
part 'bookmark_model.g.dart';

@freezed
class BookmarkModel with _$BookmarkModel {
  const factory BookmarkModel({
    required String publicId,
    required String userPublicId,
    required String contentType,
    required String contentId,
    String? contentTitle,
    String? contentExcerpt,
    String? contentImageUrl,
    String? contentMetadata,
    @Default(false) bool isActive,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _BookmarkModel;

  factory BookmarkModel.fromJson(Map<String, dynamic> json) =>
      _$BookmarkModelFromJson(json);
}
