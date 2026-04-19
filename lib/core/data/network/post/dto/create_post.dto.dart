import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_post.dto.g.dart';
part 'create_post.dto.freezed.dart';

@freezed
abstract class CreatePostDto with _$CreatePostDto {
  const factory CreatePostDto({
    required String assetVersionId,
    String? caption,
    required bool isPublic,
  }) = _CreatePostDto;

  factory CreatePostDto.fromJson(Map<String, dynamic> json) =>
      _$CreatePostDtoFromJson(json);
}
