import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/theme/colors.dart';
import '../../../../../core/components/cards/respi_card.dart';
import '../../../../../core/components/feedback/respi_badge.dart';
import '../../../../../core/components/feedback/respi_empty_state.dart';
import '../../../../../core/components/feedback/respi_skeleton.dart';
import '../../../../../core/navigation/route_names.dart';
import '../../../../../core/theme/tokens/respi_shapes.dart';
import '../../../../../core/theme/tokens/respi_spacing.dart';
import '../../../../../core/theme/tokens/respi_typography.dart';
import '../../../../../core/widgets/feedback/app_error_state.dart';
import '../../patients/models/nurse_patient.dart';
import '../providers/nurse_assignments_provider.dart';
import '../providers/nurse_worklist_provider.dart';
import '../widgets/worklist_item_card.dart';
import '../widgets/worklist_filter_bar.dart';

/// Step 12.4: Nurse operational dashboard.
///
/// Consumes ONLY existing Step 12.3 state providers
/// (`nurseAssignmentsProvider`, `nurseWorklistProvider`, `nurseDashboardProvider`).
/// Does not read repositories/Supabase directly and does not add clinical logic.
///
/// This view is embedded inside the existing NurseShell body — it is a
/// `ConsumerWidget` (no own `Scaffold`) so the shell's app bar and bottom
/// navigation remain intact.
class NurseDashboardView extends ConsumerWidget {
  const NurseDashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async {
        // Preserves filter/search during refresh; recomputes from sources.
        // nurseWorklistProvider.refresh() already reloads nurseDashboardProvider.
        await ref.read(nurseAssignmentsProvider.notifier).refresh();
        await ref.read(nurseWorklistProvider.notifier).refresh();
      },
      child: CustomScrollView(
        slivers: [
          /// 1. Nurse context / greeting
          SliverToBoxAdapter(
            child: _NurseGreeting(
              state: ref.watch(nurseAssignmentsProvider),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: RespiSpacing.xl)),

          /// 2. Attention summary
          SliverToBoxAdapter(
            child: NurseAttentionSummary(
              worklist: ref.watch(nurseWorklistProvider),
              onRetry: () => ref.read(nurseWorklistProvider.notifier).refresh(),
              onSelectFilter: (filter) =>
                  ref.read(nurseWorklistProvider.notifier).setFilter(filter),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: RespiSpacing.xl)),

          /// 3. Clinical worklist
          SliverToBoxAdapter(
            child: _NurseWorklist(
              worklist: ref.watch(nurseWorklistProvider),
              ref: ref,
            ),
          ),

          /// 4. Assigned patients
          SliverToBoxAdapter(
            child: _NurseAssignedPatients(
              state: ref.watch(nurseAssignmentsProvider),
              ref: ref,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: RespiSpacing.xl)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 1. Nurse context / greeting
// ---------------------------------------------------------------------------
class _NurseGreeting extends StatelessWidget {
  const _NurseGreeting({required this.state});
  final NurseAssignmentsState state;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final nurseName = state.nurseName;
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: RespiSpacing.md, vertical: RespiSpacing.sm),
      child: (nurseName == null || nurseName.isEmpty)
          ? const RespiSkeleton(width: 180, height: 28)
          : Semantics(
              // Screen readers announce the nurse's name once, up front.
              label: 'Bonjour, $nurseName',
              child: Text(
                'Bonjour, $nurseName',
                style: textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// 2. Attention summary
// ---------------------------------------------------------------------------
class NurseAttentionSummary extends StatelessWidget {
  const NurseAttentionSummary({
    super.key,
    required this.worklist,
    this.onRetry,
    this.onSelectFilter,
  });

  final NurseWorklistState worklist;

  /// Real retry exposed to the summary's error state. When null the error
  /// block renders without an action (no fake button).
  final VoidCallback? onRetry;

  /// Applying a category filter uses the existing worklist filter interaction
  /// (no new navigation/screen). When null the breakdown is informational only.
  final ValueChanged<NurseWorklistFilter>? onSelectFilter;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).colorScheme.brightness == Brightness.dark;
    final fg = isDark ? AppColors.textPrimary : AppColors.textPrimary;

    if (worklist.isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: RespiSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Attention',
                style: RespiTypography.titleMedium.copyWith(color: fg)),
            const SizedBox(height: RespiSpacing.sm),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: RespiSpacing.sm),
              itemBuilder: (_, __) => const RespiSkeleton(height: 48),
            ),
          ],
        ),
      );
    }

    if (worklist.errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: RespiSpacing.md),
        child: AppErrorState(
          title: 'Impossible de charger le résumé',
          message: worklist.errorMessage!,
          retryLabel: 'Réessayer',
          onRetry: onRetry,
        ),
      );
    }

    final count = worklist.attentionCount;
    // Per-category counts derive from the same worklist provider state as the
    // queue, so they can never drift from the visible items (Step 12.8 §10/§27).
    final categories = [
      (
        label: 'Alertes',
        value: worklist.openAlertsCount,
        filter: NurseWorklistFilter.alerts,
      ),
      (
        label: 'Tâches',
        value: worklist.openTasksCount,
        filter: NurseWorklistFilter.tasks,
      ),
      (
        label: 'Suivis',
        value: worklist.monitoringReviewCount,
        filter: NurseWorklistFilter.monitoring,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: RespiSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Attention',
              style: RespiTypography.titleMedium.copyWith(color: fg)),
          const SizedBox(height: RespiSpacing.sm),
          Semantics(
            label: 'À traiter, $count. '
                'Alertes, ${categories[0].value}. '
                'Tâches, ${categories[1].value}. '
                'Suivis, ${categories[2].value}.',
            // Counts are fully conveyed in text so they remain accessible
            // without relying on color (§41).
            child: RespiCard(
              padding: const EdgeInsets.symmetric(
                  horizontal: RespiSpacing.md, vertical: RespiSpacing.sm),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.notifications_outlined,
                          color: AppColors.warning),
                      const SizedBox(width: RespiSpacing.sm),
                      Text('À traiter',
                          style:
                              RespiTypography.bodyMedium.copyWith(color: fg)),
                      const Spacer(),
                      RespiBadge(
                        label: count.toString(),
                        variant: count > 0
                            ? RespiBadgeVariant.warning
                            : RespiBadgeVariant.neutral,
                      ),
                    ],
                  ),
                  const SizedBox(height: RespiSpacing.md),
                  Row(
                    children: [
                      for (final c in categories)
                        _AttentionCategory(
                          label: c.label,
                          value: c.value,
                          selected: worklist.filter == c.filter,
                          onTap: onSelectFilter == null
                              ? null
                              : () => onSelectFilter!(c.filter),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact per-category stat for the attention summary.
///
/// Selection-aware: tapping applies the corresponding worklist filter (the same
/// interaction the filter bar uses), never a fake/dedicated screen action.
/// Enforces a >=48dp touch target and exposes an accessible label.
class _AttentionCategory extends StatelessWidget {
  const _AttentionCategory({
    required this.label,
    required this.value,
    required this.selected,
    this.onTap,
  });

  final String label;
  final int value;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).colorScheme.brightness == Brightness.dark;
    final fg = isDark ? AppColors.textPrimary : AppColors.textPrimary;
    return Expanded(
      child: Semantics(
        button: onTap != null,
        selected: selected,
        label: '$label, $value',
        child: InkWell(
          onTap: onTap,
          borderRadius: RespiShapes.mdRadius,
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: RespiSpacing.sm),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : Colors.transparent,
              borderRadius: RespiShapes.mdRadius,
              border: selected
                  ? Border.all(color: AppColors.primary.withValues(alpha: 0.4))
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('$value',
                    style: RespiTypography.titleMedium.copyWith(color: fg)),
                Text(label,
                    style: RespiTypography.bodySmall
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 3. Clinical worklist
// ---------------------------------------------------------------------------
class _NurseWorklist extends StatelessWidget {
  const _NurseWorklist({required this.worklist, required this.ref});
  final NurseWorklistState worklist;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).colorScheme.brightness == Brightness.dark;
    final fg = isDark ? AppColors.textPrimary : AppColors.textPrimary;

    final filteredItems = worklist.filteredItems;

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: RespiSpacing.md, vertical: RespiSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('File de travail',
              style: RespiTypography.titleMedium.copyWith(color: fg)),
          const SizedBox(height: RespiSpacing.sm),
          // Filter bar — never disabled while loading; selected filter preserved.
          WorklistFilterBar(
            selected: worklist.filter,
            onSelected: (filter) =>
                ref.read(nurseWorklistProvider.notifier).setFilter(filter),
          ),
          const SizedBox(height: RespiSpacing.sm),
          if (worklist.isLoading && worklist.items.isEmpty)
            // Initial loading skeleton.
            const Column(
              children: [
                RespiSkeleton(width: double.infinity, height: 80),
                SizedBox(height: RespiSpacing.md),
                RespiSkeleton(width: double.infinity, height: 80),
                SizedBox(height: RespiSpacing.md),
                RespiSkeleton(width: double.infinity, height: 80),
              ],
            )
          else if (worklist.errorMessage != null)
            AppErrorState(
              title: 'Impossible de charger la file de travail',
              message: worklist.errorMessage!,
              retryLabel: 'Réessayer',
              onRetry: () => ref.read(nurseWorklistProvider.notifier).refresh(),
            )
          else if (worklist.items.isEmpty)
            const RespiEmptyState(
              icon: Icons.task_alt_rounded,
              title: 'Vous êtes à jour',
              message: 'Rien ne nécessite votre attention pour le moment.',
            )
          else if (filteredItems.isEmpty)
            // Filter active but no matching items — contextual empty state.
            _FilteredEmptyState(
              filter: worklist.filter,
              onClear: () => ref.read(nurseWorklistProvider.notifier).setFilter(
                    NurseWorklistFilter.all,
                  ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredItems.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: RespiSpacing.sm),
              itemBuilder: (context, index) =>
                  WorklistItemCard(item: filteredItems[index]),
            ),
        ],
      ),
    );
  }
}

/// Contextual empty state shown when the underlying worklist has items but the
/// active filter produces zero results. Distinct from the global "all caught
/// up" state so the nurse understands the list was merely filtered.
class _FilteredEmptyState extends StatelessWidget {
  const _FilteredEmptyState({required this.filter, required this.onClear});
  final NurseWorklistFilter filter;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final label = switch (filter) {
      NurseWorklistFilter.all => 'Tous',
      NurseWorklistFilter.alerts => 'Alertes',
      NurseWorklistFilter.tasks => 'Tâches',
      NurseWorklistFilter.monitoring => 'Suivis',
      NurseWorklistFilter.needsAttention => 'À traiter',
    };

    return RespiEmptyState(
      icon: Icons.filter_alt_off_outlined,
      title: 'Aucun $label trouvé',
      message: 'Aucun élément ne correspond au filtre sélectionné.',
      actionLabel: 'Afficher tous les éléments',
      onAction: onClear,
    );
  }
}

// ---------------------------------------------------------------------------
// 4. Assigned patients
// ---------------------------------------------------------------------------
class _NurseAssignedPatients extends StatelessWidget {
  const _NurseAssignedPatients({required this.state, required this.ref});
  final NurseAssignmentsState state;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).colorScheme.brightness == Brightness.dark;
    final fg = isDark ? AppColors.textPrimary : AppColors.textPrimary;

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: RespiSpacing.md, vertical: RespiSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Patients assignés',
              style: RespiTypography.titleMedium.copyWith(color: fg)),
          const SizedBox(height: RespiSpacing.sm),
          if (state.errorMessage != null)
            AppErrorState(
              title: 'Impossible de charger les patients',
              message: state.errorMessage!,
              retryLabel: 'Réessayer',
              onRetry: () =>
                  ref.read(nurseAssignmentsProvider.notifier).refresh(),
            )
          else if (state.assignedPatients.isEmpty && !state.isLoading)
            const RespiEmptyState(
              icon: Icons.people_outline_rounded,
              title: 'Aucun patient assigné',
              message: 'Aucun patient n’est assigné à vous actuellement.',
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.assignedPatients.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: RespiSpacing.sm),
              itemBuilder: (context, index) {
                final NursePatient patient = state.assignedPatients[index];
                final count =
                    ref.watch(nursePatientWorkCountProvider(patient.id));
                return RespiCard(
                  child: Material(
                    type: MaterialType.transparency,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: RespiSpacing.md,
                          vertical: RespiSpacing.sm),
                      title: Text(patient.fullName,
                          style: RespiTypography.titleMedium
                              .copyWith(fontWeight: FontWeight.w600)),
                      subtitle: Text(
                          '${patient.condition} · ${patient.classification}',
                          style: RespiTypography.bodySmall
                              .copyWith(color: AppColors.textSecondary)),
                      trailing: count > 0
                          ? RespiBadge(
                              label: '$count',
                              variant: RespiBadgeVariant.warning)
                          : null,
                      onTap: () => context.push(
                        RouteNames.nursePatientDetail
                            .replaceFirst(':patientId', patient.id),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
