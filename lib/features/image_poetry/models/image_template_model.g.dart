// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_template_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ImageTemplateModelImpl _$$ImageTemplateModelImplFromJson(
        Map<String, dynamic> json) =>
    _$ImageTemplateModelImpl(
      publicId: json['publicId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      category: json['category'] as String,
      backgroundImageUrl: json['backgroundImageUrl'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      layoutConfig: json['layoutConfig'] as Map<String, dynamic>,
      isPremium: json['isPremium'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
      usageCount: (json['usageCount'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$ImageTemplateModelImplToJson(
        _$ImageTemplateModelImpl instance) =>
    <String, dynamic>{
      'publicId': instance.publicId,
      'name': instance.name,
      'description': instance.description,
      'category': instance.category,
      'backgroundImageUrl': instance.backgroundImageUrl,
      'thumbnailUrl': instance.thumbnailUrl,
      'layoutConfig': instance.layoutConfig,
      'isPremium': instance.isPremium,
      'isActive': instance.isActive,
      'displayOrder': instance.displayOrder,
      'usageCount': instance.usageCount,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
