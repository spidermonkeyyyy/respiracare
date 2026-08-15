import 'package:flutter/material.dart';

/// Color manipulation helpers.
extension ColorX on Color {
  /// Returns this color with modified opacity.
  Color withOpacityValue(double value) =>
      withValues(alpha: value.clamp(0.0, 1.0));

  /// Lightens the color by a percentage (0.0 - 1.0).
  Color lighten(double amount) {
    final hsl = HSLColor.fromColor(this);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }

  /// Darkens the color by a percentage (0.0 - 1.0).
  Color darken(double amount) {
    final hsl = HSLColor.fromColor(this);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }
}
