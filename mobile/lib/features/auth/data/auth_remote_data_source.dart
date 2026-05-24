import 'package:dio/dio.dart';
import 'package:ventureiq_app/core/networking/api_endpoints.dart';
import 'package:ventureiq_app/core/networking/api_response.dart';

/// Response model for token exchange and refresh API calls.
///
/// Maps the backend `TokenResponseSchema`:
/// ```json
/// { "access_token": "...", "refresh_token": "...", "token_type": "bearer", "expires_in": 3600 }
/// ```
class TokenResponse {
  const TokenResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
  });

  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;

  /// Factory matching the `T Function(dynamic json)` signature
  /// required by [ApiResponseParser.parse].
  factory TokenResponse.fromJson(dynamic json) {
    final map = json as Map<String, dynamic>;
    return TokenResponse(
      accessToken: map['access_token'] as String,
      refreshToken: map['refresh_token'] as String,
      tokenType: map['token_type'] as String,
      expiresIn: map['expires_in'] as int,
    );
  }
}

/// Remote data source for auth-related backend API calls.
///
/// Calls:
/// - `POST /api/v1/auth/exchange` — exchange Firebase ID token for backend JWT pair
/// - `POST /api/v1/auth/refresh` — refresh an expired access token
///
/// Uses the existing [ApiResponseParser] to unwrap the envelope response.
class AuthRemoteDataSource {
  AuthRemoteDataSource({required Dio dio}) : _dio = dio;

  final Dio _dio;

  /// Exchange a Firebase ID token for a backend JWT token pair.
  ///
  /// Sends `{ "firebase_token": "<idToken>" }` and receives the
  /// standard envelope: `{ "data": { ... }, "meta": { ... } }`.
  Future<TokenResponse> exchangeToken({
    required String firebaseToken,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.authExchange,
      data: {'firebase_token': firebaseToken},
    );

    final parsed = ApiResponseParser.parse(
      response.data!,
      TokenResponse.fromJson,
    );

    return parsed.data;
  }

  /// Refresh an expired access token using a refresh token.
  ///
  /// The refresh token is single-use — after a successful refresh,
  /// the old refresh token is invalidated. Store the new pair immediately.
  ///
  /// Uses a **separate** Dio instance (without AuthInterceptor)
  /// to avoid infinite recursion.
  Future<TokenResponse> refreshToken({
    required String refreshToken,
    required Dio plainDio,
  }) async {
    final response = await plainDio.post<Map<String, dynamic>>(
      '${_dio.options.baseUrl}${ApiEndpoints.authRefresh}',
      data: {'refresh_token': refreshToken},
    );

    final parsed = ApiResponseParser.parse(
      response.data!,
      TokenResponse.fromJson,
    );

    return parsed.data;
  }
}
