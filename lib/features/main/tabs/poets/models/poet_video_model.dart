import 'package:freezed_annotation/freezed_annotation.dart';

part 'poet_video_model.freezed.dart';
part 'poet_video_model.g.dart';

@freezed
class PoetVideoModel with _$PoetVideoModel {
  const factory PoetVideoModel({
    required String publicId,
    required String title,
    String? description,
    @JsonKey(name: 'videoUrl') required String videoUrl,
    @JsonKey(name: 'thumbnailUrl') String? thumbnailUrl,
    required int duration,
    @JsonKey(name: 'yearRecorded') int? yearRecorded,
    @JsonKey(name: 'videoType') required String videoType,
  }) = _PoetVideoModel;

  factory PoetVideoModel.fromJson(Map<String, dynamic> json) =>
      _$PoetVideoModelFromJson(json);
}
