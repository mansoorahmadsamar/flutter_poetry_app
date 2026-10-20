// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hashtag_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HashtagDtoImpl _$$HashtagDtoImplFromJson(Map<String, dynamic> json) =>
    _$HashtagDtoImpl(
      slug: json['slug'] as String,
      name: json['name'] as String?,
      color: json['color'] as String?,
      languageCode: json['languageCode'] as String?,
      tagType: json['tagType'] as String?,
      coupletCount: (json['coupletCount'] as num?)?.toInt() ?? 0,
      poemCount: (json['poemCount'] as num?)?.toInt() ?? 0,
      imageCount: (json['imageCount'] as num?)?.toInt() ?? 0,
      poetCount: (json['poetCount'] as num?)?.toInt() ?? 0,
      bookCount: (json['bookCount'] as num?)?.toInt() ?? 0,
      videoCount: (json['videoCount'] as num?)?.toInt() ?? 0,
      totalUsage: (json['totalUsage'] as num?)?.toInt() ?? 0,
      nameUr: const PlaceholderStringConverter().fromJson(json['nameUr']),
      nameEn: const PlaceholderStringConverter().fromJson(json['nameEn']),
      nameHi: const PlaceholderStringConverter().fromJson(json['nameHi']),
      definition:
          const PlaceholderStringConverter().fromJson(json['definition']),
    );

Map<String, dynamic> _$$HashtagDtoImplToJson(_$HashtagDtoImpl instance) =>
    <String, dynamic>{
      'slug': instance.slug,
      'name': instance.name,
      'color': instance.color,
      'languageCode': instance.languageCode,
      'tagType': instance.tagType,
      'coupletCount': instance.coupletCount,
      'poemCount': instance.poemCount,
      'imageCount': instance.imageCount,
      'poetCount': instance.poetCount,
      'bookCount': instance.bookCount,
      'videoCount': instance.videoCount,
      'totalUsage': instance.totalUsage,
      'nameUr': const PlaceholderStringConverter().toJson(instance.nameUr),
      'nameEn': const PlaceholderStringConverter().toJson(instance.nameEn),
      'nameHi': const PlaceholderStringConverter().toJson(instance.nameHi),
      'definition':
          const PlaceholderStringConverter().toJson(instance.definition),
    };
