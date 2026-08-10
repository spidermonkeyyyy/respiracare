import 'package:flutter/material.dart';
import 'package:respiracare/app/theme/colors.dart';
import 'package:respiracare/app/theme/radius.dart';
import 'package:respiracare/app/theme/spacing.dart';
import 'package:respiracare/app/theme/typography.dart';
import 'app_card.dart';

enum HealthStatusVariant {
  normal,
  attention,
  information,
}

class HealthStatusCard extends StatelessWidget {
  final String title;
  final String value;
  final String statusText;
  final String? subtitle;
  final HealthStatusVariant variant;
  final VoidCallback? onTap;

  const HealthStatusCard({
    super.key,
    required this.title,
    required this.value,
    required this.statusText,
    this.subtitle,
    this.variant = HealthStatusVariant.normal,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusConfig = _getStatusConfig();

    return AppCard(
      onTap: onTap,
      borderColor: statusConfig.color.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                style: AppTypography.secondaryText,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm + 2,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: statusConfig.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      statusConfig.icon,
                      size: 14.0,
                      color: statusConfig.color,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      statusText,
                      style: AppTypography.labelMedium.copyWith(
                        color: statusConfig.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTypography.displayLarge.copyWith(
              fontSize: 28.0,
              color: AppColors.textPrimary,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle!,
              style: AppTypography.labelMedium,
            ),
          ],
        ],
      ),
    );
  }

  _StatusConfig _getStatusConfig() {
    switch (variant) {
      case HealthStatusVariant.normal:
        return const _StatusConfig(
          color: AppColors.success,
          icon: Icons.check_circle_rounded,
        );
      case HealthStatusVariant.attention:
        return const _StatusConfig(
          color: AppColors.warning,
          icon: Icons.warning_amber_rounded,
        );
      case HealthStatusVariant.information:
        return const _StatusConfig(
          color: AppColors.info,
          icon: Icons.info_outline_rounded,
        );
    }
  }
}

class _StatusConfig {
  final Color color;
  final IconData icon;

  const _StatusConfig({required this.color, required this.icon});
}
