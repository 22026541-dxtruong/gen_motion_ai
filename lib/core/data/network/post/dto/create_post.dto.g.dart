// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_post.dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreatePostDto _$CreatePostDtoFromJson(Map<String, dynamic> json) =>
    CreatePostDto(
      assetVersionId: json['assetVersionId'] as String,
      caption: json['caption'] as String?,
      isPublic: json['isPublic'] as String,
    );

Map<String, dynamic> _$CreatePostDtoToJson(CreatePostDto instance) =>
    <String, dynamic>{
      'assetVersionId': instance.assetVersionId,
      'caption': instance.caption,
      'isPublic': instance.isPublic,
    };
