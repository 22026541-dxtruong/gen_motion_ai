// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserDto _$UserDtoFromJson(Map<String, dynamic> json) => UserDto(
  id: json['id'] as String,
  email: json['email'] as String?,
  username: json['username'] as String,
  avatarUrl: json['avatarUrl'] as String?,
  bio: json['bio'] as String?,
  role: json['role'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  credits: json['credits'] == null
      ? null
      : UserCreditsDto.fromJson(json['credits'] as Map<String, dynamic>),
  counts: json['counts'] == null
      ? null
      : UserCountsDto.fromJson(json['counts'] as Map<String, dynamic>),
  jobs: json['jobs'] == null
      ? null
      : UserJobsPageDto.fromJson(json['jobs'] as Map<String, dynamic>),
);

Map<String, dynamic> _$UserDtoToJson(UserDto instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'username': instance.username,
  'avatarUrl': instance.avatarUrl,
  'bio': instance.bio,
  'role': instance.role,
  'createdAt': instance.createdAt?.toIso8601String(),
  'credits': instance.credits?.toJson(),
  'counts': instance.counts?.toJson(),
  'jobs': instance.jobs?.toJson(),
};

UserCreditsDto _$UserCreditsDtoFromJson(Map<String, dynamic> json) =>
    UserCreditsDto(
      balance: (json['balance'] as num).toInt(),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$UserCreditsDtoToJson(UserCreditsDto instance) =>
    <String, dynamic>{
      'balance': instance.balance,
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

UserCountsDto _$UserCountsDtoFromJson(Map<String, dynamic> json) =>
    UserCountsDto(
      followers: (json['followers'] as num).toInt(),
      following: (json['following'] as num).toInt(),
      posts: (json['posts'] as num).toInt(),
      jobs: (json['jobs'] as num).toInt(),
    );

Map<String, dynamic> _$UserCountsDtoToJson(UserCountsDto instance) =>
    <String, dynamic>{
      'followers': instance.followers,
      'following': instance.following,
      'posts': instance.posts,
      'jobs': instance.jobs,
    };

UserJobDto _$UserJobDtoFromJson(Map<String, dynamic> json) => UserJobDto(
  id: json['id'] as String,
  type: json['type'] as String,
  status: json['status'] as String,
  progress: (json['progress'] as num).toInt(),
  prompt: json['prompt'] as String,
  negativePrompt: json['negativePrompt'] as String?,
  modelName: json['modelName'] as String,
  turboEnabled: json['turboEnabled'] as bool,
  creditCost: (json['creditCost'] as num).toInt(),
  provider: json['provider'] as String?,
  errorMessage: json['errorMessage'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  startedAt: json['startedAt'] == null
      ? null
      : DateTime.parse(json['startedAt'] as String),
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
  failedAt: json['failedAt'] == null
      ? null
      : DateTime.parse(json['failedAt'] as String),
);

Map<String, dynamic> _$UserJobDtoToJson(UserJobDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'status': instance.status,
      'progress': instance.progress,
      'prompt': instance.prompt,
      'negativePrompt': instance.negativePrompt,
      'modelName': instance.modelName,
      'turboEnabled': instance.turboEnabled,
      'creditCost': instance.creditCost,
      'provider': instance.provider,
      'errorMessage': instance.errorMessage,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'startedAt': instance.startedAt?.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'failedAt': instance.failedAt?.toIso8601String(),
    };

UserJobsPageDto _$UserJobsPageDtoFromJson(Map<String, dynamic> json) =>
    UserJobsPageDto(
      data: (json['data'] as List<dynamic>)
          .map((e) => UserJobDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextCursor: json['nextCursor'] as String?,
      take: (json['take'] as num).toInt(),
    );

Map<String, dynamic> _$UserJobsPageDtoToJson(UserJobsPageDto instance) =>
    <String, dynamic>{
      'data': instance.data.map((e) => e.toJson()).toList(),
      'nextCursor': instance.nextCursor,
      'take': instance.take,
    };
