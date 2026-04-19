import 'package:json_annotation/json_annotation.dart';

part 'create_post_like.dto.g.dart';

@JsonSerializable()
class CreatePostLikeDto {
  final String postId;

  const CreatePostLikeDto({required this.postId});

  factory CreatePostLikeDto.fromJson(Map<String, dynamic> json) =>
      _$CreatePostLikeDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreatePostLikeDtoToJson(this);
}
