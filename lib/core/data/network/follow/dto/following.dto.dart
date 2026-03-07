import 'package:json_annotation/json_annotation.dart';
import 'follow_user.dto.dart';

part 'following.dto.g.dart';

@JsonSerializable()
class FollowingDto {
  final String id;
  final FollowUserDto following;

  FollowingDto({
    required this.id,
    required this.following,
  });

  factory FollowingDto.fromJson(Map<String, dynamic> json) =>
      _$FollowingDtoFromJson(json);

  Map<String, dynamic> toJson() => _$FollowingDtoToJson(this);
}