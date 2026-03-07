// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_post.dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetPostDto _$GetPostDtoFromJson(Map<String, dynamic> json) => GetPostDto(
  id: json['id'] as String,
  caption: json['caption'] as String?,
  viewCount: (json['viewCount'] as num).toInt(),
  commentCount: (json['comment_count'] as num).toInt(),
  likeCount: (json['like_count'] as num).toInt(),
  createdAt: DateTime.parse(json['created_at'] as String),
  user: PostUserDto.fromJson(json['user'] as Map<String, dynamic>),
  assetVersion: PostAssetVersionDto.fromJson(
    json['asset_version'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$GetPostDtoToJson(GetPostDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'caption': instance.caption,
      'viewCount': instance.viewCount,
      'comment_count': instance.commentCount,
      'like_count': instance.likeCount,
      'created_at': instance.createdAt.toIso8601String(),
      'user': instance.user,
      'asset_version': instance.assetVersion,
    };

PostUserDto _$PostUserDtoFromJson(Map<String, dynamic> json) =>
    PostUserDto(id: json['id'] as String, username: json['username'] as String);

Map<String, dynamic> _$PostUserDtoToJson(PostUserDto instance) =>
    <String, dynamic>{'id': instance.id, 'username': instance.username};

PostAssetVersionDto _$PostAssetVersionDtoFromJson(Map<String, dynamic> json) =>
    PostAssetVersionDto(
      id: json['id'] as String,
      fileUrl: json['file_url'] as String,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$PostAssetVersionDtoToJson(
  PostAssetVersionDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'file_url': instance.fileUrl,
  'metadata': instance.metadata,
};
