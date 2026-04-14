import 'package:json_annotation/json_annotation.dart';

part 'refresh_token.dto.g.dart';

@JsonSerializable(includeIfNull: false)
class RefreshTokenDto {
  final String refreshToken;

  const RefreshTokenDto({required this.refreshToken});

  factory RefreshTokenDto.fromJson(Map<String, dynamic> json) =>
      _$RefreshTokenDtoFromJson(json);

  Map<String, dynamic> toJson() => _$RefreshTokenDtoToJson(this);
}
