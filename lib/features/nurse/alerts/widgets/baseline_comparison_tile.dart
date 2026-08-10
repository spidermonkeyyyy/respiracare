import 'package:flutter/material.dart';

import '../../../../app/theme/colors.dart';
import '../../../../app/theme/radius.dart';
import '../../../../app/theme/spacing.dart';
import '../../../../app/theme/typography.dart';
import '../models/supporting_measurement.dart';
import 'alert_visuals.dart';

/// Displays one measurement, optionally against the patient's own reference.
///
/// Renders facts only — current value, reference value, variation. It never
/// labels a variation as dangerous or reassuring; interpretation is the
/// nurse's, informed by the rules layer.
class BaselineComparisonTile extends StatelessWidget {
  final SupportingMeasurement measurement;

  /// Compact form drops the reference row, keeping list cards scannable.
  final bool compact;

  const BaselineComparisonTile({
    super.key,
    required this.measurement,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: _semanticLabel,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    measurement.label,
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  AlertVisuals.trendIcon(measurement.trend),
                  size: 16.0,
                  color: AlertVisuals.trendColor(measurement.trend),
                  semanticLabel: measurement.trend.label,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              measurement.value,
              style: AppTypography.titleLarge.copyWith(fontSize: 18.0),
            ),
            if (!compact && measurement.hasComparison) ...[
              const SizedBox(height: AppSpacing.sm),
              _ReferenceRow(
                label: 'Valeur de référence',
                value: measurement.referenceValue!,
              ),
              if (measurement.variation != null && measurement.variation!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                _ReferenceRow(label: 'Variation', value: measurement.variation!),
              ],
            ],
            if (!compact && measurement.note != null && measurement.note!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                measurement.note!,
                style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String get _semanticLabel {
    final buffer = StringBuffer('${measurement.label}: ${measurement.value}');
    if (measurement.hasComparison) {
      buffer.write('. Valeur de référence: ${measurement.referenceValue}');
      if (measurement.variation != null && measurement.variation!.isNotEmpty) {
        buffer.write('. Variation: ${measurement.variation}');
      }
    }
    buffer.write('. Tendance: ${measurement.trend.label}');
    return buffer.toString();
  }
}

class _ReferenceRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReferenceRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary),
        ),
        const Spacer(),
        Text(
          value,
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
