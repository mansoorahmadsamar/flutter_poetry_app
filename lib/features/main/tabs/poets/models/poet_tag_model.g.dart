// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'poet_tag_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PoetTagModelImpl _$$PoetTagModelImplFromJson(Map<String, dynamic> json) =>
    _$PoetTagModelImpl(
      publicId: json['publicId'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      color: json['color'] as String?,
      tagType: json['tagType'] as String,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$$PoetTagModelImplToJson(_$PoetTagModelImpl instance) =>
    <String, dynamic>{
      'publicId': instance.publicId,
      'name': instance.name,
      'slug': instance.slug,
      'color': instance.color,
      'tagType': instance.tagType,
      'description': instance.description,
    };
