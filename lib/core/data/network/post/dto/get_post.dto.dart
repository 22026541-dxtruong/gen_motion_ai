import 'package:json_annotation/json_annotation.dart';

part 'get_post.dto.g.dart';

@JsonSerializable()
class GetPostDto {
  final String id;
  final String? caption;
  final int viewCount;
  @JsonKey(name: 'comment_count')
  final int commentCount;
  @JsonKey(name: 'like_count')
  final int likeCount;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  final PostUserDto user;
  @JsonKey(name: 'asset_version')
  final PostAssetVersionDto assetVersion;

  GetPostDto({
    required this.id,
    this.caption,
    required this.viewCount,
    required this.commentCount,
    required this.likeCount,
    required this.createdAt,
    required this.user,
    required this.assetVersion,
  });

  factory GetPostDto.fromJson(Map<String, dynamic> json) =>
      _$GetPostDtoFromJson(json);

  Map<String, dynamic> toJson() => _$GetPostDtoToJson(this);
}

@JsonSerializable()
class PostUserDto {
  final String id;
  final String username;

  PostUserDto({
    required this.id,
    required this.username,
  });

  factory PostUserDto.fromJson(Map<String, dynamic> json) =>
      _$PostUserDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PostUserDtoToJson(this);
}

@JsonSerializable()
class PostAssetVersionDto {
  final String id;
  @JsonKey(name: 'file_url')
  final String fileUrl;

  final Map<String, dynamic>? metadata;

  PostAssetVersionDto({
    required this.id,
    required this.fileUrl,
    this.metadata,
  });

  factory PostAssetVersionDto.fromJson(Map<String, dynamic> json) =>
      _$PostAssetVersionDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PostAssetVersionDtoToJson(this);
}
