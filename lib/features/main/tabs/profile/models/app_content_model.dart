import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_content_model.freezed.dart';
part 'app_content_model.g.dart';

@freezed
class AppContentModel with _$AppContentModel {
  const factory AppContentModel({
    required String publicId,
    required String contentKey,
    required String title,
    required String content,
    required String languageCode,
    int? displayOrder,
    String? updatedAt,
  }) = _AppContentModel;

  factory AppContentModel.fromJson(Map<String, dynamic> json) =>
      _$AppContentModelFromJson(json);
}
