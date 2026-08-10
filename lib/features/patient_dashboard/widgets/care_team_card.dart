import 'package:flutter/material.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/radius.dart';
import '../../../app/theme/spacing.dart';
import '../../../app/theme/typography.dart';
import '../../../core/widgets/cards/app_card.dart';
import '../models/patient_dashboard_data.dart';

class CareTeamCard extends StatelessWidget {
  final PatientDashboardData data;
  final VoidCallback onViewCareTeam;

  const CareTeamCard({
    super.key,
    required this.data,
    required this.onViewCareTeam,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onViewCareTeam,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
                child: const Icon(
                  Icons.medical_services_outlined,
                  size: 20.0,
                  color: AppColors.info,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Votre équipe soignante',
                      style: AppTypography.titleLarge.copyWith(fontSize: 16.0),
                    ),
                    Text(
                      'Dernière revue : ${data.lastCareTeamReview}',
                      style: AppTypography.labelMedium,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppRadius.small),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18.0,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  child: Text(
                    data.nurseName.isNotEmpty
                        ? data.nurseName[0].toUpperCase()
                        : 'N',
                    style: AppTypography.titleLarge.copyWith(
                      fontSize: 14.0,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Infirmière référente : ${data.nurseName}\nVos données de télésurveillance sont régulièrement vérifiées.',
                    style: AppTypography.secondaryText.copyWith(
                      fontSize: 13.0,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
