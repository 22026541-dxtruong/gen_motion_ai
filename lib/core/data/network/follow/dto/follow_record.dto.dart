import 'package:json_annotation/json_annotation.dart';

part 'follow_record.dto.g.dart';

@JsonSerializable()
class FollowRecordDto {
  final String id;
  final String followerId;
  final String followingId;
  final DateTime createdAt;

  const FollowRecordDto({
    required this.id,
    required this.followerId,
    required this.followingId,
    required this.createdAt,
  });

  factory FollowRecordDto.fromJson(Map<String, dynamic> json) =>
      _$FollowRecordDtoFromJson(json);

  Map<String, dynamic> toJson() => _$FollowRecordDtoToJson(this);
}
