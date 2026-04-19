// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'explore_feed.dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExploreFeedDto _$ExploreFeedDtoFromJson(Map<String, dynamic> json) =>
    ExploreFeedDto(
      mode: json['mode'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => ExploreItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextCursor: json['nextCursor'] as String?,
      limit: (json['limit'] as num).toInt(),
      fallback: json['fallback'] as String?,
      signals: json['signals'] == null
          ? null
          : ExploreSignalsDto.fromJson(json['signals'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ExploreFeedDtoToJson(ExploreFeedDto instance) =>
    <String, dynamic>{
      'mode': instance.mode,
      'data': instance.data,
      'nextCursor': instance.nextCursor,
      'limit': instance.limit,
      'fallback': instance.fallback,
      'signals': instance.signals,
    };

ExploreSignalsDto _$ExploreSignalsDtoFromJson(Map<String, dynamic> json) =>
    ExploreSignalsDto(
      topTopics: (json['topTopics'] as List<dynamic>)
          .map((e) => ExploreTopTopicDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      followingCreators: (json['followingCreators'] as num).toInt(),
    );

Map<String, dynamic> _$ExploreSignalsDtoToJson(ExploreSignalsDto instance) =>
    <String, dynamic>{
      'topTopics': instance.topTopics,
      'followingCreators': instance.followingCreators,
    };

ExploreTopTopicDto _$ExploreTopTopicDtoFromJson(Map<String, dynamic> json) =>
    ExploreTopTopicDto(
      topic: json['topic'] as String,
      score: (json['score'] as num).toDouble(),
    );

Map<String, dynamic> _$ExploreTopTopicDtoToJson(ExploreTopTopicDto instance) =>
    <String, dynamic>{'topic': instance.topic, 'score': instance.score};
