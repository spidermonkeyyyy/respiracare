import 'package:flutter/material.dart';

import '../../../../app/theme/colors.dart';
import '../../../../app/theme/spacing.dart';
import '../../../../app/theme/typography.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../models/monitoring_rule.dart';
import 'alert_priority_badge.dart';

/// Plain-language preview of a rule, separating *what it watches* from *how
/// urgent the resulting review is*.
///
/// This is the bridge between the builder form and the nurse's mental model:
/// she reads "Si SpO₂ ... ET Dyspnée ..." and "Priorité élevée" without
/// touching config syntax.
class RuleSummary extends StatelessWidget {
  final MonitoringRule rule;

  const RuleSummary({super.key, required this.rule});

  @override
  Widget build(BuildContext context) {
    final group = rule.conditionGroup;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      borderColor: AppColors.primary.withValues(alpha: 0.25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_outlined,
                  color: AppColors.primary, size: 18.0),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Résumé de la règle',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Si ${group.mode.sentence.toLowerCase()}:',
            style: AppTypography.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          if (group.conditions.isEmpty)
            Text(
              'Aucune condition configurée.',
              style:
                  AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
            )
          else
            for (final condition in group.conditions)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('•  ', style: AppTypography.bodyMedium),
                    Expanded(
                      child: Text(condition.displayText,
                          style: AppTypography.bodyMedium),
                    ),
                  ],
                ),
              ),
          const SizedBox(height: AppSpacing.sm),
          const Divider(height: 1.0, color: AppColors.border),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const Text('Action: ', style: AppTypography.labelMedium),
              Text(rule.action.label, style: AppTypography.labelMedium),
              const SizedBox(width: AppSpacing.md),
              AlertPriorityBadge(priority: rule.priority),
            ],
          ),
        ],
      ),
    );
  }
}
