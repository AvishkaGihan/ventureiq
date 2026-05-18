import 'package:flutter_test/flutter_test.dart';
import 'package:ventureiq_app/core/utils/responsive.dart';

void main() {
  group('ResponsiveConfig', () {
    group('Tier Detection', () {
      test('width 320 is Compact', () {
        final config = ResponsiveConfig.fromWidth(320);
        expect(config.tier, ScreenTier.compact);
      });

      test('width 350 is Compact', () {
        final config = ResponsiveConfig.fromWidth(350);
        expect(config.tier, ScreenTier.compact);
      });

      test('width 374 is Compact', () {
        final config = ResponsiveConfig.fromWidth(374);
        expect(config.tier, ScreenTier.compact);
      });

      test('width 375 is Standard', () {
        final config = ResponsiveConfig.fromWidth(375);
        expect(config.tier, ScreenTier.standard);
      });

      test('width 390 is Standard', () {
        final config = ResponsiveConfig.fromWidth(390);
        expect(config.tier, ScreenTier.standard);
      });

      test('width 413 is Standard', () {
        final config = ResponsiveConfig.fromWidth(413);
        expect(config.tier, ScreenTier.standard);
      });

      test('width 414 is Large', () {
        final config = ResponsiveConfig.fromWidth(414);
        expect(config.tier, ScreenTier.large);
      });

      test('width 430 is Large', () {
        final config = ResponsiveConfig.fromWidth(430);
        expect(config.tier, ScreenTier.large);
      });

      test('width 480 is Large', () {
        final config = ResponsiveConfig.fromWidth(480);
        expect(config.tier, ScreenTier.large);
      });
    });

    group('Compact Tier Properties', () {
      test('horizontalMargin is 12', () {
        final config = ResponsiveConfig.fromWidth(350);
        expect(config.horizontalMargin, 12);
      });

      test('cardPadding is 12', () {
        final config = ResponsiveConfig.fromWidth(350);
        expect(config.cardPadding, 12);
      });

      test('heroScoreSize is 56', () {
        final config = ResponsiveConfig.fromWidth(350);
        expect(config.heroScoreSize, 56);
      });

      test('bodyFontSize is 14', () {
        final config = ResponsiveConfig.fromWidth(350);
        expect(config.bodyFontSize, 14);
      });
    });

    group('Standard Tier Properties', () {
      test('horizontalMargin is 16', () {
        final config = ResponsiveConfig.fromWidth(390);
        expect(config.horizontalMargin, 16);
      });

      test('cardPadding is 16', () {
        final config = ResponsiveConfig.fromWidth(390);
        expect(config.cardPadding, 16);
      });

      test('heroScoreSize is 72', () {
        final config = ResponsiveConfig.fromWidth(390);
        expect(config.heroScoreSize, 72);
      });

      test('bodyFontSize is 15', () {
        final config = ResponsiveConfig.fromWidth(390);
        expect(config.bodyFontSize, 15);
      });
    });

    group('Large Tier Properties', () {
      test('horizontalMargin is 20', () {
        final config = ResponsiveConfig.fromWidth(430);
        expect(config.horizontalMargin, 20);
      });

      test('cardPadding is 20', () {
        final config = ResponsiveConfig.fromWidth(430);
        expect(config.cardPadding, 20);
      });

      test('heroScoreSize is 80', () {
        final config = ResponsiveConfig.fromWidth(430);
        expect(config.heroScoreSize, 80);
      });

      test('bodyFontSize is 15', () {
        final config = ResponsiveConfig.fromWidth(430);
        expect(config.bodyFontSize, 15);
      });
    });
  });
}
