import 'package:json_annotation/json_annotation.dart';

part 'comment.dto.g.dart';

@JsonSerializable()
class CommentDto {
  final String id;
  final String content;
  final DateTime createdAt;
  final CommentUserDto user;

  CommentDto({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.user,
  });

  factory CommentDto.fromJson(Map<String, dynamic> json) =>
      _$CommentDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CommentDtoToJson(this);
}

@JsonSerializable()
class CommentUserDto {
  final String id;
  final String username;

  CommentUserDto({required this.id, required this.username});

  factory CommentUserDto.fromJson(Map<String, dynamic> json) =>
      _$CommentUserDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CommentUserDtoToJson(this);
}
