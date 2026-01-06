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
    @Default(0) int deathYear,
    @JsonKey(name: 'profileImageUrl') String? profileImageUrl,
    String? gender, // MALE, FEMALE, OTHER
    String? era, // CLASSICAL, MODERN, CONTEMPORARY, EMERGING
    @Default(0) int poemCount,
    @Default(0) int viewCount,
    @JsonKey(name: 'isFeatured') @Default(false) bool isFeatured,
    @JsonKey(name: 'isTrending') @Default(false) bool isTrending,
    @JsonKey(name: 'birthPlace') String? birthPlace,
    String? country,
    @JsonKey(name: 'countryFlag') String? countryFlag,
    @JsonKey(name: 'countryFlagUrl') String? countryFlagUrl,
    @JsonKey(name: 'topTags') @Default([]) List<String> topTags,
    @JsonKey(name: 'isActive') @Default(true) bool isActive,  // Added from API response
  }) = _PoetModel;

  factory PoetModel.fromJson(Map<String, dynamic> json) =>
      _$PoetModelFromJson(json);
}
