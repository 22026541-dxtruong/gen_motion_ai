import 'package:json_annotation/json_annotation.dart';

part 'record_explore_event.dto.g.dart';

@JsonSerializable(includeIfNull: false)
class RecordExploreEventDto {
  final String postId;
  final String eventType;
  final Map<String, dynamic>? metadata;

  const RecordExploreEventDto({
    required this.postId,
    required this.eventType,
    this.metadata,
  });

  factory RecordExploreEventDto.fromJson(Map<String, dynamic> json) =>
      _$RecordExploreEventDtoFromJson(json);

  Map<String, dynamic> toJson() => _$RecordExploreEventDtoToJson(this);
}
