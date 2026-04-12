class ApiError {
  final int? statusCode;
  final String code;
  final String message;
  final Object? details;
  final String? path;
  final String? timestamp;

  ApiError({
    this.statusCode,
    required this.code,
    required this.message,
    this.details,
    this.path,
    this.timestamp,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    final error = json['error'];
    if (error is Map<String, dynamic>) {
      return ApiError(
        statusCode: json['statusCode'] as int?,
        code: error['code']?.toString() ?? 'UNKNOWN_ERROR',
        message: error['message']?.toString() ?? 'Unknown error',
        details: error['details'],
        path: json['path'] as String?,
        timestamp: json['timestamp'] as String?,
      );
    }

    return ApiError(
      statusCode: json['statusCode'] as int?,
      code: 'UNKNOWN_ERROR',
      message: json['message']?.toString() ?? 'Unknown error',
      details: json['details'],
      path: json['path'] as String?,
      timestamp: json['timestamp'] as String?,
    );
  }

  String get displayMessage {
    final buffer = StringBuffer(message);
    if (details != null) {
      if (details is List) {
        buffer.write(': ${(details as List).join(', ')}');
      } else {
        buffer.write(': $details');
      }
    }
    return buffer.toString();
  }
}

class ApiException implements Exception {
  final ApiError error;

  ApiException(this.error);

  @override
  String toString() => '${error.code}: ${error.displayMessage}';
}

String formatApiErrorMessage(ApiError error) {
  return '${error.message}${error.details != null ? ' (${error.details})' : ''}';
}

ApiError? parseApiError(dynamic responseData) {
  if (responseData is Map<String, dynamic>) {
    return ApiError.fromJson(responseData);
  }
  return null;
}
