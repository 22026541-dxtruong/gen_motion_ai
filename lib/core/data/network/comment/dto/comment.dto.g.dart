// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment.dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommentDto _$CommentDtoFromJson(Map<String, dynamic> json) => CommentDto(
  id: json['id'] as String,
  content: json['content'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  user: CommentUserDto.fromJson(json['user'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CommentDtoToJson(CommentDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'createdAt': instance.createdAt.toIso8601String(),
      'user': instance.user,
    };

CommentUserDto _$CommentUserDtoFromJson(Map<String, dynamic> json) =>
    CommentUserDto(
      id: json['id'] as String,
      username: json['username'] as String,
    );

Map<String, dynamic> _$CommentUserDtoToJson(CommentUserDto instance) =>
    <String, dynamic>{'id': instance.id, 'username': instance.username};
