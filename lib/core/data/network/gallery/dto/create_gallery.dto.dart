import 'package:json_annotation/json_annotation.dart';

part 'create_gallery.dto.g.dart';

@JsonSerializable()
class CreateGalleryDto {
  final String assetVersionId;

  CreateGalleryDto({required this.assetVersionId});

  factory CreateGalleryDto.fromJson(Map<String, dynamic> json) =>
      _$CreateGalleryDtoFromJson(json);
  Map<String, dynamic> toJson() => _$CreateGalleryDtoToJson(this);
}
