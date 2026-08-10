import 'package:flutter/material.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/spacing.dart';
import '../../../../app/theme/typography.dart';
import '../models/adherence_record.dart';

class AdherenceSummary extends StatelessWidget {
  final double adherenceRate;
  final int confirmedCount;
  final int notConfirmedCount;
  final List<AdherenceRecord> records;

  const AdherenceSummary({
    super.key,
    required this.adherenceRate,
    required this.confirmedCount,
    required this.notConfirmedCount,
    required this.records,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (adherenceRate * 100).round();
    final weekdays = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    final dayIcons = records.map((record) {
      final status = record.adherenceRate >= 1.0
          ? _DayStatus.complete
          : record.scheduledCount == 0
              ? _DayStatus.empty
              : _DayStatus.partial;
      return status;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Observance',
          style: AppTypography.titleLarge,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Cette semaine',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$percentage% ',
                    style: AppTypography.headlineLarge.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    '$confirmedCount prises confirmées',
                    style: AppTypography.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: LinearProgressIndicator(
                  value: adherenceRate,
                  minHeight: 10.0,
                  backgroundColor: AppColors.surfaceVariant,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '$notConfirmedCount prise${notConfirmedCount > 1 ? 's' : ''} non confirmée${notConfirmedCount > 1 ? 's' : ''}',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(weekdays.length, (index) {
                  final label = weekdays[index];
                  final status = index < dayIcons.length ? dayIcons[index] : _DayStatus.empty;
                  return Column(
                    children: [
                      Text(label, style: AppTypography.labelMedium),
                      const SizedBox(height: AppSpacing.xs),
                      _StatusDot(status: status),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

enum _DayStatus { complete, partial, empty }

class _StatusDot extends StatelessWidget {
  final _DayStatus status;

  const _StatusDot({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = status == _DayStatus.complete
        ? AppColors.success
        : status == _DayStatus.partial
            ? AppColors.warning
            : AppColors.border;
    final icon = status == _DayStatus.complete
        ? Icons.check_circle
        : status == _DayStatus.partial
            ? Icons.remove_circle_outline
            : Icons.remove;
    return Icon(icon, size: 18.0, color: color);
  }
}
