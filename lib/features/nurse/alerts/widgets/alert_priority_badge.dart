import 'package:flutter/material.dart';

import '../../../../app/theme/radius.dart';
import '../../../../app/theme/spacing.dart';
import '../../../../app/theme/typography.dart';
import '../models/alert_priority.dart';
import 'alert_visuals.dart';

/// Priority indicator combining colour, icon and text.
///
/// Never renders colour alone — see [AlertVisuals] for the rationale.
class AlertPriorityBadge extends StatelessWidget {
  final AlertPriority priority;

  /// When false, only the icon is shown; the text is still exposed to screen
  /// readers via [Semantics].
  final bool showLabel;

  const AlertPriorityBadge({
    super.key,
    required this.priority,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = AlertVisuals.priorityColor(priority);

    return Semantics(
      label: '${priority.label}. ${priority.handlingGuidance}',
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: showLabel ? AppSpacing.sm : AppSpacing.xs,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: color.withValues(alpha: 0.28)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(AlertVisuals.priorityIcon(priority), size: 16.0, color: color),
            if (showLabel) ...[
              const SizedBox(width: AppSpacing.xs),
              Text(
                priority.label,
                style: AppTypography.labelMedium.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
