// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'poet_video_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PoetVideoModelImpl _$$PoetVideoModelImplFromJson(Map<String, dynamic> json) =>
    _$PoetVideoModelImpl(
      publicId: json['publicId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      videoUrl: json['videoUrl'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      duration: (json['duration'] as num).toInt(),
      yearRecorded: (json['yearRecorded'] as num?)?.toInt(),
      videoType: json['videoType'] as String,
    );

Map<String, dynamic> _$$PoetVideoModelImplToJson(
        _$PoetVideoModelImpl instance) =>
    <String, dynamic>{
      'publicId': instance.publicId,
      'title': instance.title,
      'description': instance.description,
      'videoUrl': instance.videoUrl,
      'thumbnailUrl': instance.thumbnailUrl,
      'duration': instance.duration,
      'yearRecorded': instance.yearRecorded,
      'videoType': instance.videoType,
    };
