import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/radius.dart';
import '../../../../app/theme/spacing.dart';
import '../../../../app/theme/typography.dart';
import '../../../../core/utils/animations/app_animations.dart';
import '../../../../app/widgets/app_header.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../core/widgets/feedback/app_empty_state.dart';
import '../../../../core/widgets/feedback/app_error_state.dart';
import '../providers/rehabilitation_provider.dart';
import '../widgets/exercise_card.dart';
import '../widgets/exercise_progress.dart';
import '../models/exercise.dart';

/// Main rehabilitation screen showing program overview and today's exercise
class RehabilitationScreen extends ConsumerStatefulWidget {
  const RehabilitationScreen({super.key});

  @override
  ConsumerState<RehabilitationScreen> createState() =>
      _RehabilitationScreenState();
}

class _RehabilitationScreenState extends ConsumerState<RehabilitationScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(rehabilitationProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: 'Rééducation respiratoire',
        showBackButton: true,
        onBack: () => context.pop(),
      ),
      body: SafeArea(
        child: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(RehabilitationState state) {
    // Loading State
    if (state.isLoading) {
      return const _RehabilitationSkeleton();
    }

    // Error State
    if (state.errorMessage != null) {
      return AppErrorState(
        title: 'Impossible de charger votre programme',
        message: state.errorMessage!,
        retryLabel: 'Réessayer',
        onRetry: () => ref.read(rehabilitationProvider.notifier).loadProgram(),
      );
    }

    // Empty State (no program)
    if (state.program == null) {
      return AppEmptyState(
        title: 'Aucun programme assigné',
        message:
            'Votre équipe soignante n\'a pas encore défini de programme de rééducation pour vous.',
        icon: Icons.fitness_center_outlined,
        actionLabel: 'Actualiser',
        onActionPressed: () =>
            ref.read(rehabilitationProvider.notifier).loadProgram(),
      );
    }

    final program = state.program!;
    final todaysExercise = state.todaysExercise;
    final exercises = program.exercises;

    // Build weekly completion array (mock: first N days completed)
    final weeklyCompletion =
        List.generate(7, (i) => i < state.weeklySessionsCompleted);

    return RefreshIndicator(
      onRefresh: () => ref.read(rehabilitationProvider.notifier).loadProgram(),
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
                const Text(
                  'Votre programme',
                  style: AppTypography.headlineLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  program.description,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Today's Exercise Section
          if (todaysExercise != null) ...[
            AppSlideAnimation(
              delay: const Duration(milliseconds: 100),
              child: _buildTodaysExercise(todaysExercise, state),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],

          // Weekly Progress
          AppSlideAnimation(
            delay: const Duration(milliseconds: 150),
            child: ExerciseProgress(
              completedSessions: state.weeklySessionsCompleted,
              targetSessions: state.weeklyTargetSessions,
              weeklyCompletion: weeklyCompletion,
              index: 2,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // All Exercises List
          AppSlideAnimation(
            delay: const Duration(milliseconds: 200),
            child: _buildExercisesList(exercises, todaysExercise, state),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildTodaysExercise(Exercise exercise, RehabilitationState state) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      backgroundColor: AppColors.primary.withValues(alpha: 0.04),
      borderColor: AppColors.primary.withValues(alpha: 0.3),
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
                  size: 24.0,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Aujourd\'hui',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      exercise.name,
                      style: AppTypography.titleLarge.copyWith(fontSize: 18.0),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  exercise.formattedDuration,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.surface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            text: 'Commencer la séance',
            icon: Icons.play_arrow_rounded,
            fullWidth: true,
            onPressed: () => context.push(
              '/patient/education/rehabilitation/exercise/${exercise.id}',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExercisesList(
    List<Exercise> exercises,
    Exercise? todaysExercise,
    RehabilitationState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mon programme',
          style: AppTypography.titleLarge,
        ),
        const SizedBox(height: AppSpacing.md),
        ...exercises.asMap().entries.map((entry) {
          final index = entry.key;
          final exercise = entry.value;
          final isTodays = todaysExercise?.id == exercise.id;
          final isCompleted = _isExerciseCompleted(exercise, state);
          return ExerciseCard(
            exercise: exercise,
            isTodaysExercise: isTodays,
            isCompleted: isCompleted,
            index: index,
            onTap: () => context.push(
              '/patient/education/rehabilitation/exercise/${exercise.id}',
            ),
          );
        }),
      ],
    );
  }

  bool _isExerciseCompleted(Exercise exercise, RehabilitationState state) {
    // Check if exercise was completed today
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    return state.recentSessions.any((session) {
      final sessionDate = DateTime(
        session.completedAt.year,
        session.completedAt.month,
        session.completedAt.day,
      );
      return session.exerciseId == exercise.id && sessionDate == todayDate;
    });
  }
}

/// Skeleton loader for rehabilitation screen
class _RehabilitationSkeleton extends StatelessWidget {
  const _RehabilitationSkeleton();

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
          height: 28.0,
          width: 150.0,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppRadius.small),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          height: 20.0,
          width: 250.0,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppRadius.small),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        // Today's exercise skeleton
        Container(
          height: 140.0,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        // Progress skeleton
        Container(
          height: 120.0,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        // Exercise list skeleton
        ...List.generate(3, (i) {
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
