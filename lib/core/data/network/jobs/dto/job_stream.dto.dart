import 'package:gen_motion_ai/core/data/network/jobs/dto/job.dto.dart';

class JobStreamEventDto {
  const JobStreamEventDto._({
    required this.type,
    this.snapshot,
    this.status,
    this.log,
    this.heartbeat,
  });

  final String type;
  final JobStreamSnapshotDto? snapshot;
  final JobStreamStatusDto? status;
  final JobLogDto? log;
  final JobStreamHeartbeatDto? heartbeat;

  factory JobStreamEventDto.fromSse(
    String eventType,
    Map<String, dynamic> payload,
  ) {
    switch (eventType) {
      case 'snapshot':
        return JobStreamEventDto._(
          type: eventType,
          snapshot: JobStreamSnapshotDto.fromJson(payload),
        );
      case 'status':
        return JobStreamEventDto._(
          type: eventType,
          status: JobStreamStatusDto.fromJson(payload),
        );
      case 'log':
        return JobStreamEventDto._(
          type: eventType,
          log: JobLogDto.fromJson(payload),
        );
      case 'heartbeat':
        return JobStreamEventDto._(
          type: eventType,
          heartbeat: JobStreamHeartbeatDto.fromJson(payload),
        );
      default:
        throw UnsupportedError('Unsupported SSE event: $eventType');
    }
  }
}

class JobStreamSnapshotDto {
  const JobStreamSnapshotDto({
    required this.jobId,
    required this.status,
    required this.progress,
    this.errorMessage,
    this.provider,
    this.modelName,
    this.presetId,
    this.tier,
    this.estimatedDurationSeconds,
    this.workflow,
    required this.createdAt,
    required this.updatedAt,
    this.startedAt,
    this.completedAt,
    this.failedAt,
    this.logs = const [],
  });

  final String jobId;
  final String status;
  final int progress;
  final String? errorMessage;
  final String? provider;
  final String? modelName;
  final String? presetId;
  final String? tier;
  final int? estimatedDurationSeconds;
  final String? workflow;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? failedAt;
  final List<JobLogDto> logs;

  factory JobStreamSnapshotDto.fromJson(Map<String, dynamic> json) {
    return JobStreamSnapshotDto(
      jobId: json['jobId'] as String,
      status: json['status'] as String,
      progress: (json['progress'] as num?)?.toInt() ?? 0,
      errorMessage: json['errorMessage'] as String?,
      provider: json['provider'] as String?,
      modelName: json['modelName'] as String?,
      presetId: json['presetId'] as String?,
      tier: json['tier'] as String?,
      estimatedDurationSeconds:
          (json['estimatedDurationSeconds'] as num?)?.toInt(),
      workflow: json['workflow'] as String?,
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
      logs: (json['logs'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(JobLogDto.fromJson)
          .toList(),
    );
  }
}

class JobStreamStatusDto {
  const JobStreamStatusDto({
    required this.jobId,
    required this.status,
    required this.progress,
    this.errorMessage,
    this.startedAt,
    this.completedAt,
    this.failedAt,
    required this.occurredAt,
  });

  final String jobId;
  final String status;
  final int progress;
  final String? errorMessage;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? failedAt;
  final DateTime occurredAt;

  factory JobStreamStatusDto.fromJson(Map<String, dynamic> json) {
    return JobStreamStatusDto(
      jobId: json['jobId'] as String,
      status: json['status'] as String,
      progress: (json['progress'] as num?)?.toInt() ?? 0,
      errorMessage: json['errorMessage'] as String?,
      startedAt: json['startedAt'] is String
          ? DateTime.parse(json['startedAt'] as String)
          : null,
      completedAt: json['completedAt'] is String
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      failedAt: json['failedAt'] is String
          ? DateTime.parse(json['failedAt'] as String)
          : null,
      occurredAt: DateTime.parse(json['occurredAt'] as String),
    );
  }
}

class JobStreamHeartbeatDto {
  const JobStreamHeartbeatDto({
    required this.jobId,
    required this.timestamp,
  });

  final String jobId;
  final DateTime timestamp;

  factory JobStreamHeartbeatDto.fromJson(Map<String, dynamic> json) {
    return JobStreamHeartbeatDto(
      jobId: json['jobId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
