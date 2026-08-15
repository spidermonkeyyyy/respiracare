import 'package:flutter/widgets.dart';

/// RespiraCare responsive breakpoints.
///
/// Mobile first: base styles are mobile, override at larger breakpoints.
class RespiBreakpoints {
  RespiBreakpoints._();

  static const double sm = 360; // Small phones
  static const double md = 600; // Large phones / small tablets
  static const double lg = 840; // Tablets
  static const double xl = 1200; // Large tablets / desktop
}

/// Extension for responsive checks against layout constraints.
extension RespiBreakpointExtension on BoxConstraints {
  bool get isMobile => maxWidth < RespiBreakpoints.md;
  bool get isTablet =>
      maxWidth >= RespiBreakpoints.md && maxWidth < RespiBreakpoints.lg;
  bool get isDesktop => maxWidth >= RespiBreakpoints.lg;
}
