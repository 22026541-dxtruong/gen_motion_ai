import 'package:json_annotation/json_annotation.dart';

part 'follow_user.dto.g.dart';

@JsonSerializable()
class FollowUserDto {
  final String id;
  final String username;

  FollowUserDto({
    required this.id,
    required this.username,
  });

  factory FollowUserDto.fromJson(Map<String, dynamic> json) =>
      _$FollowUserDtoFromJson(json);

  Map<String, dynamic> toJson() => _$FollowUserDtoToJson(this);
}
