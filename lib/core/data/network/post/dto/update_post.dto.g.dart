// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_post.dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdatePostDto _$UpdatePostDtoFromJson(Map<String, dynamic> json) =>
    UpdatePostDto(
      assetVersionId: json['asset_version_id'] as String?,
      caption: json['caption'] as String?,
      isPublic: json['is_public'] as bool?,
    );

Map<String, dynamic> _$UpdatePostDtoToJson(UpdatePostDto instance) =>
    <String, dynamic>{
      'asset_version_id': instance.assetVersionId,
      'caption': instance.caption,
      'is_public': instance.isPublic,
    };
