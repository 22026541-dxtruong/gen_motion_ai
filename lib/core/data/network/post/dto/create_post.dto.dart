import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_post.dto.g.dart';
part 'create_post.dto.freezed.dart';

@freezed
abstract class CreatePostDto with _$CreatePostDto {
  const factory CreatePostDto({
    @JsonKey(name: 'asset_version_id') required String assetVersionId,
    String? caption,
    @JsonKey(name: 'is_public') required String isPublic,
  }) = _CreatePostDto;

  factory CreatePostDto.fromJson(Map<String, dynamic> json) =>
      _$CreatePostDtoFromJson(json);
}
