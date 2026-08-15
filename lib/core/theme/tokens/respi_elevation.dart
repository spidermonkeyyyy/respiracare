import 'package:flutter/material.dart';

/// RespiraCare elevation tokens.
///
/// Subtle, soft shadows keep clinical UI calm. Pair with [RespiShapes] radii.
class RespiElevation {
  RespiElevation._();

  /// Minimal lift - chips, badges, pressed cards.
  static const List<BoxShadow> xs = <BoxShadow>[
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 1.0,
      offset: Offset(0, 1),
    ),
  ];

  /// Subtle card elevation.
  static const List<BoxShadow> sm = <BoxShadow>[
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 4.0,
      offset: Offset(0, 1),
    ),
  ];

  /// Standard card / sheet elevation.
  static const List<BoxShadow> md = <BoxShadow>[
    BoxShadow(
      color: Color(0x1F000000),
      blurRadius: 8.0,
      offset: Offset(0, 2),
    ),
  ];

  /// Raised surface - dialogs, FAB, menus.
  static const List<BoxShadow> lg = <BoxShadow>[
    BoxShadow(
      color: Color(0x29000000),
      blurRadius: 16.0,
      offset: Offset(0, 4),
    ),
  ];

  /// Prominent elevation - modals, drawers.
  static const List<BoxShadow> xl = <BoxShadow>[
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 24.0,
      offset: Offset(0, 8),
    ),
  ];
}
