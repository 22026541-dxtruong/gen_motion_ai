import 'package:freezed_annotation/freezed_annotation.dart';

part 'register.dto.freezed.dart';
part 'register.dto.g.dart';

@freezed
abstract class RegisterDto with _$RegisterDto {
  const factory RegisterDto({
    required String email,
    required String password,
  }) = _RegisterDto;

  factory RegisterDto.fromJson(Map<String, dynamic> json) =>
      _$RegisterDtoFromJson(json);
}