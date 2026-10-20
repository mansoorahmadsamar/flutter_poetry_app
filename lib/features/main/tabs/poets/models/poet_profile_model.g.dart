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
      biography: const PlaceholderStringConverter().fromJson(json['biography']),
      shortBio: const PlaceholderStringConverter().fromJson(json['shortBio']),
      gender: const PlaceholderStringConverter().fromJson(json['gender']),
      era: const PlaceholderStringConverter().fromJson(json['era']),
      birthYear: (json['birthYear'] as num).toInt(),
      deathYear: (json['deathYear'] as num?)?.toInt(),
      birthDate: json['birthDate'] as String?,
      deathDate: json['deathDate'] as String?,
      birthPlace:
          const PlaceholderStringConverter().fromJson(json['birthPlace']),
      country: const PlaceholderStringConverter().fromJson(json['country']),
      countryFlag:
          const PlaceholderStringConverter().fromJson(json['countryFlag']),
      countryFlagUrl:
          const PlaceholderStringConverter().fromJson(json['countryFlagUrl']),
      primaryLanguageCode: const PlaceholderStringConverter()
          .fromJson(json['primaryLanguageCode']),
      primaryLanguageName: const PlaceholderStringConverter()
          .fromJson(json['primaryLanguageName']),
      isFeatured: json['isFeatured'] as bool? ?? false,
      isTrending: json['isTrending'] as bool? ?? false,
      isVerified: json['isVerified'] as bool? ?? false,
      viewCount: (json['viewCount'] as num).toInt(),
      followerCount: (json['followerCount'] as num).toInt(),
      poemCount: (json['poemCount'] as num).toInt(),
      profileImageUrl:
          const PlaceholderStringConverter().fromJson(json['profileImageUrl']),
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
      'biography':
          const PlaceholderStringConverter().toJson(instance.biography),
      'shortBio': const PlaceholderStringConverter().toJson(instance.shortBio),
      'gender': const PlaceholderStringConverter().toJson(instance.gender),
      'era': const PlaceholderStringConverter().toJson(instance.era),
      'birthYear': instance.birthYear,
      'deathYear': instance.deathYear,
      'birthDate': instance.birthDate,
      'deathDate': instance.deathDate,
      'birthPlace':
          const PlaceholderStringConverter().toJson(instance.birthPlace),
      'country': const PlaceholderStringConverter().toJson(instance.country),
      'countryFlag':
          const PlaceholderStringConverter().toJson(instance.countryFlag),
      'countryFlagUrl':
          const PlaceholderStringConverter().toJson(instance.countryFlagUrl),
      'primaryLanguageCode': const PlaceholderStringConverter()
          .toJson(instance.primaryLanguageCode),
      'primaryLanguageName': const PlaceholderStringConverter()
          .toJson(instance.primaryLanguageName),
      'isFeatured': instance.isFeatured,
      'isTrending': instance.isTrending,
      'isVerified': instance.isVerified,
      'viewCount': instance.viewCount,
      'followerCount': instance.followerCount,
      'poemCount': instance.poemCount,
      'profileImageUrl':
          const PlaceholderStringConverter().toJson(instance.profileImageUrl),
      'gallery': instance.gallery,
      'books': instance.books,
      'videos': instance.videos,
      'facts': instance.facts,
      'tags': instance.tags,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };
