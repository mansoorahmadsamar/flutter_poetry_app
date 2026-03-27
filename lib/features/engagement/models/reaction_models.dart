import 'package:freezed_annotation/freezed_annotation.dart';

part 'reaction_models.freezed.dart';
part 'reaction_models.g.dart';

/// A single reaction type from GET /api/reactions/types.
@freezed
class ReactionType with _$ReactionType {
  const factory ReactionType({
    required String key,
    required String emoji,
    required String urduLabel,
    required String englishLabel,
  }) = _ReactionType;

  factory ReactionType.fromJson(Map<String, dynamic> json) =>
      _$ReactionTypeFromJson(json);
}

/// Reaction breakdown embedded in content DTOs (poems, couplets, images).
@freezed
class ReactionSummary with _$ReactionSummary {
  const ReactionSummary._();

  const factory ReactionSummary({
    @Default(0) int total,
    Map<String, int>? byType,
    String? userReaction,
  }) = _ReactionSummary;

  factory ReactionSummary.fromJson(Map<String, dynamic> json) =>
      _$ReactionSummaryFromJson(json);

  bool get hasUserReacted => userReaction != null;
}

/// Response from POST /api/{type}/{id}/react and DELETE /api/{type}/{id}/react.
@freezed
class ReactionResponse with _$ReactionResponse {
  const factory ReactionResponse({
    String? userReaction,
    @Default(0) int totalReactionCount,
    Map<String, int>? reactionCounts,
    String? message,
  }) = _ReactionResponse;

  factory ReactionResponse.fromJson(Map<String, dynamic> json) =>
      _$ReactionResponseFromJson(json);
}
