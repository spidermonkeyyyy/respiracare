import 'package:flutter/material.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/radius.dart';
import '../../../../app/theme/spacing.dart' show AppSpacing;
import '../../../../app/theme/typography.dart';
import '../../../../core/utils/animations/app_animations.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../models/exercise.dart';

/// Card displaying an exercise in the rehabilitation program
class ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final bool isTodaysExercise;
  final bool isCompleted;
  final VoidCallback? onTap;
  final int? index; // For staggered animation

  const ExerciseCard({
    super.key,
    required this.exercise,
    this.isTodaysExercise = false,
    this.isCompleted = false,
    this.onTap,
    this.index,
  });

  @override
  Widget build(BuildContext context) {
    return AppSlideAnimation(
      delay:
          index != null ? Duration(milliseconds: 80 * index!) : Duration.zero,
      direction: SlideDirection.up,
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.all(AppSpacing.md),
        backgroundColor: isTodaysExercise
            ? AppColors.primary.withValues(alpha: 0.04)
            : AppColors.surface,
        borderColor: isTodaysExercise
            ? AppColors.primary.withValues(alpha: 0.3)
            : AppColors.border,
        child: Row(
          children: [
            // Exercise number / status indicator
            Container(
              width: 40.0,
              height: 40.0,
              decoration: BoxDecoration(
                color: _getStatusColor().withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.medium),
                border: Border.all(
                  color: _getStatusColor().withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: isCompleted
                    ? Icon(
                        Icons.check_rounded,
                        color: _getStatusColor(),
                        size: 20.0,
                      )
                    : Text(
                        '${exercise.order}',
                        style: AppTypography.titleLarge.copyWith(
                          color: _getStatusColor(),
                          fontSize: 16.0,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Exercise info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (isTodaysExercise) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                            vertical: 2.0,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Text(
                            'AUJOURD\'HUI',
                            style: AppTypography.labelMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 10.0,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                      ],
                      Expanded(
                        child: Text(
                          exercise.name,
                          style:
                              AppTypography.titleLarge.copyWith(fontSize: 16.0),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    exercise.description,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 14.0,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        exercise.formattedDuration,
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Chevron
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textMuted,
              size: 24.0,
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    if (isCompleted) return AppColors.success;
    if (isTodaysExercise) return AppColors.primary;
    return AppColors.textMuted;
  }
}
