import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ventureiq_app/features/auth/data/auth_remote_data_source.dart';
import 'package:ventureiq_app/features/auth/data/auth_repository.dart';
import 'package:ventureiq_app/features/auth/data/token_storage.dart';

// ──────────────────────────────────────────────────────────────
// Mocks — NEVER call real Firebase or Google in tests
// ──────────────────────────────────────────────────────────────

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockUserCredential extends Mock implements UserCredential {}

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}

class MockGoogleSignInAuthentication extends Mock
    implements GoogleSignInAuthentication {}

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockTokenStorage extends Mock implements TokenStorage {}

class FakeAuthCredential extends Fake implements AuthCredential {}

void main() {
  late AuthRepository repository;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockGoogleSignIn mockGoogleSignIn;
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockTokenStorage mockTokenStorage;
  late MockUser mockUser;
  late MockGoogleSignInAccount mockGoogleAccount;
  late MockGoogleSignInAuthentication mockGoogleAuth;

  setUpAll(() {
    registerFallbackValue(FakeAuthCredential());
  });

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockGoogleSignIn = MockGoogleSignIn();
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockTokenStorage = MockTokenStorage();
    mockUser = MockUser();
    mockGoogleAccount = MockGoogleSignInAccount();
    mockGoogleAuth = MockGoogleSignInAuthentication();

    repository = AuthRepository(
      remoteDataSource: mockRemoteDataSource,
      tokenStorage: mockTokenStorage,
      firebaseAuth: mockFirebaseAuth,
      googleSignIn: mockGoogleSignIn,
    );

    // Common stubs for Google Sign-In v7.x pattern
    when(() => mockGoogleSignIn.authenticate())
        .thenAnswer((_) async => mockGoogleAccount);
    when(() => mockGoogleAccount.authentication).thenReturn(mockGoogleAuth);
    when(() => mockGoogleAuth.idToken).thenReturn('google-id-token');
    when(() => mockGoogleAccount.email).thenReturn('upgraded@gmail.com');
    when(() => mockGoogleAccount.displayName).thenReturn('Upgraded User');
  });

  group('AuthRepository.upgradeToGoogle', () {
    test(
      'happy path: linkWithCredential + backend upgrade + token storage',
      () async {
        // Arrange — anonymous user
        when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(() => mockUser.isAnonymous).thenReturn(true);
        when(() => mockUser.uid).thenReturn('anon-uid-123');
        when(() => mockUser.email).thenReturn('upgraded@gmail.com');
        when(() => mockUser.displayName).thenReturn('Upgraded User');

        // linkWithCredential succeeds
        final mockCredential = MockUserCredential();
        when(() => mockUser.linkWithCredential(any()))
            .thenAnswer((_) async => mockCredential);

        // Force-refreshed ID token
        when(() => mockUser.getIdToken(true))
            .thenAnswer((_) async => 'refreshed-firebase-token');

        // Backend upgrade returns new tokens
        when(
          () => mockRemoteDataSource.upgradeAccount(
            firebaseToken: any(named: 'firebaseToken'),
          ),
        ).thenAnswer(
          (_) async => const TokenResponse(
            accessToken: 'upgrade-access-token',
            refreshToken: 'upgrade-refresh-token',
            tokenType: 'bearer',
            expiresIn: 3600,
          ),
        );

        // Token storage
        when(
          () => mockTokenStorage.writeTokens(
            accessToken: any(named: 'accessToken'),
            refreshToken: any(named: 'refreshToken'),
          ),
        ).thenAnswer((_) async {});

        // Act
        final result = await repository.upgradeToGoogle();

        // Assert — AuthUser reflects Google identity with preserved UID
        expect(result.id, 'anon-uid-123');
        expect(result.email, 'upgraded@gmail.com');
        expect(result.displayName, 'Upgraded User');
        expect(result.authMethod, 'google');
        expect(result.isAnonymous, false);
        expect(result.tier, 'free');

        // Verify flow: linkWithCredential NOT signInWithCredential
        verify(() => mockUser.linkWithCredential(any())).called(1);
        verifyNever(() => mockFirebaseAuth.signInWithCredential(any()));

        // Verify backend upgrade was called
        verify(
          () => mockRemoteDataSource.upgradeAccount(
            firebaseToken: 'refreshed-firebase-token',
          ),
        ).called(1);

        // Verify new tokens were stored
        verify(
          () => mockTokenStorage.writeTokens(
            accessToken: 'upgrade-access-token',
            refreshToken: 'upgrade-refresh-token',
          ),
        ).called(1);
      },
    );

    test(
      'error: credential-already-in-use throws AccountAlreadyInUseException',
      () async {
        // Arrange
        when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(() => mockUser.isAnonymous).thenReturn(true);
        when(() => mockUser.uid).thenReturn('anon-uid-123');

        when(() => mockUser.linkWithCredential(any())).thenThrow(
          FirebaseAuthException(code: 'credential-already-in-use'),
        );

        // Act & Assert
        expect(
          () => repository.upgradeToGoogle(),
          throwsA(isA<AccountAlreadyInUseException>()),
        );
      },
    );

    test(
      'error: provider-already-linked throws ProviderAlreadyLinkedException',
      () async {
        // Arrange
        when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(() => mockUser.isAnonymous).thenReturn(true);
        when(() => mockUser.uid).thenReturn('anon-uid-123');

        when(() => mockUser.linkWithCredential(any())).thenThrow(
          FirebaseAuthException(code: 'provider-already-linked'),
        );

        // Act & Assert
        expect(
          () => repository.upgradeToGoogle(),
          throwsA(isA<ProviderAlreadyLinkedException>()),
        );
      },
    );

    test(
      'error: backend upgrade fails after linkWithCredential → compensating unlink',
      () async {
        // Arrange — anonymous user
        when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(() => mockUser.isAnonymous).thenReturn(true);
        when(() => mockUser.uid).thenReturn('anon-uid-123');

        // linkWithCredential succeeds
        final mockCredential = MockUserCredential();
        when(() => mockUser.linkWithCredential(any()))
            .thenAnswer((_) async => mockCredential);

        // Force-refreshed ID token succeeds
        when(() => mockUser.getIdToken(true))
            .thenAnswer((_) async => 'refreshed-firebase-token');

        // Backend upgrade FAILS
        when(
          () => mockRemoteDataSource.upgradeAccount(
            firebaseToken: any(named: 'firebaseToken'),
          ),
        ).thenThrow(Exception('Backend upgrade failed'));

        // Compensating unlink succeeds
        when(() => mockUser.unlink('google.com'))
            .thenAnswer((_) async => mockUser);

        // Act & Assert
        expect(
          () => repository.upgradeToGoogle(),
          throwsA(isA<Exception>()),
        );

        // Verify compensating unlink was called
        await untilCalled(() => mockUser.unlink('google.com'));
        verify(() => mockUser.unlink('google.com')).called(1);
      },
    );

    test(
      'should throw when there is no anonymous session',
      () async {
        // Arrange — no user
        when(() => mockFirebaseAuth.currentUser).thenReturn(null);

        // Act & Assert
        expect(
          () => repository.upgradeToGoogle(),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('no anonymous session'),
            ),
          ),
        );
      },
    );

    test(
      'should throw when user is not anonymous',
      () async {
        // Arrange — already authenticated
        when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(() => mockUser.isAnonymous).thenReturn(false);

        // Act & Assert
        expect(
          () => repository.upgradeToGoogle(),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('no anonymous session'),
            ),
          ),
        );
      },
    );
  });
}
