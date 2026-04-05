import 'package:gen_motion_ai/core/data/network/assets/dto/asset.dto.dart';

class CreateVideoJobRequestDto {
  const CreateVideoJobRequestDto({
    required this.inputAssetId,
    required this.prompt,
    this.negativePrompt,
    this.presetId,
  });

  final String inputAssetId;
  final String prompt;
  final String? negativePrompt;
  final String? presetId;

  Map<String, dynamic> toJson() => {
    'inputAssetId': inputAssetId,
    'prompt': prompt,
    if (negativePrompt != null && negativePrompt!.trim().isNotEmpty)
      'negativePrompt': negativePrompt,
    if (presetId != null) 'presetId': presetId,
  };
}

class CreateVideoJobResponseDto {
  const CreateVideoJobResponseDto({
    required this.jobId,
    required this.status,
    required this.creditCost,
    this.provider,
    this.modelName,
    this.presetId,
    this.tier,
    required this.turboEnabled,
    this.estimatedDurationSeconds,
  });

  final String jobId;
  final String status;
  final int creditCost;
  final String? provider;
  final String? modelName;
  final String? presetId;
  final String? tier;
  final bool turboEnabled;
  final int? estimatedDurationSeconds;

  factory CreateVideoJobResponseDto.fromJson(Map<String, dynamic> json) {
    return CreateVideoJobResponseDto(
      jobId: json['jobId'] as String,
      status: json['status'] as String,
      creditCost: (json['creditCost'] as num?)?.toInt() ?? 0,
      provider: json['provider'] as String?,
      modelName: json['modelName'] as String?,
      presetId: json['presetId'] as String?,
      tier: json['tier'] as String?,
      turboEnabled: json['turboEnabled'] as bool? ?? false,
      estimatedDurationSeconds: (json['estimatedDurationSeconds'] as num?)
          ?.toInt(),
    );
  }
}

class JobSignedAssetDto {
  const JobSignedAssetDto({
    required this.assetId,
    this.bucket,
    this.objectKey,
    this.mimeType,
    this.sizeBytes,
    required this.downloadUrl,
    required this.expiresIn,
    this.createdAt,
  });

  final String assetId;
  final String? bucket;
  final String? objectKey;
  final String? mimeType;
  final int? sizeBytes;
  final String downloadUrl;
  final int expiresIn;
  final DateTime? createdAt;

  factory JobSignedAssetDto.fromJson(Map<String, dynamic> json) {
    return JobSignedAssetDto(
      assetId: json['assetId'] as String,
      bucket: json['bucket'] as String?,
      objectKey: json['objectKey'] as String?,
      mimeType: json['mimeType'] as String?,
      sizeBytes: (json['sizeBytes'] as num?)?.toInt(),
      downloadUrl: json['downloadUrl'] as String,
      expiresIn: (json['expiresIn'] as num?)?.toInt() ?? 3600,
      createdAt: json['createdAt'] is String
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }
}

class JobLogDto {
  const JobLogDto({
    required this.jobId,
    required this.message,
    required this.createdAt,
  });

  final String jobId;
  final String message;
  final DateTime createdAt;

  factory JobLogDto.fromJson(Map<String, dynamic> json) {
    return JobLogDto(
      jobId: json['jobId'] as String,
      message: json['message'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class JobSummaryDto {
  const JobSummaryDto({
    required this.id,
    required this.type,
    required this.status,
    required this.progress,
    required this.prompt,
    this.provider,
    this.modelName,
    this.presetId,
    this.tier,
    this.estimatedDurationSeconds,
    this.workflow,
    required this.createdAt,
    required this.updatedAt,
    this.output,
    this.thumbnail,
  });

  final String id;
  final String type;
  final String status;
  final int progress;
  final String prompt;
  final String? provider;
  final String? modelName;
  final String? presetId;
  final String? tier;
  final int? estimatedDurationSeconds;
  final String? workflow;
  final DateTime createdAt;
  final DateTime updatedAt;
  final JobSignedAssetDto? output;
  final JobSignedAssetDto? thumbnail;

  factory JobSummaryDto.fromJson(Map<String, dynamic> json) {
    return JobSummaryDto(
      id: json['id'] as String,
      type: json['type'] as String,
      status: json['status'] as String,
      progress: (json['progress'] as num?)?.toInt() ?? 0,
      prompt: json['prompt'] as String? ?? '',
      provider: json['provider'] as String?,
      modelName: json['modelName'] as String?,
      presetId: json['presetId'] as String?,
      tier: json['tier'] as String?,
      estimatedDurationSeconds: (json['estimatedDurationSeconds'] as num?)
          ?.toInt(),
      workflow: json['workflow'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      output: json['output'] is Map<String, dynamic>
          ? JobSignedAssetDto.fromJson(json['output'] as Map<String, dynamic>)
          : null,
      thumbnail: json['thumbnail'] is Map<String, dynamic>
          ? JobSignedAssetDto.fromJson(
              json['thumbnail'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  bool get isTerminal => isTerminalJobStatus(status);
  bool get canCancel => canCancelJobStatus(status);
  double get progressValue => (progress.clamp(0, 100) as num).toDouble() / 100;
}

class JobDetailDto {
  const JobDetailDto({
    required this.id,
    required this.type,
    required this.status,
    required this.progress,
    required this.prompt,
    this.negativePrompt,
    this.provider,
    this.modelName,
    this.presetId,
    this.tier,
    this.estimatedDurationSeconds,
    this.workflow,
    required this.creditCost,
    this.errorMessage,
    required this.createdAt,
    required this.updatedAt,
    this.startedAt,
    this.completedAt,
    this.failedAt,
    this.inputAssets = const [],
    this.outputAssets = const [],
    this.output,
    this.logs = const [],
    this.thumbnailAssets = const [],
    this.thumbnail,
  });

  final String id;
  final String type;
  final String status;
  final int progress;
  final String prompt;
  final String? negativePrompt;
  final String? provider;
  final String? modelName;
  final String? presetId;
  final String? tier;
  final int? estimatedDurationSeconds;
  final String? workflow;
  final int creditCost;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? failedAt;
  final List<AssetDto> inputAssets;
  final List<AssetDto> outputAssets;
  final JobSignedAssetDto? output;
  final List<JobLogDto> logs;
  final List<AssetDto> thumbnailAssets;
  final JobSignedAssetDto? thumbnail;

  factory JobDetailDto.fromJson(Map<String, dynamic> json) {
    return JobDetailDto(
      id: json['id'] as String,
      type: json['type'] as String,
      status: json['status'] as String,
      progress: (json['progress'] as num?)?.toInt() ?? 0,
      prompt: json['prompt'] as String? ?? '',
      negativePrompt: json['negativePrompt'] as String?,
      provider: json['provider'] as String?,
      modelName: json['modelName'] as String?,
      presetId: json['presetId'] as String?,
      tier: json['tier'] as String?,
      estimatedDurationSeconds: (json['estimatedDurationSeconds'] as num?)
          ?.toInt(),
      workflow: json['workflow'] as String?,
      creditCost: (json['creditCost'] as num?)?.toInt() ?? 0,
      errorMessage: json['errorMessage'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      startedAt: json['startedAt'] is String
          ? DateTime.parse(json['startedAt'] as String)
          : null,
      completedAt: json['completedAt'] is String
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      failedAt: json['failedAt'] is String
          ? DateTime.parse(json['failedAt'] as String)
          : null,
      inputAssets: (json['inputAssets'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(AssetDto.fromJson)
          .toList(),
      outputAssets: (json['outputAssets'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(AssetDto.fromJson)
          .toList(),
      output: json['output'] is Map<String, dynamic>
          ? JobSignedAssetDto.fromJson(json['output'] as Map<String, dynamic>)
          : null,
      logs: (json['logs'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(JobLogDto.fromJson)
          .toList(),
      thumbnailAssets: (json['thumbnailAssets'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(AssetDto.fromJson)
          .toList(),
      thumbnail: json['thumbnail'] is Map<String, dynamic>
          ? JobSignedAssetDto.fromJson(
              json['thumbnail'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  bool get isTerminal => isTerminalJobStatus(status);
  bool get canCancel => canCancelJobStatus(status);
}

class JobResultDto {
  const JobResultDto({
    required this.jobId,
    required this.status,
    required this.progress,
    required this.creditCost,
    required this.resultReady,
    this.provider,
    this.modelName,
    this.presetId,
    this.tier,
    this.estimatedDurationSeconds,
    this.workflow,
    this.assetId,
    this.bucket,
    this.objectKey,
    this.mimeType,
    this.sizeBytes,
    this.downloadUrl,
    this.expiresIn,
    this.createdAt,
    this.thumbnail,
  });

  final String jobId;
  final String status;
  final int progress;
  final int creditCost;
  final bool resultReady;
  final String? provider;
  final String? modelName;
  final String? presetId;
  final String? tier;
  final int? estimatedDurationSeconds;
  final String? workflow;
  final String? assetId;
  final String? bucket;
  final String? objectKey;
  final String? mimeType;
  final int? sizeBytes;
  final String? downloadUrl;
  final int? expiresIn;
  final DateTime? createdAt;
  final JobSignedAssetDto? thumbnail;

  factory JobResultDto.fromJson(Map<String, dynamic> json) {
    return JobResultDto(
      jobId: json['jobId'] as String,
      status: json['status'] as String,
      progress: (json['progress'] as num?)?.toInt() ?? 0,
      creditCost: (json['creditCost'] as num?)?.toInt() ?? 0,
      resultReady: json['resultReady'] as bool? ?? false,
      provider: json['provider'] as String?,
      modelName: json['modelName'] as String?,
      presetId: json['presetId'] as String?,
      tier: json['tier'] as String?,
      estimatedDurationSeconds: (json['estimatedDurationSeconds'] as num?)
          ?.toInt(),
      workflow: json['workflow'] as String?,
      assetId: json['assetId'] as String?,
      bucket: json['bucket'] as String?,
      objectKey: json['objectKey'] as String?,
      mimeType: json['mimeType'] as String?,
      sizeBytes: (json['sizeBytes'] as num?)?.toInt(),
      downloadUrl: json['downloadUrl'] as String?,
      expiresIn: (json['expiresIn'] as num?)?.toInt(),
      createdAt: json['createdAt'] is String
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      thumbnail: json['thumbnail'] is Map<String, dynamic>
          ? JobSignedAssetDto.fromJson(
              json['thumbnail'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  factory JobResultDto.fromCreateJob(CreateVideoJobResponseDto job) {
    return JobResultDto(
      jobId: job.jobId,
      status: job.status,
      progress: 1,
      creditCost: job.creditCost,
      resultReady: false,
      provider: job.provider,
      modelName: job.modelName,
      presetId: job.presetId,
      tier: job.tier,
      estimatedDurationSeconds: job.estimatedDurationSeconds,
    );
  }

  bool get isTerminal => isTerminalJobStatus(status);
  bool get canCancel => canCancelJobStatus(status);
  double get progressValue => (progress.clamp(0, 100) as num).toDouble() / 100;
}

class CancelJobResponseDto {
  const CancelJobResponseDto({
    required this.jobId,
    required this.status,
    required this.refundedCredit,
  });

  final String jobId;
  final String status;
  final int refundedCredit;

  factory CancelJobResponseDto.fromJson(Map<String, dynamic> json) {
    return CancelJobResponseDto(
      jobId: json['jobId'] as String,
      status: json['status'] as String,
      refundedCredit: (json['refundedCredit'] as num?)?.toInt() ?? 0,
    );
  }
}

bool isTerminalJobStatus(String status) {
  switch (status) {
    case 'COMPLETED':
    case 'FAILED':
    case 'CANCELLED':
      return true;
    default:
      return false;
  }
}

bool canCancelJobStatus(String status) {
  switch (status) {
    case 'PENDING':
    case 'QUEUED':
    case 'PROCESSING':
      return true;
    default:
      return false;
  }
}
