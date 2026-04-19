// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'explore_item.dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExploreItem _$ExploreItemFromJson(Map<String, dynamic> json) => ExploreItem(
  id: json['id'] as String,
  assetVersionId: json['assetVersionId'] as String,
  title: json['title'] as String,
  topic: json['topic'] as String,
  isTrending: json['isTrending'] as bool,
  score: (json['score'] as num).toDouble(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  personalScore: (json['personalScore'] as num?)?.toDouble(),
  assetVersion: ExploreAssetVersionDto.fromJson(
    json['assetVersion'] as Map<String, dynamic>,
  ),
  post: ExplorePostDto.fromJson(json['post'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ExploreItemToJson(ExploreItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'assetVersionId': instance.assetVersionId,
      'title': instance.title,
      'topic': instance.topic,
      'isTrending': instance.isTrending,
      'score': instance.score,
      'createdAt': instance.createdAt.toIso8601String(),
      'personalScore': instance.personalScore,
      'assetVersion': instance.assetVersion,
      'post': instance.post,
    };

ExploreAssetVersionDto _$ExploreAssetVersionDtoFromJson(
  Map<String, dynamic> json,
) => ExploreAssetVersionDto(
  id: json['id'] as String,
  fileUrl: json['fileUrl'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
  asset: json['asset'] == null
      ? null
      : ExploreAssetDto.fromJson(json['asset'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ExploreAssetVersionDtoToJson(
  ExploreAssetVersionDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'fileUrl': instance.fileUrl,
  'metadata': instance.metadata,
  'asset': instance.asset,
};

ExploreAssetDto _$ExploreAssetDtoFromJson(Map<String, dynamic> json) =>
    ExploreAssetDto(
      id: json['id'] as String,
      userId: json['userId'] as String,
      mimeType: json['mimeType'] as String?,
      originalName: json['originalName'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$ExploreAssetDtoToJson(ExploreAssetDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'mimeType': instance.mimeType,
      'originalName': instance.originalName,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

ExplorePostDto _$ExplorePostDtoFromJson(Map<String, dynamic> json) =>
    ExplorePostDto(
      id: json['id'] as String,
      caption: json['caption'] as String?,
      user: ExplorePostUserDto.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ExplorePostDtoToJson(ExplorePostDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'caption': instance.caption,
      'user': instance.user,
    };

ExplorePostUserDto _$ExplorePostUserDtoFromJson(Map<String, dynamic> json) =>
    ExplorePostUserDto(
      id: json['id'] as String,
      username: json['username'] as String,
      avatarUrl: json['avatarUrl'] as String?,
    );

Map<String, dynamic> _$ExplorePostUserDtoToJson(ExplorePostUserDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'avatarUrl': instance.avatarUrl,
    };
