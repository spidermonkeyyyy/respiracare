import 'package:flutter/material.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/radius.dart';
import '../../../../app/theme/spacing.dart';
import '../../../../app/theme/typography.dart';
import '../../../../core/utils/animations/app_animations.dart';
import '../../../../core/widgets/cards/app_card.dart';

/// Reusable card for education hub sections
class EducationCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;
  final String? actionLabel;
  final int? index; // For staggered animation

  const EducationCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    this.onTap,
    this.actionLabel,
    this.index,
  });

  @override
  Widget build(BuildContext context) {
    final animationDelay =
        index != null ? Duration(milliseconds: 100 * index!) : Duration.zero;

    return AppSlideAnimation(
      delay: animationDelay,
      direction: SlideDirection.up,
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.medium),
              ),
              child: Icon(
                icon,
                size: 28.0,
                color: iconColor,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.titleLarge.copyWith(fontSize: 16.0),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (actionLabel != null) ...[
              const SizedBox(width: AppSpacing.sm),
              Text(
                actionLabel!,
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
            ],
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textMuted,
              size: 24.0,
            ),
          ],
        ),
      ),
    );
  }
}
