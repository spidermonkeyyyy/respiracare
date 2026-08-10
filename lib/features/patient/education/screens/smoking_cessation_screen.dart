import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/radius.dart';
import '../../../../app/theme/spacing.dart';
import '../../../../app/theme/typography.dart';
import '../../../../core/utils/animations/app_animations.dart';
import '../../../../core/widgets/buttons/app_button.dart'
    show AppButton, AppButtonVariant;
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../core/widgets/feedback/app_error_state.dart';
import '../providers/smoking_cessation_provider.dart';
import '../models/smoking_entry.dart';
import '../widgets/craving_entry_card.dart';
import '../widgets/smoking_progress_card.dart';

/// Smoking cessation dashboard screen
class SmokingCessationScreen extends ConsumerStatefulWidget {
  const SmokingCessationScreen({super.key});

  @override
  ConsumerState<SmokingCessationScreen> createState() =>
      _SmokingCessationScreenState();
}

class _SmokingCessationScreenState
    extends ConsumerState<SmokingCessationScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(smokingCessationProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Sevrage tabagique'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(SmokingCessationState state) {
    // Loading State
    if (state.isLoading) {
      return const _SmokingSkeleton();
    }

    // Error State
    if (state.errorMessage != null) {
      return AppErrorState(
        title: 'Impossible de charger votre carnet',
        message: state.errorMessage!,
        retryLabel: 'Réessayer',
        onRetry: () => ref.read(smokingCessationProvider.notifier).loadData(),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(smokingCessationProvider.notifier).loadData(),
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
                  'Votre objectif',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  state.currentGoal,
                  style: AppTypography.headlineLarge,
                ),
                const SizedBox(height: AppSpacing.md),
                if (state.entries.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                      border: Border.all(
                        color: AppColors.accent.withValues(alpha: 0.2),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          size: 20.0,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'Vous suivez votre sevrage depuis ${state.trackedDays} jours. Continuez ainsi !',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Today's summary
          if (state.todaysEntry != null) ...[
            AppSlideAnimation(
              delay: const Duration(milliseconds: 100),
              child: _buildTodaysSummary(state.todaysEntry!),
            ),
          ] else ...[
            AppSlideAnimation(
              delay: const Duration(milliseconds: 100),
              child: _buildNoEntryToday(),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),

          // Progress cards
          AppSlideAnimation(
            delay: const Duration(milliseconds: 150),
            child: _buildProgressCards(state),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Actions
          AppSlideAnimation(
            delay: const Duration(milliseconds: 200),
            child: _buildActions(state),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Recent entries preview
          if (state.entries.isNotEmpty) ...[
            AppSlideAnimation(
              delay: const Duration(milliseconds: 250),
              child: _buildRecentEntries(state),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ],
      ),
    );
  }

  Widget _buildTodaysSummary(SmokingEntry entry) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      backgroundColor: AppColors.surfaceVariant.withValues(alpha: 0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
                child: const Icon(
                  Icons.today_rounded,
                  size: 20.0,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Aujourd\'hui',
                style: AppTypography.titleLarge.copyWith(fontSize: 16.0),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.smoking_rooms_rounded,
                  label: 'Cigarettes',
                  value: '${entry.cigarettesConsumed}',
                  color: entry.cigarettesConsumed == 0
                      ? AppColors.success
                      : AppColors.warning,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildStatItem(
                  icon: _getCravingIcon(entry.cravingIntensity),
                  label: 'Envie',
                  value: entry.cravingIntensity.label,
                  color: _getCravingColor(entry.cravingIntensity),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.label_outline_rounded,
                  label: 'Déclencheur',
                  value: entry.trigger.label,
                  color: AppColors.info,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoEntryToday() {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
                child: const Icon(
                  Icons.today_rounded,
                  size: 20.0,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Aujourd\'hui',
                style: AppTypography.titleLarge.copyWith(fontSize: 16.0),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Aucune entrée pour aujourd\'huit. Ajoutez votre suivi quotidien.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCards(SmokingCessationState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Votre progression',
          style: AppTypography.titleLarge,
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: SmokingProgressCard(
                title: 'Jours suivis',
                value: '${state.trackedDays}',
                subtitle: 'de suivi quotidien',
                icon: Icons.calendar_today_rounded,
                iconColor: AppColors.primary,
                index: 0,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: SmokingProgressCard(
                title: 'Moyenne / jour',
                value: state.averageDailyCigarettes.toStringAsFixed(1),
                subtitle: 'cigarettes (7j)',
                icon: Icons.trending_down_rounded,
                iconColor: state.averageDailyCigarettes < 5
                    ? AppColors.success
                    : AppColors.warning,
                index: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: SmokingProgressCard(
                title: 'Cette semaine',
                value: '${state.weeklyCigarettes}',
                subtitle: 'cigarettes au total',
                icon: Icons.date_range_rounded,
                iconColor: AppColors.secondary,
                index: 2,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: SmokingProgressCard(
                title: 'Régularité',
                value: '${(state.trackingCompletionRate * 100).toInt()}%',
                subtitle: 'de jours renseignés',
                icon: Icons.check_circle_outline_rounded,
                iconColor: state.trackingCompletionRate >= 0.8
                    ? AppColors.success
                    : AppColors.warning,
                progress: state.trackingCompletionRate,
                index: 3,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActions(SmokingCessationState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions',
          style: AppTypography.titleLarge,
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: AppButton(
                text: state.todaysEntry != null
                    ? 'Modifier l\'entrée'
                    : 'Ajouter une entrée',
                icon: Icons.edit_rounded,
                fullWidth: true,
                onPressed: () =>
                    context.push('/patient/education/smoking/entry'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppButton(
                text: 'Voir ma progression',
                icon: Icons.analytics_rounded,
                variant: AppButtonVariant.outlined,
                fullWidth: true,
                onPressed: () =>
                    context.push('/patient/education/smoking/progress'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentEntries(SmokingCessationState state) {
    final recentEntries = state.entries.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Dernières entrées',
              style: AppTypography.titleLarge,
            ),
            TextButton(
              onPressed: () =>
                  context.push('/patient/education/smoking/progress'),
              child: Text(
                'Voir tout',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ...recentEntries.asMap().entries.map((entry) {
          final index = entry.key;
          final smokingEntry = entry.value;
          return CravingEntryCard(
            entry: smokingEntry,
            index: index,
            onTap: () => context.push('/patient/education/smoking/progress'),
          );
        }),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          child: Icon(icon, size: 20.0, color: color),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTypography.titleLarge.copyWith(
            fontSize: 16.0,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  IconData _getCravingIcon(CravingIntensity intensity) {
    switch (intensity) {
      case CravingIntensity.low:
        return Icons.sentiment_satisfied_rounded;
      case CravingIntensity.moderate:
        return Icons.sentiment_neutral_rounded;
      case CravingIntensity.high:
        return Icons.sentiment_very_dissatisfied_rounded;
    }
  }

  Color _getCravingColor(CravingIntensity intensity) {
    switch (intensity) {
      case CravingIntensity.low:
        return AppColors.success;
      case CravingIntensity.moderate:
        return AppColors.warning;
      case CravingIntensity.high:
        return AppColors.danger;
    }
  }
}

/// Skeleton loader for smoking cessation screen
class _SmokingSkeleton extends StatelessWidget {
  const _SmokingSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      children: [
        Container(
          height: 28.0,
          width: 100.0,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppRadius.small),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          height: 32.0,
          width: 180.0,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppRadius.small),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          height: 120.0,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 100.0,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Container(
                height: 100.0,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 100.0,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Container(
                height: 100.0,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 48.0,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppRadius.button),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Container(
                height: 48.0,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppRadius.button),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
