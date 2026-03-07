import 'package:dio/dio.dart';
import 'package:gen_motion_ai/core/data/local/storage/secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorage secureStorage;

  AuthInterceptor(this.secureStorage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      // Lấy token từ storage
      final token = await secureStorage.getAccessToken();

      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (e) {
      // Log lỗi nếu cần, nhưng vẫn cho request tiếp tục
      // print('AuthInterceptor Error: $e');
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      // Xử lý khi token hết hạn hoặc không hợp lệ
      await secureStorage.deleteAccessToken();

      // TODO: Thêm logic điều hướng về màn hình Login hoặc trigger Refresh Token tại đây
    }
    return handler.next(err);
  }
}
