// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'explore_query.dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExploreQuery _$ExploreQueryFromJson(Map<String, dynamic> json) => ExploreQuery(
  mode: json['mode'] as String?,
  topic: json['topic'] as String?,
  trending: json['trending'] as String?,
  sort: json['sort'] as String?,
  limit: (json['limit'] as num?)?.toInt(),
  cursor: json['cursor'] as String?,
);

Map<String, dynamic> _$ExploreQueryToJson(ExploreQuery instance) =>
    <String, dynamic>{
      'mode': instance.mode,
      'topic': instance.topic,
      'trending': instance.trending,
      'sort': instance.sort,
      'limit': instance.limit,
      'cursor': instance.cursor,
    };
