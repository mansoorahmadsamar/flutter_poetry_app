// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'poet_book_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PoetBookModelImpl _$$PoetBookModelImplFromJson(Map<String, dynamic> json) =>
    _$PoetBookModelImpl(
      publicId: json['publicId'] as String,
      languageCode: json['languageCode'] as String,
      languageName: json['languageName'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      description: json['description'] as String?,
      yearPublished: (json['yearPublished'] as num?)?.toInt(),
      publisher: json['publisher'] as String?,
      isbn: json['isbn'] as String?,
      isbn13: json['isbn13'] as String?,
      pageCount: (json['pageCount'] as num?)?.toInt(),
      coverImageUrl: json['coverImageUrl'] as String?,
      isAvailable: json['isAvailable'] as bool,
      bookType: json['bookType'] as String,
    );

Map<String, dynamic> _$$PoetBookModelImplToJson(_$PoetBookModelImpl instance) =>
    <String, dynamic>{
      'publicId': instance.publicId,
      'languageCode': instance.languageCode,
      'languageName': instance.languageName,
      'title': instance.title,
      'subtitle': instance.subtitle,
      'description': instance.description,
      'yearPublished': instance.yearPublished,
      'publisher': instance.publisher,
      'isbn': instance.isbn,
      'isbn13': instance.isbn13,
      'pageCount': instance.pageCount,
      'coverImageUrl': instance.coverImageUrl,
      'isAvailable': instance.isAvailable,
      'bookType': instance.bookType,
    };
