import 'package:json_annotation/json_annotation.dart';

part 'id_response.dto.g.dart';

@JsonSerializable()
class IdResponseDto {
  final String id;

  IdResponseDto({required this.id});

  factory IdResponseDto.fromJson(Map<String, dynamic> json) => _$IdResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$IdResponseDtoToJson(this);
}
