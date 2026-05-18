import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ventureiq_app/core/theme/app_typography.dart';

class _MyHttpOverrides extends HttpOverrides {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = _MyHttpOverrides();

  group('AppTypography', () {
    group('Type Scale Sizes', () {
      test('display is 40px', () {
        expect(AppTypography.display.fontSize, 40);
      });

      test('h1 is 28px', () {
        expect(AppTypography.h1.fontSize, 28);
      });

      test('h2 is 22px', () {
        expect(AppTypography.h2.fontSize, 22);
      });

      test('h3 is 18px', () {
        expect(AppTypography.h3.fontSize, 18);
      });

      test('body is 15px', () {
        expect(AppTypography.body.fontSize, 15);
      });

      test('bodySm is 13px', () {
        expect(AppTypography.bodySm.fontSize, 13);
      });

      test('caption is 12px', () {
        expect(AppTypography.caption.fontSize, 12);
      });

      test('micro is 11px', () {
        expect(AppTypography.micro.fontSize, 11);
      });
    });

    group('Font Weights', () {
      test('display is ExtraBold (800)', () {
        expect(AppTypography.display.fontWeight, FontWeight.w800);
      });

      test('h1 is Bold (700)', () {
        expect(AppTypography.h1.fontWeight, FontWeight.w700);
      });

      test('h2 is Bold (700)', () {
        expect(AppTypography.h2.fontWeight, FontWeight.w700);
      });

      test('h3 is SemiBold (600)', () {
        expect(AppTypography.h3.fontWeight, FontWeight.w600);
      });

      test('body is Regular (400)', () {
        expect(AppTypography.body.fontWeight, FontWeight.w400);
      });

      test('micro is Medium (500)', () {
        expect(AppTypography.micro.fontWeight, FontWeight.w500);
      });
    });

    group('Letter Spacing', () {
      test('display has -0.03em letter spacing', () {
        expect(AppTypography.display.letterSpacing, closeTo(-0.03 * 40, 0.01));
      });

      test('h1 has -0.02em letter spacing', () {
        expect(AppTypography.h1.letterSpacing, closeTo(-0.02 * 28, 0.01));
      });

      test('h2 has -0.02em letter spacing', () {
        expect(AppTypography.h2.letterSpacing, closeTo(-0.02 * 22, 0.01));
      });

      test('h3 has -0.01em letter spacing', () {
        expect(AppTypography.h3.letterSpacing, closeTo(-0.01 * 18, 0.01));
      });

      test('body has 0 letter spacing', () {
        expect(AppTypography.body.letterSpacing, 0);
      });

      test('micro has 0.02em letter spacing', () {
        expect(AppTypography.micro.letterSpacing, closeTo(0.02 * 11, 0.01));
      });
    });

    group('TextTheme Mapping', () {
      test('textTheme maps displayLarge correctly', () {
        final textTheme = AppTypography.textTheme;
        expect(textTheme.displayLarge?.fontSize, 40);
        expect(textTheme.displayLarge?.fontWeight, FontWeight.w800);
      });

      test('textTheme maps headlineLarge correctly', () {
        final textTheme = AppTypography.textTheme;
        expect(textTheme.headlineLarge?.fontSize, 28);
        expect(textTheme.headlineLarge?.fontWeight, FontWeight.w700);
      });

      test('textTheme maps headlineMedium correctly', () {
        final textTheme = AppTypography.textTheme;
        expect(textTheme.headlineMedium?.fontSize, 22);
      });

      test('textTheme maps titleLarge correctly', () {
        final textTheme = AppTypography.textTheme;
        expect(textTheme.titleLarge?.fontSize, 18);
        expect(textTheme.titleLarge?.fontWeight, FontWeight.w600);
      });

      test('textTheme maps bodyLarge correctly', () {
        final textTheme = AppTypography.textTheme;
        expect(textTheme.bodyLarge?.fontSize, 15);
      });

      test('textTheme maps bodyMedium correctly', () {
        final textTheme = AppTypography.textTheme;
        expect(textTheme.bodyMedium?.fontSize, 13);
      });

      test('textTheme maps bodySmall correctly', () {
        final textTheme = AppTypography.textTheme;
        expect(textTheme.bodySmall?.fontSize, 12);
      });

      test('textTheme maps labelSmall correctly', () {
        final textTheme = AppTypography.textTheme;
        expect(textTheme.labelSmall?.fontSize, 11);
        expect(textTheme.labelSmall?.fontWeight, FontWeight.w500);
      });
    });

    group('Monospace', () {
      test('mono is 14px', () {
        expect(AppTypography.mono.fontSize, 14);
      });

      test('monoSm is 12px', () {
        expect(AppTypography.monoSm.fontSize, 12);
      });
    });
  });
}
