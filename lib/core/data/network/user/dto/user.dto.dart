import 'package:json_annotation/json_annotation.dart';

part 'user.dto.g.dart';

@JsonSerializable()
class UserDto {
  final String id;
  final String email;
  final String username;
  final String? avatarUrl;
  final String? bio;

  UserDto({
    required this.id,
    required this.email,
    required this.username,
    this.avatarUrl,
    this.bio,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) => _$UserDtoFromJson(json);
  Map<String, dynamic> toJson() => _$UserDtoToJson(this);
}