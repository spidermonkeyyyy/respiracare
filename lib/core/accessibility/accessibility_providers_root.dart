import 'package:flutter/material.dart';
import 'reduced_motion_provider.dart';
import 'high_contrast_provider.dart';
import 'text_scale_provider.dart';

/// Wraps the application with all accessibility system observers.
///
/// Place this ABOVE MaterialApp in the widget tree.
class AccessibilityProvidersRoot extends StatelessWidget {
  const AccessibilityProvidersRoot({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ReducedMotionObserver(
      child: HighContrastObserver(
        child: TextScaleObserver(
          child: child,
        ),
      ),
    );
  }
}
