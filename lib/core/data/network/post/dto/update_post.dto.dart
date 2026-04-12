import 'package:json_annotation/json_annotation.dart';

part 'update_post.dto.g.dart';

@JsonSerializable()
class UpdatePostDto {
  @JsonKey(name: 'asset_version_id')
  final String? assetVersionId;
  final String? caption;
  @JsonKey(name: 'is_public')
  final bool? isPublic;

  UpdatePostDto({this.assetVersionId, this.caption, this.isPublic});

  factory UpdatePostDto.fromJson(Map<String, dynamic> json) => _$UpdatePostDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UpdatePostDtoToJson(this);
}
