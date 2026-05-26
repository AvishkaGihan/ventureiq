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

  group('AuthNotifier upgrade routing', () {
    test(
      'signInWithGoogle routes to upgradeToGoogle when anonymous',
      () async {
        // Arrange — start in anonymous state
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
        when(() => mockRepo.upgradeToGoogle()).thenAnswer(
          (_) async => const AuthUser(
            id: 'anon-123', // UID preserved!
            email: 'upgraded@gmail.com',
            displayName: 'Upgraded User',
            tier: 'free',
            authMethod: 'google',
            isAnonymous: false,
          ),
        );

        container = createContainer();
        await container.read(authNotifierProvider.future);

        // Verify we're anonymous
        final beforeState = container.read(authNotifierProvider).value;
        expect(beforeState, isA<AuthStateAnonymous>());

        // Act
        await container
            .read(authNotifierProvider.notifier)
            .signInWithGoogle();

        // Assert — transitioned to authenticated
        final afterState = container.read(authNotifierProvider).value;
        expect(afterState, isA<AuthStateAuthenticated>());
        final authState = afterState! as AuthStateAuthenticated;
        expect(authState.user.id, 'anon-123'); // UID preserved
        expect(authState.user.email, 'upgraded@gmail.com');
        expect(authState.user.authMethod, 'google');
        expect(authState.user.isAnonymous, false);

        // Verify upgradeToGoogle was called, NOT signInWithGoogle
        verify(() => mockRepo.upgradeToGoogle()).called(1);
        verifyNever(() => mockRepo.signInWithGoogle());
      },
    );

    test(
      'signInWithGoogle routes to signInWithGoogle when unauthenticated (fresh sign-in after sign-out)',
      () async {
        // Arrange — start anonymous, then force to unauthenticated
        when(() => mockTokenStorage.hasTokens())
            .thenAnswer((_) async => false);

        container = createContainer();
        await container.read(authNotifierProvider.future);

        // Force to unauthenticated state (simulates sign-out → fresh sign-in)
        container.read(authNotifierProvider.notifier).forceUnauthenticated();
        final stateBeforeGoogle = container.read(authNotifierProvider).value;
        expect(stateBeforeGoogle, isA<AuthStateUnauthenticated>());

        // Stub signInWithGoogle
        when(() => mockRepo.signInWithGoogle()).thenAnswer(
          (_) async => const AuthUser(
            id: 'google-new-456',
            email: 'newuser@gmail.com',
            displayName: 'New User',
            tier: 'free',
            authMethod: 'google',
            isAnonymous: false,
          ),
        );

        // Act
        await container
            .read(authNotifierProvider.notifier)
            .signInWithGoogle();

        // Assert — fresh sign-in was used
        final afterState = container.read(authNotifierProvider).value;
        expect(afterState, isA<AuthStateAuthenticated>());
        final authState = afterState! as AuthStateAuthenticated;
        expect(authState.user.id, 'google-new-456');

        // Verify signInWithGoogle was called, NOT upgradeToGoogle
        verify(() => mockRepo.signInWithGoogle()).called(1);
        verifyNever(() => mockRepo.upgradeToGoogle());
      },
    );

    test(
      'signInWithGoogle shows error on AccountAlreadyInUseException and remains anonymous',
      () async {
        // Arrange — anonymous state
        when(() => mockTokenStorage.hasTokens())
            .thenAnswer((_) async => false);
        when(() => mockRepo.upgradeToGoogle())
            .thenThrow(const AccountAlreadyInUseException());

        container = createContainer();
        await container.read(authNotifierProvider.future);

        // Act
        await container
            .read(authNotifierProvider.notifier)
            .signInWithGoogle();

        // Assert — error state with AccountAlreadyInUseException
        final state = container.read(authNotifierProvider);
        expect(state.hasError, true);
        expect(state.error, isA<AccountAlreadyInUseException>());
      },
    );

    test(
      'signInWithGoogle restores anonymous state on generic failure',
      () async {
        // Arrange — anonymous state
        when(() => mockTokenStorage.hasTokens())
            .thenAnswer((_) async => false);
        when(() => mockRepo.upgradeToGoogle())
            .thenThrow(Exception('Network error'));

        container = createContainer();
        await container.read(authNotifierProvider.future);

        // Act
        await container
            .read(authNotifierProvider.notifier)
            .signInWithGoogle();

        // Assert — ends in error state
        final state = container.read(authNotifierProvider);
        expect(state.hasError, true);
      },
    );

    test(
      'signInWithGoogle silently restores state on user cancellation',
      () async {
        // Arrange — anonymous state
        when(() => mockTokenStorage.hasTokens())
            .thenAnswer((_) async => false);
        when(() => mockRepo.upgradeToGoogle())
            .thenThrow(Exception('Sign in was canceled by user'));

        container = createContainer();
        await container.read(authNotifierProvider.future);

        // Act
        await container
            .read(authNotifierProvider.notifier)
            .signInWithGoogle();

        // Assert — previous (anonymous) state restored silently, not error
        final state = container.read(authNotifierProvider);
        expect(state.hasError, false);
        expect(state.value, isA<AuthStateAnonymous>());
      },
    );
  });
}
