import 'package:flutter/material.dart';

/// RespiraCare Soft Surface Shadow Tokens
abstract class AppShadows {
  static const List<BoxShadow> small = [
    BoxShadow(
      color: Color.fromRGBO(15, 23, 42, 0.04),
      blurRadius: 6.0,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> medium = [
    BoxShadow(
      color: Color.fromRGBO(15, 23, 42, 0.08),
      blurRadius: 16.0,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> large = [
    BoxShadow(
      color: Color.fromRGBO(15, 23, 42, 0.12),
      blurRadius: 24.0,
      offset: Offset(0, 8),
    ),
  ];
}
