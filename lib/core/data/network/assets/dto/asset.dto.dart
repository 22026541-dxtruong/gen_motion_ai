class AssetDto {
  const AssetDto({
    required this.id,
    required this.userId,
    this.jobId,
    required this.type,
    required this.role,
    this.originalName,
    this.mimeType,
    this.versions = const [],
    this.user,
    this.job,
  });

  final String id;
  final String userId;
  final String? jobId;
  final String type;
  final String role;
  final String? originalName;
  final String? mimeType;
  final List<AssetVersionDto> versions;
  final AssetUserSummaryDto? user;
  final AssetJobSummaryDto? job;

  factory AssetDto.fromJson(Map<String, dynamic> json) {
    return AssetDto(
      id: json['id'] as String,
      userId: json['userId'] as String,
      jobId: json['jobId'] as String?,
      type: json['type'] as String,
      role: json['role'] as String,
      originalName: json['originalName'] as String?,
      mimeType: json['mimeType'] as String?,
      versions: (json['versions'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(AssetVersionDto.fromJson)
          .toList(),
      user: json['user'] is Map<String, dynamic>
          ? AssetUserSummaryDto.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      job: json['job'] is Map<String, dynamic>
          ? AssetJobSummaryDto.fromJson(json['job'] as Map<String, dynamic>)
          : null,
    );
  }
}

class AssetVersionDto {
  const AssetVersionDto({
    required this.id,
    required this.version,
    required this.bucket,
    required this.objectKey,
    this.originalName,
    this.mimeType,
    this.sizeBytes,
    required this.createdAt,
    this.metadata,
  });

  final String id;
  final int version;
  final String bucket;
  final String objectKey;
  final String? originalName;
  final String? mimeType;
  final int? sizeBytes;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  factory AssetVersionDto.fromJson(Map<String, dynamic> json) {
    return AssetVersionDto(
      id: json['id'] as String,
      version: (json['version'] as num?)?.toInt() ?? 1,
      bucket: json['bucket'] as String,
      objectKey: json['objectKey'] as String,
      originalName: json['originalName'] as String?,
      mimeType: json['mimeType'] as String?,
      sizeBytes: (json['sizeBytes'] as num?)?.toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      metadata: json['metadata'] is Map<String, dynamic>
          ? json['metadata'] as Map<String, dynamic>
          : null,
    );
  }
}

class AssetUserSummaryDto {
  const AssetUserSummaryDto({required this.id, required this.username});

  final String id;
  final String username;

  factory AssetUserSummaryDto.fromJson(Map<String, dynamic> json) {
    return AssetUserSummaryDto(
      id: json['id'] as String,
      username: json['username'] as String,
    );
  }
}

class AssetJobSummaryDto {
  const AssetJobSummaryDto({
    required this.id,
    required this.type,
    required this.status,
  });

  final String id;
  final String type;
  final String status;

  factory AssetJobSummaryDto.fromJson(Map<String, dynamic> json) {
    return AssetJobSummaryDto(
      id: json['id'] as String,
      type: json['type'] as String,
      status: json['status'] as String,
    );
  }
}

class AssetDownloadUrlDto {
  const AssetDownloadUrlDto({required this.url, required this.expiresIn});

  final String url;
  final int expiresIn;

  factory AssetDownloadUrlDto.fromJson(Map<String, dynamic> json) {
    return AssetDownloadUrlDto(
      url: json['url'] as String,
      expiresIn: (json['expiresIn'] as num?)?.toInt() ?? 3600,
    );
  }
}
