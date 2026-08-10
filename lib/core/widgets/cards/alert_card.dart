import 'package:flutter/material.dart';
import 'package:respiracare/app/theme/colors.dart';
import 'package:respiracare/app/theme/radius.dart';
import 'package:respiracare/app/theme/spacing.dart';
import 'package:respiracare/app/theme/typography.dart';
import '../buttons/app_button.dart';
import 'app_card.dart';

enum AlertCardState {
  newAlert,
  reviewing,
  resolved,
}

class AlertCard extends StatelessWidget {
  final String patientName;
  final String alertReason;
  final String timestamp;
  final AlertCardState state;
  final VoidCallback? onActionPressed;
  final String actionLabel;

  const AlertCard({
    super.key,
    required this.patientName,
    required this.alertReason,
    required this.timestamp,
    this.state = AlertCardState.newAlert,
    this.onActionPressed,
    this.actionLabel = 'Review',
  });

  @override
  Widget build(BuildContext context) {
    final statusConfig = _getStatusConfig();

    return AppCard(
      borderColor: statusConfig.borderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16.0,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Text(
                      patientName.isNotEmpty
                          ? patientName[0].toUpperCase()
                          : 'P',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patientName,
                        style:
                            AppTypography.titleLarge.copyWith(fontSize: 16.0),
                      ),
                      Text(
                        timestamp,
                        style: AppTypography.labelMedium,
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: statusConfig.badgeBg,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      statusConfig.icon,
                      size: 12.0,
                      color: statusConfig.badgeText,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      statusConfig.label,
                      style: AppTypography.labelMedium.copyWith(
                        color: statusConfig.badgeText,
                        fontWeight: FontWeight.w600,
                        fontSize: 11.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            alertReason,
            style: AppTypography.bodyMedium,
          ),
          if (onActionPressed != null) ...[
            const SizedBox(height: AppSpacing.md),
            AppButton(
              text: actionLabel,
              onPressed: onActionPressed,
              variant: state == AlertCardState.newAlert
                  ? AppButtonVariant.primary
                  : AppButtonVariant.outlined,
              fullWidth: true,
            ),
          ],
        ],
      ),
    );
  }

  _AlertConfig _getStatusConfig() {
    switch (state) {
      case AlertCardState.newAlert:
        return const _AlertConfig(
          label: 'NEW ALERT',
          borderColor: AppColors.danger,
          badgeBg: Color(0xFFFEE2E2), // Soft red background
          badgeText: AppColors.danger,
          icon: Icons.error_outline_rounded,
        );
      case AlertCardState.reviewing:
        return const _AlertConfig(
          label: 'IN REVIEW',
          borderColor: AppColors.warning,
          badgeBg: Color(0xFFFEF3C7), // Soft amber background
          badgeText: AppColors.warning,
          icon: Icons.hourglass_top_rounded,
        );
      case AlertCardState.resolved:
        return const _AlertConfig(
          label: 'RESOLVED',
          borderColor: AppColors.border,
          badgeBg: Color(0xFFDCFCE7), // Soft green background
          badgeText: AppColors.success,
          icon: Icons.check_circle_outline_rounded,
        );
    }
  }
}

class _AlertConfig {
  final String label;
  final Color borderColor;
  final Color badgeBg;
  final Color badgeText;
  final IconData icon;

  const _AlertConfig({
    required this.label,
    required this.borderColor,
    required this.badgeBg,
    required this.badgeText,
    required this.icon,
  });
}
