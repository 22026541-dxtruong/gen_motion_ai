import 'package:json_annotation/json_annotation.dart';

part 'login.dto.g.dart';

@JsonSerializable()
class LoginDto{
  final String email;
  final String password;

  LoginDto({
    required this.email,
    required this.password,
  });

  factory LoginDto.fromJson(Map<String, dynamic> json) => _$LoginDtoFromJson(json);
  Map<String, dynamic> toJson() => _$LoginDtoToJson(this);
}
