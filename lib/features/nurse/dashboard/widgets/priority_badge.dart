import 'package:flutter/material.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/radius.dart';
import '../../../../app/theme/spacing.dart';
import '../../../../app/theme/typography.dart';
import '../../dashboard/models/monitoring_rule.dart';

class PriorityBadge extends StatelessWidget {
  final PriorityLevel priority;

  const PriorityBadge({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    final details = _detailsFor(priority);
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: details.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: details.color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(details.icon, size: 16.0, color: details.color),
          const SizedBox(width: AppSpacing.xs),
          Text(
            details.label,
            style: AppTypography.labelMedium
                .copyWith(color: details.color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  _PriorityDetails _detailsFor(PriorityLevel priority) {
    switch (priority) {
      case PriorityLevel.high:
        return const _PriorityDetails(
          label: 'Priorité élevée',
          icon: Icons.warning_amber_rounded,
          color: AppColors.danger,
        );
      case PriorityLevel.reviewRequired:
        return const _PriorityDetails(
          label: 'À revoir',
          icon: Icons.remove_red_eye_outlined,
          color: AppColors.warning,
        );
      case PriorityLevel.informational:
        return const _PriorityDetails(
          label: 'Information',
          icon: Icons.info_outline_rounded,
          color: AppColors.info,
        );
    }
  }
}

class _PriorityDetails {
  final String label;
  final IconData icon;
  final Color color;

  const _PriorityDetails(
      {required this.label, required this.icon, required this.color});
}
