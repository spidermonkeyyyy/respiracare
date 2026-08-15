import 'package:flutter/material.dart';

/// An overlay that paints semantic bounds and labels for debugging.
///
/// Wrap your app with this in debug mode to visualize accessibility:
/// ```dart
/// SemanticsDebugOverlay(
///   enabled: kDebugMode,
///   child: MyApp(),
/// )
/// ```
class SemanticsDebugOverlay extends StatelessWidget {
  const SemanticsDebugOverlay({
    super.key,
    required this.child,
    this.enabled = false,
  });

  final Widget child;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    return Stack(
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _SemanticsDebugPainter(),
              size: Size.infinite,
            ),
          ),
        ),
      ],
    );
  }
}

class _SemanticsDebugPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // This would traverse the semantics tree and paint bounds.
    // Basic implementation placeholder for debug mode visual confirmation.
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
