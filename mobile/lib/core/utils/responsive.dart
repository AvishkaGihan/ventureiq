import 'package:flutter/widgets.dart';

/// VentureIQ Responsive Configuration
///
/// Implements 3 screen tiers (Compact, Standard, Large) with
/// tier-specific layout properties for consistent responsive behavior.
///
/// Usage: `final config = ResponsiveConfig.of(context);`
/// Then access `config.horizontalMargin`, `config.cardPadding`, etc.

/// Screen size tier classification.
enum ScreenTier {
  /// 320–374dp width
  compact,

  /// 375–413dp width
  standard,

  /// 414–480dp+ width
  large,
}

/// Responsive layout configuration based on screen width.
class ResponsiveConfig {
  const ResponsiveConfig._({
    required this.tier,
    required this.horizontalMargin,
    required this.cardPadding,
    required this.heroScoreSize,
    required this.bodyFontSize,
  });

  /// Breakpoint for Standard tier
  static const double breakpointStandard = 375;

  /// Breakpoint for Large tier
  static const double breakpointLarge = 414;

  /// Current screen tier
  final ScreenTier tier;

  /// Horizontal margin for page content
  final double horizontalMargin;

  /// Padding inside cards
  final double cardPadding;

  /// Size of the hero viability score display
  final double heroScoreSize;

  /// Body text font size for this tier
  final double bodyFontSize;

  /// Compact tier config (320ΓÇô374dp)
  static const ResponsiveConfig _compact = ResponsiveConfig._(
    tier: ScreenTier.compact,
    horizontalMargin: 12,
    cardPadding: 12,
    heroScoreSize: 56,
    bodyFontSize: 14,
  );

  /// Standard tier config (375ΓÇô413dp)
  static const ResponsiveConfig _standard = ResponsiveConfig._(
    tier: ScreenTier.standard,
    horizontalMargin: 16,
    cardPadding: 16,
    heroScoreSize: 72,
    bodyFontSize: 15,
  );

  /// Large tier config (414dp+)
  static const ResponsiveConfig _large = ResponsiveConfig._(
    tier: ScreenTier.large,
    horizontalMargin: 20,
    cardPadding: 20,
    heroScoreSize: 80,
    bodyFontSize: 15,
  );

  /// Determine the responsive config from BuildContext.
  ///
  /// Uses [MediaQuery.sizeOf] for efficient rebuilds.
  factory ResponsiveConfig.of(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return fromWidth(width);
  }

  /// Determine the responsive config from a raw width value.
  ///
  /// Useful for testing without a BuildContext.
  static ResponsiveConfig fromWidth(double width) {
    if (width < breakpointStandard) {
      return _compact;
    } else if (width < breakpointLarge) {
      return _standard;
    } else {
      return _large;
    }
  }
}

