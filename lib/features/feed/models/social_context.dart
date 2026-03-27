import 'package:freezed_annotation/freezed_annotation.dart';

part 'social_context.freezed.dart';

@Freezed(toJson: false)
class SocialContext with _$SocialContext {
  const factory SocialContext({
    List<String>? reactedByNames,
    int? totalReactions,
    String? trendingLabel,
    String? velocityLabel,
    String? activityLabel,
  }) = _SocialContext;

  factory SocialContext.fromJson(Map<String, dynamic> json) {
    return SocialContext(
      reactedByNames: (json['reactedByNames'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      totalReactions: json['totalReactions'] as int?,
      trendingLabel: json['trendingLabel'] as String?,
      velocityLabel: json['velocityLabel'] as String?,
      activityLabel: json['activityLabel'] as String?,
    );
  }
}
