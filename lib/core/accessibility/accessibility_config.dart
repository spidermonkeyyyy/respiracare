import 'package:flutter/rendering.dart';

/// Central accessibility configuration for RespiraCare.
///
/// All accessibility constants and thresholds are defined here
/// to ensure consistency across the application.
class AccessibilityConfig {
  AccessibilityConfig._();

  // ─── Touch Targets ─────────────────────────────────────────
  /// WCAG 2.5.5 Target Size (Level AAA) — 44×44dp minimum.
  /// We enforce 48×48dp for extra safety with elderly users.
  static const double minTouchTarget = 48.0;

  /// Minimum tap area expansion for small widgets (icons, close buttons).
  static const double minTapArea = 48.0;

  // ─── Text Scaling ──────────────────────────────────────────
  /// Maximum text scale factor the app supports.
  /// Clamped at 2.0 to prevent layout breakage while ensuring high legibility.
  static const double maxTextScaleFactor = 2.0;

  /// Minimum text scale factor (never shrink below this).
  static const double minTextScaleFactor = 0.8;

  // ─── Contrast ──────────────────────────────────────────────
  /// WCAG 2.1 AA minimum contrast for normal text.
  static const double minContrastNormal = 4.5;

  /// WCAG 2.1 AA minimum contrast for large text (18pt+ or 14pt+ bold).
  static const double minContrastLarge = 3.0;

  /// WCAG 2.1 AA minimum contrast for UI components and graphical objects.
  static const double minContrastUI = 3.0;

  // ─── Motion ────────────────────────────────────────────────
  /// Maximum animation duration when reduced motion is enabled.
  static const Duration reducedMotionMaxDuration = Duration(milliseconds: 50);

  /// Whether to disable parallax and continuous animations entirely
  /// when reduced motion is preferred.
  static const bool disableAnimationsUnderReducedMotion = true;

  // ─── Focus ─────────────────────────────────────────────────
  /// Focus highlight border width.
  static const double focusBorderWidth = 3.0;

  /// Focus highlight border radius.
  static const double focusBorderRadius = 4.0;

  // ─── Screen Reader ─────────────────────────────────────────
  /// Delay before announcing dynamic content changes.
  static const Duration liveRegionDelay = Duration(milliseconds: 100);

  /// Priority for urgent announcements (alerts, errors).
  static const AnnounceSemanticsEvent urgentAnnouncement =
      AnnounceSemanticsEvent('urgent', TextDirection.ltr, 0);
}