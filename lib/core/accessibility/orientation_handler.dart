import 'package:flutter/material.dart';

/// Handles orientation changes gracefully.
///
/// Some screens (like video recording or chart viewing) benefit from
/// landscape layout. Others (forms, lists) should remain portrait-optimized.
class OrientationHandler extends StatelessWidget {
  const OrientationHandler({
    super.key,
    required this.portrait,
    this.landscape,
    this.allowLandscape = true,
  });

  final Widget portrait;
  final Widget? landscape;
  final bool allowLandscape;

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (orientation == Orientation.landscape && allowLandscape && landscape != null) {
          return landscape!;
        }
        return portrait;
      },
    );
  }
}
