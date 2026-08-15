import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'accessibility_config.dart';

/// Provides the current text scale factor, clamped to safe bounds.
///
/// Listens to system MediaQuery changes and ensures the app never
/// breaks completely at extreme text sizes, while still supporting
/// users who need large text.
final textScaleProvider = Provider<double>((ref) {
  final mediaQuery = ref.watch(mediaQueryProvider);
  final scale = mediaQuery.textScaler.scale(1.0);
  return scale.clamp(
    AccessibilityConfig.minTextScaleFactor,
    AccessibilityConfig.maxTextScaleFactor,
  );
}, dependencies: [mediaQueryProvider]);

/// Raw MediaQuery access for the current build context.
/// In practice, this is overridden at the root of your widget tree
/// with a MediaQuery-aware implementation.
final mediaQueryProvider = Provider<MediaQueryData>((ref) {
  throw UnimplementedError(
    'Override mediaQueryProvider at the root of your widget tree '
    'with a MediaQuery-aware implementation.',
  );
});

/// Widget that observes MediaQuery and exposes clamped text scale.
class TextScaleObserver extends StatelessWidget {
  const TextScaleObserver({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return ProviderScope(
      overrides: [
        mediaQueryProvider.overrideWithValue(mediaQuery),
        textScaleProvider.overrideWith((ref) {
          final scale = mediaQuery.textScaler.scale(1.0);
          return scale.clamp(
            AccessibilityConfig.minTextScaleFactor,
            AccessibilityConfig.maxTextScaleFactor,
          );
        }),
      ],
      child: child,
    );
  }
}

/// A wrapper that constrains text scaling for a subtree.
///
/// Use this around specific screens or components that are
/// particularly sensitive to text size changes.
class ConstrainedTextScale extends StatelessWidget {
  const ConstrainedTextScale({
    super.key,
    required this.child,
    this.minScale = AccessibilityConfig.minTextScaleFactor,
    this.maxScale = AccessibilityConfig.maxTextScaleFactor,
  });

  final Widget child;
  final double minScale;
  final double maxScale;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final currentScale = mediaQuery.textScaler.scale(1.0);
    final clampedScale = currentScale.clamp(minScale, maxScale);

    if (currentScale == clampedScale) return child;

    return MediaQuery(
      data: mediaQuery.copyWith(
        textScaler: TextScaler.linear(clampedScale),
      ),
      child: child,
    );
  }
}