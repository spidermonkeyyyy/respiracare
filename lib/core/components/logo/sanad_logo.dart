import 'package:flutter/material.dart';

/// A theme-aware logo widget for the Sanad app.
///
/// - **Light mode** → blue logo (`sanad_logo_light.png`)
/// - **Dark mode**  → dark/black logo (`sanad_logo_dark.png`)
///
/// Usage:
/// ```dart
/// SanadLogo(size: 80)
/// SanadLogo.small()    // 48 × 48
/// SanadLogo.medium()   // 80 × 80  (default)
/// SanadLogo.large()    // 120 × 120
/// SanadLogo.hero()     // 160 × 160
/// ```
class SanadLogo extends StatelessWidget {
  const SanadLogo({
    super.key,
    this.size = 80,
    this.borderRadius,
    this.semanticLabel = 'Sanad logo',
  });

  /// Convenience constructors
  const SanadLogo.small({Key? key})
      : this(key: key, size: 48);
  const SanadLogo.medium({Key? key})
      : this(key: key, size: 80);
  const SanadLogo.large({Key? key})
      : this(key: key, size: 120);
  const SanadLogo.hero({Key? key})
      : this(key: key, size: 160);

  final double size;
  final BorderRadius? borderRadius;
  final String semanticLabel;

  /// Asset path for the current brightness.
  static String assetFor(Brightness brightness) {
    return brightness == Brightness.dark
        ? 'assets/images/logo/sanad_logo_dark.png'
        : 'assets/images/logo/sanad_logo_light.png';
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final asset = assetFor(brightness);
    final radius = borderRadius ?? BorderRadius.circular(size * 0.2237);

    return Semantics(
      label: semanticLabel,
      image: true,
      child: ClipRRect(
        borderRadius: radius,
        child: Image.asset(
          asset,
          width: size,
          height: size,
          fit: BoxFit.cover,
          // Smooth crossfade on first paint
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded || frame != null) return child;
            return AnimatedOpacity(
              opacity: frame == null ? 0 : 1,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              child: child,
            );
          },
        ),
      ),
    );
  }
}

/// A row that combines the [SanadLogo] with the "Sanad" wordmark.
///
/// Adapts text colour to the current theme automatically.
class SanadBrand extends StatelessWidget {
  const SanadBrand({
    super.key,
    this.logoSize = 40,
    this.gap = 10,
    this.textStyle,
  });

  final double logoSize;
  final double gap;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultStyle = theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: theme.colorScheme.onSurface,
        ) ??
        const TextStyle(fontWeight: FontWeight.w700);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SanadLogo(size: logoSize),
        SizedBox(width: gap),
        Text(
          'Sanad',
          style: textStyle ?? defaultStyle,
        ),
      ],
    );
  }
}
