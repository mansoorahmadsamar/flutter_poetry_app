// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discover_bundle_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DiscoverBundleImpl _$$DiscoverBundleImplFromJson(Map<String, dynamic> json) =>
    _$DiscoverBundleImpl(
      trendingSearches: TrendingSearches.fromJson(
          json['trendingSearches'] as Map<String, dynamic>),
      editorsPicks:
          ContentSection.fromJson(json['editorsPicks'] as Map<String, dynamic>),
      recommended:
          ContentSection.fromJson(json['recommended'] as Map<String, dynamic>),
      featuredPoets: ContentSection.fromJson(
          json['featuredPoets'] as Map<String, dynamic>),
      categories:
          ContentSection.fromJson(json['categories'] as Map<String, dynamic>),
      language: json['language'] as String,
      personalized: json['personalized'] as bool? ?? false,
      timestamp: (json['timestamp'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$DiscoverBundleImplToJson(
        _$DiscoverBundleImpl instance) =>
    <String, dynamic>{
      'trendingSearches': instance.trendingSearches,
      'editorsPicks': instance.editorsPicks,
      'recommended': instance.recommended,
      'featuredPoets': instance.featuredPoets,
      'categories': instance.categories,
      'language': instance.language,
      'personalized': instance.personalized,
      'timestamp': instance.timestamp,
    };

_$TrendingSearchesImpl _$$TrendingSearchesImplFromJson(
        Map<String, dynamic> json) =>
    _$TrendingSearchesImpl(
      daily: (json['daily'] as List<dynamic>?)
              ?.map((e) => TrendingQuery.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      weekly: (json['weekly'] as List<dynamic>?)
              ?.map((e) => TrendingQuery.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$TrendingSearchesImplToJson(
        _$TrendingSearchesImpl instance) =>
    <String, dynamic>{
      'daily': instance.daily,
      'weekly': instance.weekly,
    };

_$TrendingQueryImpl _$$TrendingQueryImplFromJson(Map<String, dynamic> json) =>
    _$TrendingQueryImpl(
      query: json['query'] as String,
      searchCount: (json['searchCount'] as num?)?.toInt() ?? 0,
      rank: (json['rank'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$TrendingQueryImplToJson(_$TrendingQueryImpl instance) =>
    <String, dynamic>{
      'query': instance.query,
      'searchCount': instance.searchCount,
      'rank': instance.rank,
    };

_$ContentSectionImpl _$$ContentSectionImplFromJson(Map<String, dynamic> json) =>
    _$ContentSectionImpl(
      sectionTitle: json['sectionTitle'] as String?,
      sectionKey: json['sectionKey'] as String?,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => ContentCard.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$ContentSectionImplToJson(
        _$ContentSectionImpl instance) =>
    <String, dynamic>{
      'sectionTitle': instance.sectionTitle,
      'sectionKey': instance.sectionKey,
      'items': instance.items,
      'totalCount': instance.totalCount,
    };

_$ContentCardImpl _$$ContentCardImplFromJson(Map<String, dynamic> json) =>
    _$ContentCardImpl(
      type: json['type'] as String,
      publicId: json['publicId'] as String,
      primaryText: json['primaryText'] as String,
      secondaryText: json['secondaryText'] as String?,
      badge: json['badge'] as String?,
      badgeKey: json['badgeKey'] as String?,
      metrics: json['metrics'] == null
          ? null
          : ContentMetrics.fromJson(json['metrics'] as Map<String, dynamic>),
      language: json['language'] as String? ?? 'ur',
      direction: json['direction'] as String? ?? 'rtl',
      score: (json['score'] as num?)?.toDouble(),
      imageUrl: json['imageUrl'] as String?,
    );

Map<String, dynamic> _$$ContentCardImplToJson(_$ContentCardImpl instance) =>
    <String, dynamic>{
      'type': instance.type,
      'publicId': instance.publicId,
      'primaryText': instance.primaryText,
      'secondaryText': instance.secondaryText,
      'badge': instance.badge,
      'badgeKey': instance.badgeKey,
      'metrics': instance.metrics,
      'language': instance.language,
      'direction': instance.direction,
      'score': instance.score,
      'imageUrl': instance.imageUrl,
    };

_$ContentMetricsImpl _$$ContentMetricsImplFromJson(Map<String, dynamic> json) =>
    _$ContentMetricsImpl(
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
      shareCount: (json['shareCount'] as num?)?.toInt() ?? 0,
      bookmarkCount: (json['bookmarkCount'] as num?)?.toInt() ?? 0,
      viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$ContentMetricsImplToJson(
        _$ContentMetricsImpl instance) =>
    <String, dynamic>{
      'likeCount': instance.likeCount,
      'shareCount': instance.shareCount,
      'bookmarkCount': instance.bookmarkCount,
      'viewCount': instance.viewCount,
    };
