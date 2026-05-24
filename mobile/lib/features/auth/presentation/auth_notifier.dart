import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ventureiq_app/features/auth/data/auth_repository.dart';
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

  /// Trigger Google Sign-In flow, Firebase credential, and backend JWT exchange.
  ///
  /// Called when user taps "Sign in with Google" in Profile tab.
  /// If the user cancels the sign-in dialog, silently restores the previous state.
  Future<void> signInWithGoogle() async {
    final previousState = state;
    state = const AsyncValue.loading();
    try {
      final user = await _authRepository.signInWithGoogle();
      state = AsyncValue.data(AuthState.authenticated(user));
    } catch (e) {
      // Check if this is a user cancellation — restore previous state silently
      if (e.toString().contains('canceled') ||
          e.toString().contains('cancelled')) {
        state = previousState;
      } else {
        state = AsyncValue.error(e, StackTrace.current);
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
