import 'package:flutter/material.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/spacing.dart';
import '../../../../app/theme/typography.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../models/medication_reminder.dart';

class TreatmentMedicationCard extends StatelessWidget {
  final MedicationReminder reminder;
  final VoidCallback onTap;
  final VoidCallback onConfirm;

  const TreatmentMedicationCard({
    super.key,
    required this.reminder,
    required this.onTap,
    required this.onConfirm,
  });

  String get statusLabel {
    switch (reminder.status) {
      case MedicationStatus.confirmed:
        return 'Pris';
      case MedicationStatus.pending:
        return 'À prendre';
      case MedicationStatus.notConfirmed:
        return 'Non confirmée';
      case MedicationStatus.upcoming:
        return 'À venir';
    }
  }

  Color get statusColor {
    switch (reminder.status) {
      case MedicationStatus.confirmed:
        return AppColors.success;
      case MedicationStatus.pending:
        return AppColors.primary;
      case MedicationStatus.notConfirmed:
        return AppColors.warning;
      case MedicationStatus.upcoming:
        return AppColors.textSecondary;
    }
  }

  bool get canConfirm =>
      reminder.status == MedicationStatus.pending || reminder.status == MedicationStatus.notConfirmed;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formattedTime(reminder.scheduledAt),
                style: AppTypography.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder.medicationLabel,
                      style: AppTypography.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Prescrit par votre médecin',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Icon(
                          reminder.status == MedicationStatus.confirmed
                              ? Icons.check_circle_outline_rounded
                              : Icons.schedule,
                          size: 16.0,
                          color: statusColor,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          statusLabel,
                          style: AppTypography.labelLarge.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              AppButton(
                text: reminder.status == MedicationStatus.confirmed
                    ? 'Confirmé'
                    : canConfirm
                        ? 'Confirmer'
                        : 'Voir les détails',
                variant: reminder.status == MedicationStatus.confirmed
                    ? AppButtonVariant.outlined
                    : AppButtonVariant.primary,
                onPressed: canConfirm ? onConfirm : onTap,
                enabled: reminder.status != MedicationStatus.confirmed,
                fullWidth: false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formattedTime(DateTime dateTime) {
    final hours = dateTime.hour.toString().padLeft(2, '0');
    final minutes = dateTime.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }
}
