import 'package:json_annotation/json_annotation.dart';
import 'follow_user.dto.dart';

part 'follower.dto.g.dart';

@JsonSerializable()
class FollowerDto {
  final String id;
  final FollowUserDto follower;

  FollowerDto({required this.id, required this.follower});

  factory FollowerDto.fromJson(Map<String, dynamic> json) =>
      _$FollowerDtoFromJson(json);

  Map<String, dynamic> toJson() => _$FollowerDtoToJson(this);
}
