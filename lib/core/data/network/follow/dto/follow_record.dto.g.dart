// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'follow_record.dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FollowRecordDto _$FollowRecordDtoFromJson(Map<String, dynamic> json) =>
    FollowRecordDto(
      id: json['id'] as String,
      followerId: json['followerId'] as String,
      followingId: json['followingId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$FollowRecordDtoToJson(FollowRecordDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'followerId': instance.followerId,
      'followingId': instance.followingId,
      'createdAt': instance.createdAt.toIso8601String(),
    };
