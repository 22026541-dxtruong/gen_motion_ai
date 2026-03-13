import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_post.dto.freezed.dart';
part 'update_post.dto.g.dart';

@freezed
abstract class UpdatePostDto with _$UpdatePostDto {
  @JsonSerializable(includeIfNull: false)
  const factory UpdatePostDto({
    @JsonKey(name: 'asset_version_id') String? assetVersionId,
    String? caption,
    @JsonKey(name: 'is_public') bool? isPublic,
  }) = _UpdatePostDto;

  factory UpdatePostDto.fromJson(Map<String, dynamic> json) =>
      _$UpdatePostDtoFromJson(json);
}
