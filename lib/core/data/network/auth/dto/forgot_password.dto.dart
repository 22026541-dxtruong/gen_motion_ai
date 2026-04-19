import 'package:json_annotation/json_annotation.dart';

part 'forgot_password.dto.g.dart';

@JsonSerializable(includeIfNull: false)
class ForgotPasswordDto {
  final String email;

  const ForgotPasswordDto({required this.email});

  factory ForgotPasswordDto.fromJson(Map<String, dynamic> json) =>
      _$ForgotPasswordDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ForgotPasswordDtoToJson(this);
}
