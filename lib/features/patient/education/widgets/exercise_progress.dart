import 'package:flutter/material.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/radius.dart';
import '../../../../app/theme/spacing.dart';
import '../../../../app/theme/typography.dart';
import '../../../../core/utils/animations/app_animations.dart';
import '../../../../core/widgets/cards/app_card.dart';

/// Weekly progress calendar for rehabilitation
class ExerciseProgress extends StatelessWidget {
  final int completedSessions;
  final int targetSessions;
  final List<bool> weeklyCompletion; // 7 days, true = completed
  final int? index; // For staggered animation

  const ExerciseProgress({
    super.key,
    required this.completedSessions,
    required this.targetSessions,
    required this.weeklyCompletion,
    this.index,
  });

  @override
  Widget build(BuildContext context) {
    final days = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

    return AppSlideAnimation(
      delay:
          index != null ? Duration(milliseconds: 100 * index!) : Duration.zero,
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cette semaine',
                  style: AppTypography.titleLarge.copyWith(fontSize: 16.0),
                ),
                Text(
                  '$completedSessions séances sur $targetSessions prévues',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: LinearProgressIndicator(
                value: targetSessions > 0
                    ? (completedSessions / targetSessions).clamp(0.0, 1.0)
                    : 0.0,
                minHeight: 8.0,
                backgroundColor: AppColors.surfaceVariant,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // Day indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (i) {
                final isCompleted =
                    i < weeklyCompletion.length && weeklyCompletion[i];
                final isToday = _isToday(i);

                return AppScaleAnimation(
                  delay: Duration(milliseconds: 50 * i),
                  child: Column(
                    children: [
                      Text(
                        days[i],
                        style: AppTypography.labelMedium.copyWith(
                          color: isToday
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontWeight:
                              isToday ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Container(
                        width: 32.0,
                        height: 32.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _getDayColor(isCompleted, isToday),
                          border: isToday
                              ? Border.all(color: AppColors.primary, width: 2.0)
                              : null,
                        ),
                        child: Center(
                          child: isCompleted
                              ? Icon(
                                  Icons.check_rounded,
                                  color: AppColors.surface,
                                  size: 18.0,
                                )
                              : null,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  bool _isToday(int dayIndex) {
    final now = DateTime.now();
    // dayIndex 0 = Monday, 6 = Sunday
    // DateTime.weekday: 1 = Monday, 7 = Sunday
    final todayWeekday = now.weekday - 1; // 0-6
    return dayIndex == todayWeekday;
  }

  Color _getDayColor(bool isCompleted, bool isToday) {
    if (isCompleted) return AppColors.success;
    if (isToday) return AppColors.primary.withValues(alpha: 0.1);
    return AppColors.surfaceVariant;
  }
}
