/// VentureIQ Design System — Spacing & Border Radius
///
/// Defines the 4px-based spacing scale and border radius tokens
/// used consistently across the entire application.
///
/// Usage: `AppSpacing.space4` for 16px padding,
/// `AppSpacing.radiusMd` for 12px border radius.
class AppSpacing {
  AppSpacing._();

  // ──────────────────────────────────────────────────────────────
  // Spacing Scale (4px base unit)
  // ──────────────────────────────────────────────────────────────

  /// 4px — minimal spacing
  static const double space1 = 4;

  /// 8px — tight spacing
  static const double space2 = 8;

  /// 12px — compact spacing
  static const double space3 = 12;

  /// 16px — standard spacing
  static const double space4 = 16;

  /// 20px — comfortable spacing
  static const double space5 = 20;

  /// 24px — section spacing
  static const double space6 = 24;

  /// 32px — group spacing
  static const double space7 = 32;

  /// 40px — large spacing
  static const double space8 = 40;

  /// 48px — extra-large spacing
  static const double space9 = 48;

  /// 64px — maximum spacing
  static const double space10 = 64;

  // ──────────────────────────────────────────────────────────────
  // Border Radius Scale
  // ──────────────────────────────────────────────────────────────

  /// 8px — small radius (buttons, chips)
  static const double radiusSm = 8;

  /// 12px — medium radius (cards, inputs)
  static const double radiusMd = 12;

  /// 16px — large radius (dialogs)
  static const double radiusLg = 16;

  /// 20px — extra-large radius (bottom sheets)
  static const double radiusXl = 20;

  /// 9999px — full/pill radius
  static const double radiusFull = 9999;
}
