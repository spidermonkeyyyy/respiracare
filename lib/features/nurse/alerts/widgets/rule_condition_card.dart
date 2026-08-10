import 'package:flutter/material.dart';

import '../../../../app/theme/colors.dart';
import '../../../../app/theme/spacing.dart';
import '../../../../app/theme/typography.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../models/rule_condition.dart';

/// Read-only rendering of a single rule condition.
///
/// Shows exactly what the condition observes and how it compares, so the nurse
/// can sanity-check the rule without reading raw config. The structure is
/// generic — no clinical interpretation is added here.
class RuleConditionCard extends StatelessWidget {
  final RuleCondition condition;
  final VoidCallback? onRemove;

  const RuleConditionCard({
    super.key,
    required this.condition,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final complete = condition.isComplete;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      borderColor: complete
          ? AppColors.border
          : AppColors.warning.withValues(alpha: 0.4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  condition.metricLabel,
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  condition.displayText,
                  style: AppTypography.bodyMedium,
                ),
                if (!complete) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Condition incomplète',
                    style: AppTypography.labelMedium
                        .copyWith(color: AppColors.warning),
                  ),
                ],
              ],
            ),
          ),
          if (onRemove != null)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.danger),
              tooltip: 'Supprimer la condition',
              onPressed: onRemove,
            ),
        ],
      ),
    );
  }
}
