// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiResponse<T> _$ApiResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => ApiResponse<T>(
  success: json['success'] as bool,
  message: json['message'] as String,
  data: _$nullableGenericFromJson(json['data'], fromJsonT),
);

Map<String, dynamic> _$ApiResponseToJson<T>(
  ApiResponse<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': _$nullableGenericToJson(instance.data, toJsonT),
};

T? _$nullableGenericFromJson<T>(
  Object? input,
  T Function(Object? json) fromJson,
) => input == null ? null : fromJson(input);

Object? _$nullableGenericToJson<T>(
  T? input,
  Object? Function(T value) toJson,
) => input == null ? null : toJson(input);

Pageable _$PageableFromJson(Map<String, dynamic> json) => Pageable(
  pageNumber: (json['pageNumber'] as num).toInt(),
  pageSize: (json['pageSize'] as num).toInt(),
  offset: (json['offset'] as num).toInt(),
  paged: json['paged'] as bool,
  unpaged: json['unpaged'] as bool,
);

Map<String, dynamic> _$PageableToJson(Pageable instance) => <String, dynamic>{
  'pageNumber': instance.pageNumber,
  'pageSize': instance.pageSize,
  'offset': instance.offset,
  'paged': instance.paged,
  'unpaged': instance.unpaged,
};

PaginatedResponse<T> _$PaginatedResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => PaginatedResponse<T>(
  content: (json['content'] as List<dynamic>).map(fromJsonT).toList(),
  pageable: Pageable.fromJson(json['pageable'] as Map<String, dynamic>),
  totalElements: (json['totalElements'] as num).toInt(),
  totalPages: (json['totalPages'] as num).toInt(),
  last: json['last'] as bool,
  first: json['first'] as bool,
  numberOfElements: (json['numberOfElements'] as num).toInt(),
  size: (json['size'] as num).toInt(),
  number: (json['number'] as num).toInt(),
  empty: json['empty'] as bool,
);

Map<String, dynamic> _$PaginatedResponseToJson<T>(
  PaginatedResponse<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'content': instance.content.map(toJsonT).toList(),
  'pageable': instance.pageable,
  'totalElements': instance.totalElements,
  'totalPages': instance.totalPages,
  'last': instance.last,
  'first': instance.first,
  'numberOfElements': instance.numberOfElements,
  'size': instance.size,
  'number': instance.number,
  'empty': instance.empty,
};
