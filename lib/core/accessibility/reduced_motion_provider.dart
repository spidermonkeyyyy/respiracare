import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'accessibility_config.dart';

/// Whether the user prefers reduced motion.
///
/// When true:
/// - All animations should use [AccessibilityConfig.reducedMotionMaxDuration]
/// - Parallax and continuous animations should be disabled
/// - Page transitions should be instant or fade-only
final reducedMotionProvider = Provider<bool>((ref) {
  // This is overridden at the app root with a MediaQuery observer
  return false;
});

/// Provides animation duration based on reduced motion preference.
final animationDurationProvider = Provider.family<Duration, Duration>((ref, normalDuration) {
  final reduced = ref.watch(reducedMotionProvider);
  if (reduced && AccessibilityConfig.disableAnimationsUnderReducedMotion) {
    return AccessibilityConfig.reducedMotionMaxDuration;
  }
  return normalDuration;
});

/// Widget that observes system reduced motion setting.
class ReducedMotionObserver extends StatelessWidget {
  const ReducedMotionObserver({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.of(context).disableAnimations;

    return ProviderScope(
      overrides: [
        reducedMotionProvider.overrideWithValue(disableAnimations),
        animationDurationProvider.overrideWith((ref, normalDuration) {
          final reduced = ref.watch(reducedMotionProvider);
          if (reduced && AccessibilityConfig.disableAnimationsUnderReducedMotion) {
            return AccessibilityConfig.reducedMotionMaxDuration;
          }
          return normalDuration;
        }),
      ],
      child: child,
    );
  }
}

/// An AnimatedContainer that respects reduced motion.
class AccessibleAnimatedContainer extends ConsumerWidget {
  const AccessibleAnimatedContainer({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.alignment,
    this.padding,
    this.color,
    this.decoration,
    this.foregroundDecoration,
    this.width,
    this.height,
    this.constraints,
    this.margin,
    this.transform,
    this.transformAlignment,
    this.clipBehavior = Clip.none,
  });

  final Widget child;
  final Duration duration;
  final Curve curve;
  final AlignmentGeometry? alignment;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Decoration? decoration;
  final Decoration? foregroundDecoration;
  final double? width;
  final double? height;
  final BoxConstraints? constraints;
  final EdgeInsetsGeometry? margin;
  final Matrix4? transform;
  final AlignmentGeometry? transformAlignment;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effectiveDuration = ref.watch(animationDurationProvider(duration));

    return AnimatedContainer(
      duration: effectiveDuration,
      curve: curve,
      alignment: alignment,
      padding: padding,
      color: color,
      decoration: decoration,
      foregroundDecoration: foregroundDecoration,
      width: width,
      height: height,
      constraints: constraints,
      margin: margin,
      transform: transform,
      transformAlignment: transformAlignment,
      clipBehavior: clipBehavior,
      child: child,
    );
  }
}

/// An AnimatedOpacity that respects reduced motion.
class AccessibleAnimatedOpacity extends ConsumerWidget {
  const AccessibleAnimatedOpacity({
    super.key,
    required this.child,
    required this.opacity,
    this.duration = const Duration(milliseconds: 200),
    this.curve = Curves.easeInOut,
    this.onEnd,
    this.alwaysIncludeSemantics = false,
  });

  final Widget child;
  final double opacity;
  final Duration duration;
  final Curve curve;
  final VoidCallback? onEnd;
  final bool alwaysIncludeSemantics;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effectiveDuration = ref.watch(animationDurationProvider(duration));

    return AnimatedOpacity(
      opacity: opacity,
      duration: effectiveDuration,
      curve: curve,
      onEnd: onEnd,
      alwaysIncludeSemantics: alwaysIncludeSemantics,
      child: child,
    );
  }
}
