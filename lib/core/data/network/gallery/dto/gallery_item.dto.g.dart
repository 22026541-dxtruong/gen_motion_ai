// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gallery_item.dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GalleryItemDto _$GalleryItemDtoFromJson(Map<String, dynamic> json) =>
    GalleryItemDto(
      isPublic: json['isPublic'] as bool? ?? false,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      assetVersion: json['assetVersion'] == null
          ? null
          : GalleryAssetVersionDto.fromJson(
              json['assetVersion'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$GalleryItemDtoToJson(GalleryItemDto instance) =>
    <String, dynamic>{
      'isPublic': instance.isPublic,
      'createdAt': instance.createdAt?.toIso8601String(),
      'assetVersion': instance.assetVersion,
    };

GalleryAssetVersionDto _$GalleryAssetVersionDtoFromJson(
  Map<String, dynamic> json,
) => GalleryAssetVersionDto(
  id: json['id'] as String,
  fileUrl: json['fileUrl'] as String?,
  mimeType: json['mimeType'] as String?,
  width: (json['width'] as num?)?.toInt(),
  height: (json['height'] as num?)?.toInt(),
  durationMs: (json['durationMs'] as num?)?.toInt(),
);

Map<String, dynamic> _$GalleryAssetVersionDtoToJson(
  GalleryAssetVersionDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'fileUrl': instance.fileUrl,
  'mimeType': instance.mimeType,
  'width': instance.width,
  'height': instance.height,
  'durationMs': instance.durationMs,
};
