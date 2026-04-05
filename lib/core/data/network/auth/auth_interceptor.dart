import 'package:dio/dio.dart';
import 'package:gen_motion_ai/core/data/local/storage/secure_storage.dart';
import 'package:gen_motion_ai/core/data/network/api_endpoints.dart';
import 'package:gen_motion_ai/core/data/network/auth/dto/auth_response.dto.dart';
import 'package:gen_motion_ai/core/data/network/auth/dto/refresh_token.dto.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._dio, this.secureStorage);

  static const _retryKey = 'auth_retry';
  static const _skipRefreshKey = 'skip_auth_refresh';

  final Dio _dio;
  final SecureStorage secureStorage;
  Future<String?>? _refreshFuture;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final token = await secureStorage.getAccessToken();

      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (_) {}

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final requestOptions = err.requestOptions;
    final isUnauthorized = err.response?.statusCode == 401;
    final alreadyRetried = requestOptions.extra[_retryKey] == true;
    final skipRefresh = requestOptions.extra[_skipRefreshKey] == true;

    if (!isUnauthorized ||
        alreadyRetried ||
        skipRefresh ||
        _isAuthRoute(requestOptions.path)) {
      if (isUnauthorized && _isAuthRoute(requestOptions.path)) {
        await secureStorage.clearAllTokens();
      }
      return handler.next(err);
    }

    try {
      final accessToken = await _refreshAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        await secureStorage.clearAllTokens();
        return handler.next(err);
      }

      final response = await _dio.fetch<dynamic>(
        requestOptions.copyWith(
          headers: {
            ...requestOptions.headers,
            'Authorization': 'Bearer $accessToken',
          },
          extra: {...requestOptions.extra, _retryKey: true},
        ),
      );

      return handler.resolve(response);
    } catch (_) {
      await secureStorage.clearAllTokens();
    }

    return handler.next(err);
  }

  bool _isAuthRoute(String path) {
    return path.endsWith(ApiEndpoints.login) ||
        path.endsWith(ApiEndpoints.register) ||
        path.endsWith(ApiEndpoints.refresh) ||
        path.endsWith(ApiEndpoints.logout) ||
        path.endsWith(ApiEndpoints.logoutAll);
  }

  Future<String?> _refreshAccessToken() async {
    _refreshFuture ??= _performRefresh();
    try {
      return await _refreshFuture;
    } finally {
      _refreshFuture = null;
    }
  }

  Future<String?> _performRefresh() async {
    final refreshToken = await secureStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return null;
    }

    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.refresh,
      data: RefreshTokenDto(refreshToken: refreshToken).toJson(),
      options: Options(extra: {_skipRefreshKey: true}),
    );

    final data = response.data;
    if (data == null) {
      return null;
    }

    final authResponse = AuthResponse.fromJson(data);
    await secureStorage.saveAccessToken(authResponse.accessToken);
    await secureStorage.saveRefreshToken(authResponse.refreshToken);

    return authResponse.accessToken;
  }
}
