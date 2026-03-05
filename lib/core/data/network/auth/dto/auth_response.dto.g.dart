// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_response.dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) => AuthResponse(
  accessToken: json['access_token'] as String,
  userId: json['user_id'] as String,
  email: json['email'] as String,
  username: json['username'] as String,
);

Map<String, dynamic> _$AuthResponseToJson(AuthResponse instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'email': instance.email,
      'username': instance.username,
      'access_token': instance.accessToken,
    };
