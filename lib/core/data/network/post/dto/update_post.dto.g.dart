// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_post.dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdatePostDto _$UpdatePostDtoFromJson(Map<String, dynamic> json) =>
    UpdatePostDto(
      assetVersionId: json['assetVersionId'] as String?,
      caption: json['caption'] as String?,
      isPublic: json['isPublic'] as bool?,
    );

Map<String, dynamic> _$UpdatePostDtoToJson(UpdatePostDto instance) =>
    <String, dynamic>{
      'assetVersionId': instance.assetVersionId,
      'caption': instance.caption,
      'isPublic': instance.isPublic,
    };
