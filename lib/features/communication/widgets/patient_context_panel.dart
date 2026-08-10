import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/colors.dart';
import '../../../app/theme/radius.dart';
import '../../../app/theme/spacing.dart';
import '../../../app/theme/typography.dart';
import '../../../core/widgets/cards/app_card.dart';
import '../../../core/widgets/buttons/app_button.dart';

/// Concise patient context for the nurse conversation (step 4.10I).
///
/// Shows only high-value, current information so the nurse never has to leave
/// the conversation to understand what is happening. "Voir le dossier" opens
/// the full patient profile — we do not duplicate the profile here.
class PatientContextPanel extends StatelessWidget {
  final String patientName;
  final String latestSpo2;
  final String latestDyspnea;
  final int activeAlertCount;
  final int adherenceRate;
  final String patientId;

  const PatientContextPanel({
    super.key,
    required this.patientName,
    required this.latestSpo2,
    required this.latestDyspnea,
    required this.activeAlertCount,
    required this.adherenceRate,
    required this.patientId,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  patientName,
                  style: AppTypography.titleLarge,
                ),
              ),
              const Icon(Icons.person_outline_rounded, color: AppColors.textMuted),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _StatTile(label: 'Dernière SpO₂', value: latestSpo2),
              _StatTile(label: 'Dyspnée', value: latestDyspnea),
              _StatTile(
                label: 'Alertes actives',
                value: '$activeAlertCount',
              ),
              _StatTile(label: 'Observance', value: '$adherenceRate %'),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              text: 'Voir le dossier',
              onPressed: () => context.push('/nurse/patients/$patientId'),
              variant: AppButtonVariant.outlined,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;

  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (MediaQuery.of(context).size.width - AppSpacing.md * 4) / 2,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 2.0),
          Text(
            value,
            style: AppTypography.titleLarge.copyWith(fontSize: 18.0),
          ),
        ],
      ),
    );
  }
}
