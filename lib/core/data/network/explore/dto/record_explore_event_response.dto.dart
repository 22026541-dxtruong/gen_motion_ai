import 'package:json_annotation/json_annotation.dart';

part 'record_explore_event_response.dto.g.dart';

@JsonSerializable()
class RecordExploreEventResponseDto {
  final bool ok;
  final String postId;
  final String? topic;
  final String eventType;
  final double weight;

  const RecordExploreEventResponseDto({
    required this.ok,
    required this.postId,
    required this.topic,
    required this.eventType,
    required this.weight,
  });

  factory RecordExploreEventResponseDto.fromJson(Map<String, dynamic> json) =>
      _$RecordExploreEventResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$RecordExploreEventResponseDtoToJson(this);
}
