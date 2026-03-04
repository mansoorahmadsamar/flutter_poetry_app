// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unified_bookmark_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TopPoetImpl _$$TopPoetImplFromJson(Map<String, dynamic> json) =>
    _$TopPoetImpl(
      poetId: json['poetId'] as String,
      poetName: json['poetName'] as String,
      bookmarkCount: (json['bookmarkCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$TopPoetImplToJson(_$TopPoetImpl instance) =>
    <String, dynamic>{
      'poetId': instance.poetId,
      'poetName': instance.poetName,
      'bookmarkCount': instance.bookmarkCount,
    };
