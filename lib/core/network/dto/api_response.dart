import 'package:json_annotation/json_annotation.dart';

part 'api_response.g.dart';

/// Generic API response wrapper
/// All API responses follow this structure based on the API documentation
@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$ApiResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$ApiResponseToJson(this, toJsonT);
}

/// Pageable metadata for paginated responses
@JsonSerializable()
class Pageable {
  final int pageNumber;
  final int pageSize;
  final int offset;
  final bool paged;
  final bool unpaged;

  Pageable({
    required this.pageNumber,
    required this.pageSize,
    required this.offset,
    required this.paged,
    required this.unpaged,
  });

  factory Pageable.fromJson(Map<String, dynamic> json) =>
      _$PageableFromJson(json);

  Map<String, dynamic> toJson() => _$PageableToJson(this);
}

/// Paginated response wrapper
@JsonSerializable(genericArgumentFactories: true)
class PaginatedResponse<T> {
  final List<T> content;
  final Pageable? pageable;  // Made nullable - search API doesn't include this
  final int totalElements;
  final int totalPages;
  final bool last;
  final bool first;
  @JsonKey(name: 'numberOfElements') final int? numberOfElements;  // Made nullable
  @JsonKey(name: 'pageSize') final int size;  // Maps from pageSize
  @JsonKey(name: 'pageNumber') final int number;  // Maps from pageNumber
  final bool? empty;  // Made nullable

  PaginatedResponse({
    required this.content,
    this.pageable,
    required this.totalElements,
    required this.totalPages,
    required this.last,
    required this.first,
    this.numberOfElements,
    required this.size,
    required this.number,
    this.empty,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$PaginatedResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$PaginatedResponseToJson(this, toJsonT);
}
