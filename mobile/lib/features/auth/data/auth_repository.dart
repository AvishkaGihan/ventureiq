import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ventureiq_app/features/auth/data/auth_remote_data_source.dart';
import 'package:ventureiq_app/features/auth/data/token_storage.dart';
import 'package:ventureiq_app/features/auth/domain/auth_entity.dart';

/// Thrown when `linkWithCredential` fails because the Google account
/// is already linked to a different Firebase UID.
class AccountAlreadyInUseException implements Exception {
  const AccountAlreadyInUseException();

  @override
  String toString() => 'AccountAlreadyInUseException: '
      'This Google account is already linked to another account.';
}

/// Thrown when `linkWithCredential` fails because the user already
/// has a Google provider linked.
class ProviderAlreadyLinkedException implements Exception {
  const ProviderAlreadyLinkedException();

  @override
  String toString() => 'ProviderAlreadyLinkedException: '
      'A Google provider is already linked to this account.';
}

/// Repository implementing all authentication operations.
///
/// Orchestrates:
/// 1. Firebase Authentication (anonymous + Google credential)
/// 2. Backend JWT token exchange via [AuthRemoteDataSource]
/// 3. Secure token persistence via [TokenStorage]
/// 4. Anonymous-to-Google upgrade via `linkWithCredential`
class AuthRepository {
  AuthRepository({
    required AuthRemoteDataSource remoteDataSource,
    required TokenStorage tokenStorage,
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  }) : _remoteDataSource = remoteDataSource,
       _tokenStorage = tokenStorage,
       _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final AuthRemoteDataSource _remoteDataSource;
  final TokenStorage _tokenStorage;
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  /// Sign in anonymously via Firebase, then exchange for backend JWT.
  ///
  /// Flow:
  /// 1. `FirebaseAuth.instance.signInAnonymously()`
  /// 2. Get Firebase ID token
  /// 3. Exchange for backend JWT pair
  /// 4. Store tokens securely
  /// 5. Return [AuthUser] with anonymous identity
  Future<AuthUser> signInAnonymously() async {
    final credential = await _firebaseAuth.signInAnonymously();
    final user = credential.user;

    if (user == null) {
      throw Exception('Firebase anonymous sign-in returned null user');
    }

    final idToken = await user.getIdToken();
    if (idToken == null) {
      throw Exception('Failed to obtain Firebase ID token');
    }

    final tokenResponse = await _remoteDataSource.exchangeToken(
      firebaseToken: idToken,
    );

    await _tokenStorage.writeTokens(
      accessToken: tokenResponse.accessToken,
      refreshToken: tokenResponse.refreshToken,
    );

    return AuthUser(
      id: user.uid,
      email: null,
      displayName: null,
      tier: 'free',
      authMethod: 'anonymous',
      isAnonymous: true,
    );
  }

  /// Sign in with Google via GoogleSignIn + Firebase credential.
  ///
  /// Uses GoogleSignIn v7.x singleton pattern:
  /// - `GoogleSignIn.instance.authenticate()` (not deprecated `signIn()`)
  ///
  /// Flow:
  /// 1. `GoogleSignIn.instance.authenticate()` → get Google tokens
  /// 2. Create Firebase `GoogleAuthProvider.credential`
  /// 3. `FirebaseAuth.instance.signInWithCredential(credential)`
  /// 4. Exchange Firebase ID token for backend JWT
  /// 5. Store tokens securely
  /// 6. Return [AuthUser] with Google identity
  Future<AuthUser> signInWithGoogle() async {
    final googleUser = await _googleSignIn.authenticate();
    // In v7.x, .authentication is a sync getter, not a Future
    final googleAuth = googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    final user = userCredential.user;

    if (user == null) {
      throw Exception('Firebase Google sign-in returned null user');
    }

    final idToken = await user.getIdToken();
    if (idToken == null) {
      throw Exception('Failed to obtain Firebase ID token');
    }

    final tokenResponse = await _remoteDataSource.exchangeToken(
      firebaseToken: idToken,
    );

    await _tokenStorage.writeTokens(
      accessToken: tokenResponse.accessToken,
      refreshToken: tokenResponse.refreshToken,
    );

    // Use googleUser.displayName as primary source — Firebase User.displayName
    // may be null immediately after signInWithCredential.
    return AuthUser(
      id: user.uid,
      email: user.email ?? googleUser.email,
      displayName: googleUser.displayName ?? user.displayName,
      tier: 'free',
      authMethod: 'google',
      isAnonymous: false,
    );
  }

  /// Upgrade an anonymous session to Google-authenticated.
  ///
  /// Uses `linkWithCredential` (NOT `signInWithCredential`) to preserve
  /// the anonymous Firebase UID, preventing data loss.
  ///
  /// Flow:
  /// 1. Google Sign-In → get credential
  /// 2. `currentUser.linkWithCredential(credential)` — UID stays the same
  /// 3. Get refreshed Firebase ID token (now has Google provider)
  /// 4. `POST /api/v1/auth/upgrade` — backend updates user to Google
  /// 5. Store new backend JWT pair
  /// 6. Re-tag local reports (stub for now)
  /// 7. Return [AuthUser] with Google identity
  ///
  /// **Atomicity**: If the backend upgrade fails after `linkWithCredential`
  /// succeeds, a compensating `unlink('google.com')` is attempted to
  /// restore the anonymous state.
  ///
  /// Throws:
  /// - [AccountAlreadyInUseException] if the Google account is already
  ///   linked to a different Firebase UID
  /// - [ProviderAlreadyLinkedException] if a Google provider is already
  ///   linked to this user
  Future<AuthUser> upgradeToGoogle() async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null || !currentUser.isAnonymous) {
      throw Exception('Cannot upgrade: no anonymous session');
    }

    final googleUser = await _googleSignIn.authenticate();
    final googleAuth = googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    bool linkSucceeded = false;

    try {
      // 1. Link credential to existing anonymous user (UID stays same)
      await currentUser.linkWithCredential(credential);
      linkSucceeded = true;

      // 2. Get new Firebase ID token (now has Google provider)
      final idToken = await currentUser.getIdToken(true); // force refresh
      if (idToken == null) {
        throw Exception('Failed to obtain Firebase ID token after link');
      }

      // 3. Call backend upgrade endpoint
      final tokenResponse = await _remoteDataSource.upgradeAccount(
        firebaseToken: idToken,
      );

      // 4. Store new backend tokens
      await _tokenStorage.writeTokens(
        accessToken: tokenResponse.accessToken,
        refreshToken: tokenResponse.refreshToken,
      );

      // 5. Stub: re-tag Hive reports (UID doesn't change with linkWithCredential)
      await retagLocalReports(
        oldUid: currentUser.uid,
        newUid: currentUser.uid,
      );

      // Use googleUser.displayName as primary source — Firebase User.displayName
      // is null after linkWithCredential on anonymous accounts (known Firebase behavior).
      return AuthUser(
        id: currentUser.uid,
        email: googleUser.email,
        displayName: googleUser.displayName,
        tier: 'free',
        authMethod: 'google',
        isAnonymous: false,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'credential-already-in-use') {
        throw const AccountAlreadyInUseException();
      }
      if (e.code == 'provider-already-linked') {
        throw const ProviderAlreadyLinkedException();
      }
      rethrow;
    } catch (e) {
      // Compensating action: if linkWithCredential succeeded but a later
      // step failed, attempt to unlink the Google provider to restore
      // the anonymous state.
      if (linkSucceeded) {
        try {
          await currentUser.unlink('google.com');
        } catch (unlinkError) {
          debugPrint(
            '[AuthRepository] CRITICAL: Failed to unlink Google after '
            'upgrade failure. User may be in inconsistent state. '
            'Error: $unlinkError',
          );
        }
      }
      rethrow;
    }
  }

  /// Stub: Re-tag locally cached reports with the new user ID.
  ///
  /// When `linkWithCredential` is used, the Firebase UID stays the same,
  /// so this is effectively a no-op. The method signature and call point
  /// are established now so future stories (Epic 3+) can fill in the
  /// Hive implementation when report models are added.
  ///
  /// TODO(epic-3): Implement Hive report re-tagging when report models exist.
  Future<void> retagLocalReports({
    required String oldUid,
    required String newUid,
  }) async {
    // No-op: Hive is not yet integrated. Will be implemented in Epic 3+.
  }

  /// Sign out: clear stored tokens, sign out from Firebase and Google.
  Future<void> signOut() async {
    try {
      await _tokenStorage.deleteTokens();
    } catch (e) {
      debugPrint('[AuthRepository] deleteTokens failed: $e');
    }
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      debugPrint('[AuthRepository] FirebaseAuth signOut failed: $e');
    }
    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // Google sign-out failure is non-critical
    }
  }

  /// Check if tokens are cached in secure storage.
  Future<bool> hasCachedTokens() async {
    return _tokenStorage.hasTokens();
  }

  /// Get the current Firebase user, if any.
  User? get currentFirebaseUser => _firebaseAuth.currentUser;
}
