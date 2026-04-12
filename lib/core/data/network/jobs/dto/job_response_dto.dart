import 'package:json_annotation/json_annotation.dart';

part 'job_response_dto.g.dart';

@JsonSerializable()
class JobResponseDto {
  final String? jobId;
  final String? id;
  final String status;
  final int? progress;
  final String? type;
  final String? prompt;
  final String? modelName;
  final String? provider;
  final int? creditCost;
  final String? errorMessage;
  final bool? resultReady;
  final String? downloadUrl;
  final String? mimeType;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;

  JobResponseDto({
    this.jobId,
    this.id,
    required this.status,
    this.progress,
    this.type,
    this.prompt,
    this.modelName,
    this.provider,
    this.creditCost,
    this.errorMessage,
    this.resultReady,
    this.downloadUrl,
    this.mimeType,
    this.createdAt,
    this.updatedAt,
    this.completedAt,
  });

  String get effectiveId => jobId ?? id ?? '';

  factory JobResponseDto.fromJson(Map<String, dynamic> json) =>
      _$JobResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$JobResponseDtoToJson(this);
}
