// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_comment.dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateCommentDto _$CreateCommentDtoFromJson(Map<String, dynamic> json) =>
    CreateCommentDto(
      postId: json['postId'] as String,
      content: json['content'] as String,
    );

Map<String, dynamic> _$CreateCommentDtoToJson(CreateCommentDto instance) =>
    <String, dynamic>{'postId': instance.postId, 'content': instance.content};
