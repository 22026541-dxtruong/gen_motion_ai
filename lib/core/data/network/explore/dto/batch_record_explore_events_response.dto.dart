import 'package:json_annotation/json_annotation.dart';

part 'batch_record_explore_events_response.dto.g.dart';

@JsonSerializable()
class BatchRecordExploreEventsResponseDto {
  final bool ok;
  final int requested;
  final int accepted;
  final int recordedCount;
  final int skippedCount;
  final Map<String, int> groupedByType;
  final List<ExploreTopicUpdateDto> topicUpdates;
  final int hiddenPostCount;

  const BatchRecordExploreEventsResponseDto({
    required this.ok,
    required this.requested,
    required this.accepted,
    required this.recordedCount,
    required this.skippedCount,
    required this.groupedByType,
    required this.topicUpdates,
    required this.hiddenPostCount,
  });

  factory BatchRecordExploreEventsResponseDto.fromJson(
    Map<String, dynamic> json,
  ) => _$BatchRecordExploreEventsResponseDtoFromJson(json);

  Map<String, dynamic> toJson() =>
      _$BatchRecordExploreEventsResponseDtoToJson(this);
}

@JsonSerializable()
class ExploreTopicUpdateDto {
  final String topic;
  final double totalWeight;

  const ExploreTopicUpdateDto({
    required this.topic,
    required this.totalWeight,
  });

  factory ExploreTopicUpdateDto.fromJson(Map<String, dynamic> json) =>
      _$ExploreTopicUpdateDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ExploreTopicUpdateDtoToJson(this);
}
