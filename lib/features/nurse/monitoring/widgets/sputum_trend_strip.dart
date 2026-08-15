import 'package:flutter/material.dart';

import '../../../../app/theme/colors.dart';
import '../../../../app/theme/spacing.dart';
import '../../../../app/theme/typography.dart';
import '../models/respiratory_trend.dart';

/// Horizontal strip of sputum-severity markers, one per plotted day.
///
/// Colour is uniform (single hue by severity) so it is readable by
/// colorblind users; the tooltip/detail panel carries the exact value.
class SputumTrendStrip extends StatelessWidget {
  final List<RespiratoryTrendPoint> points;

  const SputumTrendStrip({super.key, this.points = const []});

  static Color colorFor(SputumSeverity severity) {
    switch (severity) {
      case SputumSeverity.none:
        return AppColors.success;
      case SputumSeverity.low:
        return AppColors.info;
      case SputumSeverity.moderate:
        return AppColors.warning;
      case SputumSeverity.high:
        return AppColors.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    final series = points.where((p) => p.sputum != null).toList();

    if (series.isEmpty) {
      return Text('Aucune donnée de sécrétions.',
          style: AppTypography.bodySmall
              .copyWith(color: AppColors.textSecondary));
    }

    return SizedBox(
      height: 24,
      child: Row(
        children: [
          for (final point in series)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: Container(
                  decoration: BoxDecoration(
                    color: colorFor(point.sputum!),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Colour legend for the sputum strip.
class SputumLegend extends StatelessWidget {
  const SputumLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.xs,
      children: [
        for (final severity in SputumSeverity.values)
          _LegendItem(
            color: SputumTrendStrip.colorFor(severity),
            label: severity.label,
          ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(label, style: AppTypography.labelSmall),
      ],
    );
  }
}
