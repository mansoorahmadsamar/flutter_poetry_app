// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'poem_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PoetSummaryModelImpl _$$PoetSummaryModelImplFromJson(
        Map<String, dynamic> json) =>
    _$PoetSummaryModelImpl(
      publicId: json['publicId'] as String,
      name: json['name'] as String,
      shortBio: json['shortBio'] as String?,
      birthYear: (json['birthYear'] as num?)?.toInt(),
      deathYear: (json['deathYear'] as num?)?.toInt(),
      profileImageUrl: json['profileImageUrl'] as String?,
      gender: json['gender'] as String?,
      era: json['era'] as String?,
      poemCount: (json['poemCount'] as num?)?.toInt(),
      viewCount: (json['viewCount'] as num?)?.toInt(),
      isFeatured: json['isFeatured'] as bool?,
      isTrending: json['isTrending'] as bool?,
      birthPlace: json['birthPlace'] as String?,
      country: json['country'] as String?,
      countryFlag: json['countryFlag'] as String?,
      countryFlagUrl: json['countryFlagUrl'] as String?,
      isActive: json['isActive'] as bool?,
      topTags: (json['topTags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      tagSlugs: (json['tagSlugs'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$PoetSummaryModelImplToJson(
        _$PoetSummaryModelImpl instance) =>
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
      'birthPlace': instance.birthPlace,
      'country': instance.country,
      'countryFlag': instance.countryFlag,
      'countryFlagUrl': instance.countryFlagUrl,
      'isActive': instance.isActive,
      'topTags': instance.topTags,
      'tagSlugs': instance.tagSlugs,
    };

_$PoemModelImpl _$$PoemModelImplFromJson(Map<String, dynamic> json) =>
    _$PoemModelImpl(
      publicId: json['publicId'] as String,
      poetPublicId: json['poetPublicId'] as String,
      poetName: json['poetName'] as String,
      poetProfileImageUrl: json['poetProfileImageUrl'] as String?,
      categoryPublicId: json['categoryPublicId'] as String?,
      categoryName: json['categoryName'] as String?,
      poetryType: json['poetryType'] as String,
      poetryTypeName: json['poetryTypeName'] as String?,
      poetryTypeUrduName: json['poetryTypeUrduName'] as String?,
      poetryTypeEnglishName: json['poetryTypeEnglishName'] as String?,
      contentType: json['contentType'] as String,
      requiresStructuredParsing: json['requiresStructuredParsing'] as bool?,
      imageUrl: json['imageUrl'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      yearWritten: (json['yearWritten'] as num?)?.toInt(),
      source: json['source'] as String?,
      license: json['license'] as String?,
      uploadedByUsername: json['uploadedByUsername'] as String?,
      isPublic: json['isPublic'] as bool? ?? true,
      isFeatured: json['isFeatured'] as bool? ?? false,
      viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
      shareCount: (json['shareCount'] as num?)?.toInt() ?? 0,
      isLikedByCurrentUser: json['isLikedByCurrentUser'] as bool?,
      isBookmarkedByCurrentUser: json['isBookmarkedByCurrentUser'] as bool?,
      commentCount: (json['commentCount'] as num?)?.toInt(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      bookmarkedAt: json['bookmarkedAt'] == null
          ? null
          : DateTime.parse(json['bookmarkedAt'] as String),
      likedAt: json['likedAt'] == null
          ? null
          : DateTime.parse(json['likedAt'] as String),
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => TagModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      contents: (json['contents'] as List<dynamic>?)
              ?.map((e) => PoemContentModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      originalContent: json['originalContent'] == null
          ? null
          : PoemContentModel.fromJson(
              json['originalContent'] as Map<String, dynamic>),
      title: json['title'] as String?,
      excerpt: json['excerpt'] as String?,
      reactions: json['reactions'] as Map<String, dynamic>?,
      poet: json['poet'] == null
          ? null
          : PoetSummaryModel.fromJson(json['poet'] as Map<String, dynamic>),
      couplets: (json['couplets'] as List<dynamic>?)
              ?.map((e) => CoupletModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$PoemModelImplToJson(_$PoemModelImpl instance) =>
    <String, dynamic>{
      'publicId': instance.publicId,
      'poetPublicId': instance.poetPublicId,
      'poetName': instance.poetName,
      'poetProfileImageUrl': instance.poetProfileImageUrl,
      'categoryPublicId': instance.categoryPublicId,
      'categoryName': instance.categoryName,
      'poetryType': instance.poetryType,
      'poetryTypeName': instance.poetryTypeName,
      'poetryTypeUrduName': instance.poetryTypeUrduName,
      'poetryTypeEnglishName': instance.poetryTypeEnglishName,
      'contentType': instance.contentType,
      'requiresStructuredParsing': instance.requiresStructuredParsing,
      'imageUrl': instance.imageUrl,
      'thumbnailUrl': instance.thumbnailUrl,
      'yearWritten': instance.yearWritten,
      'source': instance.source,
      'license': instance.license,
      'uploadedByUsername': instance.uploadedByUsername,
      'isPublic': instance.isPublic,
      'isFeatured': instance.isFeatured,
      'viewCount': instance.viewCount,
      'likeCount': instance.likeCount,
      'shareCount': instance.shareCount,
      'isLikedByCurrentUser': instance.isLikedByCurrentUser,
      'isBookmarkedByCurrentUser': instance.isBookmarkedByCurrentUser,
      'commentCount': instance.commentCount,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'bookmarkedAt': instance.bookmarkedAt?.toIso8601String(),
      'likedAt': instance.likedAt?.toIso8601String(),
      'tags': instance.tags,
      'contents': instance.contents,
      'originalContent': instance.originalContent,
      'title': instance.title,
      'excerpt': instance.excerpt,
      'reactions': instance.reactions,
      'poet': instance.poet,
      'couplets': instance.couplets,
    };

_$PoemContentModelImpl _$$PoemContentModelImplFromJson(
        Map<String, dynamic> json) =>
    _$PoemContentModelImpl(
      publicId: json['publicId'] as String,
      languageCode: json['languageCode'] as String,
      languageName: json['languageName'] as String,
      languageNativeName: json['languageNativeName'] as String,
      script: json['script'] as String,
      scriptUrduName: json['scriptUrduName'] as String?,
      scriptEnglishName: json['scriptEnglishName'] as String?,
      scriptDirection: json['scriptDirection'] as String?,
      title: json['title'] as String,
      fullText: json['fullText'] as String,
      isOriginal: json['isOriginal'] as bool? ?? true,
      translatedBy: json['translatedBy'] as String?,
      notes: json['notes'] as String?,
      verses: (json['verses'] as List<dynamic>?)
              ?.map((e) => VerseModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      totalVerses: (json['totalVerses'] as num?)?.toInt() ?? 0,
      totalCouplets: (json['totalCouplets'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$PoemContentModelImplToJson(
        _$PoemContentModelImpl instance) =>
    <String, dynamic>{
      'publicId': instance.publicId,
      'languageCode': instance.languageCode,
      'languageName': instance.languageName,
      'languageNativeName': instance.languageNativeName,
      'script': instance.script,
      'scriptUrduName': instance.scriptUrduName,
      'scriptEnglishName': instance.scriptEnglishName,
      'scriptDirection': instance.scriptDirection,
      'title': instance.title,
      'fullText': instance.fullText,
      'isOriginal': instance.isOriginal,
      'translatedBy': instance.translatedBy,
      'notes': instance.notes,
      'verses': instance.verses,
      'totalVerses': instance.totalVerses,
      'totalCouplets': instance.totalCouplets,
    };

_$TagModelImpl _$$TagModelImplFromJson(Map<String, dynamic> json) =>
    _$TagModelImpl(
      publicId: json['publicId'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      color: json['color'] as String?,
      tagType: json['tagType'] as String,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$$TagModelImplToJson(_$TagModelImpl instance) =>
    <String, dynamic>{
      'publicId': instance.publicId,
      'name': instance.name,
      'slug': instance.slug,
      'color': instance.color,
      'tagType': instance.tagType,
      'description': instance.description,
    };

_$VerseModelImpl _$$VerseModelImplFromJson(Map<String, dynamic> json) =>
    _$VerseModelImpl(
      publicId: json['publicId'] as String?,
      text: json['verseText'] as String,
      verseType: json['verseType'] as String?,
      verseNumber: (json['verseNumber'] as num?)?.toInt(),
      coupletNumber: (json['coupletNumber'] as num?)?.toInt(),
      romanizedText: json['romanizedText'] as String?,
      translation: json['translation'] as String?,
    );

Map<String, dynamic> _$$VerseModelImplToJson(_$VerseModelImpl instance) =>
    <String, dynamic>{
      'publicId': instance.publicId,
      'verseText': instance.text,
      'verseType': instance.verseType,
      'verseNumber': instance.verseNumber,
      'coupletNumber': instance.coupletNumber,
      'romanizedText': instance.romanizedText,
      'translation': instance.translation,
    };
