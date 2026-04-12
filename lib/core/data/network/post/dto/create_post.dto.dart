import 'package:json_annotation/json_annotation.dart';

part 'create_post.dto.g.dart';

@JsonSerializable()
class CreatePostDto {
  @JsonKey(name: 'asset_version_id')
  final String assetVersionId;
  final String? caption;
  @JsonKey(name: 'is_public')
  final String isPublic;

  CreatePostDto({required this.assetVersionId, this.caption, required this.isPublic});

  factory CreatePostDto.fromJson(Map<String, dynamic> json) => _$CreatePostDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreatePostDtoToJson(this);
}
