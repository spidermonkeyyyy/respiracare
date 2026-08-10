import 'package:flutter/material.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/spacing.dart';
import '../../../../app/theme/typography.dart';
import '../../../../core/widgets/cards/app_card.dart';

class PatientRehabilitationScreen extends StatelessWidget {
  const PatientRehabilitationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Rééducation Respiratoire'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: AppCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.fitness_center_rounded, size: 48, color: AppColors.accent),
                SizedBox(height: AppSpacing.md),
                Text('Exercices de Rééducation', style: AppTypography.headlineLarge),
                SizedBox(height: AppSpacing.sm),
                Text(
                  'Écran de démonstration pour les exercices de respiration guidée et le suivi hebdomadaire.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PatientCareTeamScreen extends StatelessWidget {
  const PatientCareTeamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Équipe Soignante'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: AppCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.medical_services_outlined, size: 48, color: AppColors.info),
                SizedBox(height: AppSpacing.md),
                Text('Suivi par l\'Équipe Soignante', style: AppTypography.headlineLarge),
                SizedBox(height: AppSpacing.sm),
                Text(
                  'Écran de démonstration pour visualiser les infirmiers référents et l\'historique des revues.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
