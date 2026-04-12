import 'package:json_annotation/json_annotation.dart';

part 'gallery_item.dto.g.dart';

@JsonSerializable()
class GalleryItemDto {
  final bool isPublic;
  final DateTime? createdAt;
  final GalleryAssetVersionDto? assetVersion;

  GalleryItemDto({
    this.isPublic = false,
    this.createdAt,
    this.assetVersion,
  });

  factory GalleryItemDto.fromJson(Map<String, dynamic> json) =>
      _$GalleryItemDtoFromJson(json);
  Map<String, dynamic> toJson() => _$GalleryItemDtoToJson(this);
}

@JsonSerializable()
class GalleryAssetVersionDto {
  final String id;
  final String? fileUrl;
  final String? mimeType;
  final int? width;
  final int? height;
  final int? durationMs;

  GalleryAssetVersionDto({
    required this.id,
    this.fileUrl,
    this.mimeType,
    this.width,
    this.height,
    this.durationMs,
  });

  factory GalleryAssetVersionDto.fromJson(Map<String, dynamic> json) =>
      _$GalleryAssetVersionDtoFromJson(json);
  Map<String, dynamic> toJson() => _$GalleryAssetVersionDtoToJson(this);
}
