import 'package:flutter/material.dart';

/// RespiraCare motion tokens.
///
/// Motion is calm and purposeful.
class RespiMotion {
  RespiMotion._();

  /// Quick micro-interactions (tap feedback, small fades).
  static const Duration fast = Duration(milliseconds: 150);

  /// Standard transitions (page sections, card entrance).
  static const Duration normal = Duration(milliseconds: 300);

  /// Deliberate, noticeable transitions (sheets, dialogs).
  static const Duration slow = Duration(milliseconds: 450);

  /// Standard easing for entrance/exit animations.
  static const Curve standard = Curves.easeInOut;

  /// Emphasized easing for prominent transitions.
  static const Curve emphasized = Curves.easeOutCubic;

  /// Decelerate easing for content appearing in.
  static const Curve decelerate = Curves.decelerate;
}
