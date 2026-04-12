import 'package:json_annotation/json_annotation.dart';

part 'user.dto.g.dart';

@JsonSerializable()
class UserDto {
  final String id;
  final String email;
  final String username;
  final String? avatarUrl;
  final String? bio;
  final String? role;
  final DateTime? createdAt;
  final UserCreditsDto? credits;
  final UserCountsDto? counts;

  UserDto({
    required this.id,
    required this.email,
    required this.username,
    this.avatarUrl,
    this.bio,
    this.role,
    this.createdAt,
    this.credits,
    this.counts,
  });

  int get creditBalance => credits?.balance ?? 0;

  factory UserDto.fromJson(Map<String, dynamic> json) => _$UserDtoFromJson(json);
  Map<String, dynamic> toJson() => _$UserDtoToJson(this);
}

@JsonSerializable()
class UserCreditsDto {
  final int balance;

  UserCreditsDto({required this.balance});

  factory UserCreditsDto.fromJson(Map<String, dynamic> json) =>
      _$UserCreditsDtoFromJson(json);
  Map<String, dynamic> toJson() => _$UserCreditsDtoToJson(this);
}

@JsonSerializable()
class UserCountsDto {
  final int followers;
  final int following;
  final int posts;
  final int jobs;

  UserCountsDto({
    this.followers = 0,
    this.following = 0,
    this.posts = 0,
    this.jobs = 0,
  });

  factory UserCountsDto.fromJson(Map<String, dynamic> json) =>
      _$UserCountsDtoFromJson(json);
  Map<String, dynamic> toJson() => _$UserCountsDtoToJson(this);
}