import 'package:json_annotation/json_annotation.dart';

part 'logout.dto.g.dart';

@JsonSerializable(includeIfNull: false)
class LogoutDto {
  final String refreshToken;

  const LogoutDto({required this.refreshToken});

  factory LogoutDto.fromJson(Map<String, dynamic> json) =>
      _$LogoutDtoFromJson(json);

  Map<String, dynamic> toJson() => _$LogoutDtoToJson(this);
}
