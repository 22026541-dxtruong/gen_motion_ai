import 'package:json_annotation/json_annotation.dart';

part 'explore_item.dto.g.dart';

@JsonSerializable()
class ExploreItem {
  final String id;
  final String assetVersionId;
  final String title;
  final String topic;
  final bool isTrending;
  final double score;
  final DateTime createdAt;
  final double? personalScore;
  final ExploreAssetVersionDto assetVersion;
  final ExplorePostDto post;

  const ExploreItem({
    required this.id,
    required this.assetVersionId,
    required this.title,
    required this.topic,
    required this.isTrending,
    required this.score,
    required this.createdAt,
    this.personalScore,
    required this.assetVersion,
    required this.post,
  });

  factory ExploreItem.fromJson(Map<String, dynamic> json) =>
      _$ExploreItemFromJson(json);

  Map<String, dynamic> toJson() => _$ExploreItemToJson(this);
}

@JsonSerializable()
class ExploreAssetVersionDto {
  final String id;
  final String? fileUrl;
  final Map<String, dynamic>? metadata;
  final ExploreAssetDto? asset;

  const ExploreAssetVersionDto({
    required this.id,
    this.fileUrl,
    this.metadata,
    this.asset,
  });

  factory ExploreAssetVersionDto.fromJson(Map<String, dynamic> json) =>
      _$ExploreAssetVersionDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ExploreAssetVersionDtoToJson(this);
}

@JsonSerializable()
class ExploreAssetDto {
  final String id;
  final String userId;
  final String? mimeType;
  final String? originalName;
  final DateTime? createdAt;

  const ExploreAssetDto({
    required this.id,
    required this.userId,
    this.mimeType,
    this.originalName,
    this.createdAt,
  });

  factory ExploreAssetDto.fromJson(Map<String, dynamic> json) =>
      _$ExploreAssetDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ExploreAssetDtoToJson(this);
}

@JsonSerializable()
class ExplorePostDto {
  final String id;
  final String? caption;
  final ExplorePostUserDto user;

  const ExplorePostDto({
    required this.id,
    this.caption,
    required this.user,
  });

  factory ExplorePostDto.fromJson(Map<String, dynamic> json) =>
      _$ExplorePostDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ExplorePostDtoToJson(this);
}

@JsonSerializable()
class ExplorePostUserDto {
  final String id;
  final String username;
  final String? avatarUrl;

  const ExplorePostUserDto({
    required this.id,
    required this.username,
    this.avatarUrl,
  });

  factory ExplorePostUserDto.fromJson(Map<String, dynamic> json) =>
      _$ExplorePostUserDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ExplorePostUserDtoToJson(this);
}
