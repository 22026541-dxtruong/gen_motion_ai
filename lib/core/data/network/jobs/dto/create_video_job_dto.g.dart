// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_video_job_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateVideoJobDto _$CreateVideoJobDtoFromJson(Map<String, dynamic> json) =>
    CreateVideoJobDto(
      inputAssetId: json['inputAssetId'] as String,
      prompt: json['prompt'] as String,
      negativePrompt: json['negativePrompt'] as String?,
      modelName: json['modelName'] as String?,
      aspectRatio: json['aspectRatio'] as String?,
      turboEnabled: json['turboEnabled'] as bool?,
      duration: json['duration'] as String?,
    );

Map<String, dynamic> _$CreateVideoJobDtoToJson(CreateVideoJobDto instance) =>
    <String, dynamic>{
      'inputAssetId': instance.inputAssetId,
      'prompt': instance.prompt,
      'negativePrompt': instance.negativePrompt,
      'modelName': instance.modelName,
      'aspectRatio': instance.aspectRatio,
      'turboEnabled': instance.turboEnabled,
      'duration': instance.duration,
    };
