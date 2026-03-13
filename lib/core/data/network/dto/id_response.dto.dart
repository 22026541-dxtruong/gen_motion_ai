import 'package:freezed_annotation/freezed_annotation.dart';

part 'id_response.dto.freezed.dart';
part 'id_response.dto.g.dart';

@freezed
abstract class IdResponseDto with _$IdResponseDto {
  const factory IdResponseDto({
    required String id,
  }) = _IdResponseDto;

  factory IdResponseDto.fromJson(Map<String, dynamic> json) =>
      _$IdResponseDtoFromJson(json);
}