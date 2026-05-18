import 'package:flutter/material.dart';

/// VentureIQ Design System — Color Palette
///
/// Complete color system implementing the VentureIQ dark theme specification.
/// All colors are defined as exact hex values per the UX design spec.
///
/// Usage: Reference via `AppColors.surface000`, `AppColors.electricViolet`, etc.
/// Never hardcode hex values in widgets — always use this class.
class AppColors {
  AppColors._();

  // ──────────────────────────────────────────────────────────────
  // Surface System (8 Layers)
  // ──────────────────────────────────────────────────────────────

  /// App background — darkest surface
  static const Color surface000 = Color(0xFF09090B);

  /// Card background
  static const Color surface050 = Color(0xFF0F1117);

  /// Elevated cards, bottom sheets, dialogs
  static const Color surface100 = Color(0xFF151823);

  /// Active/hover state backgrounds
  static const Color surface150 = Color(0xFF1A1E2E);

  /// Input field fills
  static const Color surface200 = Color(0xFF222639);

  /// Custom intermediate surface (not mapped to ColorScheme)
  static const Color surface250 = Color(0xFF2A2F45);

  /// Borders
  static const Color surface300 = Color(0xFF343A52);

  /// Muted icons, dividers
  static const Color surface400 = Color(0xFF4A5173);

  // ──────────────────────────────────────────────────────────────
  // Brand Accent Colors
  // ──────────────────────────────────────────────────────────────

  /// Primary brand color
  static const Color electricViolet = Color(0xFF6C5CE7);

  /// Hover state for Electric Violet
  static const Color violetHover = Color(0xFF7E70F0);

  /// Secondary accent
  static const Color cyan = Color(0xFF00D2FF);

  /// Tertiary accent — synthesis/coordinator
  static const Color synthesisViolet = Color(0xFFA78BFA);

  // ──────────────────────────────────────────────────────────────
  // Agent Identity Colors
  // ──────────────────────────────────────────────────────────────

  // Scout Agent
  static const Color scoutFull = Color(0xFF3B82F6);
  static const Color scoutMuted = Color(0x663B82F6);
  static const Color scoutGlow = Color(0x4D3B82F6);

  // Rival Agent
  static const Color rivalFull = Color(0xFFF43F5E);
  static const Color rivalMuted = Color(0x66F43F5E);
  static const Color rivalGlow = Color(0x4DF43F5E);

  // CFO Agent
  static const Color cfoFull = Color(0xFFF59E0B);
  static const Color cfoMuted = Color(0x66F59E0B);
  static const Color cfoGlow = Color(0x4DF59E0B);

  // Devil's Advocate Agent
  static const Color devilsAdvocateFull = Color(0xFFEF4444);
  static const Color devilsAdvocateMuted = Color(0x66EF4444);
  static const Color devilsAdvocateGlow = Color(0x4DEF4444);

  // Strategist Agent
  static const Color strategistFull = Color(0xFF10B981);
  static const Color strategistMuted = Color(0x6610B981);
  static const Color strategistGlow = Color(0x4D10B981);

  // Coordinator Agent
  static const Color coordinatorFull = Color(0xFFA78BFA);
  static const Color coordinatorMuted = Color(0x66A78BFA);
  static const Color coordinatorGlow = Color(0x4DA78BFA);

  // ──────────────────────────────────────────────────────────────
  // Confidence Indicator Colors
  // ──────────────────────────────────────────────────────────────

  /// High confidence — verified
  static const Color verifiedGreen = Color(0xFF22C55E);

  /// Medium confidence — caution
  static const Color cautionAmber = Color(0xFFF59E0B);

  /// Low confidence — warning
  static const Color warningRed = Color(0xFFEF4444);

  // ──────────────────────────────────────────────────────────────
  // Text System Colors
  // ──────────────────────────────────────────────────────────────

  /// Primary text — headings and body
  static const Color textPrimary = Color(0xFFF0F1F5);

  /// Secondary text — subtitles and labels
  static const Color textSecondary = Color(0xFFA1A7BE);

  /// Tertiary text — inactive elements and hints
  static const Color textTertiary = Color(0xFF6B7194);

  /// Disabled text
  static const Color textDisabled = Color(0xFF464D6A);

  /// Inverse text — on bright backgrounds
  static const Color textInverse = Color(0xFF09090B);

  // ──────────────────────────────────────────────────────────────
  // Feedback / Status Colors
  // ──────────────────────────────────────────────────────────────

  /// Success feedback
  static const Color success = Color(0xFF22C55E);

  /// Warning feedback
  static const Color warning = Color(0xFFF59E0B);

  /// Error feedback
  static const Color error = Color(0xFFEF4444);

  /// Info feedback
  static const Color info = Color(0xFF3B82F6);
}
