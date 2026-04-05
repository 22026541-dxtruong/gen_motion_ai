import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_response.dto.freezed.dart';
part 'auth_response.dto.g.dart';

@freezed
abstract class AuthResponse with _$AuthResponse {
  const factory AuthResponse({
    required String userId,
    required String username,
    required String email,
    required String accessToken,
    required String refreshToken,
  }) = _AuthResponse;

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
}
