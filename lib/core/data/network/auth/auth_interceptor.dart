import 'package:dio/dio.dart';
import 'package:gen_motion_ai/core/data/local/storage/secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorage secureStorage;
  bool _isRefreshing = false;
  late final Dio _dio;

  AuthInterceptor(this.secureStorage) {
    _dio = Dio();
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      // Get access token from storage
      final token = await secureStorage.getAccessToken();

      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (e) {
      // Continue with request even if token retrieval fails
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      // Handle 401 Unauthorized
      try {
        // Try to refresh token
        final refreshToken = await secureStorage.getRefreshToken();

        if (refreshToken != null && refreshToken.isNotEmpty) {
          if (!_isRefreshing) {
            _isRefreshing = true;

            try {
              // Call refresh endpoint - adjust path as needed
              final response = await _dio.post(
                '${err.requestOptions.baseUrl}/auth/refresh',
                data: {'refreshToken': refreshToken},
              );

              if (response.statusCode == 200 && response.data is Map) {
                final newAccessToken = response.data['accessToken'] ?? response.data['access_token'];
                
                if (newAccessToken != null) {
                  // Save new token
                  await secureStorage.saveAccessToken(newAccessToken);

                  // Update original request with new token
                  err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

                  // Retry original request
                  _isRefreshing = false;
                  return handler.resolve(await _dio.request(
                    err.requestOptions.path,
                    options: Options(
                      method: err.requestOptions.method,
                      headers: err.requestOptions.headers,
                    ),
                    data: err.requestOptions.data,
                    queryParameters: err.requestOptions.queryParameters,
                  ));
                }
              }
            } catch (refreshErr) {
              _isRefreshing = false;
              // Refresh failed, clear tokens and return error
              await secureStorage.deleteAccessToken();
              await secureStorage.deleteRefreshToken();
              return handler.next(err);
            }
          }
        } else {
          // No refresh token, clear auth and fail
          await secureStorage.deleteAccessToken();
          await secureStorage.deleteRefreshToken();
        }
      } catch (e) {
        // Error during refresh process
      }

      return handler.next(err);
    }

    return handler.next(err);
  }
}
