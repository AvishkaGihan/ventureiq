import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ventureiq_app/main.dart';

class _MyHttpOverrides extends HttpOverrides {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = _MyHttpOverrides();

  group('VentureIQApp', () {
    testWidgets('renders without error inside ProviderScope', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: VentureIQApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('applies dark theme', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: VentureIQApp(),
        ),
      );
      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(
        find.byType(MaterialApp),
      );
      expect(materialApp.theme?.brightness, Brightness.dark);
    });

    testWidgets('does not show debug banner', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: VentureIQApp(),
        ),
      );
      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(
        find.byType(MaterialApp),
      );
      expect(materialApp.debugShowCheckedModeBanner, isFalse);
    });
  });
}
