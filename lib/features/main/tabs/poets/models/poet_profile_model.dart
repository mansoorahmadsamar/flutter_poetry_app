import 'package:freezed_annotation/freezed_annotation.dart';
import 'poet_image_model.dart';
import 'poet_book_model.dart';
import 'poet_video_model.dart';
import 'poet_tag_model.dart';

part 'poet_profile_model.freezed.dart';
part 'poet_profile_model.g.dart';

@freezed
class PoetProfileModel with _$PoetProfileModel {
  const factory PoetProfileModel({
    required String publicId,
    required String name,
    String? biography,
    @JsonKey(name: 'shortBio') required String shortBio,
    String? gender,
    String? era,
    required int birthYear,
    int? deathYear,
    @JsonKey(name: 'birthDate') String? birthDate,
    @JsonKey(name: 'deathDate') String? deathDate,
    @JsonKey(name: 'birthPlace') String? birthPlace,
    String? country,
    @JsonKey(name: 'countryFlag') String? countryFlag,
    @JsonKey(name: 'countryFlagUrl') String? countryFlagUrl,
    @JsonKey(name: 'primaryLanguageCode') String? primaryLanguageCode,
    @JsonKey(name: 'primaryLanguageName') String? primaryLanguageName,
    @JsonKey(name: 'isFeatured') required bool isFeatured,
    @JsonKey(name: 'isTrending') required bool isTrending,
    @JsonKey(name: 'isVerified') required bool isVerified,
    @JsonKey(name: 'viewCount') required int viewCount,
    @JsonKey(name: 'followerCount') required int followerCount,
    @JsonKey(name: 'poemCount') required int poemCount,
    @JsonKey(name: 'profileImageUrl') String? profileImageUrl,
    List<PoetImageModel>? gallery,
    List<PoetBookModel>? books,
    List<PoetVideoModel>? videos,
    List<String>? facts,
    List<PoetTagModel>? tags,
    @JsonKey(name: 'createdAt') String? createdAt,
    @JsonKey(name: 'updatedAt') String? updatedAt,
  }) = _PoetProfileModel;

  factory PoetProfileModel.fromJson(Map<String, dynamic> json) =>
      _$PoetProfileModelFromJson(json);
}
