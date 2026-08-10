import 'package:flutter/material.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/radius.dart';
import '../../../../app/theme/spacing.dart';
import '../../../../app/theme/typography.dart';
import '../../../../core/utils/animations/app_animations.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../models/smoking_entry.dart';

/// Card displaying a single smoking entry in the history
class CravingEntryCard extends StatelessWidget {
  final SmokingEntry entry;
  final VoidCallback? onTap;
  final int? index; // For staggered animation

  const CravingEntryCard({
    super.key,
    required this.entry,
    this.onTap,
    this.index,
  });

  @override
  Widget build(BuildContext context) {
    return AppSlideAnimation(
      delay:
          index != null ? Duration(milliseconds: 50 * index!) : Duration.zero,
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Date, time, cigarettes
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.formattedDate,
                        style:
                            AppTypography.titleLarge.copyWith(fontSize: 16.0),
                      ),
                      Text(
                        entry.formattedTime,
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: _getCigaretteColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.smoking_rooms_rounded,
                        size: 16.0,
                        color: _getCigaretteColor(),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '${entry.cigarettesConsumed}',
                        style: AppTypography.titleLarge.copyWith(
                          fontSize: 16.0,
                          color: _getCigaretteColor(),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            // Craving intensity and trigger
            Row(
              children: [
                _buildInfoChip(
                  icon: _getCravingIcon(),
                  label: entry.cravingIntensity.label,
                  color: _getCravingColor(),
                ),
                const SizedBox(width: AppSpacing.sm),
                _buildInfoChip(
                  icon: Icons.label_outline_rounded,
                  label: entry.trigger.label,
                  color: AppColors.info,
                ),
              ],
            ),
            // Personal note
            if (entry.personalNote != null &&
                entry.personalNote!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.note_alt_outlined,
                      size: 16.0,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        '"${entry.personalNote!}"',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.0, color: color),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCigaretteColor() {
    if (entry.cigarettesConsumed == 0) return AppColors.success;
    if (entry.cigarettesConsumed <= 3) return AppColors.warning;
    if (entry.cigarettesConsumed <= 6) return AppColors.accent;
    return AppColors.danger;
  }

  IconData _getCravingIcon() {
    switch (entry.cravingIntensity) {
      case CravingIntensity.low:
        return Icons.sentiment_satisfied_rounded;
      case CravingIntensity.moderate:
        return Icons.sentiment_neutral_rounded;
      case CravingIntensity.high:
        return Icons.sentiment_very_dissatisfied_rounded;
    }
  }

  Color _getCravingColor() {
    switch (entry.cravingIntensity) {
      case CravingIntensity.low:
        return AppColors.success;
      case CravingIntensity.moderate:
        return AppColors.warning;
      case CravingIntensity.high:
        return AppColors.danger;
    }
  }
}
