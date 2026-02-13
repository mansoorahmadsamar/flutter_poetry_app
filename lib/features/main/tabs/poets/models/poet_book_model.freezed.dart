// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'poet_book_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PoetBookModel _$PoetBookModelFromJson(Map<String, dynamic> json) {
  return _PoetBookModel.fromJson(json);
}

/// @nodoc
mixin _$PoetBookModel {
  String get publicId => throw _privateConstructorUsedError;
  @JsonKey(name: 'languageCode')
  String get languageCode => throw _privateConstructorUsedError;
  @JsonKey(name: 'languageName')
  String get languageName => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get subtitle => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'yearPublished')
  int? get yearPublished => throw _privateConstructorUsedError;
  String? get publisher => throw _privateConstructorUsedError;
  String? get isbn => throw _privateConstructorUsedError;
  String? get isbn13 => throw _privateConstructorUsedError;
  @JsonKey(name: 'pageCount')
  int? get pageCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'coverImageUrl')
  String? get coverImageUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'isAvailable')
  bool get isAvailable => throw _privateConstructorUsedError;
  @JsonKey(name: 'bookType')
  String get bookType => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PoetBookModelCopyWith<PoetBookModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PoetBookModelCopyWith<$Res> {
  factory $PoetBookModelCopyWith(
          PoetBookModel value, $Res Function(PoetBookModel) then) =
      _$PoetBookModelCopyWithImpl<$Res, PoetBookModel>;
  @useResult
  $Res call(
      {String publicId,
      @JsonKey(name: 'languageCode') String languageCode,
      @JsonKey(name: 'languageName') String languageName,
      String title,
      String? subtitle,
      String? description,
      @JsonKey(name: 'yearPublished') int? yearPublished,
      String? publisher,
      String? isbn,
      String? isbn13,
      @JsonKey(name: 'pageCount') int? pageCount,
      @JsonKey(name: 'coverImageUrl') String? coverImageUrl,
      @JsonKey(name: 'isAvailable') bool isAvailable,
      @JsonKey(name: 'bookType') String bookType});
}

/// @nodoc
class _$PoetBookModelCopyWithImpl<$Res, $Val extends PoetBookModel>
    implements $PoetBookModelCopyWith<$Res> {
  _$PoetBookModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? publicId = null,
    Object? languageCode = null,
    Object? languageName = null,
    Object? title = null,
    Object? subtitle = freezed,
    Object? description = freezed,
    Object? yearPublished = freezed,
    Object? publisher = freezed,
    Object? isbn = freezed,
    Object? isbn13 = freezed,
    Object? pageCount = freezed,
    Object? coverImageUrl = freezed,
    Object? isAvailable = null,
    Object? bookType = null,
  }) {
    return _then(_value.copyWith(
      publicId: null == publicId
          ? _value.publicId
          : publicId // ignore: cast_nullable_to_non_nullable
              as String,
      languageCode: null == languageCode
          ? _value.languageCode
          : languageCode // ignore: cast_nullable_to_non_nullable
              as String,
      languageName: null == languageName
          ? _value.languageName
          : languageName // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      subtitle: freezed == subtitle
          ? _value.subtitle
          : subtitle // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      yearPublished: freezed == yearPublished
          ? _value.yearPublished
          : yearPublished // ignore: cast_nullable_to_non_nullable
              as int?,
      publisher: freezed == publisher
          ? _value.publisher
          : publisher // ignore: cast_nullable_to_non_nullable
              as String?,
      isbn: freezed == isbn
          ? _value.isbn
          : isbn // ignore: cast_nullable_to_non_nullable
              as String?,
      isbn13: freezed == isbn13
          ? _value.isbn13
          : isbn13 // ignore: cast_nullable_to_non_nullable
              as String?,
      pageCount: freezed == pageCount
          ? _value.pageCount
          : pageCount // ignore: cast_nullable_to_non_nullable
              as int?,
      coverImageUrl: freezed == coverImageUrl
          ? _value.coverImageUrl
          : coverImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      isAvailable: null == isAvailable
          ? _value.isAvailable
          : isAvailable // ignore: cast_nullable_to_non_nullable
              as bool,
      bookType: null == bookType
          ? _value.bookType
          : bookType // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PoetBookModelImplCopyWith<$Res>
    implements $PoetBookModelCopyWith<$Res> {
  factory _$$PoetBookModelImplCopyWith(
          _$PoetBookModelImpl value, $Res Function(_$PoetBookModelImpl) then) =
      __$$PoetBookModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String publicId,
      @JsonKey(name: 'languageCode') String languageCode,
      @JsonKey(name: 'languageName') String languageName,
      String title,
      String? subtitle,
      String? description,
      @JsonKey(name: 'yearPublished') int? yearPublished,
      String? publisher,
      String? isbn,
      String? isbn13,
      @JsonKey(name: 'pageCount') int? pageCount,
      @JsonKey(name: 'coverImageUrl') String? coverImageUrl,
      @JsonKey(name: 'isAvailable') bool isAvailable,
      @JsonKey(name: 'bookType') String bookType});
}

/// @nodoc
class __$$PoetBookModelImplCopyWithImpl<$Res>
    extends _$PoetBookModelCopyWithImpl<$Res, _$PoetBookModelImpl>
    implements _$$PoetBookModelImplCopyWith<$Res> {
  __$$PoetBookModelImplCopyWithImpl(
      _$PoetBookModelImpl _value, $Res Function(_$PoetBookModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? publicId = null,
    Object? languageCode = null,
    Object? languageName = null,
    Object? title = null,
    Object? subtitle = freezed,
    Object? description = freezed,
    Object? yearPublished = freezed,
    Object? publisher = freezed,
    Object? isbn = freezed,
    Object? isbn13 = freezed,
    Object? pageCount = freezed,
    Object? coverImageUrl = freezed,
    Object? isAvailable = null,
    Object? bookType = null,
  }) {
    return _then(_$PoetBookModelImpl(
      publicId: null == publicId
          ? _value.publicId
          : publicId // ignore: cast_nullable_to_non_nullable
              as String,
      languageCode: null == languageCode
          ? _value.languageCode
          : languageCode // ignore: cast_nullable_to_non_nullable
              as String,
      languageName: null == languageName
          ? _value.languageName
          : languageName // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      subtitle: freezed == subtitle
          ? _value.subtitle
          : subtitle // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      yearPublished: freezed == yearPublished
          ? _value.yearPublished
          : yearPublished // ignore: cast_nullable_to_non_nullable
              as int?,
      publisher: freezed == publisher
          ? _value.publisher
          : publisher // ignore: cast_nullable_to_non_nullable
              as String?,
      isbn: freezed == isbn
          ? _value.isbn
          : isbn // ignore: cast_nullable_to_non_nullable
              as String?,
      isbn13: freezed == isbn13
          ? _value.isbn13
          : isbn13 // ignore: cast_nullable_to_non_nullable
              as String?,
      pageCount: freezed == pageCount
          ? _value.pageCount
          : pageCount // ignore: cast_nullable_to_non_nullable
              as int?,
      coverImageUrl: freezed == coverImageUrl
          ? _value.coverImageUrl
          : coverImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      isAvailable: null == isAvailable
          ? _value.isAvailable
          : isAvailable // ignore: cast_nullable_to_non_nullable
              as bool,
      bookType: null == bookType
          ? _value.bookType
          : bookType // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PoetBookModelImpl implements _PoetBookModel {
  const _$PoetBookModelImpl(
      {required this.publicId,
      @JsonKey(name: 'languageCode') required this.languageCode,
      @JsonKey(name: 'languageName') required this.languageName,
      required this.title,
      this.subtitle,
      this.description,
      @JsonKey(name: 'yearPublished') this.yearPublished,
      this.publisher,
      this.isbn,
      this.isbn13,
      @JsonKey(name: 'pageCount') this.pageCount,
      @JsonKey(name: 'coverImageUrl') this.coverImageUrl,
      @JsonKey(name: 'isAvailable') required this.isAvailable,
      @JsonKey(name: 'bookType') required this.bookType});

  factory _$PoetBookModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PoetBookModelImplFromJson(json);

  @override
  final String publicId;
  @override
  @JsonKey(name: 'languageCode')
  final String languageCode;
  @override
  @JsonKey(name: 'languageName')
  final String languageName;
  @override
  final String title;
  @override
  final String? subtitle;
  @override
  final String? description;
  @override
  @JsonKey(name: 'yearPublished')
  final int? yearPublished;
  @override
  final String? publisher;
  @override
  final String? isbn;
  @override
  final String? isbn13;
  @override
  @JsonKey(name: 'pageCount')
  final int? pageCount;
  @override
  @JsonKey(name: 'coverImageUrl')
  final String? coverImageUrl;
  @override
  @JsonKey(name: 'isAvailable')
  final bool isAvailable;
  @override
  @JsonKey(name: 'bookType')
  final String bookType;

  @override
  String toString() {
    return 'PoetBookModel(publicId: $publicId, languageCode: $languageCode, languageName: $languageName, title: $title, subtitle: $subtitle, description: $description, yearPublished: $yearPublished, publisher: $publisher, isbn: $isbn, isbn13: $isbn13, pageCount: $pageCount, coverImageUrl: $coverImageUrl, isAvailable: $isAvailable, bookType: $bookType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PoetBookModelImpl &&
            (identical(other.publicId, publicId) ||
                other.publicId == publicId) &&
            (identical(other.languageCode, languageCode) ||
                other.languageCode == languageCode) &&
            (identical(other.languageName, languageName) ||
                other.languageName == languageName) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.subtitle, subtitle) ||
                other.subtitle == subtitle) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.yearPublished, yearPublished) ||
                other.yearPublished == yearPublished) &&
            (identical(other.publisher, publisher) ||
                other.publisher == publisher) &&
            (identical(other.isbn, isbn) || other.isbn == isbn) &&
            (identical(other.isbn13, isbn13) || other.isbn13 == isbn13) &&
            (identical(other.pageCount, pageCount) ||
                other.pageCount == pageCount) &&
            (identical(other.coverImageUrl, coverImageUrl) ||
                other.coverImageUrl == coverImageUrl) &&
            (identical(other.isAvailable, isAvailable) ||
                other.isAvailable == isAvailable) &&
            (identical(other.bookType, bookType) ||
                other.bookType == bookType));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      publicId,
      languageCode,
      languageName,
      title,
      subtitle,
      description,
      yearPublished,
      publisher,
      isbn,
      isbn13,
      pageCount,
      coverImageUrl,
      isAvailable,
      bookType);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PoetBookModelImplCopyWith<_$PoetBookModelImpl> get copyWith =>
      __$$PoetBookModelImplCopyWithImpl<_$PoetBookModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PoetBookModelImplToJson(
      this,
    );
  }
}

abstract class _PoetBookModel implements PoetBookModel {
  const factory _PoetBookModel(
          {required final String publicId,
          @JsonKey(name: 'languageCode') required final String languageCode,
          @JsonKey(name: 'languageName') required final String languageName,
          required final String title,
          final String? subtitle,
          final String? description,
          @JsonKey(name: 'yearPublished') final int? yearPublished,
          final String? publisher,
          final String? isbn,
          final String? isbn13,
          @JsonKey(name: 'pageCount') final int? pageCount,
          @JsonKey(name: 'coverImageUrl') final String? coverImageUrl,
          @JsonKey(name: 'isAvailable') required final bool isAvailable,
          @JsonKey(name: 'bookType') required final String bookType}) =
      _$PoetBookModelImpl;

  factory _PoetBookModel.fromJson(Map<String, dynamic> json) =
      _$PoetBookModelImpl.fromJson;

  @override
  String get publicId;
  @override
  @JsonKey(name: 'languageCode')
  String get languageCode;
  @override
  @JsonKey(name: 'languageName')
  String get languageName;
  @override
  String get title;
  @override
  String? get subtitle;
  @override
  String? get description;
  @override
  @JsonKey(name: 'yearPublished')
  int? get yearPublished;
  @override
  String? get publisher;
  @override
  String? get isbn;
  @override
  String? get isbn13;
  @override
  @JsonKey(name: 'pageCount')
  int? get pageCount;
  @override
  @JsonKey(name: 'coverImageUrl')
  String? get coverImageUrl;
  @override
  @JsonKey(name: 'isAvailable')
  bool get isAvailable;
  @override
  @JsonKey(name: 'bookType')
  String get bookType;
  @override
  @JsonKey(ignore: true)
  _$$PoetBookModelImplCopyWith<_$PoetBookModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
