// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'follower.dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FollowerDto _$FollowerDtoFromJson(Map<String, dynamic> json) => FollowerDto(
  id: json['id'] as String,
  follower: FollowUserDto.fromJson(json['follower'] as Map<String, dynamic>),
);

Map<String, dynamic> _$FollowerDtoToJson(FollowerDto instance) =>
    <String, dynamic>{'id': instance.id, 'follower': instance.follower};
