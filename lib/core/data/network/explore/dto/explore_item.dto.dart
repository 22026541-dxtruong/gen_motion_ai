import 'package:json_annotation/json_annotation.dart';

part 'explore_item.dto.g.dart';

@JsonSerializable()
class ExploreItem {
  final String id;
  final String title;
  final String topic;
  final bool isTrending;
  final double score;
  final String? postId;
  final ExploreAssetVersion? assetVersion;
  final ExplorePost? post;

  ExploreItem({
    required this.id,
    required this.title,
    required this.topic,
    this.isTrending = false,
    required this.score,
    this.postId,
    this.assetVersion,
    this.post,
  });

  factory ExploreItem.fromJson(Map<String, dynamic> json) =>
      _$ExploreItemFromJson(json);

  Map<String, dynamic> toJson() => _$ExploreItemToJson(this);
}

@JsonSerializable()
class ExploreAssetVersion {
  final String id;
  final String? fileUrl;
  final String? mimeType;
  final int? width;
  final int? height;

  ExploreAssetVersion({
    required this.id,
    this.fileUrl,
    this.mimeType,
    this.width,
    this.height,
  });

  factory ExploreAssetVersion.fromJson(Map<String, dynamic> json) =>
      _$ExploreAssetVersionFromJson(json);

  Map<String, dynamic> toJson() => _$ExploreAssetVersionToJson(this);
}

@JsonSerializable()
class ExplorePostUser {
  final String id;
  final String username;
  final String? avatarUrl;

  ExplorePostUser({
    required this.id,
    required this.username,
    this.avatarUrl,
  });

  factory ExplorePostUser.fromJson(Map<String, dynamic> json) =>
      _$ExplorePostUserFromJson(json);

  Map<String, dynamic> toJson() => _$ExplorePostUserToJson(this);
}

@JsonSerializable()
class ExplorePost {
  final String id;
  final String? caption;
  final int likeCount;
  final int viewCount;
  final int commentCount;
  final ExplorePostUser? user;

  ExplorePost({
    required this.id,
    this.caption,
    this.likeCount = 0,
    this.viewCount = 0,
    this.commentCount = 0,
    this.user,
  });

  factory ExplorePost.fromJson(Map<String, dynamic> json) =>
      _$ExplorePostFromJson(json);

  Map<String, dynamic> toJson() => _$ExplorePostToJson(this);
}
