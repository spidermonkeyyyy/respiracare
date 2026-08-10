import 'package:flutter/material.dart';

/// RespiraCare Shape & Border Radius Tokens
abstract class AppRadius {
  static const double small = 8.0;
  static const double button = 12.0;
  static const double medium = 16.0;
  static const double large = 24.0;
  static const double pill = 100.0;

  static const BorderRadius smallBorderRadius = BorderRadius.all(Radius.circular(small));
  static const BorderRadius buttonBorderRadius = BorderRadius.all(Radius.circular(button));
  static const BorderRadius mediumBorderRadius = BorderRadius.all(Radius.circular(medium));
  static const BorderRadius largeBorderRadius = BorderRadius.all(Radius.circular(large));
  static const BorderRadius pillBorderRadius = BorderRadius.all(Radius.circular(pill));
}
