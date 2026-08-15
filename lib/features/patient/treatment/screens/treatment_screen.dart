import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "../../../../app/theme/colors.dart";
import "../../../../app/theme/spacing.dart";
import "../../../../app/theme/typography.dart";
import "../../../../core/utils/animations/app_animations.dart";
import "../../../../core/widgets/cards/app_card.dart";
import "../../../../core/widgets/feedback/app_empty_state.dart";
import "../../../../core/widgets/feedback/app_error_state.dart";
import "../models/medication_reminder.dart";
import "../providers/treatment_provider.dart";
import "../widgets/medication_card.dart";
import "adherence_history_screen.dart";
import "inhaler_education_screen.dart";
import "medication_detail_screen.dart";

class TreatmentScreen extends ConsumerWidget {
  const TreatmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(treatmentProvider);
    final notifier = ref.read(treatmentProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        toolbarHeight: 44.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go("/patient/home"),
          tooltip: "Retour",
        ),
        title: Text(
          "Traitement",
          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: notifier.loadAll,
          color: AppColors.primary,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: _buildBody(context, state, notifier),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
      BuildContext context, TreatmentState state, TreatmentNotifier notifier) {
    if (state.isAnyLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null) {
      return AppErrorState(
        title: "Impossible de charger le traitement",
        message: state.errorMessage!,
        retryLabel: "Réessayer",
        onRetry: notifier.loadAll,
      );
    }

    if (state.todayReminders.isEmpty) {
      return AppEmptyState(
        title: "Aucun traitement prévu aujourd’hui",
        message: "Votre planning de traitement sera affiché ici.",
        icon: Icons.medication_outlined,
        actionLabel: "Voir l’éducation",
        onActionPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const InhalerEducationScreen()),
        ),
      );
    }

    final nextReminder = state.todayReminders
        .where((r) => r.status != MedicationStatus.confirmed)
        .toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

    return ListView(
      children: [
        AppFadeAnimation(
          duration: const Duration(milliseconds: 300),
          child: AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Aujourd’hui", style: AppTypography.titleLarge),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  "${state.pendingReminderCount} rappels restants",
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                ),
                if (nextReminder.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      const Icon(Icons.notifications_active_outlined,
                          size: 18.0, color: AppColors.primary),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        "Prochain rappel ${_formattedTime(nextReminder.first.scheduledAt)}",
                        style: AppTypography.bodyMedium
                            .copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const AdherenceHistoryScreen()),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.surface,
                          foregroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0)),
                          side: const BorderSide(color: AppColors.primary),
                        ),
                        child: const Text("Voir l’observance"),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const InhalerEducationScreen()),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.surface,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0)),
                        ),
                        child: const Text("Technique d’inhalation"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ...state.todayReminders.asMap().entries.map((entry) {
          final reminder = entry.value;
          return AppSlideAnimation(
            duration: const Duration(milliseconds: 300),
            delay: Duration(milliseconds: 80 * entry.key),
            direction: SlideDirection.up,
            child: Column(
              children: [
                TreatmentMedicationCard(
                  reminder: reminder,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          MedicationDetailScreen(reminder: reminder),
                    ),
                  ),
                  onConfirm: () =>
                      _confirmReminder(context, notifier, reminder),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          );
        }),
      ],
    );
  }

  void _confirmReminder(BuildContext context, TreatmentNotifier notifier,
      MedicationReminder reminder) async {
    if (reminder.status == MedicationStatus.confirmed) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirmer la prise ?"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(reminder.medicationLabel, style: AppTypography.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              Text("Horaire\n${_formattedTime(reminder.scheduledAt)}",
                  style: AppTypography.bodyMedium),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Annuler"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Confirmer"),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await notifier.confirmReminder(reminder.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Prise enregistrée.")),
        );
      }
    }
  }

  String _formattedTime(DateTime dateTime) {
    final hours = dateTime.hour.toString().padLeft(2, "0");
    final minutes = dateTime.minute.toString().padLeft(2, "0");
    return "$hours:$minutes";
  }
}
