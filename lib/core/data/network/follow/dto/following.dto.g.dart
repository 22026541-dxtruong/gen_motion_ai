// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'following.dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FollowingDto _$FollowingDtoFromJson(Map<String, dynamic> json) => FollowingDto(
  id: json['id'] as String,
  following: FollowUserDto.fromJson(json['following'] as Map<String, dynamic>),
);

Map<String, dynamic> _$FollowingDtoToJson(FollowingDto instance) =>
    <String, dynamic>{'id': instance.id, 'following': instance.following};
