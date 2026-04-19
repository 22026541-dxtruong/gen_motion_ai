// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_post.dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreatePostDto _$CreatePostDtoFromJson(Map<String, dynamic> json) =>
    _CreatePostDto(
      assetVersionId: json['assetVersionId'] as String,
      caption: json['caption'] as String?,
      isPublic: json['isPublic'] as bool,
    );

Map<String, dynamic> _$CreatePostDtoToJson(_CreatePostDto instance) =>
    <String, dynamic>{
      'assetVersionId': instance.assetVersionId,
      'caption': instance.caption,
      'isPublic': instance.isPublic,
    };
