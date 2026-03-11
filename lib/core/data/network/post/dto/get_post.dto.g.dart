// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_post.dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GetPostDto _$GetPostDtoFromJson(Map<String, dynamic> json) => _GetPostDto(
  id: json['id'] as String,
  caption: json['caption'] as String?,
  viewCount: (json['view_count'] as num).toInt(),
  commentCount: (json['comment_count'] as num).toInt(),
  likeCount: (json['like_count'] as num).toInt(),
  createdAt: DateTime.parse(json['created_at'] as String),
  isLiked: json['is_liked'] as bool,
  isFollowed: json['is_followed'] as bool,
  user: PostUserDto.fromJson(json['user'] as Map<String, dynamic>),
  assetVersion: PostAssetVersionDto.fromJson(
    json['asset_version'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$GetPostDtoToJson(_GetPostDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'caption': instance.caption,
      'view_count': instance.viewCount,
      'comment_count': instance.commentCount,
      'like_count': instance.likeCount,
      'created_at': instance.createdAt.toIso8601String(),
      'is_liked': instance.isLiked,
      'is_followed': instance.isFollowed,
      'user': instance.user,
      'asset_version': instance.assetVersion,
    };

_PostUserDto _$PostUserDtoFromJson(Map<String, dynamic> json) => _PostUserDto(
  id: json['id'] as String,
  username: json['username'] as String,
  avatarUrl: json['avatar_url'] as String?,
);

Map<String, dynamic> _$PostUserDtoToJson(_PostUserDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'avatar_url': instance.avatarUrl,
    };

_PostAssetVersionDto _$PostAssetVersionDtoFromJson(Map<String, dynamic> json) =>
    _PostAssetVersionDto(
      id: json['id'] as String,
      fileUrl: json['file_url'] as String,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$PostAssetVersionDtoToJson(
  _PostAssetVersionDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'file_url': instance.fileUrl,
  'metadata': instance.metadata,
};
