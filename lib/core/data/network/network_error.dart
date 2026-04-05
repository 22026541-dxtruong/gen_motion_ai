import 'package:dio/dio.dart';

String networkErrorMessage(Object error) {
  if (error is DioException) {
    final data = error.response?.data;

    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
      if (message is List) {
        final parts = message.whereType<String>().toList();
        if (parts.isNotEmpty) {
          return parts.join('\n');
        }
      }
      final errorText = data['error'];
      if (errorText is String && errorText.trim().isNotEmpty) {
        return errorText;
      }
    }

    if (error.message != null && error.message!.trim().isNotEmpty) {
      return error.message!;
    }
  }

  return error.toString();
}
