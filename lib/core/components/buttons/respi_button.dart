import 'package:flutter/material.dart';
import '../../theme/tokens/respi_shapes.dart';
import '../../theme/tokens/respi_spacing.dart';
import '../../theme/tokens/respi_typography.dart';

/// Button visual variants.
enum RespiButtonVariant { primary, secondary, outlined, danger, text }

/// Button size tiers. All tiers keep a minimum 48dp touch target.
enum RespiButtonSize { small, medium, large }

/// RespiraCare primary action button.
///
/// Provides 5 variants, an optional icon, a loading state, and guarantees a
/// minimum 48dp touch target for accessibility (WCAG 2.5.5).
class RespiButton extends StatelessWidget {
  const RespiButton({
    super.key,
    required this.label,
    this.icon,
    this.variant = RespiButtonVariant.primary,
    this.size = RespiButtonSize.medium,
    this.onPressed,
    this.isLoading = false,
    this.fullWidth = false,
    this.semanticsLabel,
  });

  final String label;
  final IconData? icon;
  final RespiButtonVariant variant;
  final RespiButtonSize size;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool fullWidth;
  final String? semanticsLabel;

  double get _minHeight {
    switch (size) {
      case RespiButtonSize.small:
        return 48.0;
      case RespiButtonSize.medium:
        return 56.0;
      case RespiButtonSize.large:
        return 64.0;
    }
  }

  Widget _buildContent(Color fg) {
    if (isLoading) {
      return SizedBox(
        width: 20, height: 20,
        child: CircularProgressIndicator(strokeWidth: 2.5, color: fg),
      );
    }
    final labelWidget = Text(label, style: RespiTypography.labelLarge.copyWith(color: fg));
    if (icon == null) return labelWidget;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: fg),
        const SizedBox(width: RespiSpacing.sm),
        labelWidget,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final enabled = onPressed != null && !isLoading;

    final content = switch (variant) {
      RespiButtonVariant.primary => _PrimaryButton(
        size: size, minHeight: _minHeight, fullWidth: fullWidth,
        color: cs.primary, fg: cs.onPrimary, content: _buildContent(cs.onPrimary),
        enabled: enabled, onPressed: onPressed,
      ),
      RespiButtonVariant.secondary => _PrimaryButton(
        size: size, minHeight: _minHeight, fullWidth: fullWidth,
        color: cs.secondary, fg: cs.onSecondary, content: _buildContent(cs.onSecondary),
        enabled: enabled, onPressed: onPressed,
      ),
      RespiButtonVariant.danger => _PrimaryButton(
        size: size, minHeight: _minHeight, fullWidth: fullWidth,
        color: cs.error, fg: cs.onError, content: _buildContent(cs.onError),
        enabled: enabled, onPressed: onPressed,
      ),
      RespiButtonVariant.outlined => _OutlinedButton(
        size: size, minHeight: _minHeight, fullWidth: fullWidth,
        borderColor: cs.primary, fg: cs.primary, content: _buildContent(cs.primary),
        enabled: enabled, onPressed: onPressed,
      ),
      RespiButtonVariant.text => _TextButton(
        size: size, minHeight: _minHeight, fullWidth: fullWidth,
        fg: cs.primary, content: _buildContent(cs.primary),
        enabled: enabled, onPressed: onPressed,
      ),
    };

    return Semantics(
      button: true,
      enabled: enabled,
      label: semanticsLabel ?? label,
      excludeSemantics: true,
      child: content,
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.size, required this.minHeight, required this.fullWidth,
    required this.color, required this.fg, required this.content,
    required this.enabled, required this.onPressed,
  });
  final RespiButtonSize size;
  final double minHeight;
  final bool fullWidth;
  final Color color;
  final Color fg;
  final Widget content;
  final bool enabled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: minHeight,
      width: fullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: fg,
          minimumSize: Size(minHeight, minHeight),
          shape: const RoundedRectangleBorder(borderRadius: RespiShapes.mdRadius),
          padding: const EdgeInsets.symmetric(horizontal: RespiSpacing.lg),
        ),
        child: content,
      ),
    );
  }
}

class _OutlinedButton extends StatelessWidget {
  const _OutlinedButton({
    required this.size, required this.minHeight, required this.fullWidth,
    required this.borderColor, required this.fg, required this.content,
    required this.enabled, required this.onPressed,
  });
  final RespiButtonSize size;
  final double minHeight;
  final bool fullWidth;
  final Color borderColor;
  final Color fg;
  final Widget content;
  final bool enabled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: minHeight,
      width: fullWidth ? double.infinity : null,
      child: OutlinedButton(
        onPressed: enabled ? onPressed : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: fg,
          side: BorderSide(color: borderColor, width: 1.5),
          minimumSize: Size(minHeight, minHeight),
          shape: const RoundedRectangleBorder(borderRadius: RespiShapes.mdRadius),
          padding: const EdgeInsets.symmetric(horizontal: RespiSpacing.lg),
        ),
        child: content,
      ),
    );
  }
}

class _TextButton extends StatelessWidget {
  const _TextButton({
    required this.size, required this.minHeight, required this.fullWidth,
    required this.fg, required this.content,
    required this.enabled, required this.onPressed,
  });
  final RespiButtonSize size;
  final double minHeight;
  final bool fullWidth;
  final Color fg;
  final Widget content;
  final bool enabled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: minHeight,
      width: fullWidth ? double.infinity : null,
      child: TextButton(
        onPressed: enabled ? onPressed : null,
        style: TextButton.styleFrom(
          foregroundColor: fg,
          minimumSize: Size(minHeight, minHeight),
          shape: const RoundedRectangleBorder(borderRadius: RespiShapes.mdRadius),
          padding: const EdgeInsets.symmetric(horizontal: RespiSpacing.lg),
        ),
        child: content,
      ),
    );
  }
}
