import 'package:json_annotation/json_annotation.dart';

part 'create_follow.dto.g.dart';

@JsonSerializable()
class CreateFollowDto {
  final String followingId;

  const CreateFollowDto({required this.followingId});

  factory CreateFollowDto.fromJson(Map<String, dynamic> json) =>
      _$CreateFollowDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreateFollowDtoToJson(this);
}
