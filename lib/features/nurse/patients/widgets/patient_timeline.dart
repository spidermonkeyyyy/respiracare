import 'package:flutter/material.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/radius.dart';
import '../../../../app/theme/spacing.dart';
import '../../../../app/theme/typography.dart';
import '../models/nurse_patient.dart';

class PatientTimeline extends StatelessWidget {
  final List<PatientTimelineEvent> events;

  const PatientTimeline({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return Text('Aucun événement disponible.',
          style: AppTypography.bodyMedium
              .copyWith(color: AppColors.textSecondary));
    }

    return Column(
      children: events.map((event) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                    width: 10.0,
                    height: 10.0,
                    decoration: const BoxDecoration(
                        color: AppColors.primary, shape: BoxShape.circle)),
                const SizedBox(
                  height: 56.0,
                  child: VerticalDivider(
                      color: AppColors.border, thickness: 1.5, width: 16.0),
                ),
              ],
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event.title,
                        style:
                            AppTypography.titleLarge.copyWith(fontSize: 16.0)),
                    const SizedBox(height: AppSpacing.xs),
                    Text(event.description,
                        style: AppTypography.bodyMedium
                            .copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
