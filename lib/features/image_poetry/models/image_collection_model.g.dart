// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_collection_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SaveImageRequestImpl _$$SaveImageRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$SaveImageRequestImpl(
      collectionName: json['collectionName'] as String? ?? 'My Images',
      isFavorite: json['isFavorite'] as bool? ?? false,
    );

Map<String, dynamic> _$$SaveImageRequestImplToJson(
        _$SaveImageRequestImpl instance) =>
    <String, dynamic>{
      'collectionName': instance.collectionName,
      'isFavorite': instance.isFavorite,
    };

_$CollectionStatsModelImpl _$$CollectionStatsModelImplFromJson(
        Map<String, dynamic> json) =>
    _$CollectionStatsModelImpl(
      totalImages: (json['totalImages'] as num?)?.toInt() ?? 0,
      favoriteCount: (json['favoriteCount'] as num?)?.toInt() ?? 0,
      collectionCount: (json['collectionCount'] as num?)?.toInt() ?? 0,
      collectionNames: (json['collectionNames'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$CollectionStatsModelImplToJson(
        _$CollectionStatsModelImpl instance) =>
    <String, dynamic>{
      'totalImages': instance.totalImages,
      'favoriteCount': instance.favoriteCount,
      'collectionCount': instance.collectionCount,
      'collectionNames': instance.collectionNames,
    };
