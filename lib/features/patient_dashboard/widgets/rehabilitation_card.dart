import 'package:flutter/material.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/radius.dart';
import '../../../app/theme/spacing.dart';
import '../../../app/theme/typography.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../core/widgets/cards/app_card.dart';
import '../models/patient_dashboard_data.dart';

class RehabilitationCard extends StatelessWidget {
  final PatientDashboardData data;
  final VoidCallback onStartRehab;

  const RehabilitationCard({
    super.key,
    required this.data,
    required this.onStartRehab,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
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
                      color: AppColors.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.small),
                    ),
                    child: const Icon(
                      Icons.fitness_center_rounded,
                      size: 20.0,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Rééducation respiratoire',
                    style: AppTypography.titleLarge.copyWith(fontSize: 16.0),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  '${data.rehabWeeklySessions} / ${data.rehabTargetSessions} cette semaine',
                  style: AppTypography.labelMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            data.rehabExerciseName,
            style: AppTypography.titleLarge.copyWith(fontSize: 15.0),
          ),
          const SizedBox(height: 2.0),
          Text(
            '${data.rehabDurationMinutes} minutes aujourd\'hui',
            style: AppTypography.secondaryText,
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            text: 'Commencer l\'exercice',
            variant: AppButtonVariant.secondary,
            icon: Icons.play_circle_outline_rounded,
            onPressed: onStartRehab,
            fullWidth: true,
          ),
        ],
      ),
    );
  }
}
