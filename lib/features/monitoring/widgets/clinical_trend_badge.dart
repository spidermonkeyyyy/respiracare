import 'package:flutter/material.dart';

import '../../../core/theme/tokens/respi_colors.dart';
import '../../../core/theme/tokens/respi_shapes.dart';
import '../../../core/theme/tokens/respi_spacing.dart';
import '../../../core/theme/tokens/respi_typography.dart';
import '../models/measurement_type.dart';
import '../utils/clinical_trend_calculator.dart';

/// Compact, non-diagnostic indicator summarizing a measured trend.
///
/// Presents the direction numerically computed by [ClinicalTrendCalculator]
/// (up / down / stable) as an icon + short label.  It never claims clinical
/// meaning — the tooltip/description always references "readings shown".
class ClinicalTrendBadge extends StatelessWidget {
  const ClinicalTrendBadge({
    super.key,
    required this.type,
    required this.summary,
  });

  final MeasurementType type;
  final TrendSummary summary;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final info = MeasurementTypeInfo.of(type);
    final isDark = cs.brightness == Brightness.dark;

    final (icon, labelText, color) = switch (summary.direction) {
      TrendDirection.upward => (
          Icons.trending_up_rounded,
          'En hausse',
          cs.primary,
        ),
      TrendDirection.downward => (
          Icons.trending_down_rounded,
          'En baisse',
          isDark ? RespiColors.warningDark : RespiColors.warning,
        ),
      TrendDirection.stable => (
          Icons.trending_flat_rounded,
          'Stable',
          cs.onSurfaceVariant,
        ),
      TrendDirection.insufficientData => (
          Icons.hourglass_empty_rounded,
          'Données insuffisantes',
          cs.onSurfaceVariant,
        ),
    };

    final tooltip = summary.readingCount == 0
        ? 'Aucune mesure sur la période sélectionnée.'
        : summary.description;

    return Semantics(
      label: '${info.accessibilityLabel} : $labelText',
      hint: 'Signalé comme une description, pas un diagnostic.',
      child: Tooltip(
        message: tooltip,
        waitDuration: const Duration(milliseconds: 400),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: RespiSpacing.sm,
            vertical: RespiSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: RespiShapes.fullRadius,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: RespiSpacing.xs),
              Text(
                labelText,
                style: RespiTypography.labelMedium.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
