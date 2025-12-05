// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookmark_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BookmarkModelImpl _$$BookmarkModelImplFromJson(Map<String, dynamic> json) =>
    _$BookmarkModelImpl(
      publicId: json['publicId'] as String,
      userPublicId: json['userPublicId'] as String,
      contentType: json['contentType'] as String,
      contentId: json['contentId'] as String,
      contentTitle: json['contentTitle'] as String?,
      contentExcerpt: json['contentExcerpt'] as String?,
      contentImageUrl: json['contentImageUrl'] as String?,
      contentMetadata: json['contentMetadata'] as String?,
      isActive: json['isActive'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$BookmarkModelImplToJson(_$BookmarkModelImpl instance) =>
    <String, dynamic>{
      'publicId': instance.publicId,
      'userPublicId': instance.userPublicId,
      'contentType': instance.contentType,
      'contentId': instance.contentId,
      'contentTitle': instance.contentTitle,
      'contentExcerpt': instance.contentExcerpt,
      'contentImageUrl': instance.contentImageUrl,
      'contentMetadata': instance.contentMetadata,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
