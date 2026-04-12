// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JobResponseDto _$JobResponseDtoFromJson(Map<String, dynamic> json) =>
    JobResponseDto(
      jobId: json['jobId'] as String?,
      id: json['id'] as String?,
      status: json['status'] as String,
      progress: (json['progress'] as num?)?.toInt(),
      type: json['type'] as String?,
      prompt: json['prompt'] as String?,
      modelName: json['modelName'] as String?,
      provider: json['provider'] as String?,
      creditCost: (json['creditCost'] as num?)?.toInt(),
      errorMessage: json['errorMessage'] as String?,
      resultReady: json['resultReady'] as bool?,
      downloadUrl: json['downloadUrl'] as String?,
      mimeType: json['mimeType'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
    );

Map<String, dynamic> _$JobResponseDtoToJson(JobResponseDto instance) =>
    <String, dynamic>{
      'jobId': instance.jobId,
      'id': instance.id,
      'status': instance.status,
      'progress': instance.progress,
      'type': instance.type,
      'prompt': instance.prompt,
      'modelName': instance.modelName,
      'provider': instance.provider,
      'creditCost': instance.creditCost,
      'errorMessage': instance.errorMessage,
      'resultReady': instance.resultReady,
      'downloadUrl': instance.downloadUrl,
      'mimeType': instance.mimeType,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
    };
