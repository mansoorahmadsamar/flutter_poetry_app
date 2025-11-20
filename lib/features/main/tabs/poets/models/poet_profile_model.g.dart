// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'poet_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PoetProfileModelImpl _$$PoetProfileModelImplFromJson(
        Map<String, dynamic> json) =>
    _$PoetProfileModelImpl(
      publicId: json['publicId'] as String,
      name: json['name'] as String,
      biography: json['biography'] as String?,
      shortBio: json['shortBio'] as String,
      gender: json['gender'] as String,
      era: json['era'] as String,
      birthYear: (json['birthYear'] as num).toInt(),
      deathYear: (json['deathYear'] as num?)?.toInt(),
      birthDate: json['birthDate'] as String?,
      deathDate: json['deathDate'] as String?,
      birthPlace: json['birthPlace'] as String?,
      country: json['country'] as String?,
      primaryLanguageCode: json['primaryLanguageCode'] as String?,
      primaryLanguageName: json['primaryLanguageName'] as String?,
      isFeatured: json['isFeatured'] as bool,
      isTrending: json['isTrending'] as bool,
      isVerified: json['isVerified'] as bool,
      viewCount: (json['viewCount'] as num).toInt(),
      followerCount: (json['followerCount'] as num).toInt(),
      poemCount: (json['poemCount'] as num).toInt(),
      profileImageUrl: json['profileImageUrl'] as String,
      gallery: (json['gallery'] as List<dynamic>?)
          ?.map((e) => PoetImageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      books: (json['books'] as List<dynamic>?)
          ?.map((e) => PoetBookModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      videos: (json['videos'] as List<dynamic>?)
          ?.map((e) => PoetVideoModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      facts:
          (json['facts'] as List<dynamic>?)?.map((e) => e as String).toList(),
      tags: (json['tags'] as List<dynamic>?)
          ?.map((e) => PoetTagModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );

Map<String, dynamic> _$$PoetProfileModelImplToJson(
        _$PoetProfileModelImpl instance) =>
    <String, dynamic>{
      'publicId': instance.publicId,
      'name': instance.name,
      'biography': instance.biography,
      'shortBio': instance.shortBio,
      'gender': instance.gender,
      'era': instance.era,
      'birthYear': instance.birthYear,
      'deathYear': instance.deathYear,
      'birthDate': instance.birthDate,
      'deathDate': instance.deathDate,
      'birthPlace': instance.birthPlace,
      'country': instance.country,
      'primaryLanguageCode': instance.primaryLanguageCode,
      'primaryLanguageName': instance.primaryLanguageName,
      'isFeatured': instance.isFeatured,
      'isTrending': instance.isTrending,
      'isVerified': instance.isVerified,
      'viewCount': instance.viewCount,
      'followerCount': instance.followerCount,
      'poemCount': instance.poemCount,
      'profileImageUrl': instance.profileImageUrl,
      'gallery': instance.gallery,
      'books': instance.books,
      'videos': instance.videos,
      'facts': instance.facts,
      'tags': instance.tags,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };
