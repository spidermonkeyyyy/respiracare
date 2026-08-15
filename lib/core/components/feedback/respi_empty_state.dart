import 'package:flutter/material.dart';
import '../../theme/tokens/respi_spacing.dart';
import '../../theme/tokens/respi_typography.dart';
import '../buttons/respi_button.dart';

/// Friendly empty state with clear next action.
class RespiEmptyState extends StatelessWidget {
  const RespiEmptyState({
    super.key,
    required this.title,
    this.message,
    this.icon,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? message;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(RespiSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon,
                  size: 64, color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
              const SizedBox(height: RespiSpacing.lg),
            ],
            Text(title,
                style:
                    RespiTypography.headlineSmall.copyWith(color: cs.onSurface),
                textAlign: TextAlign.center),
            if (message != null) ...[
              const SizedBox(height: RespiSpacing.sm),
              Text(message!,
                  style: RespiTypography.bodyLarge
                      .copyWith(color: cs.onSurfaceVariant),
                  textAlign: TextAlign.center),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: RespiSpacing.xl),
              RespiButton(
                  label: actionLabel!,
                  onPressed: onAction,
                  variant: RespiButtonVariant.outlined),
            ],
          ],
        ),
      ),
    );
  }
}
