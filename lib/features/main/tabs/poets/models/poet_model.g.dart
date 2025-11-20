// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'poet_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PoetModelImpl _$$PoetModelImplFromJson(Map<String, dynamic> json) =>
    _$PoetModelImpl(
      publicId: json['publicId'] as String,
      name: json['name'] as String,
      shortBio: json['shortBio'] as String,
      birthYear: (json['birthYear'] as num).toInt(),
      deathYear: (json['deathYear'] as num?)?.toInt(),
      profileImageUrl: json['profileImageUrl'] as String,
      gender: json['gender'] as String,
      era: json['era'] as String,
      poemCount: (json['poemCount'] as num).toInt(),
      viewCount: (json['viewCount'] as num).toInt(),
      isFeatured: json['isFeatured'] as bool,
      isTrending: json['isTrending'] as bool,
      topTags:
          (json['topTags'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$$PoetModelImplToJson(_$PoetModelImpl instance) =>
    <String, dynamic>{
      'publicId': instance.publicId,
      'name': instance.name,
      'shortBio': instance.shortBio,
      'birthYear': instance.birthYear,
      'deathYear': instance.deathYear,
      'profileImageUrl': instance.profileImageUrl,
      'gender': instance.gender,
      'era': instance.era,
      'poemCount': instance.poemCount,
      'viewCount': instance.viewCount,
      'isFeatured': instance.isFeatured,
      'isTrending': instance.isTrending,
      'topTags': instance.topTags,
    };
