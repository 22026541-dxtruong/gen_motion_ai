import 'package:json_annotation/json_annotation.dart';
import 'package:gen_motion_ai/core/data/network/explore/dto/record_explore_event.dto.dart';

part 'batch_record_explore_events.dto.g.dart';

@JsonSerializable()
class BatchRecordExploreEventsDto {
  final List<RecordExploreEventDto> events;

  const BatchRecordExploreEventsDto({required this.events});

  factory BatchRecordExploreEventsDto.fromJson(Map<String, dynamic> json) =>
      _$BatchRecordExploreEventsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$BatchRecordExploreEventsDtoToJson(this);
}
