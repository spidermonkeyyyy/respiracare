import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/spacing.dart';
import '../../../../app/theme/typography.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../models/medication_reminder.dart';
import '../providers/treatment_provider.dart';
import '../widgets/adherence_summary.dart';

class AdherenceHistoryScreen extends ConsumerWidget {
  const AdherenceHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(treatmentProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Observance'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: ListView(
            children: [
              AdherenceSummary(
                adherenceRate: state.weeklyAdherenceRate,
                confirmedCount: state.adherenceRecords.fold(0, (sum, record) => sum + record.confirmedCount),
                notConfirmedCount: state.adherenceRecords.fold(0, (sum, record) => sum + record.notConfirmedCount),
                records: state.adherenceRecords,
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Historique', style: AppTypography.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              ..._buildHistoryItems(state.history),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildHistoryItems(List<MedicationReminder> history) {
    final items = <Widget>[];
    String? currentDateLabel;

    for (final reminder in history) {
      final dateLabel = _formattedDate(reminder.scheduledAt);
      if (dateLabel != currentDateLabel) {
        currentDateLabel = dateLabel;
        items.add(Padding(
          padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.sm),
          child: Text(dateLabel, style: AppTypography.titleMedium),
        ));
      }

      items.add(AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  reminder.status == MedicationStatus.confirmed
                      ? Icons.check_circle_outline_rounded
                      : Icons.radio_button_unchecked,
                  color: reminder.status == MedicationStatus.confirmed ? AppColors.success : AppColors.warning,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  reminder.status == MedicationStatus.confirmed ? 'Prise confirmée' : 'Non confirmée',
                  style: AppTypography.bodyLarge,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(reminder.medicationLabel, style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
                Text(_formattedTime(reminder.scheduledAt), style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
              ],
            ),
            if (reminder.confirmedAt != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Confirmé à ${_formattedTime(reminder.confirmedAt!)}',
                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ],
        ),
      ));
    }

    return items;
  }

  String _formattedDate(DateTime dateTime) {
    final today = DateTime.now();
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final nowDate = DateTime(today.year, today.month, today.day);
    if (date == nowDate) {
      return 'Aujourd’hui';
    }

    final monthNames = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre',
    ];
    return '${dateTime.day} ${monthNames[dateTime.month - 1]}';
  }

  String _formattedTime(DateTime dateTime) {
    final hours = dateTime.hour.toString().padLeft(2, '0');
    final minutes = dateTime.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }
}
