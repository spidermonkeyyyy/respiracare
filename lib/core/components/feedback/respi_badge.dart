import 'package:flutter/material.dart';
import '../../theme/tokens/respi_shapes.dart';
import '../../theme/tokens/respi_spacing.dart';
import '../../theme/tokens/respi_typography.dart';

/// Semantic badge for status, counts, and triage.
enum RespiBadgeVariant { info, success, warning, error, neutral }

class RespiBadge extends StatelessWidget {
  const RespiBadge({
    super.key,
    required this.label,
    this.variant = RespiBadgeVariant.neutral,
    this.count,
    this.isDot = false,
  });

  final String label;
  final RespiBadgeVariant variant;
  final int? count;
  final bool isDot;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final (bg, fg) = switch (variant) {
      RespiBadgeVariant.info => (cs.primaryContainer, cs.onPrimaryContainer),
      RespiBadgeVariant.success => (const Color(0xFFD4F5E0), const Color(0xFF1A5230)),
      RespiBadgeVariant.warning => (const Color(0xFFFFF4E0), const Color(0xFF5C4510)),
      RespiBadgeVariant.error => (cs.errorContainer, cs.onErrorContainer),
      RespiBadgeVariant.neutral => (cs.surfaceContainerHighest, cs.onSurfaceVariant),
    };

    if (isDot) {
      return Container(
        width: 10, height: 10,
        decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
      );
    }

    return Semantics(
      container: true,
      label: '${variant.name} badge, $label',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: RespiSpacing.md, vertical: RespiSpacing.xs),
        decoration: BoxDecoration(color: bg, borderRadius: RespiShapes.fullRadius),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: RespiTypography.labelMedium.copyWith(color: fg)),
            if (count != null) ...[
              const SizedBox(width: RespiSpacing.xs),
              Text(count.toString(), style: RespiTypography.labelMedium.copyWith(color: fg, fontWeight: FontWeight.w700)),
            ],
          ],
        ),
      ),
    );
  }
}
