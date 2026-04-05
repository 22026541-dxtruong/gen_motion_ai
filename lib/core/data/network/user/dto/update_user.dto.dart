import 'package:json_annotation/json_annotation.dart';

part 'update_user.dto.g.dart';

@JsonSerializable(includeIfNull: false)
class UpdateUserDto {
  final String? username;
  final String? bio;
  final String? avatarUrl;

  const UpdateUserDto({this.username, this.bio, this.avatarUrl});

  factory UpdateUserDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateUserDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateUserDtoToJson(this);
}
