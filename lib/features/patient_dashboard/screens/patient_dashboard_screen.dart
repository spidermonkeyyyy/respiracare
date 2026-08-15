import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/spacing.dart';
import '../../../app/theme/typography.dart';

import '../../../core/utils/animations/app_animations.dart';
import '../../../core/widgets/feedback/app_empty_state.dart';
import '../../../core/widgets/feedback/app_error_state.dart';
import '../providers/patient_dashboard_provider.dart';
import '../widgets/care_team_card.dart';
import '../widgets/daily_monitoring_card.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_skeleton.dart';
import '../widgets/medication_card.dart';
import '../widgets/patient_app_shell.dart';
import '../widgets/patient_health_status_card.dart';
import '../widgets/rehabilitation_card.dart';

class PatientDashboardScreen extends ConsumerStatefulWidget {
  const PatientDashboardScreen({super.key});

  @override
  ConsumerState<PatientDashboardScreen> createState() =>
      _PatientDashboardScreenState();
}

class _PatientDashboardScreenState
    extends ConsumerState<PatientDashboardScreen> {
  PreferredSizeWidget _buildAppBar(PatientDashboardState dashboardState) {
    final notifier = ref.read(patientDashboardProvider.notifier);
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      toolbarHeight: 44.0,
      title: Row(
        children: [
          const Icon(Icons.health_and_safety_rounded,
              color: AppColors.primary, size: 22.0),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'RespiraCare',
            style:
                AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
      actions: [
        // Developer preview mode toggle buttons
        PopupMenuButton<String>(
          icon: const Icon(Icons.tune_rounded,
              color: AppColors.textSecondary, size: 20),
          tooltip: 'Modes de test',
          onSelected: (value) {
            if (value == 'normal') {
              notifier.loadDashboard();
            } else if (value == 'empty') {
              notifier.loadDashboard(forceEmpty: true);
            } else if (value == 'error') {
              notifier.loadDashboard(forceError: true);
            } else if (value == 'offline') {
              notifier.toggleOfflineMode();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'normal', child: Text('Mode Normal')),
            const PopupMenuItem(
                value: 'empty', child: Text('Mode Premier Suivi (Vide)')),
            const PopupMenuItem(
                value: 'error', child: Text('Mode Erreur de Connexion')),
            PopupMenuItem(
              value: 'offline',
              child: Text(dashboardState.isOffline
                  ? 'Désactiver Mode Hors Connexion'
                  : 'Activer Mode Hors Connexion'),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(patientDashboardProvider);
    final notifier = ref.read(patientDashboardProvider.notifier);

    return PatientAppShell(
      currentIndex: 0,
      appBar: _buildAppBar(dashboardState),
      child: SafeArea(child: _buildBody(dashboardState, notifier)),
    );
  }

  Widget _buildBody(
      PatientDashboardState state, PatientDashboardNotifier notifier) {
    // 1. Loading State
    if (state.isLoading) {
      return const DashboardSkeleton();
    }

    // 2. Error State
    if (state.errorMessage != null) {
      return AppErrorState(
        title: 'Impossible de charger votre suivi',
        message: state.errorMessage!,
        retryLabel: 'Réessayer',
        onRetry: () => notifier.loadDashboard(),
      );
    }

    // 3. Empty State (New patient with no data yet)
    if (state.isEmpty || state.data == null) {
      return AppEmptyState(
        title: 'Votre suivi commence ici',
        message:
            'Complétez votre premier suivi respiratoire pour commencer le suivi télé-médical.',
        icon: Icons.medical_services_outlined,
        actionLabel: 'Commencer mon premier suivi',
        onActionPressed: () => context.push('/patient/monitoring'),
      );
    }

    final data = state.data!;

    // 4. Main Dashboard Data Content with Staggered Entrance Animations
    return RefreshIndicator(
      onRefresh: () => notifier.loadDashboard(),
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        children: [
          // Header (Greeting + Date + Offline banner)
          AppFadeAnimation(
            duration: const Duration(milliseconds: 300),
            child: DashboardHeader(isOffline: state.isOffline),
          ),
          const SizedBox(height: AppSpacing.lg),

          // 1. Health Status Card
          AppSlideAnimation(
            duration: const Duration(milliseconds: 350),
            delay: const Duration(milliseconds: 50),
            direction: SlideDirection.up,
            child: PatientHealthStatusCard(
              data: data,
              onTap: () => context.push('/patient/monitoring'),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // 2. Daily Monitoring Card ⭐ (Most Prominent Action)
          AppSlideAnimation(
            duration: const Duration(milliseconds: 350),
            delay: const Duration(milliseconds: 100),
            direction: SlideDirection.up,
            child: DailyMonitoringCard(
              data: data,
              onStartQuestionnaire: () => context.push('/patient/monitoring'),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // 3. Medication Card
          AppSlideAnimation(
            duration: const Duration(milliseconds: 350),
            delay: const Duration(milliseconds: 150),
            direction: SlideDirection.up,
            child: MedicationCard(
              data: data,
              onViewTreatment: () => context.push('/patient/treatment'),
              onConfirmMedication: () => notifier.confirmMedication(),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // 4. Rehabilitation Card
          AppSlideAnimation(
            duration: const Duration(milliseconds: 350),
            delay: const Duration(milliseconds: 200),
            direction: SlideDirection.up,
            child: RehabilitationCard(
              data: data,
              onStartRehab: () => context.push('/patient/rehabilitation'),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // 5. Care Team Card
          AppSlideAnimation(
            duration: const Duration(milliseconds: 350),
            delay: const Duration(milliseconds: 250),
            direction: SlideDirection.up,
            child: CareTeamCard(
              data: data,
              onViewCareTeam: () => context.push('/patient/care-team'),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}
