import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/components/feedback/respi_empty_state.dart';
import '../../../core/components/layout/respi_app_bar.dart';
import '../../../core/components/layout/respi_scaffold.dart';
import '../../../core/theme/tokens/respi_spacing.dart';
import '../../../core/theme/tokens/respi_typography.dart';
import '../models/measurement_type.dart';
import '../providers/monitoring_history_provider.dart';
import '../utils/clinical_time_range.dart';
import '../widgets/clinical_chart_card.dart';
import '../widgets/measurement_type_filter.dart';
import '../widgets/chart_card_skeleton.dart';
import '../widgets/time_range_control.dart';

/// Patient-facing screen showing clinical measurement history and trends.
///
/// Reads [monitoringHistoryProvider] to load measurements for the active
/// time window and measurement types, then renders one [ClinicalChartCard]
/// per selected type.  Loading, error, empty and data states are handled here.
class MonitoringHistoryScreen extends ConsumerWidget {
  const MonitoringHistoryScreen({super.key});

  static const List<MeasurementType> _order = [
    MeasurementType.spo2,
    MeasurementType.heartRate,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(monitoringHistoryProvider);
    final notifier = ref.read(monitoringHistoryProvider.notifier);

    return RespiScaffold(
      appBar: const RespiAppBar(
        title: 'Historique',
        subtitle: 'Évolution de vos mesures',
      ),
      body: RefreshIndicator(
        onRefresh: () => notifier.refresh(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(RespiSpacing.md),
          children: [
            const _InfoBanner(),
            const SizedBox(height: RespiSpacing.md),
            _TimeRangeSection(
              selected: state.selectedRange,
              onChanged: (r) => notifier.changeRange(r),
            ),
            const SizedBox(height: RespiSpacing.md),
            if (state.isRefreshing)
              const Padding(
                padding: EdgeInsets.only(bottom: RespiSpacing.md),
                child: LinearProgressIndicator(minHeight: 2),
              ),
            _FilterSection(
              selected: state.selectedTypes,
              onToggle: (t) => notifier.toggleType(t),
            ),
            const SizedBox(height: RespiSpacing.md),
            if (state.isLoading)
              ..._buildSkeletons()
            else if (state.hasError)
              _ErrorState(onRetry: () => notifier.refresh())
            else if (_totalVisiblePoints(state) == 0)
              const _EmptyState()
            else
              ..._buildChartCards(state),
            const SizedBox(height: RespiSpacing.md),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSkeletons() {
    return [
      for (var i = 0; i < 2; i++)
        const Padding(
          padding: EdgeInsets.only(bottom: RespiSpacing.md),
          child: ChartCardSkeleton(),
        ),
    ];
  }

  int _totalVisiblePoints(MonitoringHistoryState state) {
    int total = 0;
    for (final type in _order) {
      if (state.selectedTypes.contains(type)) {
        total += state.measurementsFor(type).length;
      }
    }
    return total;
  }

  List<Widget> _buildChartCards(MonitoringHistoryState state) {
    return [
      for (final type in _order)
        if (state.selectedTypes.contains(type))
          Padding(
            padding: const EdgeInsets.only(bottom: RespiSpacing.md),
            child: ClinicalChartCard(
              type: type,
              measurements: state.measurementsFor(type),
              trend: state.trendFor(type),
            ),
          ),
    ];
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(RespiSpacing.md),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: cs.onPrimaryContainer),
          const SizedBox(width: RespiSpacing.sm),
          Expanded(
            child: Text(
              'Ces courbes reflètent vos mesures saisies. Elles sont '
              'présentées à titre informatif et ne remplacent pas un avis '
              'médical.',
              style: RespiTypography.bodySmall.copyWith(
                color: cs.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeRangeSection extends StatelessWidget {
  const _TimeRangeSection({required this.selected, required this.onChanged});

  final ClinicalTimeRange selected;
  final ValueChanged<ClinicalTimeRange> onChanged;

  @override
  Widget build(BuildContext context) {
    return TimeRangeControl(selected: selected, onChanged: onChanged);
  }
}

class _FilterSection extends StatelessWidget {
  const _FilterSection({required this.selected, required this.onToggle});

  final Set<MeasurementType> selected;
  final ValueChanged<MeasurementType> onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mesures affichées',
          style: RespiTypography.labelMedium.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: RespiSpacing.xs),
        MeasurementTypeFilter(selected: selected, onToggle: onToggle),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: RespiSpacing.xl),
      child: RespiEmptyState(
        icon: Icons.show_chart_rounded,
        title: 'Aucune mesure sur cette période',
        message:
            'Modifiez la période ou les mesures affichées, ou enregistrez une '
            'nouvelle saturation pour voir apparaître votre courbe.',
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: RespiSpacing.xl),
      child: Column(
        children: [
          Icon(Icons.cloud_off_rounded, size: 48, color: cs.error),
          const SizedBox(height: RespiSpacing.md),
          const Text(
            'Impossible de charger vos mesures',
            textAlign: TextAlign.center,
            style: RespiTypography.titleMedium,
          ),
          const SizedBox(height: RespiSpacing.sm),
          Text(
            'Vérifiez votre connexion puis réessayez.',
            textAlign: TextAlign.center,
            style: RespiTypography.bodyMedium.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: RespiSpacing.md),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }
}
