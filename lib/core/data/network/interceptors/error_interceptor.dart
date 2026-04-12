import 'package:dio/dio.dart';

class ErrorInterceptor extends Interceptor {
  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Extract error message from response
    String? errorMessage;

    if (err.response != null) {
      final data = err.response?.data;
      if (data is Map<String, dynamic>) {
        errorMessage = data['message'] ?? data['error'] ?? 'An error occurred';
      }
    }

    errorMessage ??= _getDioExceptionMessage(err);

    // Create a more user-friendly error
    final customError = DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: errorMessage,
      message: errorMessage,
    );

    return handler.next(customError);
  }

  String _getDioExceptionMessage(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.sendTimeout:
        return 'Request timeout. Please try again.';
      case DioExceptionType.receiveTimeout:
        return 'Response timeout. Please try again.';
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        if (statusCode == 401) {
          return 'Unauthorized. Please login again.';
        } else if (statusCode == 403) {
          return 'Forbidden. You do not have permission.';
        } else if (statusCode == 404) {
          return 'Resource not found.';
        } else if (statusCode == 429) {
          return 'Too many requests. Please wait before trying again.';
        } else if (statusCode == 500) {
          return 'Server error. Please try again later.';
        } else if (statusCode == 502 || statusCode == 503) {
          return 'Server temporarily unavailable. Please try again later.';
        }
        return 'An error occurred: $statusCode';
      case DioExceptionType.cancel:
        return 'Request cancelled.';
      case DioExceptionType.unknown:
        return 'Network error. Please check your connection.';
      case DioExceptionType.badCertificate:
        return 'Certificate error. Please contact support.';
      case DioExceptionType.connectionError:
        return 'Connection error. Please check your internet.';
    }
  }
}
