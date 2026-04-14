import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gen_motion_ai/core/data/local/storage/secure_storage.dart';
import 'package:gen_motion_ai/core/data/network/auth/auth_interceptor.dart';
import 'package:gen_motion_ai/core/data/network/interceptors/retry_interceptor.dart';
import 'package:gen_motion_ai/core/data/network/interceptors/error_interceptor.dart';
import 'api_endpoints.dart';

class DioClient {
  late final Dio _dio;

  DioClient(SecureStorage secureStorage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors in order
    _dio.interceptors.addAll([
      // Auth interceptor (attach token)
      AuthInterceptor(_dio, secureStorage),
      // Retry interceptor (retry on failure)
      RetryInterceptor(_dio),
      // Error interceptor (format error messages)
      ErrorInterceptor(),
      // Response interceptor (extract data)
      InterceptorsWrapper(
        onResponse: (response, handler) {
          final data = response.data;
          if (data is Map<String, dynamic>) {
            if (data['success'] == true && data.containsKey('data')) {
              response.data = data['data'];
            } else {
              throw DioException(
                requestOptions: response.requestOptions,
                message: data['message'] ?? 'Unknown error',
              );
            }
          }
          handler.next(response);
        },
      ),
      // Logging interceptor
      LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
      ),
    ]);
  }

  Dio get dio => _dio;
}

final dioClientProvider = Provider<DioClient>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return DioClient(secureStorage);
});
