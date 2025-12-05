// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'like_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LikeModelImpl _$$LikeModelImplFromJson(Map<String, dynamic> json) =>
    _$LikeModelImpl(
      publicId: json['publicId'] as String,
      userPublicId: json['userPublicId'] as String,
      contentType: json['contentType'] as String,
      contentId: json['contentId'] as String,
      isActive: json['isActive'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$LikeModelImplToJson(_$LikeModelImpl instance) =>
    <String, dynamic>{
      'publicId': instance.publicId,
      'userPublicId': instance.userPublicId,
      'contentType': instance.contentType,
      'contentId': instance.contentId,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
    };
