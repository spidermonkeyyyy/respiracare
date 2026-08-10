import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/radius.dart';
import '../../../../app/theme/spacing.dart';
import '../../../../app/theme/typography.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../core/widgets/feedback/app_empty_state.dart';
import '../../../../core/widgets/feedback/app_error_state.dart';
import '../../dashboard/widgets/priority_badge.dart';
import '../../monitoring/widgets/respiratory_trend_card.dart';
import '../../patients/providers/nurse_patients_provider.dart';
import '../../patients/widgets/patient_timeline.dart';
import '../models/nurse_patient.dart';

class NursePatientProfileScreen extends ConsumerStatefulWidget {
  final String patientId;

  const NursePatientProfileScreen({super.key, required this.patientId});

  @override
  ConsumerState<NursePatientProfileScreen> createState() =>
      _NursePatientProfileScreenState();
}

class _NursePatientProfileScreenState
    extends ConsumerState<NursePatientProfileScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    Future.microtask(() => ref
        .read(nursePatientsProvider.notifier)
        .selectPatient(widget.patientId));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(nursePatientsProvider);
    final patient = state.selectedPatient;

    if (state.errorMessage != null && patient == null) {
      return AppErrorState(
        title: 'Profil introuvable',
        message: state.errorMessage!,
        retryLabel: 'Réessayer',
        onRetry: () => ref
            .read(nursePatientsProvider.notifier)
            .selectPatient(widget.patientId),
      );
    }

    if (patient == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(patient.fullName),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(patient.fullName, style: AppTypography.headlineLarge),
                  const SizedBox(height: AppSpacing.xs),
                  Text('${patient.condition} · ${patient.classification}',
                      style: AppTypography.bodyMedium
                          .copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      PriorityBadge(priority: patient.priority),
                      const Spacer(),
                      if (patient.hasNewSubmission)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.xs),
                          decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.12),
                              borderRadius:
                                  BorderRadius.circular(AppRadius.pill)),
                          child: Text('Nouveau suivi',
                              style: AppTypography.labelMedium
                                  .copyWith(color: AppColors.success)),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              tabs: const [
                Tab(text: 'Vue générale'),
                Tab(text: 'Données'),
                Tab(text: 'Traitement'),
                Tab(text: 'Éducation'),
                Tab(text: 'Historique'),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 400,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverview(patient),
                  _buildData(patient),
                  _buildTreatment(patient),
                  _buildEducation(patient),
                  _buildHistory(patient),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverview(NursePatient patient) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dernier suivi', style: AppTypography.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          Text(
              patient.latestSubmission != null
                  ? 'Envoyé le ${_formatDate(patient.latestSubmission!.submittedAt)}'
                  : 'Aucun suivi disponible',
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.md),
          Text('Dernière observation', style: AppTypography.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          Text(patient.latestObservation ?? 'Pas d’observation récente.',
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildData(NursePatient patient) {
    return Column(
      children: [
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Dernières données', style: AppTypography.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              if (patient.latestSubmission != null) ...[
                _MetricRow(
                    label: 'SpO₂', value: '${patient.latestSubmission!.spo2}%'),
                _MetricRow(
                    label: 'Dyspnée',
                    value: '${patient.latestSubmission!.dyspneaScore}'),
                _MetricRow(
                    label: 'Toux',
                    value: patient.latestSubmission!.coughStatus),
                _MetricRow(
                    label: 'Expectorations',
                    value: patient.latestSubmission!.sputumStatus),
              ] else
                const Text('Aucune mesure disponible'),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const RespiratoryTrendCard(),
      ],
    );
  }

  Widget _buildTreatment(NursePatient patient) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Observance', style: AppTypography.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          if (patient.adherence != null) ...[
            Text(
                'Conformité hebdo: ${(patient.adherence!.weeklyCompliance * 100).toStringAsFixed(0)}%',
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.sm),
            Text(
                'Confirmées: ${patient.adherence!.confirmedCount} · Non confirmées: ${patient.adherence!.missedCount}',
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.textSecondary)),
          ] else
            const Text('Aucune donnée d’observance disponible.'),
        ],
      ),
    );
  }

  Widget _buildEducation(NursePatient patient) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Éducation', style: AppTypography.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          Text(
              'Vidéo d’inhalation: ${patient.inhalerVideo != null ? 'réceptionnée' : 'à valider'}',
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.sm),
          Text('Rééducation respiratoire: programme disponible',
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildHistory(NursePatient patient) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Historique', style: AppTypography.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          if (patient.timeline.isEmpty)
            const AppEmptyState(
                title: 'Aucun historique',
                message: 'Aucun événement n’a encore été enregistré.',
                icon: Icons.history_rounded)
          else
            PatientTimeline(events: patient.timeline),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays}j';
    if (diff.inHours > 0) return '${diff.inHours}h';
    return '${diff.inMinutes}min';
  }
}

class _MetricRow extends StatelessWidget {
  final String label;
  final String value;

  const _MetricRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTypography.bodyMedium)),
          Text(value,
              style: AppTypography.bodyMedium
                  .copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
