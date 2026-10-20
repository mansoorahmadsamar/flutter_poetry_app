import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../../core/utils/api_placeholder.dart';

part 'poet_image_model.freezed.dart';
part 'poet_image_model.g.dart';

@freezed
class PoetImageModel with _$PoetImageModel {
  const factory PoetImageModel({
    required String publicId,
    @JsonKey(name: 'imageUrl') required String imageUrl,
    @JsonKey(name: 'thumbnailUrl') @PlaceholderStringConverter() String? thumbnailUrl,
    String? caption,
    @JsonKey(name: 'altText') @Default('') String altText,
    @JsonKey(name: 'displayOrder') @Default(0) int displayOrder,
    @JsonKey(name: 'isProfileImage') @Default(false) bool isProfileImage,
    @JsonKey(name: 'imageType') @Default('OTHER') String imageType,
  }) = _PoetImageModel;

  factory PoetImageModel.fromJson(Map<String, dynamic> json) =>
      _$PoetImageModelFromJson(json);
}
