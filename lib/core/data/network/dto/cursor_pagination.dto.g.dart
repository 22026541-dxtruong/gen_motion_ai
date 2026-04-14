// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cursor_pagination.dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CursorPaginationDto<T> _$CursorPaginationDtoFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => _CursorPaginationDto<T>(
  data: (json['data'] as List<dynamic>).map(fromJsonT).toList(),
);

Map<String, dynamic> _$CursorPaginationDtoToJson<T>(
  _CursorPaginationDto<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{'data': instance.data.map(toJsonT).toList()};
