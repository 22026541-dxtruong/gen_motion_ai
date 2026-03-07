import 'package:json_annotation/json_annotation.dart';

part 'cursor_pagination.dto.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class CursorPaginationDto<T> {
  final List<T> data;
  final String? nextCursor;

  CursorPaginationDto({
    required this.data,
    this.nextCursor,
  });

  factory CursorPaginationDto.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$CursorPaginationDtoFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(
    Object Function(T value) toJsonT,
  ) =>
      _$CursorPaginationDtoToJson(this, toJsonT);
}