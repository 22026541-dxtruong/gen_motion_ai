import 'package:json_annotation/json_annotation.dart';

part 'register.dto.g.dart';

@JsonSerializable()
class RegisterDto {
  final String email;
  final String password;

  RegisterDto({required this.email, required this.password});

  factory RegisterDto.fromJson(Map<String, dynamic> json) => _$RegisterDtoFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterDtoToJson(this);
}