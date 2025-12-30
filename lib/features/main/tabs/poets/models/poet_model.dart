import 'package:freezed_annotation/freezed_annotation.dart';

part 'poet_model.freezed.dart';
part 'poet_model.g.dart';

@freezed
class PoetModel with _$PoetModel {
  const factory PoetModel({
    required String publicId,
    required String name,
    @JsonKey(name: 'shortBio') required String shortBio,
    required int birthYear,
    int? deathYear,
    @JsonKey(name: 'profileImageUrl') String? profileImageUrl,
    String? gender, // MALE, FEMALE, OTHER
    String? era, // CLASSICAL, MODERN, CONTEMPORARY, EMERGING
    required int poemCount,
    required int viewCount,
    @JsonKey(name: 'isFeatured') required bool isFeatured,
    @JsonKey(name: 'isTrending') required bool isTrending,
    @JsonKey(name: 'birthPlace') String? birthPlace,
    String? country,
    @JsonKey(name: 'countryFlag') String? countryFlag,
    @JsonKey(name: 'countryFlagUrl') String? countryFlagUrl,
    @JsonKey(name: 'topTags') List<String>? topTags,
  }) = _PoetModel;

  factory PoetModel.fromJson(Map<String, dynamic> json) =>
      _$PoetModelFromJson(json);
}
