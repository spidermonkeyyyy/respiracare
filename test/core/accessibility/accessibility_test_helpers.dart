import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

/// Helpers for writing accessibility-focused widget tests.
class AccessibilityTestHelpers {
  AccessibilityTestHelpers._();

  /// Verifies that a widget has a semantic label.
  static void expectSemanticLabel(WidgetTester tester, Finder finder, String label) {
    final semantics = tester.getSemantics(finder);
    expect(semantics.label, contains(label));
  }

  /// Verifies that a widget is a semantic button.
  static void expectSemanticButton(WidgetTester tester, Finder finder) {
    final semantics = tester.getSemantics(finder);
    // ignore: deprecated_member_use
    expect(semantics.hasFlag(SemanticsFlag.isButton), isTrue);
  }

  /// Verifies that a widget has a semantic header flag.
  static void expectSemanticHeader(WidgetTester tester, Finder finder) {
    final semantics = tester.getSemantics(finder);
    // ignore: deprecated_member_use
    expect(semantics.hasFlag(SemanticsFlag.isHeader), isTrue);
  }

  /// Verifies touch target size meets minimum.
  static void expectMinimumSize(WidgetTester tester, Finder finder, double minSize) {
    final size = tester.getSize(finder);
    expect(size.width, greaterThanOrEqualTo(minSize));
    expect(size.height, greaterThanOrEqualTo(minSize));
  }

  /// Verifies contrast ratio between two colors.
  static void expectContrastRatio(Color foreground, Color background, double minRatio) {
    final ratio = _contrastRatio(foreground, background);
    expect(ratio, greaterThanOrEqualTo(minRatio));
  }

  /// Calculates relative luminance of a color.
  static double _relativeLuminance(Color color) {
    double gamma(double c) {
      c = c / 255.0;
      return c <= 0.03928 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
    }

    final r = color.r * 255.0;
    final g = color.g * 255.0;
    final b = color.b * 255.0;

    return 0.2126 * gamma(r) +
           0.7152 * gamma(g) +
           0.0722 * gamma(b);
  }

  /// Calculates contrast ratio between two colors.
  static double _contrastRatio(Color c1, Color c2) {
    final l1 = _relativeLuminance(c1);
    final l2 = _relativeLuminance(c2);
    final lighter = l1 > l2 ? l1 : l2;
    final darker = l1 > l2 ? l2 : l1;
    return (lighter + 0.05) / (darker + 0.05);
  }
}
