// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_content_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppContentModelImpl _$$AppContentModelImplFromJson(
        Map<String, dynamic> json) =>
    _$AppContentModelImpl(
      publicId: json['publicId'] as String,
      contentKey: json['contentKey'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      languageCode: json['languageCode'] as String,
      displayOrder: (json['displayOrder'] as num?)?.toInt(),
      updatedAt: json['updatedAt'] as String?,
    );

Map<String, dynamic> _$$AppContentModelImplToJson(
        _$AppContentModelImpl instance) =>
    <String, dynamic>{
      'publicId': instance.publicId,
      'contentKey': instance.contentKey,
      'title': instance.title,
      'content': instance.content,
      'languageCode': instance.languageCode,
      'displayOrder': instance.displayOrder,
      'updatedAt': instance.updatedAt,
    };
