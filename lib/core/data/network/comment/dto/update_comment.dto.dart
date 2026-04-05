import 'package:json_annotation/json_annotation.dart';

part 'update_comment.dto.g.dart';

@JsonSerializable()
class UpdateCommentDto {
  final String content;

  UpdateCommentDto({required this.content});

  factory UpdateCommentDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateCommentDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateCommentDtoToJson(this);
}
