import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether the user has enabled high contrast mode.
final highContrastProvider = Provider<bool>((ref) {
  return false; // Overridden at app root
});

/// Observes system high contrast setting.
class HighContrastObserver extends StatelessWidget {
  const HighContrastObserver({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final highContrast = MediaQuery.of(context).highContrast;

    return ProviderScope(
      overrides: [
        highContrastProvider.overrideWithValue(highContrast),
      ],
      child: child,
    );
  }
}

/// A widget that increases contrast of its child when high contrast is enabled.
class HighContrastWrapper extends ConsumerWidget {
  const HighContrastWrapper({
    super.key,
    required this.child,
    this.borderWidth = 2.0,
  });

  final Widget child;
  final double borderWidth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isHighContrast = ref.watch(highContrastProvider);

    if (!isHighContrast) return child;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface,
          width: borderWidth,
        ),
      ),
      child: child,
    );
  }
}
