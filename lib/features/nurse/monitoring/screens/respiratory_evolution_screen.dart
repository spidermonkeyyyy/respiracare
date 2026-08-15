import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/colors.dart';
import '../../../../app/theme/spacing.dart';
import '../../../../app/theme/typography.dart';
import '../../../../core/widgets/feedback/app_empty_state.dart';
import '../../../../core/widgets/feedback/app_error_state.dart';
import '../../../../core/widgets/feedback/app_loading.dart';
import '../../patients/providers/nurse_patients_provider.dart';
import '../models/respiratory_trend.dart';
import '../providers/nurse_trend_provider.dart';
import '../widgets/respiratory_trends_charts.dart';

/// SCR-NUR-06 — Respiratory Evolution Charts screen.
///
/// Multi-metric longitudinal graph analysis (SpO₂, CAT, mMRC, sputum) with a
/// timeframe selector and tap-to-tooltip interactions.
class RespiratoryEvolutionScreen extends ConsumerStatefulWidget {
  final String patientId;

  const RespiratoryEvolutionScreen({super.key, required this.patientId});

  @override
  ConsumerState<RespiratoryEvolutionScreen> createState() =>
      _RespiratoryEvolutionScreenState();
}

class _RespiratoryEvolutionScreenState
    extends ConsumerState<RespiratoryEvolutionScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        ref.read(nurseTrendProvider.notifier).load(widget.patientId));
  }

  @override
  Widget build(BuildContext context) {
    final trend = ref.watch(nurseTrendProvider);
    final patient = ref.watch(nursePatientsProvider).selectedPatient;

    final name = patient != null ? patient.fullName : '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Évolution respiratoire'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: _buildBody(trend, name),
    );
  }

  Widget _buildBody(NurseTrendState trend, String patientName) {
    if (trend.isLoading && trend.points.isEmpty) {
      return const AppLoading(message: 'Chargement des tendances…');
    }

    if (trend.errorMessage != null && trend.points.isEmpty) {
      return AppErrorState(
        title: 'Chargement impossible',
        message: trend.errorMessage!,
        retryLabel: 'Réessayer',
        onRetry: () => ref.read(nurseTrendProvider.notifier).load(widget.patientId),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(nurseTrendProvider.notifier).load(widget.patientId),
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          if (patientName.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Text('Patient : $patientName',
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.textSecondary)),
            ),
          _buildTimeframeSelector(trend.timeframe),
          const SizedBox(height: AppSpacing.md),
          if (trend.points.isEmpty)
            const AppEmptyState(
              title: 'Pas assez de données',
              message:
                  'Insufficient data points to render trend graph for selected range.',
              icon: Icons.query_stats_rounded,
            )
          else
            RespiratoryTrendsCharts(points: trend.points),
        ],
      ),
    );
  }

  Widget _buildTimeframeSelector(TrendTimeframe current) {
    return SegmentedButton<TrendTimeframe>(
      segments: [
        for (final timeframe in TrendTimeframe.values)
          ButtonSegment(
            value: timeframe,
            label: Text(timeframe.label),
          ),
      ],
      selected: {current},
      showSelectedIcon: false,
      style: const ButtonStyle(
        visualDensity: VisualDensity.compact,
      ),
      onSelectionChanged: (selection) {
        ref.read(nurseTrendProvider.notifier).setTimeframe(selection.first);
      },
    );
  }
}
