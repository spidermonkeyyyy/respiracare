import 'package:flutter/material.dart';

import '../../../../app/theme/radius.dart';
import '../../../../app/theme/spacing.dart';
import '../../../../app/theme/typography.dart';
import '../models/alert_status.dart';
import 'alert_visuals.dart';

/// Lifecycle indicator combining colour, icon and text.
class AlertStatusBadge extends StatelessWidget {
  final AlertStatus status;
  final bool showLabel;

  const AlertStatusBadge({
    super.key,
    required this.status,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = AlertVisuals.statusColor(status);

    return Semantics(
      label: 'État: ${status.label}',
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: showLabel ? AppSpacing.sm : AppSpacing.xs,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: color.withValues(alpha: 0.24)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(AlertVisuals.statusIcon(status), size: 14.0, color: color),
            if (showLabel) ...[
              const SizedBox(width: AppSpacing.xs),
              Text(
                status.label,
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
