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
import '../models/exercise.dart';
import '../providers/rehabilitation_provider.dart';

/// Exercise detail screen with video placeholder and instructions
class ExerciseDetailScreen extends ConsumerStatefulWidget {
  final String exerciseId;

  const ExerciseDetailScreen({
    super.key,
    required this.exerciseId,
  });

  @override
  ConsumerState<ExerciseDetailScreen> createState() =>
      _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends ConsumerState<ExerciseDetailScreen> {
  Exercise? _exercise;

  @override
  void initState() {
    super.initState();
    _loadExercise();
  }

  void _loadExercise() {
    final state = ref.read(rehabilitationProvider);
    if (state.program != null) {
      try {
        _exercise = state.program!.exercises
            .firstWhere((e) => e.id == widget.exerciseId);
        setState(() {});
      } catch (_) {
        // Exercise not found
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_exercise == null) {
      return _buildNotFound();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: _exercise!.name,
        showBackButton: true,
        onBack: () => context.pop(),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            // Duration header
            AppFadeAnimation(
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                      ),
                      child: const Icon(
                        Icons.access_time_rounded,
                        size: 28.0,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Durée estimée',
                            style: AppTypography.labelMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            _exercise!.formattedDuration,
                            style: AppTypography.headlineLarge.copyWith(
                              fontSize: 28.0,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Video placeholder
            AppSlideAnimation(
              delay: const Duration(milliseconds: 100),
              child: _buildVideoPlaceholder(),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Start button
            AppSlideAnimation(
              delay: const Duration(milliseconds: 150),
              child: AppButton(
                text: 'Commencer la séance',
                icon: Icons.play_arrow_rounded,
                fullWidth: true,
                onPressed: () => context.push(
                  '/patient/education/rehabilitation/session/${_exercise!.id}',
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Objective
            AppSlideAnimation(
              delay: const Duration(milliseconds: 200),
              child: AppCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.1),
                            borderRadius:
                                BorderRadius.circular(AppRadius.small),
                          ),
                          child: const Icon(
                            Icons.flag_rounded,
                            size: 20.0,
                            color: AppColors.secondary,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'Objectif',
                          style:
                              AppTypography.titleLarge.copyWith(fontSize: 16.0),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const Text(
                      'Suivre l\'exercice présenté dans votre programme de rééducation respiratoire.',
                      style: AppTypography.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Instructions
            AppSlideAnimation(
              delay: const Duration(milliseconds: 250),
              child: AppCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.info.withValues(alpha: 0.1),
                            borderRadius:
                                BorderRadius.circular(AppRadius.small),
                          ),
                          child: const Icon(
                            Icons.description_rounded,
                            size: 20.0,
                            color: AppColors.info,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'Instructions',
                          style:
                              AppTypography.titleLarge.copyWith(fontSize: 16.0),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      _exercise!.instructions,
                      style: AppTypography.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Placeholder disclaimer
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(AppRadius.small),
                        border: Border.all(
                          color: AppColors.warning.withValues(alpha: 0.3),
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            size: 18.0,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              'Ces consignes sont des placeholders. Les instructions validées par votre équipe soignante remplaceront ce contenu.',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.warning,
                                fontSize: 13.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlaceholder() {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video thumbnail placeholder
          Container(
            height: 200.0,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppRadius.medium),
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Play button
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    size: 48.0,
                    color: AppColors.surface,
                  ),
                ),
                // Placeholder label
                Positioned(
                  bottom: AppSpacing.md,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      'Vidéo placeholder',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.surface,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Video info
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.small),
                      ),
                      child: const Icon(
                        Icons.videocam_rounded,
                        size: 16.0,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Vidéo d\'exercice guidé',
                      style: AppTypography.titleLarge.copyWith(fontSize: 16.0),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'La vidéo de démonstration sera fournie par votre équipe de rééducation.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotFound() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Exercice'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: const SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.fitness_center_outlined,
                    size: 64, color: AppColors.textMuted),
                SizedBox(height: AppSpacing.md),
                Text('Exercice non trouvé', style: AppTypography.headlineLarge),
                SizedBox(height: AppSpacing.sm),
                Text(
                  'Cet exercice n\'existe pas dans votre programme.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
