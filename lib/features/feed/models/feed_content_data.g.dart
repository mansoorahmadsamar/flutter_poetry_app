// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_content_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CoupletContentDataImpl _$$CoupletContentDataImplFromJson(
        Map<String, dynamic> json) =>
    _$CoupletContentDataImpl(
      versesTextArabic: json['versesTextArabic'] as String?,
      versesTextRoman: json['versesTextRoman'] as String?,
      poetPublicId: json['poetPublicId'] as String?,
      poetProfileImageUrl: json['poetProfileImageUrl'] as String?,
      poetBirthYear: (json['poetBirthYear'] as num?)?.toInt(),
      poetDeathYear: (json['poetDeathYear'] as num?)?.toInt(),
      poetName: json['poetName'] as String?,
      poemPublicId: json['poemPublicId'] as String?,
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
      shareCount: (json['shareCount'] as num?)?.toInt() ?? 0,
      bookmarkCount: (json['bookmarkCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$CoupletContentDataImplToJson(
        _$CoupletContentDataImpl instance) =>
    <String, dynamic>{
      'versesTextArabic': instance.versesTextArabic,
      'versesTextRoman': instance.versesTextRoman,
      'poetPublicId': instance.poetPublicId,
      'poetProfileImageUrl': instance.poetProfileImageUrl,
      'poetBirthYear': instance.poetBirthYear,
      'poetDeathYear': instance.poetDeathYear,
      'poetName': instance.poetName,
      'poemPublicId': instance.poemPublicId,
      'likeCount': instance.likeCount,
      'shareCount': instance.shareCount,
      'bookmarkCount': instance.bookmarkCount,
    };

_$PoemContentDataImpl _$$PoemContentDataImplFromJson(
        Map<String, dynamic> json) =>
    _$PoemContentDataImpl(
      title: json['title'] as String?,
      excerpt: json['excerpt'] as String?,
      poetPublicId: json['poetPublicId'] as String?,
      poetProfileImageUrl: json['poetProfileImageUrl'] as String?,
      poetBirthYear: (json['poetBirthYear'] as num?)?.toInt(),
      poetDeathYear: (json['poetDeathYear'] as num?)?.toInt(),
      poetName: json['poetName'] as String?,
      poetryType: json['poetryType'] as String?,
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
      viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
      thumbnailUrl: json['thumbnailUrl'] as String?,
    );

Map<String, dynamic> _$$PoemContentDataImplToJson(
        _$PoemContentDataImpl instance) =>
    <String, dynamic>{
      'title': instance.title,
      'excerpt': instance.excerpt,
      'poetPublicId': instance.poetPublicId,
      'poetProfileImageUrl': instance.poetProfileImageUrl,
      'poetBirthYear': instance.poetBirthYear,
      'poetDeathYear': instance.poetDeathYear,
      'poetName': instance.poetName,
      'poetryType': instance.poetryType,
      'likeCount': instance.likeCount,
      'viewCount': instance.viewCount,
      'thumbnailUrl': instance.thumbnailUrl,
    };

_$FeaturedCoupletImpl _$$FeaturedCoupletImplFromJson(
        Map<String, dynamic> json) =>
    _$FeaturedCoupletImpl(
      coupletPublicId: json['coupletPublicId'] as String?,
      verses: (json['verses'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
      script: json['script'] as String? ?? 'ARABIC',
    );

Map<String, dynamic> _$$FeaturedCoupletImplToJson(
        _$FeaturedCoupletImpl instance) =>
    <String, dynamic>{
      'coupletPublicId': instance.coupletPublicId,
      'verses': instance.verses,
      'likeCount': instance.likeCount,
      'script': instance.script,
    };

_$PoetSpotlightContentDataImpl _$$PoetSpotlightContentDataImplFromJson(
        Map<String, dynamic> json) =>
    _$PoetSpotlightContentDataImpl(
      poetName: json['poetName'] as String?,
      bio: json['bio'] as String?,
      poetPublicId: json['poetPublicId'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      birthYear: (json['birthYear'] as num?)?.toInt(),
      deathYear: (json['deathYear'] as num?)?.toInt(),
      poemCount: (json['poemCount'] as num?)?.toInt() ?? 0,
      followerCount: (json['followerCount'] as num?)?.toInt() ?? 0,
      viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
      featuredCouplet: json['featuredCouplet'] == null
          ? null
          : FeaturedCouplet.fromJson(
              json['featuredCouplet'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$PoetSpotlightContentDataImplToJson(
        _$PoetSpotlightContentDataImpl instance) =>
    <String, dynamic>{
      'poetName': instance.poetName,
      'bio': instance.bio,
      'poetPublicId': instance.poetPublicId,
      'profileImageUrl': instance.profileImageUrl,
      'birthYear': instance.birthYear,
      'deathYear': instance.deathYear,
      'poemCount': instance.poemCount,
      'followerCount': instance.followerCount,
      'viewCount': instance.viewCount,
      'featuredCouplet': instance.featuredCouplet,
    };

_$PoetImageContentDataImpl _$$PoetImageContentDataImplFromJson(
        Map<String, dynamic> json) =>
    _$PoetImageContentDataImpl(
      imageUrl: json['imageUrl'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      contentText: json['contentText'] as String?,
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
      shareCount: (json['shareCount'] as num?)?.toInt() ?? 0,
      bookmarkCount: (json['bookmarkCount'] as num?)?.toInt() ?? 0,
      poetPublicId: json['poetPublicId'] as String?,
      poetName: json['poetName'] as String?,
      poetProfileImageUrl: json['poetProfileImageUrl'] as String?,
      poetBirthYear: (json['poetBirthYear'] as num?)?.toInt(),
      poetDeathYear: (json['poetDeathYear'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$PoetImageContentDataImplToJson(
        _$PoetImageContentDataImpl instance) =>
    <String, dynamic>{
      'imageUrl': instance.imageUrl,
      'thumbnailUrl': instance.thumbnailUrl,
      'contentText': instance.contentText,
      'likeCount': instance.likeCount,
      'shareCount': instance.shareCount,
      'bookmarkCount': instance.bookmarkCount,
      'poetPublicId': instance.poetPublicId,
      'poetName': instance.poetName,
      'poetProfileImageUrl': instance.poetProfileImageUrl,
      'poetBirthYear': instance.poetBirthYear,
      'poetDeathYear': instance.poetDeathYear,
    };
