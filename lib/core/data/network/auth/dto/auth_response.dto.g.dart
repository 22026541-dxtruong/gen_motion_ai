// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_response.dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) => AuthResponse(
  accessTokenSnake: json['access_token'] as String?,
  accessToken: json['accessToken'] as String?,
  refreshTokenSnake: json['refresh_token'] as String?,
  refreshToken: json['refreshToken'] as String?,
  userId: json['userId'] as String?,
  username: json['username'] as String?,
  email: json['email'] as String?,
);

Map<String, dynamic> _$AuthResponseToJson(AuthResponse instance) =>
    <String, dynamic>{
      'access_token': instance.accessTokenSnake,
      'accessToken': instance.accessToken,
      'refresh_token': instance.refreshTokenSnake,
      'refreshToken': instance.refreshToken,
      'userId': instance.userId,
      'username': instance.username,
      'email': instance.email,
    };
