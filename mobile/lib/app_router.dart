import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_colors.dart';

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

/// Fade crossfade transition ΓÇö tab switching (0.15s)
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
final routerProvider = Provider<GoRouter>((ref) {
  return createRouter();
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
                  const _PlaceholderScreen(
                    title: 'Profile',
                    icon: Icons.person,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
