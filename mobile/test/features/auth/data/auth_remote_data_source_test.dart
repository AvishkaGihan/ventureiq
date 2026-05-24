import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ventureiq_app/core/networking/api_response.dart';
import 'package:ventureiq_app/features/auth/data/auth_remote_data_source.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late AuthRemoteDataSource dataSource;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    dataSource = AuthRemoteDataSource(dio: mockDio);
  });

  group('AuthRemoteDataSource', () {
    group('exchangeToken', () {
      test('should return TokenResponse on successful exchange', () async {
        // Arrange
        when(
          () => mockDio.post<Map<String, dynamic>>(
            any(),
            data: any(named: 'data'),
          ),
        ).thenAnswer(
          (_) async => Response(
            data: {
              'data': {
                'access_token': 'test_access_token',
                'refresh_token': 'test_refresh_token',
                'token_type': 'bearer',
                'expires_in': 3600,
              },
              'meta': {'request_id': 'test-uuid'},
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: '/api/v1/auth/exchange'),
          ),
        );

        // Act
        final result = await dataSource.exchangeToken(
          firebaseToken: 'firebase_id_token',
        );

        // Assert
        expect(result.accessToken, 'test_access_token');
        expect(result.refreshToken, 'test_refresh_token');
        expect(result.tokenType, 'bearer');
        expect(result.expiresIn, 3600);

        verify(
          () => mockDio.post<Map<String, dynamic>>(
            '/api/v1/auth/exchange',
            data: {'firebase_token': 'firebase_id_token'},
          ),
        ).called(1);
      });

      test('should throw ApiError on error envelope', () async {
        // Arrange
        when(
          () => mockDio.post<Map<String, dynamic>>(
            any(),
            data: any(named: 'data'),
          ),
        ).thenAnswer(
          (_) async => Response(
            data: {
              'error': {
                'code': 'AUTH_PROVIDER_TOKEN_INVALID',
                'message': 'Firebase token is invalid',
              },
              'meta': {'request_id': 'test-uuid'},
            },
            statusCode: 401,
            requestOptions: RequestOptions(path: '/api/v1/auth/exchange'),
          ),
        );

        // Act & Assert
        expect(
          () => dataSource.exchangeToken(firebaseToken: 'bad_token'),
          throwsA(isA<ApiError>()),
        );
      });
    });

    group('refreshToken', () {
      late MockDio mockPlainDio;

      setUp(() {
        mockPlainDio = MockDio();
        when(() => mockDio.options).thenReturn(
          BaseOptions(baseUrl: 'http://10.0.2.2:8000'),
        );
      });

      test('should return TokenResponse on successful refresh', () async {
        // Arrange
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
              'meta': {'request_id': 'test-uuid'},
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: '/api/v1/auth/refresh'),
          ),
        );

        // Act
        final result = await dataSource.refreshToken(
          refreshToken: 'old_refresh_token',
          plainDio: mockPlainDio,
        );

        // Assert
        expect(result.accessToken, 'new_access_token');
        expect(result.refreshToken, 'new_refresh_token');

        verify(
          () => mockPlainDio.post<Map<String, dynamic>>(
            'http://10.0.2.2:8000/api/v1/auth/refresh',
            data: {'refresh_token': 'old_refresh_token'},
          ),
        ).called(1);
      });

      test('should throw ApiError on refresh failure', () async {
        // Arrange
        when(
          () => mockPlainDio.post<Map<String, dynamic>>(
            any(),
            data: any(named: 'data'),
          ),
        ).thenAnswer(
          (_) async => Response(
            data: {
              'error': {
                'code': 'AUTH_INVALID_TOKEN',
                'message': 'Refresh token is invalid or expired',
              },
              'meta': {'request_id': 'test-uuid'},
            },
            statusCode: 401,
            requestOptions: RequestOptions(path: '/api/v1/auth/refresh'),
          ),
        );

        // Act & Assert
        expect(
          () => dataSource.refreshToken(
            refreshToken: 'expired_token',
            plainDio: mockPlainDio,
          ),
          throwsA(isA<ApiError>()),
        );
      });
    });
  });

  group('TokenResponse', () {
    test('fromJson should parse valid JSON', () {
      final json = {
        'access_token': 'at',
        'refresh_token': 'rt',
        'token_type': 'bearer',
        'expires_in': 7200,
      };

      final response = TokenResponse.fromJson(json);

      expect(response.accessToken, 'at');
      expect(response.refreshToken, 'rt');
      expect(response.tokenType, 'bearer');
      expect(response.expiresIn, 7200);
    });
  });
}
