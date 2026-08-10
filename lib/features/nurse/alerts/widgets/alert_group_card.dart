import 'package:flutter/material.dart';

import '../../../../app/theme/colors.dart';
import '../../../../app/theme/radius.dart';
import '../../../../app/theme/spacing.dart';
import '../../../../app/theme/typography.dart';
import '../../../../core/utils/date/app_date_format.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../models/alert_group.dart';
import '../models/alert_priority.dart';
import 'alert_visuals.dart';

/// Groups related open alerts for one patient into a single review row.
///
/// This directly addresses alert fatigue (step 4.9T/4.9U): instead of three
/// separate red rows for one patient, the nurse sees `3 éléments nécessitent
/// une revue` and decides to open the group on her terms. The group inherits
/// the highest member priority, never the average.
class AlertGroupCard extends StatelessWidget {
  final AlertGroup group;
  final VoidCallback? onTap;

  const AlertGroupCard({
    super.key,
    required this.group,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final priorityColor = AlertVisuals.priorityColor(group.priority);

    return AppCard(
      onTap: onTap,
      borderColor: priorityColor.withValues(alpha: 0.35),
      padding: EdgeInsets.zero,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 4.0,
            decoration: BoxDecoration(
              color: priorityColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.medium),
                bottomLeft: Radius.circular(AppRadius.medium),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              group.patientName,
                              style: AppTypography.titleLarge
                                  .copyWith(fontSize: 16.0),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (group.patientSummary.isNotEmpty) ...[
                              const SizedBox(height: 2.0),
                              Text(
                                group.patientSummary,
                                style: AppTypography.labelMedium.copyWith(
                                  color: AppColors.textMuted,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _PriorityPill(
                          color: priorityColor, priority: group.priority),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    group.summaryLabel,
                    style: AppTypography.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: group.concernedMetrics
                        .map((metric) => _MetricChip(text: metric))
                        .toList(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Icon(
                        AlertVisuals.statusIcon(
                          group.alerts
                              .firstWhere(
                                (alert) => alert.isOpen,
                                orElse: () => group.alerts.first,
                              )
                              .status,
                        ),
                        size: 14.0,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        group.isSingle
                            ? AppDateFormat.relative(group.mostRecentAt)
                            : '${group.count} alertes · ${AppDateFormat.shortRelative(group.mostRecentAt)}',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                      const Spacer(),
                      if (group.unreadCount > 0) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 2.0,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.danger.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Text(
                            '${group.unreadCount} non traitée${group.unreadCount > 1 ? 's' : ''}',
                            style: AppTypography.labelMedium.copyWith(
                              color: AppColors.danger,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriorityPill extends StatelessWidget {
  final Color color;
  final AlertPriority priority;

  const _PriorityPill({required this.color, required this.priority});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(AlertVisuals.priorityIcon(priority), size: 14.0, color: color),
          const SizedBox(width: AppSpacing.xs),
          Text(
            priority.label,
            style: AppTypography.labelMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String text;

  const _MetricChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      child: Text(
        text,
        style: AppTypography.labelMedium.copyWith(color: AppColors.textPrimary),
      ),
    );
  }
}
