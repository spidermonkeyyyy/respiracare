import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/colors.dart';
import '../../../../app/theme/radius.dart';
import '../../../../app/theme/spacing.dart';
import '../../../../app/theme/typography.dart';
import '../../../../core/widgets/feedback/app_empty_state.dart';
import '../../../../core/widgets/feedback/app_error_state.dart';
import '../models/alert_group.dart';
import '../providers/alert_provider.dart';
import '../widgets/alert_group_card.dart';
import 'package:respiracare/core/utils/animations/app_animations.dart';

/// Nurse alert centre.
///
/// Design goals (step 4.9B/4.9C):
///  - Group related alerts per patient to fight alert fatigue.
///  - Keep the filter set short.
///  - Answer "who / what / how important / how recent / what next" fast.
class AlertsScreen extends ConsumerStatefulWidget {
  const AlertsScreen({super.key});

  @override
  ConsumerState<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends ConsumerState<AlertsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(alertListProvider.notifier).loadAlerts());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(alertListProvider);
    final notifier = ref.read(alertListProvider.notifier);
    final groups = state.filteredGroups;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Alertes'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          if (state.openCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2.0,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    '${state.openCount} ouverte${state.openCount > 1 ? 's' : ''}',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.danger,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.errorMessage != null
                ? AppErrorState(
                    title: 'Impossible de charger les alertes',
                    message: state.errorMessage!,
                    retryLabel: 'Réessayer',
                    onRetry: () => notifier.loadAlerts(),
                  )
                : Column(
                    children: [
                      _FilterRow(
                        current: state.filter,
                        onChanged: notifier.setFilter,
                      ),
                      if (state.errorMessage != null) ...[
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Text(
                            state.errorMessage!,
                            style: AppTypography.labelMedium
                                .copyWith(color: AppColors.danger),
                          ),
                        ),
                      ],
                      Expanded(
                        child: groups.isEmpty
                            ? const AppEmptyState(
                                title: 'Aucune alerte',
                                message:
                                    'Les alertes de surveillance s\'afficheront ici.',
                                icon: Icons.notifications_none_outlined,
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                itemCount: groups.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: AppSpacing.md),
                                itemBuilder: (context, index) {
                                  final group = groups[index];
                                  return AppFadeAnimation(
                                                                      delay: Duration(milliseconds: 40 * index),
                                                                      child: AlertGroupCard(
                                                                        group: group,
                                                                        onTap: () => _openGroup(context, group),
                                                                      ),
                                                                    );
                                },
                              ),
                      ),
                    ],
                  ),
      ),
    );
  }

  void _openGroup(BuildContext context, AlertGroup group) {
    final mostUrgent = group.alerts.first;
    context.push('/nurse/alerts/${mostUrgent.id}');
  }
}

class _FilterRow extends StatelessWidget {
  final AlertFilter current;
  final ValueChanged<AlertFilter> onChanged;

  const _FilterRow({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: AlertFilter.values
            .map((filter) => Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: ChoiceChip(
                    label: Text(filter.label),
                    selected: current == filter,
                    selectedColor: AppColors.primary.withValues(alpha: 0.15),
                    onSelected: (_) => onChanged(filter),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
