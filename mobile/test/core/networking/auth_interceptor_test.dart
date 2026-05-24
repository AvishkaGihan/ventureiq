import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ventureiq_app/core/networking/auth_interceptor.dart';
import 'package:ventureiq_app/features/auth/data/token_storage.dart';

// ──────────────────────────────────────────────────────────────
// Mocks
// ──────────────────────────────────────────────────────────────

class MockTokenStorage extends Mock implements TokenStorage {}

class MockDio extends Mock implements Dio {}

class MockRequestInterceptorHandler extends Mock
    implements RequestInterceptorHandler {}

class MockErrorInterceptorHandler extends Mock
    implements ErrorInterceptorHandler {}

void main() {
  late AuthInterceptor interceptor;
  late MockTokenStorage mockTokenStorage;
  late MockDio mockPlainDio;
  late bool authExpired;

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: ''));
  });

  setUp(() {
    mockTokenStorage = MockTokenStorage();
    mockPlainDio = MockDio();
    authExpired = false;

    interceptor = AuthInterceptor(
      tokenStorage: mockTokenStorage,
      plainDio: mockPlainDio,
      onAuthExpired: () => authExpired = true,
    );
  });

  group('AuthInterceptor', () {
    group('onRequest', () {
      test('should attach Bearer token when token exists', () async {
        // Arrange
        when(() => mockTokenStorage.readAccessToken())
            .thenAnswer((_) async => 'test_access_token');

        final options = RequestOptions(path: '/api/v1/test');
        final handler = MockRequestInterceptorHandler();

        // Act
        await interceptor.onRequest(options, handler);

        // Assert
        expect(
          options.headers['Authorization'],
          'Bearer test_access_token',
        );
        verify(() => handler.next(options)).called(1);
      });

      test('should not attach header when token is null', () async {
        // Arrange
        when(() => mockTokenStorage.readAccessToken())
            .thenAnswer((_) async => null);

        final options = RequestOptions(path: '/api/v1/test');
        final handler = MockRequestInterceptorHandler();

        // Act
        await interceptor.onRequest(options, handler);

        // Assert
        expect(options.headers['Authorization'], isNull);
        verify(() => handler.next(options)).called(1);
      });

      test('should not attach header when token is empty', () async {
        // Arrange
        when(() => mockTokenStorage.readAccessToken())
            .thenAnswer((_) async => '');

        final options = RequestOptions(path: '/api/v1/test');
        final handler = MockRequestInterceptorHandler();

        // Act
        await interceptor.onRequest(options, handler);

        // Assert
        expect(options.headers['Authorization'], isNull);
        verify(() => handler.next(options)).called(1);
      });
    });

    group('onError', () {
      test('should pass through non-401 errors', () async {
        // Arrange
        final error = DioException(
          requestOptions: RequestOptions(path: '/api/v1/test'),
          response: Response(
            statusCode: 500,
            requestOptions: RequestOptions(path: '/api/v1/test'),
          ),
        );
        final handler = MockErrorInterceptorHandler();

        // Act
        await interceptor.onError(error, handler);

        // Assert
        verify(() => handler.next(error)).called(1);
        verifyNever(() => mockTokenStorage.readRefreshToken());
      });

      test('should attempt token refresh on 401', () async {
        // Arrange
        when(() => mockTokenStorage.readRefreshToken())
            .thenAnswer((_) async => 'old_refresh_token');
        when(
          () => mockPlainDio.post<Map<String, dynamic>>(
            any(),
            data: any(named: 'data'),
          ),
        ).thenAnswer(
          (_) async => Response(
            data: {
              'data': {
                'access_token': 'new_access_token',
                'refresh_token': 'new_refresh_token',
                'token_type': 'bearer',
                'expires_in': 3600,
              },
              'meta': {'request_id': 'uuid'},
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: '/api/v1/auth/refresh'),
          ),
        );
        when(
          () => mockTokenStorage.writeTokens(
            accessToken: any(named: 'accessToken'),
            refreshToken: any(named: 'refreshToken'),
          ),
        ).thenAnswer((_) async {});

        final retryResponse = Response(
          statusCode: 200,
          data: {'data': 'retried'},
          requestOptions: RequestOptions(
            path: '/api/v1/test',
            baseUrl: 'http://10.0.2.2:8000',
          ),
        );
        when(() => mockPlainDio.fetch<dynamic>(any()))
            .thenAnswer((_) async => retryResponse);

        final error = DioException(
          requestOptions: RequestOptions(
            path: '/api/v1/test',
            baseUrl: 'http://10.0.2.2:8000',
          ),
          response: Response(
            statusCode: 401,
            requestOptions: RequestOptions(
              path: '/api/v1/test',
              baseUrl: 'http://10.0.2.2:8000',
            ),
          ),
        );
        final handler = MockErrorInterceptorHandler();

        // Act
        await interceptor.onError(error, handler);

        // Assert
        verify(
          () => mockTokenStorage.writeTokens(
            accessToken: 'new_access_token',
            refreshToken: 'new_refresh_token',
          ),
        ).called(1);
        verify(() => handler.resolve(retryResponse)).called(1);
        expect(authExpired, false);
      });

      test('should clear tokens and signal auth expired on refresh failure',
          () async {
        // Arrange
        when(() => mockTokenStorage.readRefreshToken())
            .thenAnswer((_) async => 'bad_refresh_token');
        when(
          () => mockPlainDio.post<Map<String, dynamic>>(
            any(),
            data: any(named: 'data'),
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/api/v1/auth/refresh'),
            response: Response(
              statusCode: 401,
              requestOptions:
                  RequestOptions(path: '/api/v1/auth/refresh'),
            ),
          ),
        );
        when(() => mockTokenStorage.deleteTokens())
            .thenAnswer((_) async {});

        final error = DioException(
          requestOptions: RequestOptions(
            path: '/api/v1/test',
            baseUrl: 'http://10.0.2.2:8000',
          ),
          response: Response(
            statusCode: 401,
            requestOptions: RequestOptions(
              path: '/api/v1/test',
              baseUrl: 'http://10.0.2.2:8000',
            ),
          ),
        );
        final handler = MockErrorInterceptorHandler();

        // Act
        await interceptor.onError(error, handler);

        // Assert
        verify(() => mockTokenStorage.deleteTokens()).called(1);
        expect(authExpired, true);
        verify(() => handler.next(error)).called(1);
      });

      test(
        'should clear tokens when no refresh token available on 401',
        () async {
          // Arrange
          when(() => mockTokenStorage.readRefreshToken())
              .thenAnswer((_) async => null);
          when(() => mockTokenStorage.deleteTokens())
              .thenAnswer((_) async {});

          final error = DioException(
            requestOptions: RequestOptions(
              path: '/api/v1/test',
              baseUrl: 'http://10.0.2.2:8000',
            ),
            response: Response(
              statusCode: 401,
              requestOptions: RequestOptions(
                path: '/api/v1/test',
                baseUrl: 'http://10.0.2.2:8000',
              ),
            ),
          );
          final handler = MockErrorInterceptorHandler();

          // Act
          await interceptor.onError(error, handler);

          // Assert
          verify(() => mockTokenStorage.deleteTokens()).called(1);
          expect(authExpired, true);
          verify(() => handler.next(error)).called(1);
        },
      );
    });
  });
}
