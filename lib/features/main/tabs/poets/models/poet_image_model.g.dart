// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'poet_image_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PoetImageModelImpl _$$PoetImageModelImplFromJson(Map<String, dynamic> json) =>
    _$PoetImageModelImpl(
      publicId: json['publicId'] as String,
      imageUrl: json['imageUrl'] as String,
      thumbnailUrl:
          const PlaceholderStringConverter().fromJson(json['thumbnailUrl']),
      caption: json['caption'] as String?,
      altText: json['altText'] as String? ?? '',
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
      isProfileImage: json['isProfileImage'] as bool? ?? false,
      imageType: json['imageType'] as String? ?? 'OTHER',
    );

Map<String, dynamic> _$$PoetImageModelImplToJson(
        _$PoetImageModelImpl instance) =>
    <String, dynamic>{
      'publicId': instance.publicId,
      'imageUrl': instance.imageUrl,
      'thumbnailUrl':
          const PlaceholderStringConverter().toJson(instance.thumbnailUrl),
      'caption': instance.caption,
      'altText': instance.altText,
      'displayOrder': instance.displayOrder,
      'isProfileImage': instance.isProfileImage,
      'imageType': instance.imageType,
    };
