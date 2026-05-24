import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ventureiq_app/app_router.dart';
import 'package:ventureiq_app/core/theme/app_theme.dart';
import 'package:ventureiq_app/features/auth/domain/auth_entity.dart';
import 'package:ventureiq_app/features/auth/domain/auth_state.dart';
import 'package:ventureiq_app/features/auth/presentation/auth_notifier.dart';
import 'package:ventureiq_app/features/auth/presentation/auth_providers.dart';

class _MyHttpOverrides extends HttpOverrides {}

/// Fake [AuthNotifier] that immediately returns anonymous state for testing.
class _FakeAuthNotifier extends AsyncNotifier<AuthState>
    implements AuthNotifier {
  @override
  FutureOr<AuthState> build() {
    return const AuthState.anonymous(
      AuthUser(
        id: 'test-anon-uid',
        tier: 'free',
        authMethod: 'anonymous',
        isAnonymous: true,
      ),
    );
  }

  @override
  Future<void> signInAnonymously() async {}

  @override
  Future<void> signInWithGoogle() async {}

  @override
  Future<void> signOut() async {}

  @override
  void forceUnauthenticated() {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = _MyHttpOverrides();

  group('AppRouter', () {
    testWidgets('initial route renders Home screen', (tester) async {
      final router = createRouter();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: router,
            theme: AppTheme.darkTheme,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsWidgets);
    });

    testWidgets('bottom navigation bar has 4 tabs', (tester) async {
      final router = createRouter();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: router,
            theme: AppTheme.darkTheme,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationDestination), findsNWidgets(4));
    });

    testWidgets('tapping Reports tab shows Reports screen', (tester) async {
      final router = createRouter();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: router,
            theme: AppTheme.darkTheme,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reports'));
      await tester.pumpAndSettle();

      expect(find.text('Reports'), findsWidgets);
    });

    testWidgets('tapping Board tab shows Board screen', (tester) async {
      final router = createRouter();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: router,
            theme: AppTheme.darkTheme,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Board'));
      await tester.pumpAndSettle();

      expect(find.text('Board'), findsWidgets);
    });

    testWidgets('tapping Profile tab shows Profile screen', (tester) async {
      final router = createRouter();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // Override auth state to anonymous so the profile screen renders
            authNotifierProvider.overrideWith(
              () => _FakeAuthNotifier(),
            ),
          ],
          child: MaterialApp.router(
            routerConfig: router,
            theme: AppTheme.darkTheme,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      // Profile screen shows "Anonymous User" for anonymous auth state
      expect(find.text('Anonymous User'), findsOneWidget);
    });

    testWidgets('navigation to /splash renders Splash screen', (tester) async {
      final router = createRouter();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: router,
            theme: AppTheme.darkTheme,
          ),
        ),
      );
      await tester.pumpAndSettle();

      router.go('/splash');
      await tester.pumpAndSettle();

      expect(find.text('Splash'), findsWidgets);
    });

    testWidgets('unregistered route renders error screen', (tester) async {
      final router = createRouter();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: router,
            theme: AppTheme.darkTheme,
          ),
        ),
      );
      await tester.pumpAndSettle();

      router.go('/non-existent');
      await tester.pumpAndSettle();

      expect(find.textContaining('Error'), findsWidgets);
    });

    testWidgets('navigation to details shows sub-route with slide transition', (tester) async {
      final router = createRouter();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: router,
            theme: AppTheme.darkTheme,
          ),
        ),
      );
      await tester.pumpAndSettle();

      router.go('/home/details');
      await tester.pumpAndSettle();

      expect(find.text('Home Details'), findsWidgets);
    });
  });
}
