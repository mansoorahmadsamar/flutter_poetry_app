// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'couplet_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CoupletModelImpl _$$CoupletModelImplFromJson(Map<String, dynamic> json) =>
    _$CoupletModelImpl(
      publicId: json['publicId'] as String,
      coupletNumber: (json['coupletNumber'] as num).toInt(),
      coupletType: json['coupletType'] as String,
      coupletTypeName: json['coupletTypeName'] as String?,
      verses: (json['verses'] as List<dynamic>)
          .map((e) => VerseModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
      bookmarkCount: (json['bookmarkCount'] as num?)?.toInt() ?? 0,
      shareCount: (json['shareCount'] as num?)?.toInt() ?? 0,
      isLikedByCurrentUser: json['isLiked'] as bool?,
      isBookmarkedByCurrentUser: json['isBookmarked'] as bool?,
      tagSlugs: (json['tagSlugs'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      reactions: json['reactions'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$CoupletModelImplToJson(_$CoupletModelImpl instance) =>
    <String, dynamic>{
      'publicId': instance.publicId,
      'coupletNumber': instance.coupletNumber,
      'coupletType': instance.coupletType,
      'coupletTypeName': instance.coupletTypeName,
      'verses': instance.verses,
      'likeCount': instance.likeCount,
      'bookmarkCount': instance.bookmarkCount,
      'shareCount': instance.shareCount,
      'isLiked': instance.isLikedByCurrentUser,
      'isBookmarked': instance.isBookmarkedByCurrentUser,
      'tagSlugs': instance.tagSlugs,
      'createdAt': instance.createdAt?.toIso8601String(),
      'reactions': instance.reactions,
    };

_$CoupletDetailResponseImpl _$$CoupletDetailResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$CoupletDetailResponseImpl(
      publicId: json['publicId'] as String,
      coupletNumber: (json['coupletNumber'] as num).toInt(),
      coupletType: json['coupletType'] as String,
      coupletTypeName: json['coupletTypeName'] as String?,
      verses: (json['verses'] as List<dynamic>)
          .map((e) => VerseModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      poemPublicId: json['poemPublicId'] as String,
      poemTitle: json['poemTitle'] as String?,
      totalCoupletsInPoem: (json['totalCoupletsInPoem'] as num?)?.toInt(),
      poetryType: json['poetryType'] as String?,
      poetPublicId: json['poetPublicId'] as String,
      poetName: json['poetName'] as String,
      poetProfileImageUrl: json['poetProfileImageUrl'] as String?,
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
      bookmarkCount: (json['bookmarkCount'] as num?)?.toInt() ?? 0,
      shareCount: (json['shareCount'] as num?)?.toInt() ?? 0,
      isLikedByCurrentUser: json['isLiked'] as bool?,
      isBookmarkedByCurrentUser: json['isBookmarked'] as bool?,
      tagSlugs: (json['tagSlugs'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      reactions: json['reactions'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$CoupletDetailResponseImplToJson(
        _$CoupletDetailResponseImpl instance) =>
    <String, dynamic>{
      'publicId': instance.publicId,
      'coupletNumber': instance.coupletNumber,
      'coupletType': instance.coupletType,
      'coupletTypeName': instance.coupletTypeName,
      'verses': instance.verses,
      'poemPublicId': instance.poemPublicId,
      'poemTitle': instance.poemTitle,
      'totalCoupletsInPoem': instance.totalCoupletsInPoem,
      'poetryType': instance.poetryType,
      'poetPublicId': instance.poetPublicId,
      'poetName': instance.poetName,
      'poetProfileImageUrl': instance.poetProfileImageUrl,
      'likeCount': instance.likeCount,
      'bookmarkCount': instance.bookmarkCount,
      'shareCount': instance.shareCount,
      'isLiked': instance.isLikedByCurrentUser,
      'isBookmarked': instance.isBookmarkedByCurrentUser,
      'tagSlugs': instance.tagSlugs,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'reactions': instance.reactions,
    };

_$BookmarkedCoupletResponseImpl _$$BookmarkedCoupletResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$BookmarkedCoupletResponseImpl(
      coupletPublicId: json['coupletPublicId'] as String,
      coupletNumber: (json['coupletNumber'] as num).toInt(),
      coupletType: json['coupletType'] as String,
      coupletTypeName: json['coupletTypeName'] as String?,
      verses: (json['verses'] as List<dynamic>)
          .map((e) => VerseModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      poemPublicId: json['poemPublicId'] as String,
      poemTitle: json['poemTitle'] as String?,
      poemExcerpt: json['poemExcerpt'] as String?,
      poetryType: json['poetryType'] as String?,
      totalCoupletsInPoem: (json['totalCoupletsInPoem'] as num?)?.toInt(),
      poetPublicId: json['poetPublicId'] as String,
      poetName: json['poetName'] as String,
      poetProfileImageUrl: json['poetProfileImageUrl'] as String?,
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
      bookmarkCount: (json['bookmarkCount'] as num?)?.toInt() ?? 0,
      isLikedByCurrentUser: json['isLiked'] as bool?,
      isBookmarkedByCurrentUser: json['isBookmarked'] as bool?,
      tagSlugs: (json['tagSlugs'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      bookmarkedAt: json['bookmarkedAt'] == null
          ? null
          : DateTime.parse(json['bookmarkedAt'] as String),
    );

Map<String, dynamic> _$$BookmarkedCoupletResponseImplToJson(
        _$BookmarkedCoupletResponseImpl instance) =>
    <String, dynamic>{
      'coupletPublicId': instance.coupletPublicId,
      'coupletNumber': instance.coupletNumber,
      'coupletType': instance.coupletType,
      'coupletTypeName': instance.coupletTypeName,
      'verses': instance.verses,
      'poemPublicId': instance.poemPublicId,
      'poemTitle': instance.poemTitle,
      'poemExcerpt': instance.poemExcerpt,
      'poetryType': instance.poetryType,
      'totalCoupletsInPoem': instance.totalCoupletsInPoem,
      'poetPublicId': instance.poetPublicId,
      'poetName': instance.poetName,
      'poetProfileImageUrl': instance.poetProfileImageUrl,
      'likeCount': instance.likeCount,
      'bookmarkCount': instance.bookmarkCount,
      'isLiked': instance.isLikedByCurrentUser,
      'isBookmarked': instance.isBookmarkedByCurrentUser,
      'tagSlugs': instance.tagSlugs,
      'bookmarkedAt': instance.bookmarkedAt?.toIso8601String(),
    };
