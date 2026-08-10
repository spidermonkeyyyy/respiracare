import 'package:flutter/material.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/radius.dart';
import '../../../../app/theme/spacing.dart';
import '../../../../app/theme/typography.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../models/monitoring_submission.dart';

class RespiratoryTrendCard extends StatelessWidget {
  final List<MonitoringSubmission> submissions;

  const RespiratoryTrendCard({super.key, this.submissions = const []});

  @override
  Widget build(BuildContext context) {
    if (submissions.isEmpty) {
      return AppCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Text('Aucune donnée de suivi disponible.',
            style: AppTypography.bodyMedium
                .copyWith(color: AppColors.textSecondary)),
      );
    }

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tendance respiratoire', style: AppTypography.titleLarge),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _buildMetric(
                  'SpO₂', submissions.first.spo2.toString(), AppColors.primary),
              const SizedBox(width: AppSpacing.md),
              _buildMetric('Dyspnée', submissions.first.dyspneaScore.toString(),
                  AppColors.warning),
              const SizedBox(width: AppSpacing.md),
              _buildMetric(
                  'Toux', submissions.first.coughStatus, AppColors.secondary),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: Column(
              children: submissions.take(5).map((submission) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Row(
                    children: [
                      Expanded(
                          child: Text(_formatDate(submission.submittedAt),
                              style: AppTypography.bodyMedium)),
                      const SizedBox(width: AppSpacing.md),
                      Text('SpO₂ ${submission.spo2}%',
                          style: AppTypography.bodyMedium
                              .copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(width: AppSpacing.sm),
                      Text('mMRC ${submission.dyspneaScore}',
                          style: AppTypography.bodyMedium
                              .copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: AppTypography.labelMedium.copyWith(color: color)),
            const SizedBox(height: AppSpacing.xs),
            Text(value,
                style: AppTypography.titleLarge
                    .copyWith(fontSize: 18.0, color: color)),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month} ${date.hour.toString().padLeft(2, '0')}h${date.minute.toString().padLeft(2, '0')}';
  }
}
