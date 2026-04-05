import 'package:json_annotation/json_annotation.dart';

part 'message_response.dto.g.dart';

@JsonSerializable()
class MessageResponseDto {
  final String message;

  const MessageResponseDto({required this.message});

  factory MessageResponseDto.fromJson(Map<String, dynamic> json) =>
      _$MessageResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MessageResponseDtoToJson(this);
}
