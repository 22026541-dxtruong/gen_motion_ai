import 'package:freezed_annotation/freezed_annotation.dart';

part 'get_post.dto.freezed.dart';
part 'get_post.dto.g.dart';

@freezed
abstract class GetPostDto with _$GetPostDto {
  const factory GetPostDto({
    required String id,
    String? caption,
    required int viewCount,
    required int commentCount,
    required int likeCount,
    required DateTime createdAt,
    @Default(false) bool isLiked,
    @Default(false) bool isFollowed,
    required PostUserDto user,
    required PostAssetVersionDto assetVersion,
  }) = _GetPostDto;

  factory GetPostDto.fromJson(Map<String, dynamic> json) =>
      _$GetPostDtoFromJson(json);
}

@freezed
abstract class PostUserDto with _$PostUserDto {
  const factory PostUserDto({
    required String id,
    required String username,
    String? avatarUrl,
  }) = _PostUserDto;

  factory PostUserDto.fromJson(Map<String, dynamic> json) =>
      _$PostUserDtoFromJson(json);
}

@freezed
abstract class PostAssetVersionDto with _$PostAssetVersionDto {
  const factory PostAssetVersionDto({
    required String id,
    String? fileUrl,
    Map<String, dynamic>? metadata,
  }) = _PostAssetVersionDto;

  factory PostAssetVersionDto.fromJson(Map<String, dynamic> json) =>
      _$PostAssetVersionDtoFromJson(json);
}
