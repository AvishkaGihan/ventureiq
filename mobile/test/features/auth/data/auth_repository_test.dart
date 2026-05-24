import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ventureiq_app/features/auth/data/auth_remote_data_source.dart';
import 'package:ventureiq_app/features/auth/data/auth_repository.dart';
import 'package:ventureiq_app/features/auth/data/token_storage.dart';

// ──────────────────────────────────────────────────────────────
// Mocks — NEVER call real Firebase in tests
// ──────────────────────────────────────────────────────────────

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUserCredential extends Mock implements UserCredential {}

class MockUser extends Mock implements User {}

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockTokenStorage extends Mock implements TokenStorage {}

void main() {
  late AuthRepository repository;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockTokenStorage mockTokenStorage;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockTokenStorage = MockTokenStorage();

    repository = AuthRepository(
      remoteDataSource: mockRemoteDataSource,
      tokenStorage: mockTokenStorage,
      firebaseAuth: mockFirebaseAuth,
    );
  });

  group('AuthRepository', () {
    group('signInAnonymously', () {
      test('should complete anonymous auth flow and return AuthUser', () async {
        // Arrange
        final mockUser = MockUser();
        final mockCredential = MockUserCredential();

        when(() => mockUser.uid).thenReturn('anon-uid-123');
        when(() => mockUser.email).thenReturn(null);
        when(() => mockUser.displayName).thenReturn(null);
        when(() => mockUser.isAnonymous).thenReturn(true);
        when(() => mockUser.getIdToken()).thenAnswer(
          (_) async => 'firebase_id_token',
        );
        when(() => mockCredential.user).thenReturn(mockUser);
        when(() => mockFirebaseAuth.signInAnonymously()).thenAnswer(
          (_) async => mockCredential,
        );
        when(
          () => mockRemoteDataSource.exchangeToken(
            firebaseToken: any(named: 'firebaseToken'),
          ),
        ).thenAnswer(
          (_) async => const TokenResponse(
            accessToken: 'access_token',
            refreshToken: 'refresh_token',
            tokenType: 'bearer',
            expiresIn: 3600,
          ),
        );
        when(
          () => mockTokenStorage.writeTokens(
            accessToken: any(named: 'accessToken'),
            refreshToken: any(named: 'refreshToken'),
          ),
        ).thenAnswer((_) async {});

        // Act
        final result = await repository.signInAnonymously();

        // Assert
        expect(result.id, 'anon-uid-123');
        expect(result.isAnonymous, true);
        expect(result.authMethod, 'anonymous');
        expect(result.email, isNull);
        expect(result.tier, 'free');

        // Verify flow order
        verify(() => mockFirebaseAuth.signInAnonymously()).called(1);
        verify(() => mockUser.getIdToken()).called(1);
        verify(
          () => mockRemoteDataSource.exchangeToken(
            firebaseToken: 'firebase_id_token',
          ),
        ).called(1);
        verify(
          () => mockTokenStorage.writeTokens(
            accessToken: 'access_token',
            refreshToken: 'refresh_token',
          ),
        ).called(1);
      });

      test('should throw when Firebase returns null user', () async {
        // Arrange
        final mockCredential = MockUserCredential();
        when(() => mockCredential.user).thenReturn(null);
        when(() => mockFirebaseAuth.signInAnonymously()).thenAnswer(
          (_) async => mockCredential,
        );

        // Act & Assert
        expect(
          () => repository.signInAnonymously(),
          throwsA(isA<Exception>()),
        );
      });

      test('should throw when Firebase ID token is null', () async {
        // Arrange
        final mockUser = MockUser();
        final mockCredential = MockUserCredential();

        when(() => mockUser.uid).thenReturn('uid');
        when(() => mockUser.getIdToken()).thenAnswer((_) async => null);
        when(() => mockCredential.user).thenReturn(mockUser);
        when(() => mockFirebaseAuth.signInAnonymously()).thenAnswer(
          (_) async => mockCredential,
        );

        // Act & Assert
        expect(
          () => repository.signInAnonymously(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('signOut', () {
      test('should clear tokens and sign out Firebase', () async {
        // Arrange
        when(() => mockTokenStorage.deleteTokens())
            .thenAnswer((_) async {});
        when(() => mockFirebaseAuth.signOut()).thenAnswer((_) async {});

        // Act
        await repository.signOut();

        // Assert
        verify(() => mockTokenStorage.deleteTokens()).called(1);
        verify(() => mockFirebaseAuth.signOut()).called(1);
      });
    });

    group('hasCachedTokens', () {
      test('should delegate to TokenStorage', () async {
        when(() => mockTokenStorage.hasTokens())
            .thenAnswer((_) async => true);

        final result = await repository.hasCachedTokens();

        expect(result, true);
        verify(() => mockTokenStorage.hasTokens()).called(1);
      });
    });

    group('currentFirebaseUser', () {
      test('should return current Firebase user', () {
        final mockUser = MockUser();
        when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);

        expect(repository.currentFirebaseUser, mockUser);
      });

      test('should return null when no user signed in', () {
        when(() => mockFirebaseAuth.currentUser).thenReturn(null);

        expect(repository.currentFirebaseUser, isNull);
      });
    });
  });
}
