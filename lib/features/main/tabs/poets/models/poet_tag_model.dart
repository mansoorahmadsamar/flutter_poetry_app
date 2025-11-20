import 'package:freezed_annotation/freezed_annotation.dart';

part 'poet_tag_model.freezed.dart';
part 'poet_tag_model.g.dart';

@freezed
class PoetTagModel with _$PoetTagModel {
  const factory PoetTagModel({
    required String publicId,
    required String name,
    required String slug,
    String? color,
    @JsonKey(name: 'tagType') required String tagType,
    String? description,
  }) = _PoetTagModel;

  factory PoetTagModel.fromJson(Map<String, dynamic> json) =>
      _$PoetTagModelFromJson(json);
}
