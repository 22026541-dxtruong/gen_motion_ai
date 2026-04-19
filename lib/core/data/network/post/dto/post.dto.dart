import 'package:json_annotation/json_annotation.dart';

part 'post.dto.g.dart';

@JsonSerializable()
class PostDto {
  final String id;
  final String userId;
  final String assetVersionId;
  final String? caption;
  final bool isPublic;
  final int likeCount;
  final int commentCount;
  final int viewCount;
  final DateTime createdAt;

  const PostDto({
    required this.id,
    required this.userId,
    required this.assetVersionId,
    required this.caption,
    required this.isPublic,
    required this.likeCount,
    required this.commentCount,
    required this.viewCount,
    required this.createdAt,
  });

  factory PostDto.fromJson(Map<String, dynamic> json) =>
      _$PostDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PostDtoToJson(this);
}
