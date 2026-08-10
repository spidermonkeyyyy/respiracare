import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/spacing.dart';
import '../../../../app/theme/typography.dart';
import '../models/medication_reminder.dart';
import '../providers/treatment_provider.dart';
import 'inhaler_education_screen.dart';

class MedicationDetailScreen extends ConsumerWidget {
  final MedicationReminder reminder;

  const MedicationDetailScreen({super.key, required this.reminder});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(treatmentProvider);
    final notifier = ref.read(treatmentProvider.notifier);
    final currentReminder = state.todayReminders.firstWhere(
      (item) => item.id == reminder.id,
      orElse: () => reminder,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Traitement inhalé'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(currentReminder.medicationLabel, style: AppTypography.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            _buildInfoTile('Horaire', _formattedTime(currentReminder.scheduledAt)),
            const SizedBox(height: AppSpacing.sm),
            _buildInfoTile('Fréquence', currentReminder.frequency),
            const SizedBox(height: AppSpacing.sm),
            _buildInfoTile('Statut', _statusText(currentReminder.status)),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: currentReminder.status == MedicationStatus.confirmed
                  ? null
                  : () => _showConfirmationDialog(context, notifier, currentReminder),
              child: const Text('Confirmer la prise'),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text('Technique d’inhalation', style: AppTypography.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'Revoyez une courte formation pour utiliser votre dispositif correctement.',
              style: AppTypography.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const InhalerEducationScreen()),
              ),
              child: const Text('Voir le tutoriel'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.xs),
          Text(value, style: AppTypography.bodyLarge),
        ],
      ),
    );
  }

  String _statusText(MedicationStatus status) {
    return status == MedicationStatus.confirmed ? 'Confirmée' : 'À confirmer';
  }

  void _showConfirmationDialog(
    BuildContext context,
    TreatmentNotifier notifier,
    MedicationReminder currentReminder,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmer la prise ?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(currentReminder.medicationLabel, style: AppTypography.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              Text('Horaire: ${_formattedTime(currentReminder.scheduledAt)}', style: AppTypography.bodyMedium),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirmer'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await notifier.confirmReminder(currentReminder.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Prise enregistrée.')),
        );
      }
    }
  }

  String _formattedTime(DateTime dateTime) {
    final hours = dateTime.hour.toString().padLeft(2, '0');
    final minutes = dateTime.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }
}
