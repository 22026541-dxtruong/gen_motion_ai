// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_user.dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateUserDto _$UpdateUserDtoFromJson(Map<String, dynamic> json) =>
    UpdateUserDto(
      username: json['username'] as String?,
      bio: json['bio'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
    );

Map<String, dynamic> _$UpdateUserDtoToJson(UpdateUserDto instance) =>
    <String, dynamic>{
      'username': ?instance.username,
      'bio': ?instance.bio,
      'avatarUrl': ?instance.avatarUrl,
    };
