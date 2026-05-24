import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ventureiq_app/core/networking/dio_client.dart';
import 'package:ventureiq_app/features/auth/data/auth_remote_data_source.dart';
import 'package:ventureiq_app/features/auth/data/auth_repository.dart';
import 'package:ventureiq_app/features/auth/data/token_storage.dart';
import 'package:ventureiq_app/features/auth/domain/auth_state.dart';
import 'package:ventureiq_app/features/auth/presentation/auth_notifier.dart';

/// Provider for [TokenStorage] — secure storage for JWT tokens.
final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage();
});

/// Provider for [AuthRemoteDataSource] — backend auth API calls.
///
/// Uses the shared [DioClient] instance for requests.
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(dio: DioClient.instance.dio);
});

/// Provider for [AuthRepository] — orchestrates all auth operations.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    remoteDataSource: ref.read(authRemoteDataSourceProvider),
    tokenStorage: ref.read(tokenStorageProvider),
  );
});

/// Provider for [AuthNotifier] — manages auth state as [AsyncValue<AuthState>].
///
/// Usage in UI:
/// ```dart
/// final authState = ref.watch(authNotifierProvider);
/// authState.when(
///   loading: () => CircularProgressIndicator(),
///   error: (e, st) => ErrorCard(message: e.toString()),
///   data: (state) => switch (state) {
///     AuthStateUnauthenticated() => ...,
///     AuthStateAnonymous(:final user) => ...,
///     AuthStateAuthenticated(:final user) => ...,
///   },
/// );
/// ```
final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

/// Convenience provider: plain Dio instance WITHOUT AuthInterceptor.
///
/// Used for token refresh calls to avoid infinite recursion.
final plainDioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );
});
