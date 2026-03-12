import 'package:freezed_annotation/freezed_annotation.dart';

part 'hashtag_model.freezed.dart';
part 'hashtag_model.g.dart';

@freezed
class HashtagDto with _$HashtagDto {
  const factory HashtagDto({
    required String slug,
    String? name,
    String? color,
    String? languageCode,
    String? tagType,
    @Default(0) int coupletCount,
    @Default(0) int poemCount,
    @Default(0) int imageCount,
    @Default(0) int poetCount,
    @Default(0) int bookCount,
    @Default(0) int videoCount,
    @Default(0) int totalUsage,
  }) = _HashtagDto;

  factory HashtagDto.fromJson(Map<String, dynamic> json) =>
      _$HashtagDtoFromJson(json);
}
