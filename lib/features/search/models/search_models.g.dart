// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AutocompleteResponseImpl _$$AutocompleteResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$AutocompleteResponseImpl(
      poets: (json['poets'] as List<dynamic>?)
              ?.map((e) => AutocompletePoet.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      poems: (json['poems'] as List<dynamic>?)
              ?.map((e) => AutocompletePoem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => AutocompleteTag.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) =>
                  AutocompleteCategory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$AutocompleteResponseImplToJson(
        _$AutocompleteResponseImpl instance) =>
    <String, dynamic>{
      'poets': instance.poets,
      'poems': instance.poems,
      'tags': instance.tags,
      'categories': instance.categories,
      'totalCount': instance.totalCount,
    };

_$AutocompletePoetImpl _$$AutocompletePoetImplFromJson(
        Map<String, dynamic> json) =>
    _$AutocompletePoetImpl(
      publicId: json['publicId'] as String,
      name: json['name'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      era: json['era'] as String?,
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$$AutocompletePoetImplToJson(
        _$AutocompletePoetImpl instance) =>
    <String, dynamic>{
      'publicId': instance.publicId,
      'name': instance.name,
      'profileImageUrl': instance.profileImageUrl,
      'era': instance.era,
      'score': instance.score,
    };

_$AutocompletePoemImpl _$$AutocompletePoemImplFromJson(
        Map<String, dynamic> json) =>
    _$AutocompletePoemImpl(
      publicId: json['publicId'] as String,
      title: json['title'] as String,
      poetName: json['poetName'] as String,
      poetPublicId: json['poetPublicId'] as String,
      poetryType: json['poetryType'] as String,
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$$AutocompletePoemImplToJson(
        _$AutocompletePoemImpl instance) =>
    <String, dynamic>{
      'publicId': instance.publicId,
      'title': instance.title,
      'poetName': instance.poetName,
      'poetPublicId': instance.poetPublicId,
      'poetryType': instance.poetryType,
      'score': instance.score,
    };

_$AutocompleteTagImpl _$$AutocompleteTagImplFromJson(
        Map<String, dynamic> json) =>
    _$AutocompleteTagImpl(
      publicId: json['publicId'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      tagType: json['tagType'] as String,
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$$AutocompleteTagImplToJson(
        _$AutocompleteTagImpl instance) =>
    <String, dynamic>{
      'publicId': instance.publicId,
      'name': instance.name,
      'slug': instance.slug,
      'tagType': instance.tagType,
      'score': instance.score,
    };

_$AutocompleteCategoryImpl _$$AutocompleteCategoryImplFromJson(
        Map<String, dynamic> json) =>
    _$AutocompleteCategoryImpl(
      publicId: json['publicId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      iconUrl: json['iconUrl'] as String?,
      poemCount: (json['poemCount'] as num?)?.toInt() ?? 0,
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      parentCategoryPublicId: json['parentCategoryPublicId'] as String?,
      parentCategoryName: json['parentCategoryName'] as String?,
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$$AutocompleteCategoryImplToJson(
        _$AutocompleteCategoryImpl instance) =>
    <String, dynamic>{
      'publicId': instance.publicId,
      'name': instance.name,
      'description': instance.description,
      'iconUrl': instance.iconUrl,
      'poemCount': instance.poemCount,
      'displayOrder': instance.displayOrder,
      'isActive': instance.isActive,
      'parentCategoryPublicId': instance.parentCategoryPublicId,
      'parentCategoryName': instance.parentCategoryName,
      'score': instance.score,
    };

_$CoupletSearchResultImpl _$$CoupletSearchResultImplFromJson(
        Map<String, dynamic> json) =>
    _$CoupletSearchResultImpl(
      publicId: json['publicId'] as String,
      coupletNumber: (json['coupletNumber'] as num).toInt(),
      coupletType: json['coupletType'] as String?,
      coupletTypeName: json['coupletTypeName'] as String?,
      verses: (json['verses'] as List<dynamic>)
          .map((e) => VerseModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      poem: json['poem'] == null
          ? null
          : PoemSummary.fromJson(json['poem'] as Map<String, dynamic>),
      poet: json['poet'] == null
          ? null
          : PoetSummary.fromJson(json['poet'] as Map<String, dynamic>),
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
      shareCount: (json['shareCount'] as num?)?.toInt() ?? 0,
      bookmarkCount: (json['bookmarkCount'] as num?)?.toInt() ?? 0,
      engagementScore: (json['engagementScore'] as num?)?.toDouble() ?? 0.0,
      isLiked: json['isLiked'] as bool?,
      isBookmarked: json['isBookmarked'] as bool?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$CoupletSearchResultImplToJson(
        _$CoupletSearchResultImpl instance) =>
    <String, dynamic>{
      'publicId': instance.publicId,
      'coupletNumber': instance.coupletNumber,
      'coupletType': instance.coupletType,
      'coupletTypeName': instance.coupletTypeName,
      'verses': instance.verses,
      'poem': instance.poem,
      'poet': instance.poet,
      'likeCount': instance.likeCount,
      'shareCount': instance.shareCount,
      'bookmarkCount': instance.bookmarkCount,
      'engagementScore': instance.engagementScore,
      'isLiked': instance.isLiked,
      'isBookmarked': instance.isBookmarked,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

_$VerseSearchResultImpl _$$VerseSearchResultImplFromJson(
        Map<String, dynamic> json) =>
    _$VerseSearchResultImpl(
      verse: VerseModel.fromJson(json['verse'] as Map<String, dynamic>),
      poemPublicId: json['poemPublicId'] as String,
      poemTitle: json['poemTitle'] as String,
      poetryType: json['poetryType'] as String,
      poetryTypeName: json['poetryTypeName'] as String?,
      poetPublicId: json['poetPublicId'] as String,
      poetName: json['poetName'] as String,
      poetProfileImageUrl: json['poetProfileImageUrl'] as String?,
    );

Map<String, dynamic> _$$VerseSearchResultImplToJson(
        _$VerseSearchResultImpl instance) =>
    <String, dynamic>{
      'verse': instance.verse,
      'poemPublicId': instance.poemPublicId,
      'poemTitle': instance.poemTitle,
      'poetryType': instance.poetryType,
      'poetryTypeName': instance.poetryTypeName,
      'poetPublicId': instance.poetPublicId,
      'poetName': instance.poetName,
      'poetProfileImageUrl': instance.poetProfileImageUrl,
    };

_$PoemSummaryImpl _$$PoemSummaryImplFromJson(Map<String, dynamic> json) =>
    _$PoemSummaryImpl(
      publicId: json['publicId'] as String,
      title: json['title'] as String,
      poetName: json['poetName'] as String,
    );

Map<String, dynamic> _$$PoemSummaryImplToJson(_$PoemSummaryImpl instance) =>
    <String, dynamic>{
      'publicId': instance.publicId,
      'title': instance.title,
      'poetName': instance.poetName,
    };

_$PoetSummaryImpl _$$PoetSummaryImplFromJson(Map<String, dynamic> json) =>
    _$PoetSummaryImpl(
      publicId: json['publicId'] as String,
      name: json['name'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
    );

Map<String, dynamic> _$$PoetSummaryImplToJson(_$PoetSummaryImpl instance) =>
    <String, dynamic>{
      'publicId': instance.publicId,
      'name': instance.name,
      'profileImageUrl': instance.profileImageUrl,
    };

_$RecommendationResponseImpl _$$RecommendationResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$RecommendationResponseImpl(
      type: json['type'] as String,
      items: (json['items'] as List<dynamic>?)
              ?.map(
                  (e) => RecommendationItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
      message: json['message'] as String?,
      isPersonalized: json['isPersonalized'] as bool? ?? false,
      count: (json['count'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$RecommendationResponseImplToJson(
        _$RecommendationResponseImpl instance) =>
    <String, dynamic>{
      'type': instance.type,
      'items': instance.items,
      'totalCount': instance.totalCount,
      'message': instance.message,
      'isPersonalized': instance.isPersonalized,
      'count': instance.count,
    };

_$RecommendationItemImpl _$$RecommendationItemImplFromJson(
        Map<String, dynamic> json) =>
    _$RecommendationItemImpl(
      contentType: json['contentType'] as String,
      publicId: json['publicId'] as String,
      title: json['title'] as String,
      poetName: json['poetName'] as String?,
      poetPublicId: json['poetPublicId'] as String?,
      poetryType: json['poetryType'] as String?,
      categoryName: json['categoryName'] as String?,
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
      shareCount: (json['shareCount'] as num?)?.toInt() ?? 0,
      bookmarkCount: (json['bookmarkCount'] as num?)?.toInt() ?? 0,
      viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
      score: json['score'] == null
          ? 0.0
          : const NaNDoubleConverter().fromJson(json['score']),
      reason: json['reason'] as String?,
    );

Map<String, dynamic> _$$RecommendationItemImplToJson(
        _$RecommendationItemImpl instance) =>
    <String, dynamic>{
      'contentType': instance.contentType,
      'publicId': instance.publicId,
      'title': instance.title,
      'poetName': instance.poetName,
      'poetPublicId': instance.poetPublicId,
      'poetryType': instance.poetryType,
      'categoryName': instance.categoryName,
      'likeCount': instance.likeCount,
      'shareCount': instance.shareCount,
      'bookmarkCount': instance.bookmarkCount,
      'viewCount': instance.viewCount,
      'score': const NaNDoubleConverter().toJson(instance.score),
      'reason': instance.reason,
    };

_$UnifiedSearchResponseImpl _$$UnifiedSearchResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$UnifiedSearchResponseImpl(
      totalResults: (json['totalResults'] as num?)?.toInt() ?? 0,
      poetCount: (json['poetCount'] as num?)?.toInt() ?? 0,
      poemCount: (json['poemCount'] as num?)?.toInt() ?? 0,
      verseCount: (json['verseCount'] as num?)?.toInt() ?? 0,
      coupletCount: (json['coupletCount'] as num?)?.toInt() ?? 0,
      tagCount: (json['tagCount'] as num?)?.toInt() ?? 0,
      categoryCount: (json['categoryCount'] as num?)?.toInt() ?? 0,
      poets: (json['poets'] as List<dynamic>?)
              ?.map((e) => PoetModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      poems: (json['poems'] as List<dynamic>?)
              ?.map((e) => PoemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      verses: (json['verses'] as List<dynamic>?)
              ?.map(
                  (e) => VerseSearchResult.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      couplets: (json['couplets'] as List<dynamic>?)
              ?.map((e) =>
                  CoupletSearchResult.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => AutocompleteTag.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) =>
                  AutocompleteCategory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$UnifiedSearchResponseImplToJson(
        _$UnifiedSearchResponseImpl instance) =>
    <String, dynamic>{
      'totalResults': instance.totalResults,
      'poetCount': instance.poetCount,
      'poemCount': instance.poemCount,
      'verseCount': instance.verseCount,
      'coupletCount': instance.coupletCount,
      'tagCount': instance.tagCount,
      'categoryCount': instance.categoryCount,
      'poets': instance.poets,
      'poems': instance.poems,
      'verses': instance.verses,
      'couplets': instance.couplets,
      'tags': instance.tags,
      'categories': instance.categories,
    };

_$TrendingSearchImpl _$$TrendingSearchImplFromJson(Map<String, dynamic> json) =>
    _$TrendingSearchImpl(
      query: json['query'] as String,
      normalizedQuery: json['normalizedQuery'] as String,
      count: (json['count'] as num?)?.toInt() ?? 0,
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$$TrendingSearchImplToJson(
        _$TrendingSearchImpl instance) =>
    <String, dynamic>{
      'query': instance.query,
      'normalizedQuery': instance.normalizedQuery,
      'count': instance.count,
      'score': instance.score,
    };

_$RelatedSearchesResponseImpl _$$RelatedSearchesResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$RelatedSearchesResponseImpl(
      query: json['query'] as String,
      relatedSearches: (json['relatedSearches'] as List<dynamic>?)
              ?.map((e) => TrendingSearch.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
      timeWindow: json['timeWindow'] as String,
    );

Map<String, dynamic> _$$RelatedSearchesResponseImplToJson(
        _$RelatedSearchesResponseImpl instance) =>
    <String, dynamic>{
      'query': instance.query,
      'relatedSearches': instance.relatedSearches,
      'totalCount': instance.totalCount,
      'timeWindow': instance.timeWindow,
    };

_$TrendingSearchesResponseImpl _$$TrendingSearchesResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$TrendingSearchesResponseImpl(
      searches: (json['searches'] as List<dynamic>?)
              ?.map((e) => TrendingSearch.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
      timeframe: json['timeframe'] as String,
      period: json['period'] as String,
    );

Map<String, dynamic> _$$TrendingSearchesResponseImplToJson(
        _$TrendingSearchesResponseImpl instance) =>
    <String, dynamic>{
      'searches': instance.searches,
      'totalCount': instance.totalCount,
      'timeframe': instance.timeframe,
      'period': instance.period,
    };
