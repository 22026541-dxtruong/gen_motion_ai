// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_post.dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreatePostDto _$CreatePostDtoFromJson(Map<String, dynamic> json) =>
    _CreatePostDto(
      assetVersionId: json['asset_version_id'] as String,
      caption: json['caption'] as String?,
      isPublic: json['is_public'] as String,
    );

Map<String, dynamic> _$CreatePostDtoToJson(_CreatePostDto instance) =>
    <String, dynamic>{
      'asset_version_id': instance.assetVersionId,
      'caption': instance.caption,
      'is_public': instance.isPublic,
    };
