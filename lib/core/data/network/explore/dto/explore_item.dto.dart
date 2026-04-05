import 'package:json_annotation/json_annotation.dart';

part 'explore_item.dto.g.dart';

@JsonSerializable()
class ExploreItem {
  final String id;
  final double score;

  ExploreItem({required this.id, required this.score});

  factory ExploreItem.fromJson(Map<String, dynamic> json) =>
      _$ExploreItemFromJson(json);

  Map<String, dynamic> toJson() => _$ExploreItemToJson(this);
}
