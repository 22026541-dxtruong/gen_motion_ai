// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_like_record.dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostLikeRecordDto _$PostLikeRecordDtoFromJson(Map<String, dynamic> json) =>
    PostLikeRecordDto(
      id: json['id'] as String,
      userId: json['userId'] as String,
      postId: json['postId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$PostLikeRecordDtoToJson(PostLikeRecordDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'postId': instance.postId,
      'createdAt': instance.createdAt.toIso8601String(),
    };
