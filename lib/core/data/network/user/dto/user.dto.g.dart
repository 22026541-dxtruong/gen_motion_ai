// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserDto _$UserDtoFromJson(Map<String, dynamic> json) => UserDto(
  id: json['id'] as String,
  email: json['email'] as String,
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
);

Map<String, dynamic> _$UserDtoToJson(UserDto instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'username': instance.username,
  'avatarUrl': instance.avatarUrl,
  'bio': instance.bio,
  'role': instance.role,
  'createdAt': instance.createdAt?.toIso8601String(),
  'credits': instance.credits,
  'counts': instance.counts,
};

UserCreditsDto _$UserCreditsDtoFromJson(Map<String, dynamic> json) =>
    UserCreditsDto(balance: (json['balance'] as num).toInt());

Map<String, dynamic> _$UserCreditsDtoToJson(UserCreditsDto instance) =>
    <String, dynamic>{'balance': instance.balance};

UserCountsDto _$UserCountsDtoFromJson(Map<String, dynamic> json) =>
    UserCountsDto(
      followers: (json['followers'] as num?)?.toInt() ?? 0,
      following: (json['following'] as num?)?.toInt() ?? 0,
      posts: (json['posts'] as num?)?.toInt() ?? 0,
      jobs: (json['jobs'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$UserCountsDtoToJson(UserCountsDto instance) =>
    <String, dynamic>{
      'followers': instance.followers,
      'following': instance.following,
      'posts': instance.posts,
      'jobs': instance.jobs,
    };
