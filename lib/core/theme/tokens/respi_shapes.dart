import 'package:flutter/material.dart';

/// RespiraCare shape tokens.
class RespiShapes {
  RespiShapes._();

  static const Radius full = Radius.circular(999);
  static const Radius xxl = Radius.circular(24);
  static const Radius xl = Radius.circular(16);
  static const Radius md = Radius.circular(12);
  static const Radius sm = Radius.circular(8);
  static const Radius none = Radius.zero;

  // Double raw values for flexibility
  static const double smValue = 8.0;
  static const double mdValue = 12.0;
  static const double xlValue = 16.0;
  static const double xxlValue = 24.0;
  static const double fullValue = 999.0;

  // Radius helpers
  static const BorderRadius smRadius = BorderRadius.all(sm);
  static const BorderRadius mdRadius = BorderRadius.all(md);
  static const BorderRadius xlRadius = BorderRadius.all(xl);
  static const BorderRadius xxlRadius = BorderRadius.all(xxl);
  static const BorderRadius fullRadius = BorderRadius.all(full);

  static const RoundedRectangleBorder buttonShape =
      RoundedRectangleBorder(borderRadius: BorderRadius.all(full));
  static const RoundedRectangleBorder cardShape =
      RoundedRectangleBorder(borderRadius: BorderRadius.all(xl));
  static const RoundedRectangleBorder inputShape =
      RoundedRectangleBorder(borderRadius: BorderRadius.all(md));
  static const RoundedRectangleBorder dialogShape =
      RoundedRectangleBorder(borderRadius: BorderRadius.all(xxl));
  static const RoundedRectangleBorder bottomSheetShape =
      RoundedRectangleBorder(
    borderRadius: BorderRadius.only(topLeft: xxl, topRight: xxl),
  );
}
