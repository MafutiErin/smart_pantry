import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class GeminiDioClient {
  final Dio dio;

  GeminiDioClient._(this.dio);

  factory GeminiDioClient.create() {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://generativelanguage.googleapis.com/v1beta',
        // Extended timeouts to handle slower API responses
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60), // Increased for Gemini
        sendTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json', 'x-goog-api-key': apiKey},
      ),
    );

    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
        compact: true,
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final key = dotenv.env['GEMINI_API_KEY'] ?? '';
          if (key.isEmpty) {
            handler.reject(
              DioException(
                requestOptions: options,
                error: 'Missing GEMINI_API_KEY in .env',
              ),
            );
            return;
          }
          handler.next(options);
        },
        onError: (error, handler) {
          handler.next(error);
        },
      ),
    );

    // Add retry interceptor
    dio.interceptors.add(_RetryInterceptor(dio));

    return GeminiDioClient._(dio);
  }
}

/// Retry interceptor with exponential backoff
class _RetryInterceptor extends Interceptor {
  final Dio dio;
  static const int _maxRetries = 3;
  static const Duration _baseDelay = Duration(milliseconds: 500);

  _RetryInterceptor(this.dio);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Retry on timeout, connection errors, and 5xx server errors
    if (_shouldRetry(err) && err.requestOptions.extra['retryCount'] == null) {
      err.requestOptions.extra['retryCount'] = 1;

      try {
        await _retryRequest(err.requestOptions, handler);
      } catch (e) {
        handler.next(err);
      }
      return;
    }

    final retryCount = err.requestOptions.extra['retryCount'] as int? ?? 0;
    if (_shouldRetry(err) && retryCount < _maxRetries) {
      final newCount = retryCount + 1;
      err.requestOptions.extra['retryCount'] = newCount;

      try {
        await Future.delayed(_baseDelay * newCount);
        await _retryRequest(err.requestOptions, handler);
      } catch (e) {
        handler.next(err);
      }
      return;
    }

    super.onError(err, handler);
  }

  Future<void> _retryRequest(
    RequestOptions options,
    ErrorInterceptorHandler handler,
  ) async {
    try {
      final response = await dio.request<dynamic>(
        options.path,
        data: options.data,
        queryParameters: options.queryParameters,
        options: Options(
          method: options.method,
          headers: options.headers,
          contentType: options.contentType,
        ),
      );
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  bool _shouldRetry(DioException err) {
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout) {
      return true;
    }

    // Retry on 5xx server errors
    if (err.response?.statusCode != null && err.response!.statusCode! >= 500) {
      return true;
    }

    // Retry on connection errors
    if (err.type == DioExceptionType.unknown) {
      return true;
    }

    return false;
  }
}
