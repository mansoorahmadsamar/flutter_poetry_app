// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unified_bookmark_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BookmarkStatsImpl _$$BookmarkStatsImplFromJson(Map<String, dynamic> json) =>
    _$BookmarkStatsImpl(
      totalBookmarks: (json['totalBookmarks'] as num?)?.toInt() ?? 0,
      poemCount: (json['poemCount'] as num?)?.toInt() ?? 0,
      coupletCount: (json['coupletCount'] as num?)?.toInt() ?? 0,
      imageCount: (json['imageCount'] as num?)?.toInt() ?? 0,
      urduCount: (json['urduCount'] as num?)?.toInt() ?? 0,
      englishCount: (json['englishCount'] as num?)?.toInt() ?? 0,
      hindiCount: (json['hindiCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$BookmarkStatsImplToJson(_$BookmarkStatsImpl instance) =>
    <String, dynamic>{
      'totalBookmarks': instance.totalBookmarks,
      'poemCount': instance.poemCount,
      'coupletCount': instance.coupletCount,
      'imageCount': instance.imageCount,
      'urduCount': instance.urduCount,
      'englishCount': instance.englishCount,
      'hindiCount': instance.hindiCount,
    };
