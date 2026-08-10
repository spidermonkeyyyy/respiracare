import 'package:flutter/material.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/radius.dart';
import '../../../app/theme/spacing.dart';
import '../../../app/theme/typography.dart';
import '../models/monitoring_answer.dart';
import '../models/monitoring_question.dart';

class MonitoringSummaryCard extends StatelessWidget {
  final MonitoringQuestion question;
  final MonitoringAnswer? answer;
  final VoidCallback onEdit;

  const MonitoringSummaryCard({
    super.key,
    required this.question,
    required this.answer,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasAnswer = answer != null;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
          color: hasAnswer
              ? AppColors.border
              : AppColors.warning.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question.title,
                  style: AppTypography.secondaryText.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                if (hasAnswer)
                  Text(
                    question.type == QuestionType.numericInput
                        ? '${answer!.displayLabel} ${question.unit ?? ''}'
                        : answer!.displayLabel,
                    style: AppTypography.titleLarge.copyWith(
                      fontSize: 15.0,
                      color: AppColors.textPrimary,
                    ),
                  )
                else
                  Text(
                    'Aucune réponse',
                    style: AppTypography.secondaryText.copyWith(
                      color: AppColors.warning,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, size: 16.0),
            label: const Text('Modifier'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              textStyle: AppTypography.labelMedium
                  .copyWith(fontWeight: FontWeight.w600),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
