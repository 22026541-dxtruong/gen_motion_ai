import 'package:json_annotation/json_annotation.dart';

part 'auth_response.dto.g.dart';

@JsonSerializable()
class AuthResponse {
  final String? accessToken;
  final String? refreshToken;
  final String? userId;
  final String? username;
  final String? email;

  AuthResponse({
    this.accessToken,
    this.refreshToken,
    this.userId,
    this.username,
    this.email,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => _$AuthResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}
