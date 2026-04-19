// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'record_explore_event.dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecordExploreEventDto _$RecordExploreEventDtoFromJson(
  Map<String, dynamic> json,
) => RecordExploreEventDto(
  postId: json['postId'] as String,
  eventType: json['eventType'] as String,
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$RecordExploreEventDtoToJson(
  RecordExploreEventDto instance,
) => <String, dynamic>{
  'postId': instance.postId,
  'eventType': instance.eventType,
  'metadata': ?instance.metadata,
};
