import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/spacing.dart';
import '../../../../app/theme/typography.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../providers/patient_dashboard_provider.dart';

class PatientMonitoringScreen extends ConsumerWidget {
  const PatientMonitoringScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Suivi Respiratoire'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              AppCard(
                child: Column(
                  children: [
                    const Icon(
                      Icons.assignment_turned_in_outlined,
                      size: 48.0,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Questionnaire de suivi quotidien',
                      style: AppTypography.headlineLarge.copyWith(fontSize: 20.0),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Écran temporaire de démonstration pour valider la navigation.\nLe questionnaire interactif (CAT/mMRC) sera développé dans l\'étape suivante.',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppButton(
                      text: 'Simuler la complétion du suivi',
                      icon: Icons.check_circle_outline_rounded,
                      onPressed: () async {
                        await ref.read(patientDashboardProvider.notifier).completeQuestionnaire();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Suivi marqué comme complété !')),
                          );
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
