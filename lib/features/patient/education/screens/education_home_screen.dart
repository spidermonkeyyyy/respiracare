import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/radius.dart';
import '../../../../app/theme/spacing.dart';
import '../../../../app/theme/typography.dart';
import '../../../../core/utils/animations/app_animations.dart';
import '../../../../core/widgets/feedback/app_error_state.dart';
import '../providers/rehabilitation_provider.dart';
import '../providers/smoking_cessation_provider.dart';
import '../widgets/education_card.dart';

/// Education hub screen - main entry point for all educational features
class EducationHomeScreen extends ConsumerStatefulWidget {
  const EducationHomeScreen({super.key});

  @override
  ConsumerState<EducationHomeScreen> createState() =>
      _EducationHomeScreenState();
}

class _EducationHomeScreenState extends ConsumerState<EducationHomeScreen> {
  @override
  Widget build(BuildContext context) {
    final rehabState = ref.watch(rehabilitationProvider);
    final smokingState = ref.watch(smokingCessationProvider);

    final isLoading = rehabState.isLoading || smokingState.isLoading;
    final errorMessage = rehabState.errorMessage ?? smokingState.errorMessage;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Éducation'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: _buildBody(isLoading, errorMessage, rehabState, smokingState),
      ),
    );
  }

  Widget _buildBody(
    bool isLoading,
    String? errorMessage,
    RehabilitationState rehabState,
    SmokingCessationState smokingState,
  ) {
    // Loading State
    if (isLoading) {
      return const _EducationSkeleton();
    }

    // Error State
    if (errorMessage != null) {
      return AppErrorState(
        title: 'Impossible de charger l\'espace éducation',
        message: errorMessage,
        retryLabel: 'Réessayer',
        onRetry: () {
          ref.read(rehabilitationProvider.notifier).loadProgram();
          ref.read(smokingCessationProvider.notifier).loadData();
        },
      );
    }

    // Main Content
    return RefreshIndicator(
      onRefresh: () async {
        ref.read(rehabilitationProvider.notifier).loadProgram();
        ref.read(smokingCessationProvider.notifier).loadData();
      },
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        children: [
          // Header
          AppFadeAnimation(
            duration: const Duration(milliseconds: 300),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Éducation',
                  style: AppTypography.displayLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Des ressources pour vous accompagner au quotidien',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Rééducation respiratoire
          AppSlideAnimation(
            delay: const Duration(milliseconds: 100),
            child: EducationCard(
              title: 'Rééducation respiratoire',
              subtitle: 'Exercices et vidéos adaptés à votre programme',
              icon: Icons.fitness_center_rounded,
              iconColor: AppColors.primary,
              actionLabel: 'Consulter',
              onTap: () => context.push('/patient/education/rehabilitation'),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Sevrage tabagique
          AppSlideAnimation(
            delay: const Duration(milliseconds: 150),
            child: EducationCard(
              title: 'Sevrage tabagique',
              subtitle: _getSmokingSubtitle(smokingState),
              icon: Icons.smoke_free_rounded,
              iconColor: AppColors.accent,
              actionLabel:
                  smokingState.entries.isEmpty ? 'Commencer' : 'Mon carnet',
              onTap: () => context.push('/patient/education/smoking'),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Tutoriels éducatifs
          AppSlideAnimation(
            delay: const Duration(milliseconds: 200),
            child: EducationCard(
              title: 'Tutoriels éducatifs',
              subtitle:
                  'Technique d\'inhalation, guides BPCO, conseils quotidiens',
              icon: Icons.school_outlined,
              iconColor: AppColors.secondary,
              actionLabel: 'Voir les tutoriels',
              onTap: () => context.push('/patient/education/resources'),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  String _getSmokingSubtitle(SmokingCessationState state) {
    if (state.entries.isEmpty) {
      return 'Suivez votre progression vers l\'arrêt du tabac';
    }
    return 'Jours suivis: ${state.trackedDays} • Objectif: ${state.currentGoal}';
  }
}

/// Skeleton loader for education home screen
class _EducationSkeleton extends StatelessWidget {
  const _EducationSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      children: [
        // Header skeleton
        Container(
          height: 32.0,
          width: 120.0,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppRadius.small),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          height: 20.0,
          width: 200.0,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppRadius.small),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        // Card skeletons
        ...List.generate(3, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Container(
              height: 88.0,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppRadius.medium),
              ),
            ),
          );
        }),
      ],
    );
  }
}
