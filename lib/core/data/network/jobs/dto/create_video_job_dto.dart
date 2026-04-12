import 'package:json_annotation/json_annotation.dart';

part 'create_video_job_dto.g.dart';

@JsonSerializable()
class CreateVideoJobDto {
  final String inputAssetId;
  final String prompt;
  final String? negativePrompt;
  final String? modelName;
  final String? aspectRatio;
  final bool? turboEnabled;
  final String? duration;

  CreateVideoJobDto({
    required this.inputAssetId,
    required this.prompt,
    this.negativePrompt,
    this.modelName,
    this.aspectRatio,
    this.turboEnabled,
    this.duration,
  });

  factory CreateVideoJobDto.fromJson(Map<String, dynamic> json) => _$CreateVideoJobDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreateVideoJobDtoToJson(this);
}
