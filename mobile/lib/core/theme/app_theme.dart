import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// VentureIQ Design System — App Theme
///
/// Creates the dark [ThemeData] with complete Material 3 component theming.
/// Every Material component is explicitly themed — no default Material look.
class AppTheme {
  AppTheme._();

  /// The dark theme for VentureIQ.
  static ThemeData get darkTheme {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      // Brand
      primary: AppColors.electricViolet,
      onPrimary: AppColors.textInverse,
      secondary: AppColors.cyan,
      onSecondary: AppColors.textInverse,
      tertiary: AppColors.synthesisViolet,
      onTertiary: AppColors.textInverse,
      // Error
      error: AppColors.error,
      onError: AppColors.textInverse,
      // Surface system
      surface: AppColors.surface000,
      onSurface: AppColors.textPrimary,
      surfaceContainerLow: AppColors.surface050,
      surfaceContainer: AppColors.surface100,
      surfaceContainerHigh: AppColors.surface150,
      surfaceContainerHighest: AppColors.surface200,
      // Outlines
      outline: AppColors.surface300,
      outlineVariant: AppColors.surface400,
      // Misc
      inverseSurface: AppColors.textPrimary,
      onInverseSurface: AppColors.surface000,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.surface000,
      textTheme: AppTypography.textTheme,

      // ────────────────────────────────────────────────────────────
      // Card Theme
      // ────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.surface050,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          side: const BorderSide(
            color: AppColors.surface300,
          ),
        ),
        margin: EdgeInsets.zero,
      ),

      // ────────────────────────────────────────────────────────────
      // Bottom Sheet Theme
      // ────────────────────────────────────────────────────────────
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface100,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppSpacing.radiusXl),
            topRight: Radius.circular(AppSpacing.radiusXl),
          ),
        ),
        showDragHandle: true,
        dragHandleColor: AppColors.surface400,
      ),

      // ────────────────────────────────────────────────────────────
      // Input / TextField Theme
      // ────────────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(
            color: AppColors.electricViolet,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(
            color: AppColors.error,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 2,
          ),
        ),
        hintStyle: const TextStyle(color: AppColors.textTertiary),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space4,
          vertical: AppSpacing.space3,
        ),
      ),

      // ────────────────────────────────────────────────────────────
      // Button Themes (Filled & Elevated)
      // ────────────────────────────────────────────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: _commonButtonStyle,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: _commonButtonStyle.copyWith(
          elevation: WidgetStateProperty.all(0),
        ),
      ),

      // ────────────────────────────────────────────────────────────
      // TextButton Theme
      // ────────────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.electricViolet,
          backgroundColor: Colors.transparent,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),

      // ────────────────────────────────────────────────────────────
      // Chip Theme
      // ────────────────────────────────────────────────────────────
      chipTheme: const ChipThemeData(
        backgroundColor: AppColors.surface100,
        side: BorderSide(color: AppColors.surface300),
        shape: StadiumBorder(),
        labelStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 13,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.space3,
          vertical: AppSpacing.space1,
        ),
      ),

      // ────────────────────────────────────────────────────────────
      // NavigationBar Theme
      // ────────────────────────────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface050,
        indicatorColor: AppColors.electricViolet.withValues(alpha: 0.2),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: AppColors.electricViolet,
              size: 24,
            );
          }
          return const IconThemeData(
            color: AppColors.textTertiary,
            size: 24,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: AppColors.electricViolet,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            );
          }
          return const TextStyle(
            color: AppColors.textTertiary,
            fontSize: 12,
            fontWeight: FontWeight.w400,
          );
        }),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),

      // ────────────────────────────────────────────────────────────
      // SnackBar Theme
      // ────────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surface100,
        contentTextStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        behavior: SnackBarBehavior.floating,
        insetPadding: const EdgeInsets.all(AppSpacing.space4),
        dismissDirection: DismissDirection.down,
      ),

      // ────────────────────────────────────────────────────────────
      // Dialog Theme
      // ────────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface100,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          side: const BorderSide(color: AppColors.surface300),
        ),
        titleTextStyle: AppTypography.h3.copyWith(
          color: AppColors.textPrimary,
        ),
        contentTextStyle: AppTypography.body.copyWith(
          color: AppColors.textSecondary,
        ),
        elevation: 0,
      ),

      // ────────────────────────────────────────────────────────────
      // AppBar Theme (minimal — mostly for scroll behavior)
      // ────────────────────────────────────────────────────────────
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface000,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),

      // ────────────────────────────────────────────────────────────
      // Divider Theme
      // ────────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.surface300,
        thickness: 1,
        space: 1,
      ),
    );
  }

  static ButtonStyle get _commonButtonStyle => FilledButton.styleFrom(
        backgroundColor: AppColors.electricViolet,
        foregroundColor: AppColors.textInverse,
        minimumSize: const Size(0, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      );
}
