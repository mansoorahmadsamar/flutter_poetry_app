import 'package:freezed_annotation/freezed_annotation.dart';

part 'poet_image_model.freezed.dart';
part 'poet_image_model.g.dart';

@freezed
class PoetImageModel with _$PoetImageModel {
  const factory PoetImageModel({
    required String publicId,
    @JsonKey(name: 'imageUrl') required String imageUrl,
    @JsonKey(name: 'thumbnailUrl') String? thumbnailUrl,
    String? caption,
    @JsonKey(name: 'altText') required String altText,
    @JsonKey(name: 'displayOrder') required int displayOrder,
    @JsonKey(name: 'isProfileImage') required bool isProfileImage,
    @JsonKey(name: 'imageType') required String imageType,
  }) = _PoetImageModel;

  factory PoetImageModel.fromJson(Map<String, dynamic> json) =>
      _$PoetImageModelFromJson(json);
}
