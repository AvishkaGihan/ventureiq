import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ventureiq_app/features/auth/domain/auth_entity.dart';

part 'auth_state.freezed.dart';

/// Sealed class representing the authentication state of the application.
///
/// Three possible states:
/// - [unauthenticated]: No user session exists (initial state, or after sign-out)
/// - [anonymous]: Firebase anonymous auth completed, backend JWT obtained
/// - [authenticated]: Google Sign-In completed, backend JWT obtained
@freezed
sealed class AuthState with _$AuthState {
  /// No active user session.
  const factory AuthState.unauthenticated() = AuthStateUnauthenticated;

  /// Anonymous Firebase auth with backend JWT.
  const factory AuthState.anonymous(AuthUser user) = AuthStateAnonymous;

  /// Google-authenticated user with backend JWT.
  const factory AuthState.authenticated(AuthUser user) = AuthStateAuthenticated;
}
