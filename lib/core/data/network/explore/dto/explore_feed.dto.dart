import 'package:json_annotation/json_annotation.dart';
import 'package:gen_motion_ai/core/data/network/explore/dto/explore_item.dto.dart';

part 'explore_feed.dto.g.dart';

@JsonSerializable()
class ExploreFeedDto {
  final String mode;
  final List<ExploreItem> data;
  final String? nextCursor;
  final int limit;
  final String? fallback;
  final ExploreSignalsDto? signals;

  const ExploreFeedDto({
    required this.mode,
    required this.data,
    required this.nextCursor,
    required this.limit,
    this.fallback,
    this.signals,
  });

  factory ExploreFeedDto.fromJson(Map<String, dynamic> json) =>
      _$ExploreFeedDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ExploreFeedDtoToJson(this);
}

@JsonSerializable()
class ExploreSignalsDto {
  final List<ExploreTopTopicDto> topTopics;
  final int followingCreators;

  const ExploreSignalsDto({
    required this.topTopics,
    required this.followingCreators,
  });

  factory ExploreSignalsDto.fromJson(Map<String, dynamic> json) =>
      _$ExploreSignalsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ExploreSignalsDtoToJson(this);
}

@JsonSerializable()
class ExploreTopTopicDto {
  final String topic;
  final double score;

  const ExploreTopTopicDto({
    required this.topic,
    required this.score,
  });

  factory ExploreTopTopicDto.fromJson(Map<String, dynamic> json) =>
      _$ExploreTopTopicDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ExploreTopTopicDtoToJson(this);
}
