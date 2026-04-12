import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  final Dio _dio;

  RetryInterceptor(this._dio);

  static const int _maxRetries = 3;
  static const int _initialDelayMs = 1000;

  int _getCurrentRetries(RequestOptions options) {
    return options.extra['_retry_count'] ?? 0;
  }

  void _setCurrentRetries(RequestOptions options, int count) {
    options.extra['_retry_count'] = count;
  }

  bool _shouldRetry(DioException err) {
    // Retry on network errors and specific status codes
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.unknown) {
      return true;
    }

    // Retry on 429 (Too Many Requests), 502, 503, 504
    if (err.response?.statusCode == 429 ||
        err.response?.statusCode == 502 ||
        err.response?.statusCode == 503 ||
        err.response?.statusCode == 504) {
      return true;
    }

    return false;
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final retries = _getCurrentRetries(err.requestOptions);

    if (_shouldRetry(err) && retries < _maxRetries) {
      _setCurrentRetries(err.requestOptions, retries + 1);

      // Exponential backoff
      final delayMs = _initialDelayMs * (1 << retries); // 1000, 2000, 4000
      await Future.delayed(Duration(milliseconds: delayMs));

      try {
        final response = await _dio.request(
              err.requestOptions.path,
              options: Options(
                method: err.requestOptions.method,
                headers: err.requestOptions.headers,
              ),
              data: err.requestOptions.data,
              queryParameters: err.requestOptions.queryParameters,
            );

        return handler.resolve(response);
      } catch (e) {
        return handler.next(err);
      }
    }

    return handler.next(err);
  }
}
