// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'batch_record_explore_events.dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BatchRecordExploreEventsDto _$BatchRecordExploreEventsDtoFromJson(
  Map<String, dynamic> json,
) => BatchRecordExploreEventsDto(
  events: (json['events'] as List<dynamic>)
      .map((e) => RecordExploreEventDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$BatchRecordExploreEventsDtoToJson(
  BatchRecordExploreEventsDto instance,
) => <String, dynamic>{'events': instance.events};
