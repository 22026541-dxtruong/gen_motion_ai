import 'package:json_annotation/json_annotation.dart';

part 'comment_record.dto.g.dart';

@JsonSerializable()
class CommentRecordDto {
  final String id;
  final String userId;
  final String postId;
  final String content;
  final DateTime createdAt;

  const CommentRecordDto({
    required this.id,
    required this.userId,
    required this.postId,
    required this.content,
    required this.createdAt,
  });

  factory CommentRecordDto.fromJson(Map<String, dynamic> json) =>
      _$CommentRecordDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CommentRecordDtoToJson(this);
}
