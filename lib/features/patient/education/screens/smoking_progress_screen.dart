import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/radius.dart';
import '../../../../app/theme/spacing.dart';
import '../../../../app/theme/typography.dart';
import '../../../../core/utils/animations/app_animations.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../core/widgets/feedback/app_empty_state.dart';
import '../../../../core/widgets/feedback/app_error_state.dart';
import '../providers/smoking_cessation_provider.dart';
import '../widgets/craving_entry_card.dart';
import '../widgets/smoking_progress_card.dart';

class SmokingProgressScreen extends ConsumerStatefulWidget {
  const SmokingProgressScreen({super.key});

  @override
  ConsumerState<SmokingProgressScreen> createState() => _SmokingProgressScreenState();
}

class _SmokingProgressScreenState extends ConsumerState<SmokingProgressScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(smokingCessationProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Votre progression'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(SmokingCessationState state) {
    if (state.isLoading) {
      return const _ProgressSkeleton();
    }

    if (state.errorMessage != null) {
      return AppErrorState(
        title: 'Impossible de charger votre progression',
        message: state.errorMessage!,
        retryLabel: 'Réessayer',
        onRetry: () => ref.read(smokingCessationProvider.notifier).loadData(),
      );
    }

    if (state.entries.isEmpty) {
      return AppEmptyState(
        title: 'Aucune donnée de suivi',
        message: 'Ajoutez votre première entrée pour visualiser votre progression.',
        icon: Icons.insights_rounded,
        actionLabel: 'Ajouter une entrée',
        onActionPressed: () => context.push('/patient/education/smoking/entry'),
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
          AppFadeAnimation(
            duration: const Duration(milliseconds: 300),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Votre progression',
                  style: AppTypography.headlineLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${state.trackedDays} jours suivis',
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppSlideAnimation(
            delay: const Duration(milliseconds: 100),
            child: AppCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Suivi quotidien',
                    style: AppTypography.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    child: LinearProgressIndicator(
                      value: state.trackingCompletionRate.clamp(0.0, 1.0),
                      minHeight: 10.0,
                      backgroundColor: AppColors.surfaceVariant,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '${(state.trackingCompletionRate * 100).toInt()}% de jours renseignés',
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: SmokingProgressCard(
                  title: 'Objectif actuel',
                  value: state.currentGoal,
                  subtitle: 'Réduction progressive',
                  icon: Icons.flag_rounded,
                  iconColor: AppColors.secondary,
                  index: 0,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: SmokingProgressCard(
                  title: 'Cette semaine',
                  value: '${state.weeklyCigarettes}',
                  subtitle: 'cigarettes déclarées',
                  icon: Icons.calendar_today_rounded,
                  iconColor: AppColors.accent,
                  index: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            text: 'Ajouter une entrée',
            icon: Icons.edit_rounded,
            fullWidth: true,
            onPressed: () => context.push('/patient/education/smoking/entry'),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Historique récent',
            style: AppTypography.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          ...state.entries.take(5).toList().asMap().entries.map((entry) {
            final index = entry.key;
            final smokingEntry = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: CravingEntryCard(
                entry: smokingEntry,
                index: index,
              ),
            );
          }),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class _ProgressSkeleton extends StatelessWidget {
  const _ProgressSkeleton();

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
          width: 140.0,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppRadius.small),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          height: 20.0,
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
                height: 92.0,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Container(
                height: 92.0,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
