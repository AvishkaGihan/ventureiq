import 'package:flutter_test/flutter_test.dart';
import 'package:ventureiq_app/core/networking/dio_client.dart';

void main() {
  group('DioClient', () {
    setUp(() {
      DioClient.reset();
    });

    test('singleton returns same instance', () {
      final client1 = DioClient.instance;
      final client2 = DioClient.instance;
      expect(identical(client1, client2), isTrue);
    });

    test('has correct connect timeout', () {
      final client = DioClient.instance;
      expect(
        client.dio.options.connectTimeout,
        const Duration(seconds: 15),
      );
    });

    test('has correct receive timeout', () {
      final client = DioClient.instance;
      expect(
        client.dio.options.receiveTimeout,
        const Duration(seconds: 30),
      );
    });

    test('has correct send timeout', () {
      final client = DioClient.instance;
      expect(
        client.dio.options.sendTimeout,
        const Duration(seconds: 15),
      );
    });

    test('has correct base URL', () {
      final client = DioClient.instance;
      expect(client.dio.options.baseUrl, DioClient.defaultBaseUrl);
    });

    test('has interceptors configured', () {
      final client = DioClient.instance;
      // At minimum: JSON interceptor + LogInterceptor (in debug mode)
      expect(client.dio.interceptors.length, greaterThanOrEqualTo(1));
    });

    test('reset re-initializes internal dio', () {
      final dio1 = DioClient.instance.dio;
      DioClient.reset();
      final dio2 = DioClient.instance.dio;
      expect(identical(dio1, dio2), isFalse);
    });
  });
}
