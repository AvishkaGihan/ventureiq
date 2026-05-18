import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// VentureIQ Design System — Typography
///
/// Implements the 8-level type scale using Inter (primary) and
/// JetBrains Mono (monospace) via the google_fonts package.
///
/// Usage: Apply via `AppTheme.darkTheme` which sets the TextTheme,
/// or reference `AppTypography.textTheme` directly.
class AppTypography {
  AppTypography._();

  // ──────────────────────────────────────────────────────────────
  // Type Scale Definitions
  // ──────────────────────────────────────────────────────────────

  /// Display — 40px, ExtraBold (800), -0.03em, line-height 1.1
  static TextStyle get display => GoogleFonts.inter(
        fontSize: 40,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.03 * 40, // -0.03em
        height: 1.1,
      );

  /// H1 — 28px, Bold (700), -0.02em, line-height 1.2
  static TextStyle get h1 => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.02 * 28, // -0.02em
        height: 1.2,
      );

  /// H2 — 22px, Bold (700), -0.02em, line-height 1.2
  static TextStyle get h2 => GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.02 * 22, // -0.02em
        height: 1.2,
      );

  /// H3 — 18px, SemiBold (600), -0.01em, line-height 1.2
  static TextStyle get h3 => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.01 * 18, // -0.01em
        height: 1.2,
      );

  /// Body — 15px, Regular (400), 0em, line-height 1.6
  static TextStyle get body => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.6,
      );

  /// Body SM — 13px, Regular (400), 0em, line-height 1.6
  static TextStyle get bodySm => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.6,
      );

  /// Caption — 12px, Regular (400), 0em, line-height 1.6
  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.6,
      );

  /// Micro — 11px, Medium (500), 0.02em, line-height 1.6
  static TextStyle get micro => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.02 * 11, // 0.02em
        height: 1.6,
      );

  // ──────────────────────────────────────────────────────────────
  // Monospace (JetBrains Mono)
  // ──────────────────────────────────────────────────────────────

  /// Monospace body — for data, code, and numerical displays
  static TextStyle get mono => GoogleFonts.jetBrainsMono(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.6,
      );

  /// Monospace small — for inline code and metadata
  static TextStyle get monoSm => GoogleFonts.jetBrainsMono(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.6,
      );

  // ──────────────────────────────────────────────────────────────
  // Material TextTheme Factory
  // ──────────────────────────────────────────────────────────────

  /// Creates a [TextTheme] mapped to Material 3 slots.
  ///
  /// Mapping:
  /// - `displayLarge`   → Display (40px, 800)
  /// - `headlineLarge`  → H1 (28px, 700)
  /// - `headlineMedium` → H2 (22px, 700)
  /// - `titleLarge`     → H3 (18px, 600)
  /// - `bodyLarge`      → Body (15px, 400)
  /// - `bodyMedium`     → Body SM (13px, 400)
  /// - `bodySmall`      → Caption (12px, 400)
  /// - `labelSmall`     → Micro (11px, 500)
  static TextTheme get textTheme => TextTheme(
        displayLarge: display,
        headlineLarge: h1,
        headlineMedium: h2,
        titleLarge: h3,
        bodyLarge: body,
        bodyMedium: bodySm,
        bodySmall: caption,
        labelSmall: micro,
      );
}
