import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class OpenAIDioClient {
  final Dio dio;

  OpenAIDioClient._(this.dio);

  factory OpenAIDioClient.create() {
    final apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';

    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.openai.com/v1',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          if (apiKey.isNotEmpty) 'Authorization': 'Bearer $apiKey',
        },
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
          final key = dotenv.env['OPENAI_API_KEY'] ?? '';
          if (key.isEmpty) {
            handler.reject(
              DioException(
                requestOptions: options,
                error: 'Missing OPENAI_API_KEY in .env',
              ),
            );
            return;
          }

          options.headers['Authorization'] = 'Bearer $key';
          handler.next(options);
        },
        onError: (error, handler) {
          handler.next(error);
        },
      ),
    );

    return OpenAIDioClient._(dio);
  }
}
