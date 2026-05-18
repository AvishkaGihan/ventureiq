import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// VentureIQ Dio HTTP Client
///
/// Configured with JSON interceptors, logging, and timeout settings.
/// Uses a singleton pattern for consistent API communication.
class DioClient {
  DioClient._() {
    _init();
  }

  static final DioClient instance = DioClient._();
  late Dio _dio;

  /// Underlying Dio instance for direct access when needed
  Dio get dio => _dio;

  /// Default base URL for Android emulator → localhost mapping
  static const String defaultBaseUrl = 'http://10.0.2.2:8000';

  /// Connect timeout in milliseconds
  static const Duration connectTimeout = Duration(seconds: 15);

  /// Receive timeout in milliseconds
  static const Duration receiveTimeout = Duration(seconds: 30);

  /// Send timeout in milliseconds
  static const Duration sendTimeout = Duration(seconds: 15);

  void _init({String? baseUrl}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? defaultBaseUrl,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        sendTimeout: sendTimeout,
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    // JSON content-type interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers['Content-Type'] = 'application/json';
          options.headers['Accept'] = 'application/json';
          return handler.next(options);
        },
      ),
    );

    // Logging interceptor — debug mode only
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: false,
          requestBody: false,
          responseHeader: false,
          responseBody: false,
          error: true,
          logPrint: (obj) => debugPrint('[DioClient] $obj'),
        ),
      );
    }
  }

  /// Factory constructor for testing — creates a new instance with custom Dio
  @visibleForTesting
  static DioClient withDio(Dio dio) {
    instance._dio = dio;
    return instance;
  }

  /// Reset singleton — for testing only
  @visibleForTesting
  static void reset() {
    instance._dio.close(force: true);
    instance._init();
  }
}
