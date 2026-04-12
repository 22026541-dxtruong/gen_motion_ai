// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'explore_item.dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExploreItem _$ExploreItemFromJson(Map<String, dynamic> json) => ExploreItem(
  id: json['id'] as String,
  title: json['title'] as String,
  topic: json['topic'] as String,
  isTrending: json['isTrending'] as bool? ?? false,
  score: (json['score'] as num).toDouble(),
  postId: json['postId'] as String?,
  assetVersion: json['assetVersion'] == null
      ? null
      : ExploreAssetVersion.fromJson(
          json['assetVersion'] as Map<String, dynamic>,
        ),
  post: json['post'] == null
      ? null
      : ExplorePost.fromJson(json['post'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ExploreItemToJson(ExploreItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'topic': instance.topic,
      'isTrending': instance.isTrending,
      'score': instance.score,
      'postId': instance.postId,
      'assetVersion': instance.assetVersion,
      'post': instance.post,
    };

ExploreAssetVersion _$ExploreAssetVersionFromJson(Map<String, dynamic> json) =>
    ExploreAssetVersion(
      id: json['id'] as String,
      fileUrl: json['fileUrl'] as String?,
      mimeType: json['mimeType'] as String?,
      width: (json['width'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ExploreAssetVersionToJson(
  ExploreAssetVersion instance,
) => <String, dynamic>{
  'id': instance.id,
  'fileUrl': instance.fileUrl,
  'mimeType': instance.mimeType,
  'width': instance.width,
  'height': instance.height,
};

ExplorePostUser _$ExplorePostUserFromJson(Map<String, dynamic> json) =>
    ExplorePostUser(
      id: json['id'] as String,
      username: json['username'] as String,
      avatarUrl: json['avatarUrl'] as String?,
    );

Map<String, dynamic> _$ExplorePostUserToJson(ExplorePostUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'avatarUrl': instance.avatarUrl,
    };

ExplorePost _$ExplorePostFromJson(Map<String, dynamic> json) => ExplorePost(
  id: json['id'] as String,
  caption: json['caption'] as String?,
  likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
  viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
  commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
  user: json['user'] == null
      ? null
      : ExplorePostUser.fromJson(json['user'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ExplorePostToJson(ExplorePost instance) =>
    <String, dynamic>{
      'id': instance.id,
      'caption': instance.caption,
      'likeCount': instance.likeCount,
      'viewCount': instance.viewCount,
      'commentCount': instance.commentCount,
      'user': instance.user,
    };
