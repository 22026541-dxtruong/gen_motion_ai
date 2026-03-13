import 'package:freezed_annotation/freezed_annotation.dart';

part 'cursor_pagination.dto.freezed.dart';
part 'cursor_pagination.dto.g.dart';

@Freezed(genericArgumentFactories: true)
abstract class CursorPaginationDto<T> with _$CursorPaginationDto<T> {
  const factory CursorPaginationDto({
    required List<T> data,
    @JsonKey(name: 'next_cursor')
    String? nextCursor,
  }) = _CursorPaginationDto<T>;

  factory CursorPaginationDto.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$CursorPaginationDtoFromJson(json, fromJsonT);
}