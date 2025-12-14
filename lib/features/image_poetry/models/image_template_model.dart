import 'package:freezed_annotation/freezed_annotation.dart';

part 'image_template_model.freezed.dart';
part 'image_template_model.g.dart';

@freezed
class ImageTemplateModel with _$ImageTemplateModel {
  const factory ImageTemplateModel({
    required String publicId,
    required String name,
    String? description,
    required String category, // NATURE, MINIMAL, ARTISTIC, TRADITIONAL
    required String backgroundImageUrl,
    String? thumbnailUrl,
    required Map<String, dynamic> layoutConfig,
    @Default(false) bool isPremium,
    @Default(true) bool isActive,
    @Default(0) int displayOrder,
    @Default(0) int usageCount,
    DateTime? createdAt,
  }) = _ImageTemplateModel;

  factory ImageTemplateModel.fromJson(Map<String, dynamic> json) =>
      _$ImageTemplateModelFromJson(json);
}
