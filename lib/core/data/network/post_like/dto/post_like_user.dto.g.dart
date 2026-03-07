// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_like_user.dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostLikeUserDto _$PostLikeUserDtoFromJson(Map<String, dynamic> json) =>
    PostLikeUserDto(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      user: LikeUserDto.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PostLikeUserDtoToJson(PostLikeUserDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'user': instance.user,
    };

LikeUserDto _$LikeUserDtoFromJson(Map<String, dynamic> json) =>
    LikeUserDto(id: json['id'] as String, username: json['username'] as String);

Map<String, dynamic> _$LikeUserDtoToJson(LikeUserDto instance) =>
    <String, dynamic>{'id': instance.id, 'username': instance.username};
