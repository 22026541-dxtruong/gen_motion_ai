import 'package:json_annotation/json_annotation.dart';

part 'change_password.dto.g.dart';

@JsonSerializable(includeIfNull: false)
class ChangePasswordDto {
  final String oldPassword;
  final String newPassword;

  const ChangePasswordDto({
    required this.oldPassword,
    required this.newPassword,
  });

  factory ChangePasswordDto.fromJson(Map<String, dynamic> json) =>
      _$ChangePasswordDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ChangePasswordDtoToJson(this);
}
