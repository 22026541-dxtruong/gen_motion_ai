import 'package:json_annotation/json_annotation.dart';

part 'post_like_user.dto.g.dart';

@JsonSerializable()
class PostLikeUserDto {
  final String id;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  final LikeUserDto user;

  PostLikeUserDto({
    required this.id,
    required this.createdAt,
    required this.user,
  });

  factory PostLikeUserDto.fromJson(Map<String, dynamic> json) =>
      _$PostLikeUserDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PostLikeUserDtoToJson(this);
}

@JsonSerializable()
class LikeUserDto {
  final String id;
  final String username;

  LikeUserDto({required this.id, required this.username});

  factory LikeUserDto.fromJson(Map<String, dynamic> json) =>
      _$LikeUserDtoFromJson(json);

  Map<String, dynamic> toJson() => _$LikeUserDtoToJson(this);
}
