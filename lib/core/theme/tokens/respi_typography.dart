import 'package:flutter/material.dart';

/// RespiraCare semantic typography tokens.
///
/// Type scale tuned for elderly COPD patients: large base sizes, generous
/// line heights, and a clear hierarchy. All styles inherit the app font
/// family. Colors are intentionally omitted so each style can be tinted by
/// the surrounding [ColorScheme] (WCAG 2.1 AA readability).
class RespiTypography {
  RespiTypography._();

  /// Primary typeface for the application.
  static const String fontFamily = 'Inter';

  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32.0,
    height: 40.0 / 32.0,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28.0,
    height: 36.0 / 28.0,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.25,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24.0,
    height: 32.0 / 24.0,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22.0,
    height: 28.0 / 22.0,
    fontWeight: FontWeight.w600,
  );

  /// 22px semibold - section sub-headings within cards/sheets.
  static const TextStyle headlineSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22.0,
    height: 28.0 / 22.0,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20.0,
    height: 28.0 / 20.0,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.0,
    height: 24.0 / 16.0,
    fontWeight: FontWeight.w600,
  );

  /// 18px regular body - the default reading size for clinical content.
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18.0,
    height: 26.0 / 18.0,
    fontWeight: FontWeight.w400,
  );

  /// 16px regular body - used for dense lists and secondary copy.
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.0,
    height: 24.0 / 16.0,
    fontWeight: FontWeight.w400,
  );

  /// 14px regular - captions and helper text.
  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.0,
    height: 20.0 / 14.0,
    fontWeight: FontWeight.w400,
  );

  /// 14px medium - labels paired with inputs.
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.0,
    height: 20.0 / 14.0,
    fontWeight: FontWeight.w500,
  );

  /// 12px medium - chip/button labels, metadata.
  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.0,
    height: 16.0 / 12.0,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11.0,
    height: 16.0 / 11.0,
    fontWeight: FontWeight.w500,
  );

  /// Large hero/metric value (e.g. SpO2 reading). Always pair with units.
  static const TextStyle vitalLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 40.0,
    height: 48.0 / 40.0,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );

  /// Unit suffix for hero/metric values (e.g. '%').
  static const TextStyle vitalUnit = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.0,
    height: 24.0 / 16.0,
    fontWeight: FontWeight.w500,
  );
}
