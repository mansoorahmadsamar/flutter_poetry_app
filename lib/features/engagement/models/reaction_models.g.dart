// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reaction_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReactionTypeImpl _$$ReactionTypeImplFromJson(Map<String, dynamic> json) =>
    _$ReactionTypeImpl(
      key: json['key'] as String,
      emoji: json['emoji'] as String,
      urduLabel: json['urduLabel'] as String,
      englishLabel: json['englishLabel'] as String,
    );

Map<String, dynamic> _$$ReactionTypeImplToJson(_$ReactionTypeImpl instance) =>
    <String, dynamic>{
      'key': instance.key,
      'emoji': instance.emoji,
      'urduLabel': instance.urduLabel,
      'englishLabel': instance.englishLabel,
    };

_$ReactionSummaryImpl _$$ReactionSummaryImplFromJson(
        Map<String, dynamic> json) =>
    _$ReactionSummaryImpl(
      total: (json['total'] as num?)?.toInt() ?? 0,
      byType: (json['byType'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ),
      userReaction: json['userReaction'] as String?,
    );

Map<String, dynamic> _$$ReactionSummaryImplToJson(
        _$ReactionSummaryImpl instance) =>
    <String, dynamic>{
      'total': instance.total,
      'byType': instance.byType,
      'userReaction': instance.userReaction,
    };

_$ReactionResponseImpl _$$ReactionResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$ReactionResponseImpl(
      userReaction: json['userReaction'] as String?,
      totalReactionCount: (json['totalReactionCount'] as num?)?.toInt() ?? 0,
      reactionCounts: (json['reactionCounts'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ),
      message: json['message'] as String?,
    );

Map<String, dynamic> _$$ReactionResponseImplToJson(
        _$ReactionResponseImpl instance) =>
    <String, dynamic>{
      'userReaction': instance.userReaction,
      'totalReactionCount': instance.totalReactionCount,
      'reactionCounts': instance.reactionCounts,
      'message': instance.message,
    };
