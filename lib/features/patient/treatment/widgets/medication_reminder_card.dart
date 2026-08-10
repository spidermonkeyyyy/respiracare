import 'package:flutter/material.dart';
import 'package:respiracare/app/theme/colors.dart';
import 'package:respiracare/app/theme/radius.dart';
import 'package:respiracare/app/theme/spacing.dart';
import 'package:respiracare/app/theme/typography.dart';
import '../models/medication_reminder.dart';

class MedicationReminderCard extends StatelessWidget {
  final MedicationReminder reminder;
  final bool isConfirming;
  final VoidCallback? onConfirm;
  final VoidCallback? onTap;

  const MedicationReminderCard({
    super.key,
    required this.reminder,
    this.isConfirming = false,
    this.onConfirm,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.large),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.large),
            border: Border.all(color: _borderColor()),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Time header
              Row(
                children: [
                  Icon(Icons.schedule_rounded,
                      size: 14.0, color: AppColors.textMuted),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    _formatTime(reminder.scheduledAt),
                    style: AppTypography.labelMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  _StatusChip(status: reminder.status),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              const Divider(height: 1, color: AppColors.border),
              const SizedBox(height: AppSpacing.sm),

              // Medication label
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 42.0,
                    height: 42.0,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppRadius.small),
                    ),
                    child: Icon(
                      Icons.air_rounded,
                      color: AppColors.primary,
                      size: 22.0,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reminder.medicationLabel,
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Prescrit par votre médecin',
                          style: AppTypography.labelMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Action area — only shown if actionable
              if (reminder.isActionable) ...[
                const SizedBox(height: AppSpacing.md),
                _buildActionArea(context),
              ],

              // Confirmed timestamp
              if (reminder.isConfirmed && reminder.confirmedAt != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        size: 14.0, color: AppColors.success),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Confirmée à ${_formatTime(reminder.confirmedAt!)}',
                      style: AppTypography.labelMedium
                          .copyWith(color: AppColors.success),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionArea(BuildContext context) {
    if (reminder.status == MedicationStatus.notConfirmed) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadius.small),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    size: 14.0, color: AppColors.warning),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    'Cette prise n\'a pas encore été confirmée.',
                    style: AppTypography.labelMedium
                        .copyWith(color: AppColors.warning),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _ConfirmButton(isConfirming: isConfirming, onConfirm: onConfirm),
        ],
      );
    }
    return _ConfirmButton(isConfirming: isConfirming, onConfirm: onConfirm);
  }

  Color _borderColor() {
    switch (reminder.status) {
      case MedicationStatus.confirmed:
        return AppColors.success.withValues(alpha: 0.25);
      case MedicationStatus.notConfirmed:
        return AppColors.warning.withValues(alpha: 0.35);
      default:
        return AppColors.border;
    }
  }

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

// ─── Status Chip ────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final MedicationStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, icon, color) = _resolve();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.0, color: color),
          const SizedBox(width: 4.0),
          Text(label,
              style: AppTypography.labelMedium
                  .copyWith(color: color, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  (String, IconData, Color) _resolve() {
    switch (status) {
      case MedicationStatus.confirmed:
        return ('Pris', Icons.check_circle_rounded, AppColors.success);
      case MedicationStatus.notConfirmed:
        return (
          'Non confirmée',
          Icons.radio_button_unchecked_rounded,
          AppColors.warning
        );
      case MedicationStatus.upcoming:
        return ('À venir', Icons.upcoming_rounded, AppColors.info);
      case MedicationStatus.pending:
        return ('À prendre', Icons.circle_outlined, AppColors.primary);
    }
  }
}

// ─── Confirm Button ─────────────────────────────────────────────────────────

class _ConfirmButton extends StatelessWidget {
  final bool isConfirming;
  final VoidCallback? onConfirm;

  const _ConfirmButton({required this.isConfirming, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44.0,
      child: ElevatedButton.icon(
        onPressed: isConfirming ? null : onConfirm,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.surfaceVariant,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          elevation: 0,
        ),
        icon: isConfirming
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.check_rounded, size: 18.0),
        label: Text(
          isConfirming ? 'Confirmation...' : 'Confirmer la prise',
          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
