import 'package:flutter/material.dart';

import '../../../../app/theme/colors.dart';
import '../../../../app/theme/spacing.dart';
import '../../../../app/theme/typography.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../models/monitoring_rule.dart';
import 'alert_priority_badge.dart';

/// A surveillance rule row in the configuration list.
///
/// Kept to the essentials: name, status toggle, the headline of what it does,
/// and how urgent resulting reviews are. The condition detail is one tap away.
class RuleCard extends StatelessWidget {
  final MonitoringRule rule;
  final bool isPending;
  final VoidCallback? onTap;
  final VoidCallback? onToggle;
  final ValueChanged<String>? onError;

  const RuleCard({
    super.key,
    required this.rule,
    this.isPending = false,
    this.onTap,
    this.onToggle,
    this.onError,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      borderColor: rule.enabled ? AppColors.border : AppColors.surfaceVariant,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        rule.name,
                        style:
                            AppTypography.titleLarge.copyWith(fontSize: 16.0),
                      ),
                    ),
                    AlertPriorityBadge(
                        priority: rule.priority, showLabel: false),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  rule.description,
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  rule.conditionGroup.summary.isEmpty
                      ? 'Aucune condition configurée'
                      : rule.conditionGroup.summary,
                  style: AppTypography.labelMedium
                      .copyWith(color: AppColors.textPrimary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _StatusToggle(
            enabled: rule.enabled,
            pending: isPending,
            onToggle: onToggle,
          ),
        ],
      ),
    );
  }
}

class _StatusToggle extends StatelessWidget {
  final bool enabled;
  final bool pending;
  final VoidCallback? onToggle;

  const _StatusToggle({
    required this.enabled,
    required this.pending,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Switch(
          value: enabled,
          onChanged: pending ? null : (_) => onToggle?.call(),
          activeThumbColor: AppColors.primary,
        ),
        Text(
          enabled ? 'Active' : 'Inactive',
          style: AppTypography.labelMedium.copyWith(
            color: enabled ? AppColors.success : AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}
