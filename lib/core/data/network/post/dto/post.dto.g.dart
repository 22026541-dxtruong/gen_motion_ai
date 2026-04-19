// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostDto _$PostDtoFromJson(Map<String, dynamic> json) => PostDto(
  id: json['id'] as String,
  userId: json['userId'] as String,
  assetVersionId: json['assetVersionId'] as String,
  caption: json['caption'] as String?,
  isPublic: json['isPublic'] as bool,
  likeCount: (json['likeCount'] as num).toInt(),
  commentCount: (json['commentCount'] as num).toInt(),
  viewCount: (json['viewCount'] as num).toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$PostDtoToJson(PostDto instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'assetVersionId': instance.assetVersionId,
  'caption': instance.caption,
  'isPublic': instance.isPublic,
  'likeCount': instance.likeCount,
  'commentCount': instance.commentCount,
  'viewCount': instance.viewCount,
  'createdAt': instance.createdAt.toIso8601String(),
};
