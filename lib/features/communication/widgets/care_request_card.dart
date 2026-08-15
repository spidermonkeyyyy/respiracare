import 'package:flutter/material.dart';

import '../../../app/theme/colors.dart';
import '../../../app/theme/radius.dart';
import '../../../app/theme/spacing.dart';
import '../../../app/theme/typography.dart';
import '../../../core/utils/date/app_date_format.dart';
import '../../../core/widgets/cards/app_card.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../models/care_request.dart';

/// Shows a nurse-raised care request with its status.
///
/// Connected to existing features: completing it marks the linked patient task
/// done. The nurse's reason text is shown verbatim — never interpreted as a
/// clinical recommendation.
class CareRequestCard extends StatelessWidget {
  final CareRequest request;
  final VoidCallback? onComplete;

  const CareRequestCard({
    super.key,
    required this.request,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final pending = request.status.isPending;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      borderColor:
          pending ? AppColors.primary.withValues(alpha: 0.3) : AppColors.border,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.assignment_outlined,
                  color: AppColors.primary, size: 18.0),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  request.type.label,
                  style: AppTypography.labelMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2.0,
                ),
                decoration: BoxDecoration(
                  color: pending
                      ? AppColors.warning.withValues(alpha: 0.14)
                      : AppColors.success.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  request.status.label,
                  style: AppTypography.labelMedium.copyWith(
                    color: pending ? AppColors.warning : AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(request.reason, style: AppTypography.bodyMedium),
          if (request.requestedData.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              children: request.requestedData
                  .map((key) => Chip(
                        label: Text(_dataLabel(key)),
                        visualDensity: VisualDensity.compact,
                        backgroundColor: AppColors.surfaceVariant,
                      ))
                  .toList(),
            ),
          ],
          if (request.dueDate != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Échéance: ${AppDateFormat.date(request.dueDate!)}',
              style: AppTypography.labelMedium
                  .copyWith(color: AppColors.textMuted),
            ),
          ],
          if (pending && onComplete != null) ...[
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                text: 'Marquer comme complétée',
                onPressed: onComplete,
                variant: AppButtonVariant.outlined,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _dataLabel(String key) {
    switch (key) {
      case 'spo2':
        return 'Saturation';
      case 'dyspnea':
        return 'Dyspnée';
      case 'cough':
        return 'Toux';
      case 'sputum':
        return 'Expectorations';
      default:
        return key;
    }
  }
}
