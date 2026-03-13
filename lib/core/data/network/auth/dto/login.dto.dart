import 'package:freezed_annotation/freezed_annotation.dart';

part 'login.dto.freezed.dart';
part 'login.dto.g.dart';

@freezed
abstract class LoginDto with _$LoginDto {
  const factory LoginDto({
    required String email,
    required String password,
  }) = _LoginDto;

  factory LoginDto.fromJson(Map<String, dynamic> json) =>
      _$LoginDtoFromJson(json);
}