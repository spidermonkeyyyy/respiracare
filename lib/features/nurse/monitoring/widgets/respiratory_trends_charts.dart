import 'package:flutter/material.dart';

import '../../../../app/theme/colors.dart';
import '../../../../app/theme/spacing.dart';
import '../../../../app/theme/typography.dart';
import '../../../../core/components/charts/respi_line_chart.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../models/respiratory_trend.dart';
import 'mmrc_bar_chart.dart';
import 'sputum_trend_strip.dart';
import 'trend_detail_panel.dart';

/// Layout of the four SCR-NUR-06 charts plus an interactive detail panel.
///
/// Tapping a data point on any chart selects that day and reveals the
/// complete multi-metric snapshot ([TrendDetailPanel]) for it.
class RespiratoryTrendsCharts extends StatefulWidget {
  final List<RespiratoryTrendPoint> points;

  const RespiratoryTrendsCharts({super.key, required this.points});

  @override
  State<RespiratoryTrendsCharts> createState() =>
      _RespiratoryTrendsChartsState();
}

class _RespiratoryTrendsChartsState extends State<RespiratoryTrendsCharts> {
  RespiratoryTrendPoint? _selected;

  void _select(RespiratoryTrendPoint point) {
    setState(() => _selected = point);
  }

  @override
  Widget build(BuildContext context) {
    final points = widget.points;

    if (points.length < 2) {
      return const _InsufficientData();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_selected != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: TrendDetailPanel(point: _selected!),
          ),
        _LineChartCard(
          title: 'SpO₂',
          subtitle: 'Saturation en oxygène (%)',
          color: AppColors.primary,
          points: points,
          unit: '%',
          valueFor: (p) => p.spo2?.toDouble(),
          selected: _selected,
          onSelect: _select,
          baselineLabel:
              'Référence 92–98 % (à valider avec le superviseur clinique)',
        ),
        const SizedBox(height: AppSpacing.md),
        _LineChartCard(
          title: 'Score CAT',
          subtitle: 'COPD Assessment Test (0–40)',
          color: AppColors.info,
          points: points,
          unit: 'pts',
          valueFor: (p) => p.catScore?.toDouble(),
          selected: _selected,
          onSelect: _select,
        ),
        const SizedBox(height: AppSpacing.md),
        _BarChartCard(
          title: 'Dyspnée mMRC',
          subtitle: 'Grade (0–4)',
          points: points,
          selected: _selected,
          onSelect: _select,
        ),
        const SizedBox(height: AppSpacing.md),
        _SputumCard(points: points),
      ],
    );
  }
}

class _LineChartCard extends StatelessWidget {
  const _LineChartCard({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.points,
    required this.unit,
    required this.valueFor,
    required this.selected,
    required this.onSelect,
    this.baselineLabel,
  });

  final String title;
  final String subtitle;
  final Color color;
  final List<RespiratoryTrendPoint> points;
  final String unit;
  final double? Function(RespiratoryTrendPoint) valueFor;
  final RespiratoryTrendPoint? selected;
  final ValueChanged<RespiratoryTrendPoint> onSelect;
  final String? baselineLabel;

  @override
  Widget build(BuildContext context) {
    final series = <ChartPoint>[];
    for (final point in points) {
      final value = valueFor(point);
      if (value != null) {
        series.add(ChartPoint(value: value, time: point.date));
      }
    }

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.titleLarge),
          Text(subtitle,
              style: AppTypography.bodySmall
                  .copyWith(color: AppColors.textSecondary)),
          if (baselineLabel != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                const Icon(Icons.info_outline,
                    size: 14, color: AppColors.textSecondary),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(baselineLabel!,
                      style: AppTypography.labelSmall
                          .copyWith(color: AppColors.textSecondary)),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              return GestureDetector(
                onTapDown: (details) {
                  if (series.isEmpty) return;
                  final index =
                      ((details.localPosition.dx / width) * series.length)
                          .floor()
                          .clamp(0, series.length - 1);
                  onSelect(points[index]);
                },
                child: RespiLineChart(
                  points: series,
                  unit: unit,
                  color: color,
                  enableAnimation: false,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _BarChartCard extends StatelessWidget {
  const _BarChartCard({
    required this.title,
    required this.subtitle,
    required this.points,
    required this.selected,
    required this.onSelect,
  });

  final String title;
  final String subtitle;
  final List<RespiratoryTrendPoint> points;
  final RespiratoryTrendPoint? selected;
  final ValueChanged<RespiratoryTrendPoint> onSelect;

  @override
  Widget build(BuildContext context) {
    final series = points.where((p) => p.mmrcGrade != null).toList();
    final selectedIndex = selected == null
        ? null
        : series.indexWhere((p) => p.date == selected!.date);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.titleLarge),
          Text(subtitle,
              style: AppTypography.bodySmall
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.sm),
          MmrcBarChart(
            points: series,
            selectedIndex: selectedIndex,
            onPointTap: (index) => onSelect(series[index]),
          ),
        ],
      ),
    );
  }
}

class _SputumCard extends StatelessWidget {
  const _SputumCard({required this.points});

  final List<RespiratoryTrendPoint> points;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Sécrétions', style: AppTypography.titleLarge),
          Text('Volume & couleur (sévérité)',
              style: AppTypography.bodySmall
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.md),
          SputumTrendStrip(points: points),
          const SizedBox(height: AppSpacing.md),
          const SputumLegend(),
        ],
      ),
    );
  }
}

class _InsufficientData extends StatelessWidget {
  const _InsufficientData();

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Text(
        'Insufficient data points to render trend graph for selected range.',
        style: AppTypography.bodyMedium,
      ),
    );
  }
}

