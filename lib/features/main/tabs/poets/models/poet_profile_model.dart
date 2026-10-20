import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../../core/utils/api_placeholder.dart';
import 'poet_image_model.dart';
import 'poet_book_model.dart';
import 'poet_video_model.dart';
import 'poet_tag_model.dart';

part 'poet_profile_model.freezed.dart';
part 'poet_profile_model.g.dart';

/// `GET /api/poets/{id}/profile` (`PoetProfileResponse`). Optional text
/// fields read `"-"` as absent, and the `is*` flags (nullable `Boolean` columns)
/// default to false (T-181).
@freezed
class PoetProfileModel with _$PoetProfileModel {
  const factory PoetProfileModel({
    required String publicId,
    required String name,
    @PlaceholderStringConverter() String? biography,
    @JsonKey(name: 'shortBio') @PlaceholderStringConverter() String? shortBio,
    @PlaceholderStringConverter() String? gender,
    @PlaceholderStringConverter() String? era,
    required int birthYear,
    int? deathYear,
    @JsonKey(name: 'birthDate') String? birthDate,
    @JsonKey(name: 'deathDate') String? deathDate,
    @JsonKey(name: 'birthPlace') @PlaceholderStringConverter() String? birthPlace,
    @PlaceholderStringConverter() String? country,
    @JsonKey(name: 'countryFlag') @PlaceholderStringConverter() String? countryFlag,
    @JsonKey(name: 'countryFlagUrl') @PlaceholderStringConverter() String? countryFlagUrl,
    @JsonKey(name: 'primaryLanguageCode') @PlaceholderStringConverter() String? primaryLanguageCode,
    @JsonKey(name: 'primaryLanguageName') @PlaceholderStringConverter() String? primaryLanguageName,
    @JsonKey(name: 'isFeatured') @Default(false) bool isFeatured,
    @JsonKey(name: 'isTrending') @Default(false) bool isTrending,
    @JsonKey(name: 'isVerified') @Default(false) bool isVerified,
    @JsonKey(name: 'viewCount') required int viewCount,
    @JsonKey(name: 'followerCount') required int followerCount,
    @JsonKey(name: 'poemCount') required int poemCount,
    @JsonKey(name: 'profileImageUrl') @PlaceholderStringConverter() String? profileImageUrl,
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
