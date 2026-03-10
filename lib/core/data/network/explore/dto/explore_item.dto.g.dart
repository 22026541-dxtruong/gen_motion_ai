// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'explore_item.dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExploreItem _$ExploreItemFromJson(Map<String, dynamic> json) => ExploreItem(
  id: json['id'] as String,
  score: (json['score'] as num).toDouble(),
);

Map<String, dynamic> _$ExploreItemToJson(ExploreItem instance) =>
    <String, dynamic>{'id': instance.id, 'score': instance.score};
