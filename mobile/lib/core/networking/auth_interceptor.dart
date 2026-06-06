import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:ventureiq_app/core/networking/api_endpoints.dart';
import 'package:ventureiq_app/core/networking/api_response.dart';
import 'package:ventureiq_app/features/auth/data/auth_remote_data_source.dart';
import 'package:ventureiq_app/features/auth/data/token_storage.dart';

/// Callback type for signaling auth state change to unauthenticated.
typedef OnAuthExpired = void Function();

/// Dio interceptor that automatically attaches JWT Bearer tokens
/// to outgoing requests and handles 401 token refresh.
///
/// ## Request Flow
/// 1. Read access token from [TokenStorage]
/// 2. Attach `Authorization: Bearer <token>` header if token exists
///
/// ## Error Flow (401 Handling)
/// 1. Check if already retrying (prevent infinite loop)
/// 2. Read refresh token from [TokenStorage]
/// 3. Call `POST /api/v1/auth/refresh` via a **separate** plain Dio instance
/// 4. On success: store new tokens, retry original request
/// 5. On failure: clear tokens, signal auth expired, reject
///
/// **CRITICAL**: The refresh call uses [_plainDio] (no interceptors)
/// to prevent infinite recursion.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required TokenStorage tokenStorage,
    required Dio plainDio,
    required OnAuthExpired onAuthExpired,
  })  : _tokenStorage = tokenStorage,
        _plainDio = plainDio,
        _onAuthExpired = onAuthExpired;

  final TokenStorage _tokenStorage;
  final Dio _plainDio;
  final OnAuthExpired _onAuthExpired;
  Completer<String?>? _refreshCompleter;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStorage.readAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Only handle 401 Unauthorized. Rate limits (429) must surface to UI.
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // Prevent infinite loop if retry request gets a 401
    if (err.requestOptions.extra['is_retry'] == true) {
      return handler.next(err);
    }

    // If a refresh is already in progress, queue this request
    if (_refreshCompleter != null) {
      try {
        final newToken = await _refreshCompleter!.future;
        if (newToken != null) {
          final retryResponse = await _retryRequest(err.requestOptions, newToken);
          return handler.resolve(retryResponse);
        }
      } catch (_) {}
      return handler.next(err);
    }

    // Start a new refresh flow
    _refreshCompleter = Completer<String?>();

    try {
      final refreshToken = await _tokenStorage.readRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        await _handleRefreshFailure();
        _refreshCompleter!.complete(null);
        _refreshCompleter = null;
        return handler.next(err);
      }

      // Attempt token refresh using plain Dio (no interceptors)
      final response = await _plainDio.post<Map<String, dynamic>>(
        '${err.requestOptions.baseUrl}${ApiEndpoints.authRefresh}',
        data: {'refresh_token': refreshToken},
      );

      final parsed = ApiResponseParser.parse(
        response.data!,
        TokenResponse.fromJson,
      );

      final tokenResponse = parsed.data;

      // Store new token pair
      await _tokenStorage.writeTokens(
        accessToken: tokenResponse.accessToken,
        refreshToken: tokenResponse.refreshToken,
      );

      final newToken = tokenResponse.accessToken;
      _refreshCompleter!.complete(newToken);
      _refreshCompleter = null;

      // Retry original request with new token
      final retryResponse = await _retryRequest(err.requestOptions, newToken);
      return handler.resolve(retryResponse);
    } catch (e) {
      debugPrint('[AuthInterceptor] Token refresh failed: $e');
      
      // ONLY log out and delete tokens if it is an actual authentication error
      // from the server (like 400 or 401). If it is a transient network timeout/offline
      // error, we do NOT delete stored tokens to protect the active user session.
      if (e is DioException &&
          (e.response?.statusCode == 400 || e.response?.statusCode == 401)) {
        await _handleRefreshFailure();
      }
      
      _refreshCompleter!.complete(null);
      _refreshCompleter = null;
      return handler.next(err);
    }
  }

  /// Helper to retry an outgoing request with a new JWT access token.
  Future<Response<dynamic>> _retryRequest(RequestOptions options, String token) {
    options.headers['Authorization'] = 'Bearer $token';
    options.extra['is_retry'] = true;
    return _plainDio.fetch(options);
  }

  /// Clear tokens and signal unauthenticated state on refresh failure.
  Future<void> _handleRefreshFailure() async {
    await _tokenStorage.deleteTokens();
    _onAuthExpired();
  }
}
