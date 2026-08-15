import 'package:flutter/material.dart';

import '../../../core/components/cards/respi_card.dart';
import '../../../core/components/charts/respi_line_chart.dart';
import '../../../core/theme/tokens/respi_spacing.dart';
import '../../../core/theme/tokens/respi_typography.dart';
import '../models/clinical_measurement.dart';
import '../models/measurement_type.dart';
import '../utils/clinical_trend_calculator.dart';
import 'clinical_trend_badge.dart';

/// Card presenting one measurement series: header (type, latest value,
/// trend), the [RespiLineChart], and a footer with reading count.
///
/// The card is deliberately presentation-only: it receives already-sorted
/// measurements and the computed [TrendSummary] from the calling screen.
class ClinicalChartCard extends StatelessWidget {
  const ClinicalChartCard({
    super.key,
    required this.type,
    required this.measurements,
    required this.trend,
    this.chartColor,
  });

  final MeasurementType type;
  final List<ClinicalMeasurement> measurements;
  final TrendSummary trend;
  final Color? chartColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final info = MeasurementTypeInfo.of(type);
    final color = chartColor ?? cs.primary;

    final latest = measurements.isEmpty ? null : measurements.last;
    final points = [
      for (final m in measurements)
        if (m.isValid) ChartPoint(value: m.value, time: m.measuredAt),
    ];

    return RespiCard(
      borderColor: cs.outlineVariant,
      padding: const EdgeInsets.all(RespiSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      info.label,
                      style: RespiTypography.titleMedium.copyWith(
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: RespiSpacing.xxs),
                    if (latest != null)
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(fontFamily: 'Inter'),
                          children: [
                            TextSpan(
                              text: latest.displayValue,
                              style: RespiTypography.titleLarge.copyWith(
                                color: color,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextSpan(
                              text: ' · dernière mesure',
                              style: RespiTypography.bodySmall.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Text(
                        'Aucune mesure',
                        style: RespiTypography.bodyMedium.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: RespiSpacing.sm),
              ClinicalTrendBadge(type: type, summary: trend),
            ],
          ),
          const SizedBox(height: RespiSpacing.md),

          // Chart
          SizedBox(
            height: 200,
            child: RespiLineChart(
              points: points,
              unit: info.unit,
              color: color,
              semanticsLabel:
                  '${info.accessibilityLabel} : ${_describeSeries()}',
            ),
          ),

          // Footer
          const SizedBox(height: RespiSpacing.xs),
          Wrap(
            spacing: RespiSpacing.md,
            runSpacing: RespiSpacing.xs,
            children: [
              _FooterMeta(
                icon: Icons.monitor_heart_outlined,
                text: '${measurements.length} mesure'
                    '${measurements.length > 1 ? 's' : ''}',
              ),
              if (measurements.isNotEmpty)
                _FooterMeta(
                  icon: Icons.date_range_outlined,
                  text: 'du ${_fmt(measurements.first.measuredAt)} au '
                      '${_fmt(measurements.last.measuredAt)}',
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _describeSeries() {
    if (measurements.isEmpty) return 'aucune donnée';
    final values = measurements.map((m) => m.value).toList();
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);
    return '${measurements.length} mesures, de $min à $max';
  }
}

String _fmt(DateTime d) => '${d.day}/${d.month}';

class _FooterMeta extends StatelessWidget {
  const _FooterMeta({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: cs.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          text,
          style: RespiTypography.labelMedium.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
