import 'package:flutter/material.dart';

import '../../../../app/theme/colors.dart';
import '../../../../app/theme/radius.dart';
import '../../../../app/theme/spacing.dart';
import '../../../../app/theme/typography.dart';
import '../../../../core/utils/date/app_date_format.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../models/alert.dart';
import 'alert_priority_badge.dart';
import 'alert_status_badge.dart';
import 'alert_visuals.dart';

/// Single alert row in the alert centre.
///
/// Answers the five triage questions in one glance (step 4.9B): who, what,
/// how important, how recent, what next. It deliberately shows a couple of
/// supporting values and stops there — an alert card is a trigger for review,
/// not a patient chart.
class AlertCard extends StatelessWidget {
  final Alert alert;
  final VoidCallback? onTap;

  /// Number of measurement chips before collapsing into a `+N` chip.
  final int maxMeasurements;

  const AlertCard({
    super.key,
    required this.alert,
    this.onTap,
    this.maxMeasurements = 3,
  });

  @override
  Widget build(BuildContext context) {
    final priorityColor = AlertVisuals.priorityColor(alert.priority);
    final measurements = alert.supportingMeasurements;
    final visible = measurements.take(maxMeasurements).toList();
    final overflow = measurements.length - visible.length;

    return AppCard(
      onTap: onTap,
      borderColor: alert.isOpen
          ? priorityColor.withValues(alpha: 0.35)
          : AppColors.border,
      padding: EdgeInsets.zero,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Priority stripe. Redundant with the badge on purpose: it aids fast
          // scanning without being the only carrier of the information.
          Container(
            width: 4.0,
            decoration: BoxDecoration(
              color: alert.isOpen ? priorityColor : AppColors.border,
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
                              alert.patientName,
                              style: AppTypography.titleLarge
                                  .copyWith(fontSize: 16.0),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (alert.patientSummary.isNotEmpty) ...[
                              const SizedBox(height: 2.0),
                              Text(
                                alert.patientSummary,
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
                      AlertPriorityBadge(priority: alert.priority),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    alert.reason,
                    style: AppTypography.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (visible.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        for (final measurement in visible)
                          _MeasurementChip(
                            text: '${measurement.label} ${measurement.value}',
                          ),
                        if (overflow > 0) _MeasurementChip(text: '+$overflow'),
                      ],
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 14.0,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        AppDateFormat.relative(alert.createdAt),
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Flexible(child: AlertStatusBadge(status: alert.status)),
                    ],
                  ),
                  if (onTap != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    AppButton(
                      text: 'Examiner',
                      onPressed: onTap,
                      variant: alert.isOpen
                          ? AppButtonVariant.primary
                          : AppButtonVariant.outlined,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MeasurementChip extends StatelessWidget {
  final String text;

  const _MeasurementChip({required this.text});

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
