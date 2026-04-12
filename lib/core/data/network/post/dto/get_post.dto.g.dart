// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_post.dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetPostDto _$GetPostDtoFromJson(Map<String, dynamic> json) => GetPostDto(
  id: json['id'] as String,
  caption: json['caption'] as String?,
  viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
  commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
  likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
  createdAt: DateTime.parse(json['createdAt'] as String),
  isLiked: json['isLiked'] as bool? ?? false,
  isFollowed: json['isFollowed'] as bool? ?? false,
  user: json['user'] == null
      ? null
      : PostUserDto.fromJson(json['user'] as Map<String, dynamic>),
  assetVersion: json['assetVersion'] == null
      ? null
      : PostAssetVersionDto.fromJson(
          json['assetVersion'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$GetPostDtoToJson(GetPostDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'caption': instance.caption,
      'viewCount': instance.viewCount,
      'commentCount': instance.commentCount,
      'likeCount': instance.likeCount,
      'createdAt': instance.createdAt.toIso8601String(),
      'isLiked': instance.isLiked,
      'isFollowed': instance.isFollowed,
      'user': instance.user,
      'assetVersion': instance.assetVersion,
    };

PostUserDto _$PostUserDtoFromJson(Map<String, dynamic> json) => PostUserDto(
  id: json['id'] as String,
  username: json['username'] as String,
  avatarUrl: json['avatarUrl'] as String?,
);

Map<String, dynamic> _$PostUserDtoToJson(PostUserDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'avatarUrl': instance.avatarUrl,
    };

PostAssetVersionDto _$PostAssetVersionDtoFromJson(Map<String, dynamic> json) =>
    PostAssetVersionDto(
      id: json['id'] as String,
      fileUrl: json['fileUrl'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$PostAssetVersionDtoToJson(
  PostAssetVersionDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'fileUrl': instance.fileUrl,
  'metadata': instance.metadata,
};
