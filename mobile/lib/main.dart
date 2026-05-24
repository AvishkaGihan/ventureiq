import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ventureiq_app/core/networking/dio_client.dart';
import 'package:ventureiq_app/features/auth/data/token_storage.dart';
import 'package:ventureiq_app/features/auth/presentation/auth_providers.dart';

import 'app_router.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Try-catch Firebase and Google Sign-In setup to ensure startup resiliency.
  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize GoogleSignIn v7.x singleton
    await GoogleSignIn.instance.initialize();
  } catch (e) {
    debugPrint('[Main] Core Firebase/Google services failed to initialize: $e');
  }

  // Pre-initialize ProviderContainer to link global events to Riverpod
  final container = ProviderContainer();

  // Set up auth interceptor on DioClient
  final tokenStorage = TokenStorage();
  final plainDio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  DioClient.instance.addAuthInterceptor(
    tokenStorage: tokenStorage,
    plainDio: plainDio,
    onAuthExpired: () {
      // Correctly syncs back to Riverpod to notify UI of background refresh failure
      container.read(authNotifierProvider.notifier).forceUnauthenticated();
      debugPrint('[Auth] Session expired — tokens cleared and notifier forced unauthenticated');
    },
  );

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const VentureIQApp(),
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
