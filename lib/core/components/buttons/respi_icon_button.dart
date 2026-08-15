import 'package:flutter/material.dart';
import '../../accessibility/accessibility_config.dart';

/// An icon button with guaranteed minimum touch target and semantic label.
class RespiIconButton extends StatelessWidget {
  const RespiIconButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    this.onPressed,
    this.color,
    this.size = 24.0,
  }) : assert(semanticLabel.length > 0, 'semanticLabel must not be empty');

  final IconData icon;
  final String semanticLabel;
  final VoidCallback? onPressed;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: semanticLabel,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: AccessibilityConfig.minTapArea,
          height: AccessibilityConfig.minTapArea,
          child: Center(
            child: Icon(
              icon,
              size: size,
              color: color ?? Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
