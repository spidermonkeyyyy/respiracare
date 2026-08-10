import 'package:flutter/material.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/radius.dart';
import '../../../../app/theme/spacing.dart';
import '../../../../app/theme/typography.dart';
import '../../../../core/utils/animations/app_animations.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../models/educational_content.dart';

/// Card for displaying educational content in the library
class EducationalContentCard extends StatelessWidget {
  final EducationalContent content;
  final VoidCallback? onTap;
  final int? index; // For staggered animation

  const EducationalContentCard({
    super.key,
    required this.content,
    this.onTap,
    this.index,
  });

  @override
  Widget build(BuildContext context) {
    return AppSlideAnimation(
      delay:
          index != null ? Duration(milliseconds: 80 * index!) : Duration.zero,
      direction: SlideDirection.up,
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            // Category icon
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: _getCategoryColor().withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.medium),
              ),
              child: Icon(
                _getCategoryIcon(),
                size: 24.0,
                color: _getCategoryColor(),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Content info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          content.title,
                          style:
                              AppTypography.titleLarge.copyWith(fontSize: 16.0),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (content.isPlaceholder) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                            vertical: 2.0,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Text(
                            'BROUILLON',
                            style: AppTypography.labelMedium.copyWith(
                              color: AppColors.warning,
                              fontWeight: FontWeight.w600,
                              fontSize: 9.0,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    content.summary,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    EducationalCategory.getLabel(content.category),
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // Chevron
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textMuted,
              size: 24.0,
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor() {
    switch (content.category) {
      case 'sevrage':
        return AppColors.accent;
      case 'rehabilitation':
        return AppColors.primary;
      case 'inhalation':
        return AppColors.secondary;
      default:
        return AppColors.info;
    }
  }

  IconData _getCategoryIcon() {
    switch (content.category) {
      case 'sevrage':
        return Icons.smoke_free_rounded;
      case 'rehabilitation':
        return Icons.fitness_center_rounded;
      case 'inhalation':
        return Icons.air_rounded;
      default:
        return Icons.article_rounded;
    }
  }
}
