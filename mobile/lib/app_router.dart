import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_colors.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/domain/auth_entity.dart';
import 'features/auth/domain/auth_state.dart';
import 'features/auth/presentation/auth_providers.dart';

// ──────────────────────────────────────────────────────────────
// Placeholder Screens
// ──────────────────────────────────────────────────────────────

/// Placeholder screen used for each tab route.
/// Will be replaced by feature-specific screens in later stories.
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 48,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Coming Soon',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textTertiary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Profile Screen (Minimal — Story 2.2 foundation)
// ──────────────────────────────────────────────────────────────

/// Minimal Profile screen showing auth status and Google Sign-In button.
///
/// Anonymous users see "Sign in with Google" CTA.
/// Authenticated users see their name/email and a sign-out option.
/// This sets the foundation for Story 15.2 (full Profile Screen).
class _ProfileScreen extends ConsumerWidget {
  const _ProfileScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(authNotifierProvider, (previous, next) {
      // Show success toast on anonymous to authenticated upgrade
      if (previous != null &&
          previous.value is AuthStateAnonymous &&
          next.value is AuthStateAuthenticated) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account created! Your data has been preserved.'),
              backgroundColor: AppColors.success,
              duration: Duration(seconds: 4),
            ),
          );
        }
      }

      // Show error toast on error state (unless it's loading)
      if (next.hasError && !next.isLoading) {
        final error = next.error;
        final String message;
        if (error is AccountAlreadyInUseException) {
          message = 'This Google account is already in use';
        } else if (error is ProviderAlreadyLinkedException) {
          message = 'A Google provider is already linked to this account.';
        } else {
          message = 'Something went wrong during sign in';
        }
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: AppColors.surface100,
              duration: const Duration(seconds: 4),
              shape: const Border(
                left: BorderSide(color: AppColors.electricViolet, width: 4),
              ),
            ),
          );
        }
      }
    });

    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: authState.when(
            loading: () => const CircularProgressIndicator(
              color: AppColors.electricViolet,
            ),
            error: (error, _) => _ProfileError(
              message: error.toString(),
              onRetry: () => ref.invalidate(authNotifierProvider),
            ),
            data: (state) => switch (state) {
              AuthStateUnauthenticated() => const _ProfileLoading(),
              AuthStateAnonymous() => const _AnonymousProfile(),
              AuthStateAuthenticated(:final user) =>
                _AuthenticatedProfile(user: user),
            },
          ),
        ),
      ),
    );
  }
}

/// Loading indicator shown during auto-anonymous sign-in.
class _ProfileLoading extends StatelessWidget {
  const _ProfileLoading();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(color: AppColors.electricViolet),
        SizedBox(height: 16),
        Text(
          'Setting up...',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

/// Profile view for anonymous users — shows Google Sign-In CTA.
class _AnonymousProfile extends ConsumerWidget {
  const _AnonymousProfile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.person_outline,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'Anonymous User',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sign in to sync your reports across devices',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: _GoogleSignInButton(
              onPressed: () async {
                await ref
                    .read(authNotifierProvider.notifier)
                    .signInWithGoogle();
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Google Sign-In button following VentureIQ design tokens.
///
/// Electric Violet (#6C5CE7) primary CTA, 48dp height, 8dp radius.
/// Shows loading indicator when auth is in progress.
class _GoogleSignInButton extends ConsumerWidget {
  const _GoogleSignInButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(authNotifierProvider).isLoading;

    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.electricViolet,
        foregroundColor: AppColors.textPrimary,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        disabledBackgroundColor:
            AppColors.electricViolet.withValues(alpha: 0.5),
      ),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.textPrimary,
              ),
            )
          : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.login),
                SizedBox(width: 8),
                Text('Sign in with Google'),
              ],
            ),
    );
  }
}

/// Profile view for authenticated (Google) users.
class _AuthenticatedProfile extends ConsumerWidget {
  const _AuthenticatedProfile({required this.user});

  final AuthUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.account_circle,
            size: 64,
            color: AppColors.electricViolet,
          ),
          const SizedBox(height: 16),
          Text(
            user.displayName ?? 'User',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.textPrimary,
                ),
          ),
          if (user.email != null) ...[
            const SizedBox(height: 4),
            Text(
              user.email!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () async {
                await ref.read(authNotifierProvider.notifier).signOut();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                side: const BorderSide(color: AppColors.textTertiary),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Error display for profile auth failures.
class _ProfileError extends StatelessWidget {
  const _ProfileError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textTertiary,
                ),
          ),
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Navigation Shell
// ──────────────────────────────────────────────────────────────

/// Bottom navigation shell that wraps all tab routes.
class _NavigationShell extends StatelessWidget {
  const _NavigationShell({
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.assessment_outlined),
            selectedIcon: Icon(Icons.assessment),
            label: 'Reports',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Board',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Custom Page Transitions
// ──────────────────────────────────────────────────────────────

/// Slide from right transition — forward navigation (0.3s ease).
///
/// Use for push-style navigation within tabs.
CustomTransitionPage<void> slideFromRight(
  BuildContext context,
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      );
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(curvedAnimation),
        child: child,
      );
    },
  );
}

/// Fade crossfade transition — tab switching (0.15s)
CustomTransitionPage<void> _fadeCrossfade(
  BuildContext context,
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 150),

    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  );
}

// ──────────────────────────────────────────────────────────────
// Router Configuration
// ──────────────────────────────────────────────────────────────

/// GoRouter instance provided via Riverpod for testability.
///
/// Depends on [authNotifierProvider] for auth-state-aware redirects.
/// On `unauthenticated` state, triggers auto-anonymous sign-in transparently.
final routerProvider = Provider<GoRouter>((ref) {
  final router = createRouter();
  return router;
});

/// Creates the GoRouter configuration.
///
/// Extracted as a standalone function for testing.
GoRouter createRouter() {
  return GoRouter(
    initialLocation: '/home',
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Error: ${state.error}'),
      ),
    ),
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const _PlaceholderScreen(
          title: 'Splash',
          icon: Icons.rocket_launch,
        ),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const _PlaceholderScreen(
          title: 'Auth',
          icon: Icons.lock_outline,
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return _NavigationShell(navigationShell: navigationShell);
        },
        branches: [
          // Home tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                pageBuilder: (context, state) => _fadeCrossfade(
                  context,
                  state,
                  const _PlaceholderScreen(
                    title: 'Home',
                    icon: Icons.home,
                  ),
                ),
                routes: [
                  GoRoute(
                    path: 'details',
                    pageBuilder: (context, state) => slideFromRight(
                      context,
                      state,
                      const _PlaceholderScreen(
                        title: 'Home Details',
                        icon: Icons.info_outline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Reports tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/reports',
                pageBuilder: (context, state) => _fadeCrossfade(
                  context,
                  state,
                  const _PlaceholderScreen(
                    title: 'Reports',
                    icon: Icons.assessment,
                  ),
                ),
              ),
            ],
          ),
          // Board tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/board',
                pageBuilder: (context, state) => _fadeCrossfade(
                  context,
                  state,
                  const _PlaceholderScreen(
                    title: 'Board',
                    icon: Icons.groups,
                  ),
                ),
              ),
            ],
          ),
          // Profile tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                pageBuilder: (context, state) => _fadeCrossfade(
                  context,
                  state,
                  const _ProfileScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
