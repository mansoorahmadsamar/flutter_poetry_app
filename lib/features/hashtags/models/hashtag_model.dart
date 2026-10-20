import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/utils/api_placeholder.dart';
import '../utils/localized_name.dart';

part 'hashtag_model.freezed.dart';
part 'hashtag_model.g.dart';

@freezed
class HashtagDto with _$HashtagDto {
  const HashtagDto._();

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
    // Theme tags (couplet themes) may carry localized names and a one-line
    // definition. Production sends none of these yet; `"-"` reads as absent.
    @PlaceholderStringConverter() String? nameUr,
    @PlaceholderStringConverter() String? nameEn,
    @PlaceholderStringConverter() String? nameHi,
    @PlaceholderStringConverter() String? definition,
  }) = _HashtagDto;

  factory HashtagDto.fromJson(Map<String, dynamic> json) =>
      _$HashtagDtoFromJson(json);

  /// The localized name for app language [appLanguage] (fallback Urdu, then
  /// English), or null when the tag has no localized name.
  LocalizedLabel? localizedName(String appLanguage) =>
      pickLocalizedName(appLanguage, ur: nameUr, en: nameEn, hi: nameHi);

  /// What the hashtag page shows as its name: the localized name, else
  /// [name], else the slug (the behaviour before localized names).
  String displayName(String appLanguage) =>
      localizedName(appLanguage)?.text ?? presentOrNull(name) ?? slug;
}
