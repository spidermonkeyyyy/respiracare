import 'package:flutter/material.dart';

import 'tokens/respi_colors.dart';
import 'tokens/respi_typography.dart';
import 'tokens/respi_shapes.dart';

/// RespiraCare Material 3 theme definitions.
///
/// Both light and dark themes are derived from [RespiColors] so that the
/// semantic palette (and its WCAG 2.1 AA contrast guarantees) is the single
/// source of truth. Component shape and type defaults come from
/// [RespiShapes] and [RespiTypography].
abstract class RespiTheme {
  RespiTheme._();

  /// Light theme.
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: RespiColors.primary,
      brightness: Brightness.light,
      primary: RespiColors.primary,
      onPrimary: RespiColors.onPrimary,
      primaryContainer: RespiColors.primaryContainer,
      onPrimaryContainer: RespiColors.primaryDark,
      secondary: RespiColors.secondary,
      onSecondary: RespiColors.onSecondary,
      surface: RespiColors.surface,
      onSurface: RespiColors.onSurface,
      surfaceContainerHighest: RespiColors.surfaceVariant,
      onSurfaceVariant: RespiColors.onSurfaceVariant,
      error: RespiColors.error,
      onError: RespiColors.onError,
      outline: RespiColors.outline,
    );

    return _base(colorScheme);
  }

  /// Dark theme.
  static ThemeData get dark {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: RespiColors.primaryDark,
      brightness: Brightness.dark,
      primary: RespiColors.primaryDark,
      onPrimary: RespiColors.onSurfaceDark,
      primaryContainer: RespiColors.primaryContainerDark,
      onPrimaryContainer: RespiColors.onSurfaceDark,
      secondary: RespiColors.secondaryDark,
      onSecondary: RespiColors.onSurfaceDark,
      surface: RespiColors.surfaceDark,
      onSurface: RespiColors.onSurfaceDark,
      surfaceContainerHighest: RespiColors.surfaceVariantDark,
      onSurfaceVariant: RespiColors.onSurfaceVariantDark,
      error: RespiColors.errorDark,
      onError: RespiColors.onError,
      outline: RespiColors.outlineDark,
    );

    return _base(colorScheme);
  }

  static ThemeData _base(ColorScheme cs) {
    final isDark = cs.brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: isDark ? RespiColors.backgroundDark : RespiColors.background,
      fontFamily: RespiTypography.fontFamily,
      textTheme: const TextTheme(
        displayLarge: RespiTypography.displayLarge,
        displayMedium: RespiTypography.displayMedium,
        headlineLarge: RespiTypography.headlineLarge,
        headlineMedium: RespiTypography.headlineMedium,
        titleLarge: RespiTypography.titleLarge,
        titleMedium: RespiTypography.titleMedium,
        bodyLarge: RespiTypography.bodyLarge,
        bodyMedium: RespiTypography.bodyMedium,
        bodySmall: RespiTypography.bodySmall,
        labelLarge: RespiTypography.labelLarge,
        labelMedium: RespiTypography.labelMedium,
        labelSmall: RespiTypography.labelSmall,
      ),
      cardTheme: CardThemeData(
        color: isDark ? RespiColors.surfaceVariantDark : RespiColors.surface,
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: RespiShapes.xlRadius),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? RespiColors.surfaceVariantDark : RespiColors.surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        border: const OutlineInputBorder(borderRadius: RespiShapes.smRadius),
        enabledBorder: OutlineInputBorder(
          borderRadius: RespiShapes.smRadius,
          borderSide: BorderSide(color: cs.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: RespiShapes.smRadius,
          borderSide: BorderSide(color: cs.primary, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: RespiShapes.smRadius,
          borderSide: BorderSide(color: cs.error),
        ),
        labelStyle: RespiTypography.labelLarge.copyWith(color: cs.onSurfaceVariant),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: const RoundedRectangleBorder(borderRadius: RespiShapes.mdRadius),
          textStyle: RespiTypography.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: const RoundedRectangleBorder(borderRadius: RespiShapes.mdRadius),
          textStyle: RespiTypography.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: const RoundedRectangleBorder(borderRadius: RespiShapes.mdRadius),
          textStyle: RespiTypography.labelLarge,
        ),
      ),
      chipTheme: const ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: RespiShapes.fullRadius),
        labelStyle: RespiTypography.labelMedium,
        padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? RespiColors.surfaceDark : RespiColors.surface,
        foregroundColor: cs.onSurface,
        elevation: 0,
        titleTextStyle: RespiTypography.titleLarge,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedLabelStyle: RespiTypography.labelSmall,
        unselectedLabelStyle: RespiTypography.labelSmall,
      ),
      focusColor: cs.primary.withValues(alpha: 0.16),
      highlightColor: cs.primary.withValues(alpha: 0.12),
    );
  }
}
