import 'package:json_annotation/json_annotation.dart';

part 'get_post.dto.g.dart';

@JsonSerializable()
class GetPostDto {
  final String id;
  final String? caption;
  final int viewCount;
  final int commentCount;
  final int likeCount;
  final DateTime createdAt;
  final bool isLiked;
  final bool isFollowed;
  final PostUserDto? user;
  final PostAssetVersionDto? assetVersion;

  GetPostDto({
    required this.id,
    this.caption,
    this.viewCount = 0,
    this.commentCount = 0,
    this.likeCount = 0,
    required this.createdAt,
    this.isLiked = false,
    this.isFollowed = false,
    this.user,
    this.assetVersion,
  });

  factory GetPostDto.fromJson(Map<String, dynamic> json) => _$GetPostDtoFromJson(json);

  Map<String, dynamic> toJson() => _$GetPostDtoToJson(this);
}

@JsonSerializable()
class PostUserDto {
  final String id;
  final String username;
  final String? avatarUrl;

  PostUserDto({required this.id, required this.username, this.avatarUrl});

  factory PostUserDto.fromJson(Map<String, dynamic> json) => _$PostUserDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PostUserDtoToJson(this);
}

@JsonSerializable()
class PostAssetVersionDto {
  final String id;
  final String? fileUrl;
  final Map<String, dynamic>? metadata;

  PostAssetVersionDto({required this.id, this.fileUrl, this.metadata});

  factory PostAssetVersionDto.fromJson(Map<String, dynamic> json) => _$PostAssetVersionDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PostAssetVersionDtoToJson(this);
}
