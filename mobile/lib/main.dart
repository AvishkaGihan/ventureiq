import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_router.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(
    const ProviderScope(
      child: VentureIQApp(),
    ),
  );
}

/// Root application widget.
///
/// Wrapped in [ProviderScope] for Riverpod state management.
/// Uses [MaterialApp.router] with GoRouter for declarative navigation.
class VentureIQApp extends ConsumerWidget {
  const VentureIQApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'VentureIQ',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
