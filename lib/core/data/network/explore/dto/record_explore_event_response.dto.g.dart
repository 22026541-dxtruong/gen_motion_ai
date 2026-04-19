// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'record_explore_event_response.dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecordExploreEventResponseDto _$RecordExploreEventResponseDtoFromJson(
  Map<String, dynamic> json,
) => RecordExploreEventResponseDto(
  ok: json['ok'] as bool,
  postId: json['postId'] as String,
  topic: json['topic'] as String?,
  eventType: json['eventType'] as String,
  weight: (json['weight'] as num).toDouble(),
);

Map<String, dynamic> _$RecordExploreEventResponseDtoToJson(
  RecordExploreEventResponseDto instance,
) => <String, dynamic>{
  'ok': instance.ok,
  'postId': instance.postId,
  'topic': instance.topic,
  'eventType': instance.eventType,
  'weight': instance.weight,
};
