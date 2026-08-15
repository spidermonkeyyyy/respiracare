// respi_colors.dart
// Claude Amber theme — exact 1:1 mapping of CSS custom properties.
//
// Light mode palette derived from the "Claude Amber" theme (#c96442 primary
// on a warm off-white background). Dark mode palette is a matching dark amber
// scheme. All tokens are `static const` for zero-cost access.

// ignore: unused_import
import "package:flutter/material.dart";

class RespiColors {
  RespiColors._();

  // ═════════════════════════════════════════════════════════════
  // DESIGN TOKENS
  // ═════════════════════════════════════════════════════════════

  // --radius: 1rem = 16px, sm = 0.5rem = 8px, lg = 1.5rem = 24px
  static const double radius = 16.0;
  static const double radiusSm = 8.0;
  static const double radiusLg = 24.0;

  /// --spacing: 0.25rem = 4px base unit
  static const double spacingUnit = 4.0;

  // ─── Shadows (from CSS: --shadow-opacity 0.1, --shadow-blur 3px, --shadow-offset-y 1px) ───────
  static const Color shadowColor = Color(0xFF000000);
  static const double shadowOpacity = 0.1;
  static const Offset shadowOffset = Offset(0, 1);
  static const double shadowBlur = 3.0;
  static const double shadowSpread = 0.0;

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: shadowColor.withValues(alpha: shadowOpacity),
          offset: shadowOffset,
          blurRadius: shadowBlur,
          spreadRadius: shadowSpread,
        ),
      ];

  // ═════════════════════════════════════════════════════════════
  // LIGHT MODE — "Claude Amber"
  // ═════════════════════════════════════════════════════════════

  // --primary: #c96442 (warm amber/orange)
  static const Color primary = Color(0xFFC96442);
  static const Color primaryForeground = Color(0xFFFFFFFF);

  // --secondary: #e9e6dc (warm sand)
  static const Color secondary = Color(0xFFE9E6DC);
  static const Color secondaryForeground = Color(0xFF535146);

  // --accent: #e9e6dc (same as secondary in this palette)
  static const Color accent = Color(0xFFE9E6DC);
  static const Color accentForeground = Color(0xFF28261B);

  // --warning: #e8a838 (amber for warnings)
  static const Color warning = Color(0xFFE8A838);
  static const Color warningForeground = Color(0xFF1E2A32);

  // --background: #faf9f5 (warm off-white)
  static const Color background = Color(0xFFFAF9F5);

  // --foreground: #3d3929 (warm dark brown)
  static const Color foreground = Color(0xFF3D3929);

  // --card: #f5f4ef (slightly warmer than background)
  static const Color card = Color(0xFFF5F4EF);
  static const Color cardForeground = Color(0xFF141413);

  // --popover: #ffffff
  static const Color popover = Color(0xFFFFFFFF);
  static const Color popoverForeground = Color(0xFF28261B);

  // --muted: #ede9de
  static const Color muted = Color(0xFFEDE9DE);
  static const Color mutedForeground = Color(0xFF6E6D68);

  // --destructive: #141413 (near black in light mode)
  static const Color destructive = Color(0xFF141413);
  static const Color destructiveForeground = Color(0xFFFAF9F5);

  // --border: #d9d6c9
  static const Color border = Color(0xFFD9D6C9);

  // --input: #d9d6c9 (same as border in this palette)
  static const Color input = Color(0xFFD9D6C9);

  // --ring: #c96442 (same as primary)
  static const Color ring = Color(0xFFC96442);

  // --chart-*
  static const Color chart1 = Color(0xFFC96442);
  static const Color chart2 = Color(0xFFA15530);
  static const Color chart3 = Color(0xFF3D3929);
  static const Color chart4 = Color(0xFFB5A68F);
  static const Color chart5 = Color(0xFFE9E6DC);

  // Sidebar specific (for future use)
  static const Color sidebar = Color(0xFFF5F4EE);
  static const Color sidebarForeground = Color(0xFF3D3D3A);
  static const Color sidebarPrimary = Color(0xFFC96442);
  static const Color sidebarPrimaryForeground = Color(0xFFFBFBFB);
  static const Color sidebarAccent = Color(0xFFE9E6DC);
  static const Color sidebarAccentForeground = Color(0xFF343434);
  static const Color sidebarBorder = Color(0xFFEBEBEB);
  static const Color sidebarRing = Color(0xFFB5B5B5);

  // ═════════════════════════════════════════════════════════════
  // DARK MODE
  // ═════════════════════════════════════════════════════════════

  // --primary: #d97757 (lighter amber for dark)
  static const Color primaryDark = Color(0xFFD97757);
  static const Color primaryForegroundDark = Color(0xFF141413);

  // --secondary: #faf9f5
  static const Color secondaryDark = Color(0xFFFAF9F5);
  static const Color secondaryForegroundDark = Color(0xFF30302E);

  // --accent: #1a1915
  static const Color accentDark = Color(0xFF1A1915);
  static const Color accentForegroundDark = Color(0xFFF5F4EE);

  // --warning: #f0c05c (amber for dark)
  static const Color warningDark = Color(0xFFF0C05C);
  static const Color warningForegroundDark = Color(0xFF1E2A32);

  // --background: #262624
  static const Color backgroundDark = Color(0xFF262624);

  // --foreground: #f1f1ef
  static const Color foregroundDark = Color(0xFFF1F1EF);

  // --card: #2c2c2b
  static const Color cardDark = Color(0xFF2C2C2B);
  static const Color cardForegroundDark = Color(0xFFFAF9F5);

  // --popover: #30302e
  static const Color popoverDark = Color(0xFF30302E);
  static const Color popoverForegroundDark = Color(0xFFE5E5E2);

  // --muted: #1b1b19
  static const Color mutedDark = Color(0xFF1B1B19);
  static const Color mutedForegroundDark = Color(0xFFB7B5A9);

  // --destructive: #ef4444 (actual red in dark mode)
  static const Color destructiveDark = Color(0xFFEF4444);
  static const Color destructiveForegroundDark = Color(0xFFFFFFFF);

  // --border: #3e3e38
  static const Color borderDark = Color(0xFF3E3E38);

  // --input: #52514a
  static const Color inputDark = Color(0xFF52514A);

  // --ring: #d97757
  static const Color ringDark = Color(0xFFD97757);

  // --chart-*
  static const Color chart1Dark = Color(0xFFB05730);
  static const Color chart2Dark = Color(0xFF9C87F5);
  static const Color chart3Dark = Color(0xFF1A1915);
  static const Color chart4Dark = Color(0xFF2F2B48);
  static const Color chart5Dark = Color(0xFFB4552D);

  // Sidebar dark
  static const Color sidebarDark = Color(0xFF1F1E1D);
  static const Color sidebarForegroundDark = Color(0xFFC3C0B6);
  static const Color sidebarPrimaryDark = Color(0xFF343434);
  static const Color sidebarPrimaryForegroundDark = Color(0xFFFBFBFB);
  static const Color sidebarAccentDark = Color(0xFF0F0F0E);
  static const Color sidebarAccentForegroundDark = Color(0xFFC3C0B6);
  static const Color sidebarBorderDark = Color(0xFFEBEBEB);
  static const Color sidebarRingDark = Color(0xFFB5B5B5);

  // ═════════════════════════════════════════════════════════════
  // BACKWARD COMPATIBILITY ALIASES
  // ═════════════════════════════════════════════════════════════
  // These aliases maintain compatibility with existing code that uses
  // the old Material Design token names (onPrimary, surface, etc.)

  // Light mode aliases
  static Color get onPrimary => primaryForeground;
  static Color get primaryContainer => card;
  static Color get onPrimaryContainer => cardForeground;
  static Color get onSecondary => secondaryForeground;
  static Color get surface => background;
  static Color get onSurface => foreground;
  static Color get surfaceVariant => card;
  static Color get onSurfaceVariant => mutedForeground;
  static Color get error => destructive;
  static Color get onError => destructiveForeground;
  static Color get outline => border;
  static Color get outlineVariant => input;

  // Dark mode aliases
  static Color get onSurfaceDark => foregroundDark;
  static Color get primaryContainerDark => cardDark;
  static Color get onPrimaryContainerDark => cardForegroundDark;
  static Color get surfaceDark => backgroundDark;
  static Color get surfaceVariantDark => cardDark;
  static Color get onSurfaceVariantDark => mutedForegroundDark;
  static Color get errorDark => destructiveDark;
  static Color get onErrorDark => destructiveForegroundDark;
  static Color get outlineDark => borderDark;
}