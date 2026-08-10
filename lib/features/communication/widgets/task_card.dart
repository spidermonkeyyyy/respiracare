import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/colors.dart';
import '../../../../app/theme/radius.dart';
import '../../../../app/theme/spacing.dart';
import '../../../../app/theme/typography.dart';
import '../../../../core/utils/animations/app_animations.dart';
import '../../../../core/utils/date/app_date_format.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../models/communication_task.dart';

/// A patient-facing task (step 4.10M / 4.10L).
///
/// Tasks live under "À faire" and link directly to the existing workflow the
/// nurse requested — the patient never has to dig through messages to find
/// what to do. Tapping opens [actionRoute].
class TaskCard extends StatelessWidget {
  final CommunicationTask task;
  final VoidCallback? onComplete;

  const TaskCard({
    super.key,
    required this.task,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final open = task.status.isOpen;

    return AppScaleAnimation(
      duration: const Duration(milliseconds: 200),
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        borderColor:
            open ? AppColors.primary.withValues(alpha: 0.3) : AppColors.border,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  open
                      ? Icons.radio_button_unchecked_rounded
                      : Icons.task_alt_rounded,
                  color: open ? AppColors.primary : AppColors.success,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    task.title,
                    style: AppTypography.labelMedium
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                if (open)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 2.0,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      'À faire',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(task.description, style: AppTypography.bodyMedium),
            if (task.dueDate != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Échéance: ${AppDateFormat.date(task.dueDate!)}',
                style: AppTypography.labelMedium
                    .copyWith(color: AppColors.textMuted),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: open ? 'Commencer' : 'Ouvrir',
                    onPressed: () => context.push(task.actionRoute),
                    icon: Icons.arrow_forward_rounded,
                  ),
                ),
                if (open && onComplete != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  AppButton(
                    text: 'Terminer',
                    onPressed: onComplete,
                    variant: AppButtonVariant.outlined,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
