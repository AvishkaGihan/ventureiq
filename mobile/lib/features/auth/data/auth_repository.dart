import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ventureiq_app/features/auth/data/auth_remote_data_source.dart';
import 'package:ventureiq_app/features/auth/data/token_storage.dart';
import 'package:ventureiq_app/features/auth/domain/auth_entity.dart';

/// Repository implementing all authentication operations.
///
/// Orchestrates:
/// 1. Firebase Authentication (anonymous + Google credential)
/// 2. Backend JWT token exchange via [AuthRemoteDataSource]
/// 3. Secure token persistence via [TokenStorage]
///
/// Designed for forward compatibility with Story 2.3 (linkWithCredential).
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

    return AuthUser(
      id: user.uid,
      email: user.email,
      displayName: user.displayName,
      tier: 'free',
      authMethod: 'google',
      isAnonymous: false,
    );
  }

  /// Sign out: clear stored tokens, sign out from Firebase and Google.
  Future<void> signOut() async {
    await _tokenStorage.deleteTokens();
    await _firebaseAuth.signOut();
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint('[AuthRepository] Google sign-out failed/ignored: $e');
    }
  }

  /// Check if tokens are cached in secure storage.
  Future<bool> hasCachedTokens() async {
    return _tokenStorage.hasTokens();
  }

  /// Get the current Firebase user, if any.
  User? get currentFirebaseUser => _firebaseAuth.currentUser;
}
