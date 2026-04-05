import 'package:json_annotation/json_annotation.dart';

part 'create_comment.dto.g.dart';

@JsonSerializable()
class CreateCommentDto {
  final String content;

  CreateCommentDto({required this.content});

  factory CreateCommentDto.fromJson(Map<String, dynamic> json) =>
      _$CreateCommentDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreateCommentDtoToJson(this);
}
