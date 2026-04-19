// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_record.dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommentRecordDto _$CommentRecordDtoFromJson(Map<String, dynamic> json) =>
    CommentRecordDto(
      id: json['id'] as String,
      userId: json['userId'] as String,
      postId: json['postId'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$CommentRecordDtoToJson(CommentRecordDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'postId': instance.postId,
      'content': instance.content,
      'createdAt': instance.createdAt.toIso8601String(),
    };
