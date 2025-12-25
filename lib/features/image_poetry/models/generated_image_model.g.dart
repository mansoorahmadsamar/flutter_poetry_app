// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'generated_image_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GeneratedImageModelImpl _$$GeneratedImageModelImplFromJson(
        Map<String, dynamic> json) =>
    _$GeneratedImageModelImpl(
      publicId: json['publicId'] as String,
      coupletIds: (json['coupletIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      poemPublicId: json['poemPublicId'] as String?,
      poetPublicId: json['poetPublicId'] as String?,
      poetName: json['poetName'] as String?,
      languageCode: json['languageCode'] as String,
      templateId: json['templateId'] as String?,
      templateName: json['templateName'] as String?,
      isCustom: json['isCustom'] as bool? ?? false,
      imageUrl: json['imageUrl'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      width: (json['width'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
      fileSizeBytes: (json['fileSizeBytes'] as num?)?.toInt(),
      format: json['format'] as String? ?? 'PNG',
      shareCount: (json['shareCount'] as num?)?.toInt() ?? 0,
      viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
      userId: (json['userId'] as num?)?.toInt(),
      isUserCreated: json['isUserCreated'] as bool? ?? false,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$GeneratedImageModelImplToJson(
        _$GeneratedImageModelImpl instance) =>
    <String, dynamic>{
      'publicId': instance.publicId,
      'coupletIds': instance.coupletIds,
      'poemPublicId': instance.poemPublicId,
      'poetPublicId': instance.poetPublicId,
      'poetName': instance.poetName,
      'languageCode': instance.languageCode,
      'templateId': instance.templateId,
      'templateName': instance.templateName,
      'isCustom': instance.isCustom,
      'imageUrl': instance.imageUrl,
      'thumbnailUrl': instance.thumbnailUrl,
      'width': instance.width,
      'height': instance.height,
      'fileSizeBytes': instance.fileSizeBytes,
      'format': instance.format,
      'shareCount': instance.shareCount,
      'viewCount': instance.viewCount,
      'userId': instance.userId,
      'isUserCreated': instance.isUserCreated,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

_$GenerateImageRequestImpl _$$GenerateImageRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$GenerateImageRequestImpl(
      generationType: json['generationType'] as String,
      templateId: json['templateId'] as String?,
      customBackgroundUrl: json['customBackgroundUrl'] as String?,
      languageCode: json['languageCode'] as String? ?? 'ur',
      includePoetImage: json['includePoetImage'] as bool? ?? true,
      includeWatermark: json['includeWatermark'] as bool? ?? true,
      customTextColor: json['customTextColor'] as String?,
      customizations: json['customizations'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$GenerateImageRequestImplToJson(
        _$GenerateImageRequestImpl instance) =>
    <String, dynamic>{
      'generationType': instance.generationType,
      'templateId': instance.templateId,
      'customBackgroundUrl': instance.customBackgroundUrl,
      'languageCode': instance.languageCode,
      'includePoetImage': instance.includePoetImage,
      'includeWatermark': instance.includeWatermark,
      'customTextColor': instance.customTextColor,
      'customizations': instance.customizations,
    };
