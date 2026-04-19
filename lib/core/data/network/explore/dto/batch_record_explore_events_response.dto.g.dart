// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'batch_record_explore_events_response.dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BatchRecordExploreEventsResponseDto
_$BatchRecordExploreEventsResponseDtoFromJson(Map<String, dynamic> json) =>
    BatchRecordExploreEventsResponseDto(
      ok: json['ok'] as bool,
      requested: (json['requested'] as num).toInt(),
      accepted: (json['accepted'] as num).toInt(),
      recordedCount: (json['recordedCount'] as num).toInt(),
      skippedCount: (json['skippedCount'] as num).toInt(),
      groupedByType: Map<String, int>.from(json['groupedByType'] as Map),
      topicUpdates: (json['topicUpdates'] as List<dynamic>)
          .map((e) => ExploreTopicUpdateDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      hiddenPostCount: (json['hiddenPostCount'] as num).toInt(),
    );

Map<String, dynamic> _$BatchRecordExploreEventsResponseDtoToJson(
  BatchRecordExploreEventsResponseDto instance,
) => <String, dynamic>{
  'ok': instance.ok,
  'requested': instance.requested,
  'accepted': instance.accepted,
  'recordedCount': instance.recordedCount,
  'skippedCount': instance.skippedCount,
  'groupedByType': instance.groupedByType,
  'topicUpdates': instance.topicUpdates,
  'hiddenPostCount': instance.hiddenPostCount,
};

ExploreTopicUpdateDto _$ExploreTopicUpdateDtoFromJson(
  Map<String, dynamic> json,
) => ExploreTopicUpdateDto(
  topic: json['topic'] as String,
  totalWeight: (json['totalWeight'] as num).toDouble(),
);

Map<String, dynamic> _$ExploreTopicUpdateDtoToJson(
  ExploreTopicUpdateDto instance,
) => <String, dynamic>{
  'topic': instance.topic,
  'totalWeight': instance.totalWeight,
};
