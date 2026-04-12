import 'package:json_annotation/json_annotation.dart';

part 'auth_response.dto.g.dart';

@JsonSerializable()
class AuthResponse {
  @JsonKey(name: 'access_token')
  final String? accessTokenSnake;
  final String? accessToken;
  @JsonKey(name: 'refresh_token')
  final String? refreshTokenSnake;
  final String? refreshToken;
  final String? userId;
  final String? username;
  final String? email;

  AuthResponse({
    this.accessTokenSnake,
    this.accessToken,
    this.refreshTokenSnake,
    this.refreshToken,
    this.userId,
    this.username,
    this.email,
  });

  String get token => accessToken ?? accessTokenSnake ?? '';
  String get refresh => refreshToken ?? refreshTokenSnake ?? '';

  factory AuthResponse.fromJson(Map<String, dynamic> json) => _$AuthResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}