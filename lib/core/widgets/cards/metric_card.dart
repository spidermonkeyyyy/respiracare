import 'package:flutter/material.dart';
import 'package:respiracare/app/theme/colors.dart';
import 'package:respiracare/app/theme/spacing.dart';
import 'package:respiracare/app/theme/typography.dart';
import 'app_card.dart';

class MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final String? trend;
  final bool? isTrendPositive;
  final IconData? icon;
  final Color? iconColor;
  final VoidCallback? onTap;

  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.trend,
    this.isTrendPositive,
    this.icon,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppTypography.secondaryText,
              ),
              if (icon != null)
                Icon(
                  icon,
                  size: 20.0,
                  color: iconColor ?? AppColors.primary,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: AppTypography.displayLarge,
              ),
              if (unit != null) ...[
                const SizedBox(width: AppSpacing.xs),
                Text(
                  unit!,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
          if (trend != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Icon(
                  isTrendPositive == true
                      ? Icons.arrow_upward_rounded
                      : isTrendPositive == false
                          ? Icons.arrow_downward_rounded
                          : Icons.remove_rounded,
                  size: 14.0,
                  color: _getTrendColor(),
                ),
                const SizedBox(width: 2.0),
                Text(
                  trend!,
                  style: AppTypography.labelMedium.copyWith(
                    color: _getTrendColor(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _getTrendColor() {
    if (isTrendPositive == true) {
      return AppColors.success;
    } else if (isTrendPositive == false) {
      return AppColors.warning;
    }
    return AppColors.textMuted;
  }
}
