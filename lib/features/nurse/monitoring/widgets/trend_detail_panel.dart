import 'package:flutter/material.dart';

import '../../../../app/theme/colors.dart';
import '../../../../app/theme/radius.dart';
import '../../../../app/theme/spacing.dart';
import '../../../../app/theme/typography.dart';
import '../models/respiratory_trend.dart';

/// Multi-metric snapshot panel shown when a chart data point is tapped.
///
/// Presents every metric captured for the selected date so the nurse sees a
/// complete clinical picture at a glance (per SCR-NUR-06 tooltip guidance).
class TrendDetailPanel extends StatelessWidget {
  final RespiratoryTrendPoint point;

  const TrendDetailPanel({super.key, required this.point});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Détail — ${point.date.day}/${point.date.month}/${point.date.year}',
            style: AppTypography.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          _DetailRow(
              icon: Icons.monitor_heart_outlined,
              label: 'SpO₂',
              value: point.spo2 != null ? '${point.spo2}%' : '—'),
          _DetailRow(
              icon: Icons.assessment_outlined,
              label: 'Score CAT',
              value: point.catScore != null ? '${point.catScore} / 40' : '—'),
          _DetailRow(
              icon: Icons.airline_seat_flat,
              label: 'mMRC',
              value: point.mmrcGrade != null ? '${point.mmrcGrade} / 4' : '—'),
          _DetailRow(
              icon: Icons.water_drop_outlined,
              label: 'Sécrétions',
              value: point.sputum?.label ?? '—'),
          if (point.hasAlert)
            const Padding(
              padding: EdgeInsets.only(top: AppSpacing.sm),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      size: 16, color: AppColors.danger),
                  SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      'Alerte signalée ce jour.',
                      style: AppTypography.labelMedium,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(label, style: AppTypography.bodySmall)),
          Text(value,
              style: AppTypography.bodySmall
                  .copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
