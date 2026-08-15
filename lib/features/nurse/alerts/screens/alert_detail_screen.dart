import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/colors.dart';
import '../../../../app/theme/spacing.dart';
import '../../../../app/theme/typography.dart';
import '../../../../core/utils/date/app_date_format.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../core/widgets/feedback/app_error_state.dart';
import '../models/alert.dart';
import '../providers/alert_provider.dart';
import '../widgets/alert_action_panel.dart';
import '../widgets/alert_priority_badge.dart';
import '../widgets/alert_status_badge.dart';
import '../widgets/baseline_comparison_tile.dart';

/// Detail view for one alert.
///
/// Three sections, in this order:
///  1. Why it appeared (triggered rules + matched criteria) — the system's
///     reasoning, not a diagnosis.
///  2. What changed (supporting measurements vs. the patient's reference).
///  3. What to do (the nurse's action panel).
///
/// A sibling strip lets the nurse move between the other alerts for the same
/// patient without going back to the list.
class AlertDetailScreen extends ConsumerStatefulWidget {
  final String alertId;

  const AlertDetailScreen({super.key, required this.alertId});

  @override
  ConsumerState<AlertDetailScreen> createState() => _AlertDetailScreenState();
}

class _AlertDetailScreenState extends ConsumerState<AlertDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final notifier = ref.read(alertListProvider.notifier);
      if (notifier.alertById(widget.alertId) == null) {
        notifier.loadAlerts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(alertListProvider.notifier);
    final alert = ref.watch(alertByIdProvider(widget.alertId));
    final state = ref.watch(alertListProvider);

    if (alert == null) {
      if (state.isLoading) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      return Scaffold(
        appBar: AppBar(title: const Text('Alerte')),
        body: AppErrorState(
          title: 'Alerte introuvable',
          message: 'Cette alerte n\'existe plus ou n\'a pas pu être chargée.',
          retryLabel: 'Recharger',
          onRetry: () => notifier.loadAlerts(),
        ),
      );
    }

    final siblings = notifier.alertsForPatient(alert.patientId);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) => context.pop(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Détail de l\'alerte'),
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(),
          ),
          automaticallyImplyLeading: true,
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              _Header(alert: alert),
              const SizedBox(height: AppSpacing.md),
              if (siblings.length > 1)
                _Siblings(alerts: siblings, currentId: alert.id),
              const SizedBox(height: AppSpacing.md),
              _WhySection(alert: alert),
              const SizedBox(height: AppSpacing.md),
              _WhatChangedSection(alert: alert),
              const SizedBox(height: AppSpacing.md),
              AlertActionPanel(
                alert: alert,
                isPending: state.pendingAlertId == alert.id,
                onError: (message) => _showError(message),
                onChanged: () => setState(() {}),
                onAcknowledge: notifier.acknowledge,
                onRecordAction: notifier.recordAction,
                onResolve: notifier.resolve,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.danger),
    );
  }
}

class _Header extends StatelessWidget {
  final Alert alert;

  const _Header({required this.alert});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  alert.patientName,
                  style: AppTypography.titleLarge,
                ),
              ),
              AlertPriorityBadge(priority: alert.priority),
            ],
          ),
          if (alert.patientSummary.isNotEmpty) ...[
            const SizedBox(height: 2.0),
            Text(
              alert.patientSummary,
              style: AppTypography.labelMedium
                  .copyWith(color: AppColors.textMuted),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Text(alert.reason, style: AppTypography.bodyLarge),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              AlertStatusBadge(status: alert.status),
              const SizedBox(width: AppSpacing.sm),
              const Icon(Icons.schedule_rounded,
                  size: 14.0, color: AppColors.textMuted),
              const SizedBox(width: AppSpacing.xs),
              Text(
                AppDateFormat.relative(alert.createdAt),
                style: AppTypography.labelMedium
                    .copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Siblings extends StatelessWidget {
  final List<Alert> alerts;
  final String currentId;

  const _Siblings({required this.alerts, required this.currentId});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
                left: AppSpacing.xs, bottom: AppSpacing.xs),
            child: Text(
              'Autres alertes de ce patient',
              style: AppTypography.labelMedium
                  .copyWith(color: AppColors.textSecondary),
            ),
          ),
          for (final sibling in alerts)
            ListTile(
              dense: true,
              title: Text(sibling.reason, style: AppTypography.bodyMedium),
              subtitle: Text(
                '${sibling.priority.label} · ${sibling.status.label}',
                style: AppTypography.labelMedium,
              ),
              selected: sibling.id == currentId,
              onTap: () {
                if (sibling.id != currentId) {
                  context.pushReplacement('/nurse/alerts/${sibling.id}');
                }
              },
            ),
        ],
      ),
    );
  }
}

class _WhySection extends StatelessWidget {
  final Alert alert;

  const _WhySection({required this.alert});

  @override
  Widget build(BuildContext context) {
    final criteria = alert.matchedCriteria;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pourquoi cette alerte ?',
            style:
                AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Données patient conformes aux règles de surveillance configurées. '
            'Ceci n\'est pas un diagnostic.',
            style: AppTypography.bodySmall
                .copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final rule in alert.triggeredRules) ...[
            Text(
              rule.ruleName,
              style: AppTypography.labelMedium
                  .copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.xs),
            for (final criterion in rule.matchedCriteria)
              Padding(
                padding:
                    const EdgeInsets.only(left: AppSpacing.sm, bottom: 2.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('•  ', style: AppTypography.bodyMedium),
                    Expanded(
                      child: Text(criterion, style: AppTypography.bodyMedium),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: AppSpacing.sm),
          ],
          if (criteria.isEmpty)
            Text(
              'Aucun critère détaillé disponible.',
              style:
                  AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
            ),
        ],
      ),
    );
  }
}

class _WhatChangedSection extends StatelessWidget {
  final Alert alert;

  const _WhatChangedSection({required this.alert});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.sm),
          child: Text(
            'Ce qui a changé',
            style:
                AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        if (alert.supportingMeasurements.isEmpty)
          const Padding(
            padding: EdgeInsets.only(left: AppSpacing.xs),
            child: Text('Aucune mesure associée.'),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.sm,
              crossAxisSpacing: AppSpacing.sm,
              childAspectRatio: 1.6,
            ),
            itemCount: alert.supportingMeasurements.length,
            itemBuilder: (context, index) => BaselineComparisonTile(
              measurement: alert.supportingMeasurements[index],
            ),
          ),
      ],
    );
  }
}
