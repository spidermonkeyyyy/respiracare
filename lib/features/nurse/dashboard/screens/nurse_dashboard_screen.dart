import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/radius.dart';
import '../../../../app/theme/spacing.dart';
import '../../../../app/theme/typography.dart';
import '../../../../core/utils/animations/app_animations.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../core/widgets/feedback/app_empty_state.dart';
import '../../../../core/widgets/feedback/app_error_state.dart';
import '../../patients/models/nurse_patient.dart';
import '../providers/nurse_dashboard_provider.dart';
import '../widgets/priority_badge.dart';

class NurseDashboardScreen extends ConsumerWidget {
  const NurseDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(nurseDashboardProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Suivi respiratoire'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: state.isLoading
            ? const _DashboardSkeleton()
            : state.errorMessage != null
                ? AppErrorState(
                    title: 'Impossible de charger le tableau de bord',
                    message: state.errorMessage!,
                    retryLabel: 'Réessayer',
                    onRetry: () => ref
                        .read(nurseDashboardProvider.notifier)
                        .loadDashboard(),
                  )
                : RefreshIndicator(
                    onRefresh: () => ref
                        .read(nurseDashboardProvider.notifier)
                        .loadDashboard(),
                    child: ListView(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      children: [
                        AppFadeAnimation(
                          child: _buildHeader(context, state.summary),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppSlideAnimation(
                          delay: const Duration(milliseconds: 100),
                          child: _buildSummaryCards(state),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppSlideAnimation(
                          delay: const Duration(milliseconds: 150),
                          child:
                              _buildPriorityQueue(context, state.priorityQueue),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppSlideAnimation(
                          delay: const Duration(milliseconds: 200),
                          child: _buildRecentSubmissions(
                              context, state.recentSubmissions),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, dynamic summary) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bonjour, Mme Asma', style: AppTypography.headlineLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
              'Voici les patients qui demandent une attention prioritaire aujourd’hui.',
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildMetric('Patients suivis',
                    '${summary?.totalPatients ?? 0}', AppColors.primary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildMetric(
                    'Nouveaux suivis',
                    '${summary?.newSubmissionsCount ?? 0}',
                    AppColors.secondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(NurseDashboardState state) {
    return Row(
      children: [
        Expanded(
          child: AppCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber_rounded, color: AppColors.danger),
                const SizedBox(height: AppSpacing.sm),
                Text('${state.summary?.highPriorityCount ?? 0}',
                    style: AppTypography.headlineLarge),
                Text('Priorité élevée',
                    style: AppTypography.bodyMedium
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: AppCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.remove_red_eye_outlined, color: AppColors.warning),
                const SizedBox(height: AppSpacing.sm),
                Text('${state.summary?.reviewRequiredCount ?? 0}',
                    style: AppTypography.headlineLarge),
                Text('À revoir',
                    style: AppTypography.bodyMedium
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityQueue(
      BuildContext context, List<NursePatient> patients) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Patients nécessitant une attention',
                  style: AppTypography.titleLarge),
              const Spacer(),
              TextButton(
                  onPressed: () => context.push('/nurse/patients'),
                  child: const Text('Voir tous')),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (patients.isEmpty)
            AppEmptyState(
                title: 'Aucun patient à traiter',
                message: 'Le flux prioritaire est actuellement calme.',
                icon: Icons.check_circle_outline_rounded)
          else
            ...patients.map((patient) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(patient.fullName,
                                  style: AppTypography.titleLarge
                                      .copyWith(fontSize: 16.0)),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                  '${patient.condition} · ${patient.classification}',
                                  style: AppTypography.bodyMedium.copyWith(
                                      color: AppColors.textSecondary)),
                              const SizedBox(height: AppSpacing.xs),
                              if (patient.latestObservation != null)
                                Text(patient.latestObservation!,
                                    style: AppTypography.bodyMedium.copyWith(
                                        color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            PriorityBadge(priority: patient.priority),
                            const SizedBox(height: AppSpacing.sm),
                            AppButtonText(
                              onPressed: () =>
                                  context.push('/nurse/patients/${patient.id}'),
                              label: 'Consulter',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildRecentSubmissions(
      BuildContext context, List<dynamic> submissions) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Suivis récents', style: AppTypography.titleLarge),
          const SizedBox(height: AppSpacing.md),
          if (submissions.isEmpty)
            Text('Pas de nouveaux suivis à afficher.',
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.textSecondary))
          else
            ...submissions.map((submission) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Patient #${submission.patientId}',
                                style: AppTypography.bodyMedium
                                    .copyWith(fontWeight: FontWeight.w600)),
                            Text(
                                'SpO₂ ${submission.spo2} · Dyspnée ${submission.dyspneaScore}',
                                style: AppTypography.bodyMedium
                                    .copyWith(color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      Text(_formatDate(submission.submittedAt),
                          style: AppTypography.bodySmall
                              .copyWith(color: AppColors.textMuted)),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadius.medium)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.labelMedium.copyWith(color: color)),
          const SizedBox(height: AppSpacing.xs),
          Text(value,
              style: AppTypography.headlineLarge.copyWith(fontSize: 20.0)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes} min';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}j';
  }
}

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Container(
            height: 120.0,
            decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppRadius.medium))),
        const SizedBox(height: AppSpacing.md),
        Row(children: [
          Expanded(
              child: Container(
                  height: 100.0,
                  decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(AppRadius.medium)))),
          const SizedBox(width: AppSpacing.md),
          Expanded(
              child: Container(
                  height: 100.0,
                  decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(AppRadius.medium))))
        ]),
        const SizedBox(height: AppSpacing.md),
        Container(
            height: 180.0,
            decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppRadius.medium))),
      ],
    );
  }
}

class AppButtonText extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;

  const AppButtonText(
      {super.key, required this.onPressed, required this.label});

  @override
  Widget build(BuildContext context) {
    return TextButton(onPressed: onPressed, child: Text(label));
  }
}
