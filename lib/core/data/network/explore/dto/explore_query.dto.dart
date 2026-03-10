import 'package:json_annotation/json_annotation.dart';

part 'explore_query.dto.g.dart';

@JsonSerializable()
class ExploreQuery {
  final String? topic;
  final String? trending;
  final String? sort;
  final int? limit;
  final String? cursor;

  ExploreQuery({
    this.topic,
    this.trending,
    this.sort,
    this.limit,
    this.cursor,
  });

  factory ExploreQuery.fromJson(Map<String, dynamic> json) =>
      _$ExploreQueryFromJson(json);

  Map<String, dynamic> toJson() => _$ExploreQueryToJson(this);
}

