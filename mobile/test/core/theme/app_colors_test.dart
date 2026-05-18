import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ventureiq_app/core/theme/app_colors.dart';

void main() {
  group('AppColors', () {
    group('Surface System', () {
      test('surface000 is correct hex', () {
        expect(AppColors.surface000, const Color(0xFF09090B));
      });

      test('surface050 is correct hex', () {
        expect(AppColors.surface050, const Color(0xFF0F1117));
      });

      test('surface100 is correct hex', () {
        expect(AppColors.surface100, const Color(0xFF151823));
      });

      test('surface150 is correct hex', () {
        expect(AppColors.surface150, const Color(0xFF1A1E2E));
      });

      test('surface200 is correct hex', () {
        expect(AppColors.surface200, const Color(0xFF222639));
      });

      test('surface250 is correct hex', () {
        expect(AppColors.surface250, const Color(0xFF2A2F45));
      });

      test('surface300 is correct hex', () {
        expect(AppColors.surface300, const Color(0xFF343A52));
      });

      test('surface400 is correct hex', () {
        expect(AppColors.surface400, const Color(0xFF4A5173));
      });
    });

    group('Brand Accents', () {
      test('Electric Violet is correct', () {
        expect(AppColors.electricViolet, const Color(0xFF6C5CE7));
      });

      test('Violet Hover is correct', () {
        expect(AppColors.violetHover, const Color(0xFF7E70F0));
      });

      test('Cyan is correct', () {
        expect(AppColors.cyan, const Color(0xFF00D2FF));
      });

      test('Synthesis Violet is correct', () {
        expect(AppColors.synthesisViolet, const Color(0xFFA78BFA));
      });
    });

    group('Agent Identity Colors', () {
      test('Scout full color is correct', () {
        expect(AppColors.scoutFull, const Color(0xFF3B82F6));
      });

      test('Rival full color is correct', () {
        expect(AppColors.rivalFull, const Color(0xFFF43F5E));
      });

      test('CFO full color is correct', () {
        expect(AppColors.cfoFull, const Color(0xFFF59E0B));
      });

      test('Devils Advocate full color is correct', () {
        expect(AppColors.devilsAdvocateFull, const Color(0xFFEF4444));
      });

      test('Strategist full color is correct', () {
        expect(AppColors.strategistFull, const Color(0xFF10B981));
      });

      test('Coordinator full color is correct', () {
        expect(AppColors.coordinatorFull, const Color(0xFFA78BFA));
      });
    });

    group('Confidence Indicators', () {
      test('Verified Green is correct', () {
        expect(AppColors.verifiedGreen, const Color(0xFF22C55E));
      });

      test('Caution Amber is correct', () {
        expect(AppColors.cautionAmber, const Color(0xFFF59E0B));
      });

      test('Warning Red is correct', () {
        expect(AppColors.warningRed, const Color(0xFFEF4444));
      });
    });

    group('Text System', () {
      test('textPrimary is correct', () {
        expect(AppColors.textPrimary, const Color(0xFFF0F1F5));
      });

      test('textSecondary is correct', () {
        expect(AppColors.textSecondary, const Color(0xFFA1A7BE));
      });

      test('textTertiary is correct', () {
        expect(AppColors.textTertiary, const Color(0xFF6B7194));
      });

      test('textDisabled is correct', () {
        expect(AppColors.textDisabled, const Color(0xFF464D6A));
      });

      test('textInverse is correct', () {
        expect(AppColors.textInverse, const Color(0xFF09090B));
      });
    });

    group('Feedback Colors', () {
      test('success is correct', () {
        expect(AppColors.success, const Color(0xFF22C55E));
      });

      test('warning is correct', () {
        expect(AppColors.warning, const Color(0xFFF59E0B));
      });

      test('error is correct', () {
        expect(AppColors.error, const Color(0xFFEF4444));
      });

      test('info is correct', () {
        expect(AppColors.info, const Color(0xFF3B82F6));
      });
    });
  });
}
