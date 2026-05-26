import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ventureiq_app/features/auth/data/auth_repository.dart'
    show AccountAlreadyInUseException, AuthRepository;
import 'package:ventureiq_app/features/auth/domain/auth_entity.dart';
import 'package:ventureiq_app/features/auth/domain/auth_state.dart';
import 'package:ventureiq_app/features/auth/presentation/auth_providers.dart';

/// Riverpod [AsyncNotifier] managing authentication state.
///
/// State transitions:
/// - `unauthenticated` → `anonymous` (auto on first launch)
/// - `anonymous` → `authenticated` (user taps Google Sign-In)
/// - `authenticated` / `anonymous` → `unauthenticated` (sign out)
///
/// The [build] method checks for cached tokens on startup and
/// restores the previous auth state if possible.
class AuthNotifier extends AsyncNotifier<AuthState> {
  late AuthRepository _authRepository;

  @override
  FutureOr<AuthState> build() async {
    _authRepository = ref.read(authRepositoryProvider);
    final tokenStorage = ref.read(tokenStorageProvider);

    // Check for cached tokens to restore session
    final hasCached = await tokenStorage.hasTokens();

    if (hasCached) {
      final firebaseUser = _authRepository.currentFirebaseUser;
      if (firebaseUser != null) {
        final user = _userFromFirebase(firebaseUser);
        return firebaseUser.isAnonymous
            ? AuthState.anonymous(user)
            : AuthState.authenticated(user);
      }
    }

    // No cached session — automatically sign in anonymously transparently
    final user = await _authRepository.signInAnonymously();
    return AuthState.anonymous(user);
  }

  /// Trigger anonymous Firebase sign-in and backend JWT exchange.
  ///
  /// Called automatically on first launch or after token expiry.
  Future<void> signInAnonymously() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = await _authRepository.signInAnonymously();
      return AuthState.anonymous(user);
    });
  }

  /// Trigger Google Sign-In flow.
  ///
  /// **Routing logic** (Story 2.3):
  /// - If the current state is `anonymous` → calls `upgradeToGoogle()`
  ///   which uses `linkWithCredential` to preserve the UID
  /// - Otherwise → calls `signInWithGoogle()` for a fresh sign-in
  ///
  /// If the user cancels the sign-in dialog, silently restores the previous state.
  Future<void> signInWithGoogle() async {
    final previousState = state;
    // ignore: invalid_use_of_internal_member
    state = const AsyncLoading<AuthState>().copyWithPrevious(previousState);
    try {
      final AuthUser user;

      // Route: anonymous → upgrade, unauthenticated → fresh sign-in
      final currentState = previousState.value;
      if (currentState is AuthStateAnonymous) {
        user = await _authRepository.upgradeToGoogle();
      } else {
        user = await _authRepository.signInWithGoogle();
      }

      state = AsyncValue.data(AuthState.authenticated(user));
    } on AccountAlreadyInUseException catch (e) {
      // Specific error: Google account already linked to another VentureIQ account
      // The UI layer should listen for this error and show:
      // "This Google account is already in use"
      // ignore: invalid_use_of_internal_member
      state = AsyncValue<AuthState>.error(e, StackTrace.current).copyWithPrevious(previousState);
    } catch (e) {
      // Check if this is a user cancellation — restore previous state silently
      final errorStr = e.toString().toLowerCase();
      final isCancellation = (e is PlatformException &&
              (e.code == 'sign_in_canceled' || e.code == '12501')) ||
          errorStr.contains('canceled') ||
          errorStr.contains('cancelled') ||
          errorStr.contains('cancel');
      if (isCancellation) {
        state = previousState;
      } else {
        // On any failure during upgrade, the repository handles compensating
        // unlink. The user remains anonymous with data intact.
        // ignore: invalid_use_of_internal_member
        state = AsyncValue<AuthState>.error(e, StackTrace.current).copyWithPrevious(previousState);
      }
    }
  }

  /// Sign out: clear tokens, Firebase/Google sign-out, reset to transparent anonymous auth.
  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _authRepository.signOut();
      final user = await _authRepository.signInAnonymously();
      return AuthState.anonymous(user);
    });
  }

  /// Force transition to unauthenticated (used by AuthInterceptor on refresh failure).
  void forceUnauthenticated() {
    state = const AsyncValue.data(AuthState.unauthenticated());
  }

  /// Build an [AuthUser] from a Firebase [User] object.
  AuthUser _userFromFirebase(User firebaseUser) {
    return AuthUser(
      id: firebaseUser.uid,
      email: firebaseUser.email,
      displayName: firebaseUser.displayName,
      tier: 'free',
      authMethod: firebaseUser.isAnonymous ? 'anonymous' : 'google',
      isAnonymous: firebaseUser.isAnonymous,
    );
  }
}
