import 'package:json_annotation/json_annotation.dart';

part 'reset_password.dto.g.dart';

@JsonSerializable(includeIfNull: false)
class ResetPasswordDto {
  final String token;
  final String newPassword;

  const ResetPasswordDto({required this.token, required this.newPassword});

  factory ResetPasswordDto.fromJson(Map<String, dynamic> json) =>
      _$ResetPasswordDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ResetPasswordDtoToJson(this);
}
