import 'package:freezed_annotation/freezed_annotation.dart';

part 'get_post.dto.freezed.dart';
part 'get_post.dto.g.dart'; // File cho JSON

@freezed
abstract class GetPostDto with _$GetPostDto {
  const factory GetPostDto({
    required String id,
    String? caption,
    @JsonKey(name: 'view_count') required int viewCount,
    @JsonKey(name: 'comment_count') required int commentCount,
    @JsonKey(name: 'like_count') required int likeCount,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'is_liked') required bool isLiked,
    @JsonKey(name: 'is_followed') required bool isFollowed,
    required PostUserDto user,
    @JsonKey(name: 'asset_version') required PostAssetVersionDto assetVersion,
  }) = _GetPostDto;

  factory GetPostDto.fromJson(Map<String, dynamic> json) =>
      _$GetPostDtoFromJson(json);
}

@freezed
abstract class PostUserDto with _$PostUserDto {
  const factory PostUserDto({
    required String id,
    required String username,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
  }) = _PostUserDto;

  factory PostUserDto.fromJson(Map<String, dynamic> json) =>
      _$PostUserDtoFromJson(json);
}

@freezed
abstract class PostAssetVersionDto with _$PostAssetVersionDto {
  const factory PostAssetVersionDto({
    required String id,
    @JsonKey(name: 'file_url') required String fileUrl,
    Map<String, dynamic>? metadata,
  }) = _PostAssetVersionDto;

  factory PostAssetVersionDto.fromJson(Map<String, dynamic> json) =>
      _$PostAssetVersionDtoFromJson(json);
}
