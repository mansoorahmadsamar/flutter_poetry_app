import 'package:freezed_annotation/freezed_annotation.dart';

part 'poet_book_model.freezed.dart';
part 'poet_book_model.g.dart';

@freezed
class PoetBookModel with _$PoetBookModel {
  const factory PoetBookModel({
    required String publicId,
    @JsonKey(name: 'languageCode') required String languageCode,
    @JsonKey(name: 'languageName') required String languageName,
    required String title,
    String? subtitle,
    String? description,
    @JsonKey(name: 'yearPublished') int? yearPublished,
    String? publisher,
    String? isbn,
    String? isbn13,
    @JsonKey(name: 'pageCount') int? pageCount,
    @JsonKey(name: 'coverImageUrl') String? coverImageUrl,
    @JsonKey(name: 'isAvailable') required bool isAvailable,
    @JsonKey(name: 'bookType') required String bookType,
  }) = _PoetBookModel;

  factory PoetBookModel.fromJson(Map<String, dynamic> json) =>
      _$PoetBookModelFromJson(json);
}
