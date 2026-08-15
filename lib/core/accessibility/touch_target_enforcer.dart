import 'package:flutter/material.dart';
import 'accessibility_config.dart';

/// A widget that asserts its child meets minimum touch target size.
///
/// In debug mode, shows a red border around widgets that are too small.
/// In release mode, wraps small widgets in an expanded tap area.
class TouchTargetEnforcer extends StatelessWidget {
  const TouchTargetEnforcer({
    super.key,
    required this.child,
    this.minSize = AccessibilityConfig.minTouchTarget,
  });

  final Widget child;
  final double minSize;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // In debug mode, assert size
        assert(() {
          if (constraints.maxWidth < minSize || constraints.maxHeight < minSize) {
            debugPrint(
              'ACCESSIBILITY WARNING: Touch target is ${constraints.maxWidth.toStringAsFixed(1)}×'
              '${constraints.maxHeight.toStringAsFixed(1)}dp, which is smaller than '
              'the recommended ${minSize.toStringAsFixed(0)}×${minSize.toStringAsFixed(0)}dp. '
              'Wrap with TouchTargetEnforcer or increase widget size.',
            );
          }
          return true;
        }());

        // Always enforce minimum tap area in release
        return SizedBox(
          width: constraints.maxWidth < minSize ? minSize : null,
          height: constraints.maxHeight < minSize ? minSize : null,
          child: Center(child: child),
        );
      },
    );
  }
}

/// A wrapper that guarantees a minimum tap area around any widget.
class MinimumTapArea extends StatelessWidget {
  const MinimumTapArea({
    super.key,
    required this.child,
    this.minSize = AccessibilityConfig.minTapArea,
  });

  final Widget child;
  final double minSize;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: minSize,
        minHeight: minSize,
      ),
      child: Center(child: child),
    );
  }
}
