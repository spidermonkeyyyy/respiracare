import 'package:flutter/material.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/radius.dart';
import '../../../app/theme/shadows.dart';
import '../../../app/theme/spacing.dart';
import '../../../app/theme/typography.dart';
import '../../../core/utils/animations/app_animations.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../core/widgets/cards/app_card.dart';
import '../models/patient_dashboard_data.dart';

class DailyMonitoringCard extends StatelessWidget {
  final PatientDashboardData data;
  final VoidCallback onStartQuestionnaire;

  const DailyMonitoringCard({
    super.key,
    required this.data,
    required this.onStartQuestionnaire,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCompleted =
        data.questionnaireState == DailyQuestionnaireState.completed;
    final int percentage = (data.questionnaireProgress * 100).toInt();

    return AppCard(
      borderColor: isCompleted
          ? AppColors.success.withValues(alpha: 0.3)
          : AppColors.primary.withValues(alpha: 0.4),
      backgroundColor: isCompleted
          ? AppColors.success.withValues(alpha: 0.02)
          : AppColors.surface,
      shadow: isCompleted ? null : AppShadows.medium,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color:
                          (isCompleted ? AppColors.success : AppColors.primary)
                              .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.small),
                    ),
                    child: Icon(
                      isCompleted
                          ? Icons.check_circle_rounded
                          : Icons.assignment_outlined,
                      size: 22.0,
                      color:
                          isCompleted ? AppColors.success : AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Votre suivi du jour',
                    style: AppTypography.titleLarge.copyWith(fontSize: 18.0),
                  ),
                ],
              ),
              if (isCompleted)
                AppScaleAnimation(
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm + 2,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.verified_rounded,
                          size: 14.0,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'Complété',
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (isCompleted) ...[
            Text(
              'Merci ! Votre questionnaire quotidien a été transmis à votre équipe soignante.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (data.questionnaireCompletedTime != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Dernière mise à jour : ${data.questionnaireCompletedTime}',
                style: AppTypography.labelMedium,
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            AppButton(
              text: 'Voir mes données',
              variant: AppButtonVariant.outlined,
              icon: Icons.bar_chart_rounded,
              onPressed: onStartQuestionnaire,
              fullWidth: true,
            ),
          ] else ...[
            Text(
              'Quelques questions rapides sur votre respiration et vos constantes du jour.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Progression du questionnaire',
                  style: AppTypography.labelMedium,
                ),
                Text(
                  '$percentage%',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: LinearProgressIndicator(
                value: data.questionnaireProgress.clamp(0.0, 1.0),
                minHeight: 8.0,
                backgroundColor: AppColors.surfaceVariant,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              text: data.questionnaireProgress > 0
                  ? 'Reprendre le suivi'
                  : 'Commencer le suivi',
              icon: Icons.play_arrow_rounded,
              onPressed: onStartQuestionnaire,
              fullWidth: true,
            ),
          ],
        ],
      ),
    );
  }
}
