import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ventureiq_app/features/auth/data/auth_remote_data_source.dart';
import 'package:ventureiq_app/features/auth/data/auth_repository.dart';
import 'package:ventureiq_app/features/auth/data/token_storage.dart';
import 'package:ventureiq_app/features/auth/domain/auth_entity.dart';
import 'package:ventureiq_app/features/auth/domain/auth_state.dart';
import 'package:ventureiq_app/features/auth/presentation/auth_providers.dart';

// ──────────────────────────────────────────────────────────────
// Mocks
// ──────────────────────────────────────────────────────────────

class MockAuthRepository extends Mock implements AuthRepository {}

class MockTokenStorage extends Mock implements TokenStorage {}

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class Listener<T> extends Mock {
  void call(T? previous, T next);
}

void main() {
  late MockAuthRepository mockRepo;
  late MockTokenStorage mockTokenStorage;
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late ProviderContainer container;

  setUp(() {
    mockRepo = MockAuthRepository();
    mockTokenStorage = MockTokenStorage();
    mockRemoteDataSource = MockAuthRemoteDataSource();

    // Default stub to prevent unhandled call failures on auto-anonymous sign-in
    when(() => mockRepo.signInAnonymously()).thenAnswer(
      (_) async => const AuthUser(
        id: 'anon-123',
        tier: 'free',
        authMethod: 'anonymous',
        isAnonymous: true,
      ),
    );
  });

  tearDown(() {
    container.dispose();
  });

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockRepo),
        tokenStorageProvider.overrideWithValue(mockTokenStorage),
        authRemoteDataSourceProvider.overrideWithValue(mockRemoteDataSource),
      ],
    );
  }

  group('AuthNotifier', () {
    group('build (initialization)', () {
      test('should restore anonymous state when no cached tokens (transparent auto-sign-in)', () async {
        // Arrange
        when(() => mockTokenStorage.hasTokens())
            .thenAnswer((_) async => false);
        when(() => mockRepo.signInAnonymously()).thenAnswer(
          (_) async => const AuthUser(
            id: 'anon-123',
            tier: 'free',
            authMethod: 'anonymous',
            isAnonymous: true,
          ),
        );

        container = createContainer();

        // Act
        final state =
            await container.read(authNotifierProvider.future);

        // Assert
        expect(state, isA<AuthStateAnonymous>());
        final anonState = state as AuthStateAnonymous;
        expect(anonState.user.id, 'anon-123');
        expect(anonState.user.isAnonymous, true);
      });

      test(
        'should restore anonymous state when cached tokens and anonymous user',
        () async {
          // Arrange
          final mockUser = MockUser();
          when(() => mockTokenStorage.hasTokens())
              .thenAnswer((_) async => true);
          when(() => mockRepo.currentFirebaseUser).thenReturn(mockUser);
          when(() => mockUser.isAnonymous).thenReturn(true);
          when(() => mockUser.uid).thenReturn('anon-uid');
          when(() => mockUser.email).thenReturn(null);
          when(() => mockUser.displayName).thenReturn(null);

          container = createContainer();

          // Act
          final state =
              await container.read(authNotifierProvider.future);

          // Assert
          expect(state, isA<AuthStateAnonymous>());
          final anonState = state as AuthStateAnonymous;
          expect(anonState.user.id, 'anon-uid');
          expect(anonState.user.isAnonymous, true);
        },
      );

      test(
        'should restore authenticated state when cached tokens and Google user',
        () async {
          // Arrange
          final mockUser = MockUser();
          when(() => mockTokenStorage.hasTokens())
              .thenAnswer((_) async => true);
          when(() => mockRepo.currentFirebaseUser).thenReturn(mockUser);
          when(() => mockUser.isAnonymous).thenReturn(false);
          when(() => mockUser.uid).thenReturn('google-uid');
          when(() => mockUser.email).thenReturn('test@gmail.com');
          when(() => mockUser.displayName).thenReturn('Test User');

          container = createContainer();

          // Act
          final state =
              await container.read(authNotifierProvider.future);

          // Assert
          expect(state, isA<AuthStateAuthenticated>());
          final authState = state as AuthStateAuthenticated;
          expect(authState.user.id, 'google-uid');
          expect(authState.user.email, 'test@gmail.com');
          expect(authState.user.isAnonymous, false);
        },
      );
    });

    group('signInAnonymously', () {
      test(
        'should transition to anonymous state on success',
        () async {
          // Arrange
          when(() => mockTokenStorage.hasTokens())
              .thenAnswer((_) async => false);
          when(() => mockRepo.signInAnonymously()).thenAnswer(
            (_) async => const AuthUser(
              id: 'anon-123',
              tier: 'free',
              authMethod: 'anonymous',
              isAnonymous: true,
            ),
          );

          container = createContainer();
          await container.read(authNotifierProvider.future);

          // Act
          await container
              .read(authNotifierProvider.notifier)
              .signInAnonymously();

          // Assert
          final state = container.read(authNotifierProvider).value;
          expect(state, isA<AuthStateAnonymous>());
          final anonState = state! as AuthStateAnonymous;
          expect(anonState.user.id, 'anon-123');
          expect(anonState.user.isAnonymous, true);
        },
      );

      test(
        'should set error state on failure',
        () async {
          // Arrange
          when(() => mockTokenStorage.hasTokens())
              .thenAnswer((_) async => false);

          container = createContainer();
          // Initial build succeeds via the global setup default stub
          await container.read(authNotifierProvider.future);

          // Now stub it to fail for the action phase
          when(() => mockRepo.signInAnonymously())
              .thenThrow(Exception('Network error'));

          // Act
          await container
              .read(authNotifierProvider.notifier)
              .signInAnonymously();

          // Assert
          final state = container.read(authNotifierProvider);
          expect(state.hasError, true);
        },
      );
    });

    group('signInWithGoogle', () {
      test(
        'should transition to authenticated state on success',
        () async {
          // Arrange
          when(() => mockTokenStorage.hasTokens())
              .thenAnswer((_) async => false);
          when(() => mockRepo.signInAnonymously()).thenAnswer(
            (_) async => const AuthUser(
              id: 'anon-123',
              tier: 'free',
              authMethod: 'anonymous',
              isAnonymous: true,
            ),
          );
          when(() => mockRepo.signInWithGoogle()).thenAnswer(
            (_) async => const AuthUser(
              id: 'google-456',
              email: 'user@gmail.com',
              displayName: 'Test User',
              tier: 'free',
              authMethod: 'google',
              isAnonymous: false,
            ),
          );

          container = createContainer();
          await container.read(authNotifierProvider.future);

          // Act
          await container
              .read(authNotifierProvider.notifier)
              .signInWithGoogle();

          // Assert
          final state = container.read(authNotifierProvider).value;
          expect(state, isA<AuthStateAuthenticated>());
          final authState = state! as AuthStateAuthenticated;
          expect(authState.user.id, 'google-456');
          expect(authState.user.email, 'user@gmail.com');
          expect(authState.user.isAnonymous, false);
        },
      );
    });

    group('signOut', () {
      test(
        'should transition to a fresh anonymous state',
        () async {
          // Arrange
          when(() => mockTokenStorage.hasTokens())
              .thenAnswer((_) async => false);
          when(() => mockRepo.signInAnonymously()).thenAnswer(
            (_) async => const AuthUser(
              id: 'anon-new-789',
              tier: 'free',
              authMethod: 'anonymous',
              isAnonymous: true,
            ),
          );
          when(() => mockRepo.signOut()).thenAnswer((_) async {});

          container = createContainer();
          await container.read(authNotifierProvider.future);

          // Act
          await container.read(authNotifierProvider.notifier).signOut();

          // Assert
          final state = container.read(authNotifierProvider).value;
          expect(state, isA<AuthStateAnonymous>());
          final anonState = state! as AuthStateAnonymous;
          expect(anonState.user.id, 'anon-new-789');
          expect(anonState.user.isAnonymous, true);
        },
      );
    });

    group('forceUnauthenticated', () {
      test('should immediately set unauthenticated state', () async {
        // Arrange
        when(() => mockTokenStorage.hasTokens())
            .thenAnswer((_) async => false);

        container = createContainer();
        await container.read(authNotifierProvider.future);

        // Act
        container.read(authNotifierProvider.notifier).forceUnauthenticated();

        // Assert
        final state = container.read(authNotifierProvider).value;
        expect(state, isA<AuthStateUnauthenticated>());
      });
    });
  });
}
