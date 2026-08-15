import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "../core/theme/tokens/respi_colors.dart";

/// Raw design tokens that don't have a direct home in [ColorScheme].
/// Mirrors --chart-1..5, --radius, --spacing and the shadow tokens from
/// the source CSS file.
class AppTokens {
  AppTokens._();

  // --radius: 1rem (16px), used as the base and scaled down/up per widget.
  static const double radius = 16.0;
  static const double radiusSm = 8.0;
  static const double radiusLg = 20.0;

  // --spacing: 0.25rem (4px) base unit.
  static const double spacingUnit = 4.0;

  // --shadow-* tokens (light and dark share the same values in the source).
  static const Color shadowColor = Colors.black;
  static const double shadowOpacity = 0.1;
  static const Offset shadowOffset = Offset(0, 1);
  static const double shadowBlur = 3.0;

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: shadowColor.withValues(alpha: shadowOpacity),
          offset: shadowOffset,
          blurRadius: shadowBlur,
        ),
      ];
}

/// Chart/data-viz palette — not part of ColorScheme, so it's exposed as a
/// ThemeExtension. Access it with `Theme.of(context).extension<ChartColors>()`.
@immutable
class ChartColors extends ThemeExtension<ChartColors> {
  const ChartColors({
    required this.chart1,
    required this.chart2,
    required this.chart3,
    required this.chart4,
    required this.chart5,
  });

  final Color chart1;
  final Color chart2;
  final Color chart3;
  final Color chart4;
  final Color chart5;

  // Claude Amber chart colors (light mode)
  static const light = ChartColors(
    chart1: Color(0xFFC96442), // amber primary
    chart2: Color(0xFFA15530),
    chart3: Color(0xFF3D3929),
    chart4: Color(0xFFB5A68F),
    chart5: Color(0xFFE9E6DC),
  );

  // Claude Amber chart colors (dark mode)
  static const dark = ChartColors(
    chart1: Color(0xFFB05730),
    chart2: Color(0xFFD97757),
    chart3: Color(0xFF1A1915),
    chart4: Color(0xFF2F2B48),
    chart5: Color(0xFFB4552D),
  );

  List<Color> get asList => [chart1, chart2, chart3, chart4, chart5];

  @override
  ChartColors copyWith({
    Color? chart1,
    Color? chart2,
    Color? chart3,
    Color? chart4,
    Color? chart5,
  }) {
    return ChartColors(
      chart1: chart1 ?? this.chart1,
      chart2: chart2 ?? this.chart2,
      chart3: chart3 ?? this.chart3,
      chart4: chart4 ?? this.chart4,
      chart5: chart5 ?? this.chart5,
    );
  }

  @override
  ChartColors lerp(ThemeExtension<ChartColors>? other, double t) {
    if (other is! ChartColors) return this;
    return ChartColors(
      chart1: Color.lerp(chart1, other.chart1, t)!,
      chart2: Color.lerp(chart2, other.chart2, t)!,
      chart3: Color.lerp(chart3, other.chart3, t)!,
      chart4: Color.lerp(chart4, other.chart4, t)!,
      chart5: Color.lerp(chart5, other.chart5, t)!,
    );
  }
}

class AppTheme {
  AppTheme._();

  // ---- Claude Amber Light Theme Tokens ----
  static const Color _lightPrimary = RespiColors.primary;
  static const Color _lightPrimaryFg = RespiColors.primaryForeground;
  static const Color _lightSecondary = RespiColors.secondary;
  static const Color _lightSecondaryFg = RespiColors.secondaryForeground;
  static const Color _lightBackground = RespiColors.background;
  static const Color _lightForeground = RespiColors.foreground;
  static const Color _lightCard = RespiColors.card;
  static const Color _lightMuted = RespiColors.muted;
  static const Color _lightMutedFg = RespiColors.mutedForeground;
  static const Color _lightDestructive = RespiColors.destructive;
  static const Color _lightDestructiveFg = RespiColors.destructiveForeground;
  static const Color _lightBorder = RespiColors.border;
  static const Color _lightInput = RespiColors.input;
  static const Color _lightRing = RespiColors.ring;

  // ---- Claude Amber Dark Theme Tokens ----
  static const Color _darkPrimary = RespiColors.primaryDark;
  static const Color _darkPrimaryFg = RespiColors.primaryForegroundDark;
  static const Color _darkSecondary = RespiColors.secondaryDark;
  static const Color _darkSecondaryFg = RespiColors.secondaryForegroundDark;
  static const Color _darkBackground = RespiColors.backgroundDark;
  static const Color _darkForeground = RespiColors.foregroundDark;
  static const Color _darkCard = RespiColors.cardDark;
  static const Color _darkMuted = RespiColors.mutedDark;
  static const Color _darkMutedFg = RespiColors.mutedForegroundDark;
  static const Color _darkDestructive = RespiColors.destructiveDark;
  static const Color _darkDestructiveFg = RespiColors.destructiveForegroundDark;
  static const Color _darkBorder = RespiColors.borderDark;
  static const Color _darkInput = RespiColors.inputDark;
  static const Color _darkRing = RespiColors.ringDark;

  static ColorScheme get _lightScheme => const ColorScheme(
        brightness: Brightness.light,
        primary: _lightPrimary,
        onPrimary: _lightPrimaryFg,
        secondary: _lightSecondary,
        onSecondary: _lightSecondaryFg,
        tertiary: RespiColors.accent,
        onTertiary: RespiColors.accentForeground,
        error: _lightDestructive,
        onError: _lightDestructiveFg,
        surface: _lightBackground,
        onSurface: _lightForeground,
        surfaceContainer: _lightCard,
        surfaceContainerHighest: _lightMuted,
        onSurfaceVariant: _lightMutedFg,
        outline: _lightBorder,
        outlineVariant: _lightInput,
        shadow: AppTokens.shadowColor,
        scrim: Colors.black,
        inverseSurface: _lightForeground,
        onInverseSurface: _lightBackground,
        inversePrimary: _darkPrimary,
        surfaceTint: _lightRing,
      );

  static ColorScheme get _darkScheme => const ColorScheme(
        brightness: Brightness.dark,
        primary: _darkPrimary,
        onPrimary: _darkPrimaryFg,
        secondary: _darkSecondary,
        onSecondary: _darkSecondaryFg,
        tertiary: RespiColors.accentDark,
        onTertiary: RespiColors.accentForegroundDark,
        error: _darkDestructive,
        onError: _darkDestructiveFg,
        surface: _darkBackground,
        onSurface: _darkForeground,
        surfaceContainer: _darkCard,
        surfaceContainerHighest: _darkMuted,
        onSurfaceVariant: _darkMutedFg,
        outline: _darkBorder,
        outlineVariant: _darkInput,
        shadow: AppTokens.shadowColor,
        scrim: Colors.black,
        inverseSurface: _darkForeground,
        onInverseSurface: _darkBackground,
        inversePrimary: _lightPrimary,
        surfaceTint: _darkRing,
      );

  static TextTheme _textTheme(ColorScheme scheme) {
    // --font-sans: Outfit
    return GoogleFonts.outfitTextTheme().apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );
  }

  static ThemeData get light => _build(_lightScheme, ChartColors.light);
  static ThemeData get dark => _build(_darkScheme, ChartColors.dark);

  static ThemeData _build(ColorScheme scheme, ChartColors chartColors) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: _textTheme(scheme),
      extensions: [chartColors],

      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: scheme.onSurface,
        ),
      ),

      cardTheme: CardThemeData(
        color: scheme.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radius),
          side: BorderSide(color: scheme.outline, width: 1),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          disabledBackgroundColor: scheme.onSurface.withValues(alpha: 0.12),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusSm),
          ),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusSm),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.onSurface,
          side: BorderSide(color: scheme.outline),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusSm),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainer,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
          borderSide: BorderSide(color: scheme.error),
        ),
        labelStyle: TextStyle(color: scheme.onSurfaceVariant),
        hintStyle: TextStyle(color: scheme.onSurfaceVariant),
      ),

      dividerTheme: DividerThemeData(
        color: scheme.outline,
        thickness: 1,
        space: 1,
      ),

      iconTheme: IconThemeData(color: scheme.onSurface),

      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerHighest,
        labelStyle: TextStyle(color: scheme.onSurfaceVariant),
        side: BorderSide(color: scheme.outline),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TextStyle(color: scheme.onInverseSurface),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        ),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: scheme.surface,
        selectedItemColor: scheme.primary,
        unselectedItemColor: scheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        ),
      ),
    );
  }
}