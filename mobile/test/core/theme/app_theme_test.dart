import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ventureiq_app/core/theme/app_colors.dart';
import 'package:ventureiq_app/core/theme/app_theme.dart';

class _MyHttpOverrides extends HttpOverrides {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = _MyHttpOverrides();

  group('AppTheme', () {
    late ThemeData theme;

    setUp(() {
      theme = AppTheme.darkTheme;
    });

    test('dark theme has correct brightness', () {
      expect(theme.brightness, Brightness.dark);
    });

    test('uses Material 3', () {
      expect(theme.useMaterial3, isTrue);
    });

    test('primary color is Electric Violet', () {
      expect(theme.colorScheme.primary, const Color(0xFF6C5CE7));
    });

    test('secondary color is Cyan', () {
      expect(theme.colorScheme.secondary, const Color(0xFF00D2FF));
    });

    test('tertiary color is Synthesis Violet', () {
      expect(theme.colorScheme.tertiary, const Color(0xFFA78BFA));
    });

    test('surface is surface000', () {
      expect(theme.colorScheme.surface, AppColors.surface000);
    });

    test('onSurface is textPrimary', () {
      expect(theme.colorScheme.onSurface, AppColors.textPrimary);
    });

    test('outline is surface300', () {
      expect(theme.colorScheme.outline, AppColors.surface300);
    });

    test('outlineVariant is surface400', () {
      expect(theme.colorScheme.outlineVariant, AppColors.surface400);
    });

    test('surfaceContainerLow is surface050', () {
      expect(
        theme.colorScheme.surfaceContainerLow,
        AppColors.surface050,
      );
    });

    test('surfaceContainer is surface100', () {
      expect(theme.colorScheme.surfaceContainer, AppColors.surface100);
    });

    test('surfaceContainerHighest is surface200', () {
      expect(
        theme.colorScheme.surfaceContainerHighest,
        AppColors.surface200,
      );
    });

    test('scaffold background is surface000', () {
      expect(theme.scaffoldBackgroundColor, AppColors.surface000);
    });

    test('error color is correct', () {
      expect(theme.colorScheme.error, AppColors.error);
    });

    group('Component Themes', () {
      test('Card theme uses surface050 and no elevation', () {
        final cardTheme = theme.cardTheme;
        expect(cardTheme.color, AppColors.surface050);
        expect(cardTheme.elevation, 0);
      });

      test('BottomSheet theme uses surface100', () {
        expect(
          theme.bottomSheetTheme.backgroundColor,
          AppColors.surface100,
        );
        expect(theme.bottomSheetTheme.showDragHandle, isTrue);
      });

      test('InputDecoration theme is filled with surface200', () {
        final inputTheme = theme.inputDecorationTheme;
        expect(inputTheme.filled, isTrue);
        expect(inputTheme.fillColor, AppColors.surface200);
      });

      test('NavigationBar theme uses surface050 background', () {
        expect(
          theme.navigationBarTheme.backgroundColor,
          AppColors.surface050,
        );
      });

      test('SnackBar theme uses surface100', () {
        expect(
          theme.snackBarTheme.backgroundColor,
          AppColors.surface100,
        );
      });

      test('Dialog theme uses surface100', () {
        expect(
          theme.dialogTheme.backgroundColor,
          AppColors.surface100,
        );
      });

      test('AppBar theme uses surface000 and no elevation', () {
        expect(
          theme.appBarTheme.backgroundColor,
          AppColors.surface000,
        );
        expect(theme.appBarTheme.elevation, 0);
      });
    });
  });
}
