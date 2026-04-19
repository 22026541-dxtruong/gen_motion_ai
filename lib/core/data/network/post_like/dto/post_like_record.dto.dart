import 'package:json_annotation/json_annotation.dart';

part 'post_like_record.dto.g.dart';

@JsonSerializable()
class PostLikeRecordDto {
  final String id;
  final String userId;
  final String postId;
  final DateTime createdAt;

  const PostLikeRecordDto({
    required this.id,
    required this.userId,
    required this.postId,
    required this.createdAt,
  });

  factory PostLikeRecordDto.fromJson(Map<String, dynamic> json) =>
      _$PostLikeRecordDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PostLikeRecordDtoToJson(this);
}
