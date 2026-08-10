import 'package:flutter/material.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/radius.dart';
import '../../../../app/theme/spacing.dart';
import '../../../../app/theme/typography.dart';
import '../../dashboard/widgets/priority_badge.dart';
import '../models/nurse_patient.dart';

class PatientCard extends StatelessWidget {
  final NursePatient patient;
  final VoidCallback? onTap;

  const PatientCard({super.key, required this.patient, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium)),
      color: AppColors.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22.0,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                    child: Text(
                      patient.fullName
                          .split(' ')
                          .map((word) => word.isNotEmpty ? word[0] : '')
                          .take(2)
                          .join()
                          .toUpperCase(),
                      style: AppTypography.labelMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(patient.fullName,
                            style: AppTypography.titleLarge
                                .copyWith(fontSize: 16.0)),
                        const SizedBox(height: AppSpacing.xs),
                        Text('${patient.condition} · ${patient.classification}',
                            style: AppTypography.bodyMedium
                                .copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  PriorityBadge(priority: patient.priority),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              if (patient.latestObservation != null)
                Text(
                  patient.latestObservation!,
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Icon(Icons.schedule_rounded,
                      size: 16.0, color: AppColors.textMuted),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    patient.lastSubmissionAt != null
                        ? 'Dernier suivi: ${_formatDate(patient.lastSubmissionAt!)}'
                        : 'Dernier suivi: non disponible',
                    style: AppTypography.bodySmall
                        .copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays > 0) {
      return '${diff.inDays}j';
    }
    if (diff.inHours > 0) {
      return '${diff.inHours}h';
    }
    return '${diff.inMinutes}min';
  }
}
