import 'package:json_annotation/json_annotation.dart';

part 'user.dto.g.dart';

@JsonSerializable(explicitToJson: true)
class UserDto {
  final String id;
  final String? email;
  final String username;
  final String? avatarUrl;
  final String? bio;
  final String? role;
  final DateTime? createdAt;
  final UserCreditsDto? credits;
  final UserCountsDto? counts;
  final UserJobsPageDto? jobs;

  UserDto({
    required this.id,
    this.email,
    required this.username,
    this.avatarUrl,
    this.bio,
    this.role,
    this.createdAt,
    this.credits,
    this.counts,
    this.jobs
  });

  int get creditBalance => credits?.balance ?? 0;

  factory UserDto.fromJson(Map<String, dynamic> json) => _$UserDtoFromJson(json);
  Map<String, dynamic> toJson() => _$UserDtoToJson(this);
}

@JsonSerializable()
class UserCreditsDto {
  final int balance;
  final DateTime updatedAt;

  const UserCreditsDto({required this.balance, required this.updatedAt});

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

@JsonSerializable()
class UserJobDto {
  final String id;
  final String type;
  final String status;
  final int progress;
  final String prompt;
  final String? negativePrompt;
  final String modelName;
  final bool turboEnabled;
  final int creditCost;
  final String? provider;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? failedAt;

  const UserJobDto({
    required this.id,
    required this.type,
    required this.status,
    required this.progress,
    required this.prompt,
    this.negativePrompt,
    required this.modelName,
    required this.turboEnabled,
    required this.creditCost,
    this.provider,
    this.errorMessage,
    required this.createdAt,
    required this.updatedAt,
    this.startedAt,
    this.completedAt,
    this.failedAt,
  });

  factory UserJobDto.fromJson(Map<String, dynamic> json) =>
      _$UserJobDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UserJobDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class UserJobsPageDto {
  final List<UserJobDto> data;
  final String? nextCursor;
  final int take;

  const UserJobsPageDto({
    required this.data,
    this.nextCursor,
    required this.take,
  });

  factory UserJobsPageDto.fromJson(Map<String, dynamic> json) =>
      _$UserJobsPageDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UserJobsPageDtoToJson(this);
}
